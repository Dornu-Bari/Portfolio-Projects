# Analysis Report: https://medium.com/@dornubari.bariboloka/identifying-outliers-in-yobe-election-results-2023-ef89e4e487ad?source=user_profile---------0---------------------------- 

import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
from scipy.stats import zscore

# Load the dataset
file_path = 'C:\\Users\\YOBE CLUSTER DATA.xlsx'
data = pd.read_excel(file_path)

# Assuming your dataset has 'Latitude' and 'Longitude' columns
lat_long = data[['Latitude', 'Longitude']].dropna()

# Convert DataFrame to NumPy array
lat_long_np = lat_long.to_numpy()

# No of clusters
num_clusters = 6

#K-Means clustering
kmeans = KMeans(n_clusters=num_clusters, random_state=42)
kmeans.fit(lat_long_np)

# Adding cluster labels
lat_long['cluster'] = kmeans.labels_

# Adding cluster labels back to the main dataframe
data = data.dropna(subset=['Latitude', 'Longitude'])
data['cluster'] = kmeans.labels_

# Outliers columns
columns_to_check = ['APC', 'LP', 'PDP', 'NNPP']  # Replace 'Column1' and 'Column2' with actual column names

# Calculating Z-scores
for column in columns_to_check:
    data[f'zscore_{column}'] = zscore(data[column])

# Determine outliers based on Z-score threshold
zscore_threshold = 3
data['outlier'] = (np.abs(data['zscore_APC']) > zscore_threshold) | \
                  (np.abs(data['zscore_LP']) > zscore_threshold) | \
                  (np.abs(data['zscore_PDP']) > zscore_threshold) | \
                  (np.abs(data['zscore_NNPP']) > zscore_threshold)

# Update dataset with outliers
output_file_path = 'C:\\Users\\WITH_OUTLIERS_DATA.csv'
data.to_csv(output_file_path, index=False)

# Print outliers
outliers = data[data['outlier'] == True]
print("Outliers found:\n", outliers)

# Clusters Visualization
plt.figure(figsize=(10, 8))
plt.scatter(data['Longitude'], data['Latitude'], c=data['cluster'], cmap='viridis', s=100, alpha=0.8, edgecolors='k', label='Cluster')

# Outliers Mapping
outlier_data = data[data['outlier']]
plt.scatter(outlier_data['Longitude'], outlier_data['Latitude'], c='red', s=100, alpha=0.8, edgecolors='k', label='Outlier')

plt.title('K-means Clustering of Election Data with Outliers Highlighted')
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.colorbar(label='Cluster')
plt.legend()
plt.grid(True)

# Save viz
plot_file_path = 'C:\\Users\\Outlier.png'
plt.savefig(plot_file_path)
print(f"Cluster plot saved to '{plot_file_path}'.")

# Show viz
plt.show()

# Export the clustered data
output_excel_file_path = 'C:\\Users\\CLUSTERED_DATA.xlsx'
data.to_excel(output_excel_file_path, index=False)
print(f"Clustered data exported to '{output_excel_file_path}'.")

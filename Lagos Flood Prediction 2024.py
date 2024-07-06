import pandas as pd

# Load the dataset
file_path = 'C:\\Users\\dornu\\Lagos Flood Data.xlsx'
lagos_rain_data = pd.read_excel(file_path)


# Display the first few rows of the dataset
print(lagos_rain_data.head())

# Get information about the dataset
print(lagos_rain_data.info())

# Get basic statistics of the dataset
print(lagos_rain_data.describe())

import matplotlib.pyplot as plt
import seaborn as sns


# Plot the daily precipitation data
plt.figure(figsize=(10, 6))
sns.lineplot(data=lagos_rain_data, x='Date', y='Precipitation')
plt.title('Daily Precipitation in Lagos State')
plt.xlabel('Date')
plt.ylabel('Precipitation (mm)')
plt.xticks(rotation=45)
plt.show()


# Convert 'Date' column to datetime format
lagos_rain_data['Date'] = pd.to_datetime(lagos_rain_data['Date'])

# Set 'Date' as the index
lagos_rain_data.set_index('Date', inplace=True)

# Resample the data to monthly precipitation
monthly_rain_data = lagos_rain_data['Precipitation'].resample('M').sum()

# Plot the monthly precipitation data
plt.figure(figsize=(10, 6))
monthly_rain_data.plot()
plt.title('Monthly Precipitation in Lagos State')
plt.xlabel('Date')
plt.ylabel('Precipitation (mm)')
plt.show()


from statsmodels.tsa.arima.model import ARIMA

# Split the data into training and test sets
train_data = monthly_rain_data[:int(0.8 * len(monthly_rain_data))]
test_data = monthly_rain_data[int(0.8 * len(monthly_rain_data)):]

# Build and fit the ARIMA model
model = ARIMA(train_data, order=(5, 1, 0))
model_fit = model.fit()

# Forecast the next 12 months
forecast = model_fit.forecast(steps=12)

# Plot the forecast
plt.figure(figsize=(10, 6))
plt.plot(monthly_rain_data, label='Historical')
plt.plot(forecast, label='Forecast', color='red')
plt.title('Monthly Precipitation Forecast')
plt.xlabel('Date')
plt.ylabel('Precipitation (mm)')
plt.legend()
plt.show()

# Set the flood threshold
flood_threshold = 300

# Identify months with predicted precipitation above the threshold
flood_months = forecast[forecast > flood_threshold]

print("Predicted flood months:")
print(flood_months)






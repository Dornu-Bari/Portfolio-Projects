SELECT *
FROM GlobalBikeBuyers as Global_Bikers

--Rank bikers by the number of cars owned within each age group:
WITH Ranked_Bikers AS (
   SELECT
      ID,
  	  Age,
      Age_Group,
      Cars,
      RANK () OVER (PARTITION BY Age_Group ORDER BY Cars DESC) as Car_Rank
   FROM GlobalBikeBuyers as Global_Bikers
)
   SELECT
      ID,
      Age_Group,
      Cars,
      Car_Rank
   FROM Ranked_Bikers;
   
--Calculate the cumulative percentage of bikers who own a home within each age group
WITH AgeGroupStats AS (
   SELECT
      Age_Group,
      COUNT (*) as Iotal_Bikers,
      SUM (CASE WHEN Home_Owner = 'Yes' THEN 1 ELSE 0 END) as Total_Home_Owners
   FROM GlobalBikeBuyers as Global_Bikers
   GROUP BY Age_Group
)
SELECT
   Age_Group,
   ROUND (Total_Home_Owners * 100.0 / Iotal_Bikers, 2) as Total_Home_Owners_Percentage
FROM AgeGroupStats;

--Pivot the data to show the count of bikers who purchased a bike by gender
SELECT
   Gender,
   [Yes] as Purchased_Bike,
   [No] as No_Purchase
FROM (
   SELECT Gender, 
          Purchased_Bike
   FROM GlobalBikeBuyers as Global_Bikers
) AS SourceTable
PIVOT (
   COUNT(Purchased_Bike) FOR Purchased_Bike IN ([Yes], [No])
) AS PivotTable;

--Alternatively for this Pivot as some SQL platforms don't support Pivot
SELECT
    Gender,
    COUNT(CASE WHEN Purchased_Bike = 'Yes' THEN 1 END) AS Purchased_Bike,
    COUNT(CASE WHEN Purchased_Bike = 'No' THEN 1 END) AS No_Purchase
FROM GlobalBikeBuyers
GROUP BY Gender;

--Find the top 3 occupations with the highest average number of cars owned
WITH Occupation_Ranking AS (
   SELECT
      Gender,
  	  Education,
  	  Occupation,
  	  Age,
      ROUND (AVG (Cars), 2) as Avg_Owned_Cars,
      RANK() OVER (ORDER BY AVG (Cars) DESC) as Occupation_Ranked
   FROM GlobalBikeBuyers as Global_Bikers
   GROUP BY Occupation
)
SELECT       
	  Gender,
  	  Education,
  	  Occupation,
  	  Age,
      Avg_Owned_Cars
FROM Occupation_Ranking
WHERE Occupation_Ranked <= 3;

--Find the age group with the highest percentage of bikers who own a home
SELECT
   Age_Group,
   ROUND (COUNT (*) * 100.0 / SUM(COUNT (*)) OVER (), 2) as Home_Owned_Percentage
FROM GlobalBikeBuyers as Global_Bikers
WHERE Home_Owner = 'Yes'
GROUP BY Age_Group
ORDER BY Home_Owned_Percentage DESC
LIMIT 1;

--Find the occupation with the highest average number of cars owned among bikers who own a home
SELECT
   Occupation,
   AVG (Cars) as Avg_Cars_Owned
FROM GlobalBikeBuyers as Global_Bikers
WHERE Home_Owner = 'Yes'
GROUP BY occupation
ORDER BY avg_cars_owned DESC
LIMIT 1;

--Calculate the median age of bikers
SELECT
   PERCENTILE_CONT (0.5) WITHIN GROUP (ORDER BY Age) as Median_Age
FROM GlobalBikeBuyers as Global_Bikers
   
--Find the youngest and oldest biker in each region
WITH Ranked_Bikers AS (
   SELECT
      id,
      Region,
      Occupation,
      Age,
      Age_Group,
      ROW_NUMBER () OVER (PARTITION BY region ORDER BY Age ASC) as Youngest,
      ROW_NUMBER () OVER (PARTITION BY region ORDER BY Age DESC) as Oldest
   FROM GlobalBikeBuyers as Global_Bikers
)
SELECT ID, 
	Region, 
    Occupation,
    Age,
    Age_Group
FROM Ranked_Bikers
WHERE Youngest = 1 OR Oldest = 1;

--Calculate the average age of bikers who own a home and have more than one child
SELECT
   AVG(Age) as Avg_Age
FROM GlobalBikeBuyers as Global_Bikers
WHERE Home_Owner = 'Yes' AND Children > 1;

--Rank bikers based on the number of cars they own within their age group
WITH Age_Group_Car_Rank AS (
   SELECT
      ID,
      Age_Group,
      Cars,
      RANK () OVER (PARTITION BY Age_Group ORDER BY Cars DESC) as Car_Rank
   FROM GlobalBikeBuyers as Global_Bikers
)
SELECT ID, 
	Age_Group, 
    Cars, 
    Car_Rank
FROM Age_Group_Car_Rank;

--Calculate the percentage of bikers who purchased a bike within each marital status category
WITH Marital_Status_Stats AS (
   SELECT
      Marital_Status,
      COUNT(*) as Total_Bikers,
      SUM(CASE WHEN purchased_bike = 'Yes' THEN 1 ELSE 0 END) as Purchased_Bike_Count
   FROM GlobalBikeBuyers as Global_Bikers
   GROUP BY Marital_Status
)
SELECT
   Marital_Status,
   ROUND (Purchased_Bike_Count * 100.0 / Total_Bikers, 2) as Purchased_Bike_Percentage
FROM Marital_Status_Stats;

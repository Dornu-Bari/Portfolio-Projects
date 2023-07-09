--Data to be used: Location, Date, Population, New Cases, Total Cases, Total Deaths
--Data under Continent and Location is contradictory

SELECT Location, Date, Population, New_cases, Total_cases, Total_deaths
FROM Portfolio.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2;



--Evaluating between Total Cases and Total Deaths
--Ordering Location and Date columns in ascending order
--Creating a new column to calculate the % difference between Total Cases and Total Deaths

SELECT Location, Date, Total_cases, Total_deaths, (Total_Deaths/Total_cases)*100 AS Death_Percentage
FROM Portfolio.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2;


--Comparing Total Cases by Population to determine Infected Percentage by Population

SELECT Location, Date, Population, Total_cases, (Total_Deaths/Total_cases)*100 AS Infected_Population_Percentage
FROM Portfolio.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2;


--Top Countries with the Highest Infections Rates

SELECT Location, Population, MAX(Total_cases) AS Highest_Infection_Rates, MAX ((Total_Deaths/Total_cases))*100 AS Infected_Percentage
FROM Portfolio.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location, Population
ORDER BY Infected_Percentage DESC;



--Countries with Highest Mortality Rate
--Casting Total_Deaths data type as interger

SELECT Location, MAX(cast(Total_Deaths as int)) AS Total_Death_Count
FROM Portfolio.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY Total_Death_Count DESC;


--Continents ranked according to Death Count

SELECT Continent, MAX(cast(Total_Deaths as int)) AS Total_Death_Count
FROM Portfolio.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY Continent
ORDER BY Total_Death_Count DESC;


--World Data
--Global Total Cases and Deaths per day

SELECT Date, SUM(New_Cases) AS Global_Total_Cases, SUM(cast(New_deaths as int)) AS Global_Total_Deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 AS Global_Death_Percentage
FROM Portfolio.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY Date
ORDER BY 1,2;


--Total Global Covid Numbers

SELECT SUM(New_Cases) AS Global_Total_Cases, SUM(cast(New_deaths as int)) AS Global_Total_Deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 AS Global_Death_Percentage
FROM Portfolio.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY Date
ORDER BY 1,2;


--Joining two tables: Covid Deaths and Covid Vaccinations
--REnaming tables: Covid Deaths to "CD" and Covid Vaccinations to "VAC"

SELECT*
FROM Portfolio.dbo.CovidDeaths AS CD
JOIN Portfolio.dbo.CovidVaccinations AS VAC
 ON CD.Location = VAC.Location
 AND CD.Date = VAC.Date;


 --Comparing Total Population vs Vaccinations

SELECT CD.Continent, CD.Location, CD.Date, CD.Population, VAC.New_VaccinationS
FROM Portfolio.dbo.CovidDeaths AS CD
JOIN Portfolio.dbo.CovidVaccinations AS VAC
 ON CD.Location = VAC.Location
 AND CD.Date = VAC.Date
 WHERE CD.Continent IS NOT NULL
 ORDER BY 2,3;


 --Rolling Count for New_Vaccinations

SELECT CD.Continent, CD.Location, CD.Date, CD.Population, VAC.New_Vaccinations, 
SUM(CONVERT(int, VAC.New_Vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.Date) AS Rolling_People_Vaccinated
FROM Portfolio.dbo.CovidDeaths AS CD
JOIN Portfolio.dbo.CovidVaccinations AS VAC
 ON CD.Location = VAC.Location
 AND CD.Date = VAC.Date
 WHERE CD.Continent IS NOT NULL
 ORDER BY 2,3;


-- USE CTE

WITH Vaccinations_Vs_Population (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated) 
AS 
(
SELECT CD.Continent, CD.Location, CD.Date, CD.Population, VAC.New_Vaccinations, 
SUM(CONVERT(int, VAC.New_Vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.Date) AS Rolling_People_Vaccinated
FROM Portfolio.dbo.CovidDeaths AS CD
JOIN Portfolio.dbo.CovidVaccinations AS VAC
 ON CD.Location = VAC.Location
 AND CD.Date = VAC.Date
 WHERE CD.Continent IS NOT NULL
 )


 SELECT *, (Rolling_People_Vaccinated/Population)*100
 FROM Vaccinations_Vs_Population

 

 --TEMP TABLE


 CREATE TABLE #Population_Percentage_Vaccinated
 (
 Continent nvarchar (255),
 Location nvarchar (255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 Rolling_People_Vaccinated numeric
 )

 INSERT INTO #Population_Percentage_Vaccinated
 SELECT CD.Continent, CD.Location, CD.Date, CD.Population, VAC.New_Vaccinations, 
SUM(CONVERT(int, VAC.New_Vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.Date) AS Rolling_People_Vaccinated
FROM Portfolio.dbo.CovidDeaths AS CD
JOIN Portfolio.dbo.CovidVaccinations AS VAC
 ON CD.Location = VAC.Location
 AND CD.Date = VAC.Date
 WHERE CD.Continent IS NOT NULL
 ORDER BY 2,3;

 SELECT *, (Rolling_People_Vaccinated/Population)*100
 FROM #Population_Percentage_Vaccinated


 --Alternatively;
 DROP Table if exists #Population_Percentage_Vaccinated
  CREATE TABLE #Population_Percentage_Vaccinated
 (
 Continent nvarchar (255),
 Location nvarchar (255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 Rolling_People_Vaccinated numeric
 )

 INSERT INTO #Population_Percentage_Vaccinated
 SELECT CD.Continent, CD.Location, CD.Date, CD.Population, VAC.New_Vaccinations, 
SUM(CONVERT(int, VAC.New_Vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.Date) AS Rolling_People_Vaccinated
FROM Portfolio.dbo.CovidDeaths AS CD
JOIN Portfolio.dbo.CovidVaccinations AS VAC
 ON CD.Location = VAC.Location
 AND CD.Date = VAC.Date;
 

 SELECT *, (Rolling_People_Vaccinated/Population)*100
 FROM #Population_Percentage_Vaccinated;


 --Creating Views for Visualization
 --Continents ranked according to Death Count

 CREATE VIEW Population_Percentage_Vaccinated AS 
 (
 SELECT CD.Continent, CD.Location, CD.Date, CD.Population, VAC.New_Vaccinations, 
SUM(CONVERT(int, VAC.New_Vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.Date) AS Rolling_People_Vaccinated
FROM Portfolio.dbo.CovidDeaths AS CD
JOIN Portfolio.dbo.CovidVaccinations AS VAC
 ON CD.Location = VAC.Location
 AND CD.Date = VAC.Date
 WHERE CD.Continent IS NOT NULL
 )

 SELECT *
FROM Population_Percentage_Vaccinated;

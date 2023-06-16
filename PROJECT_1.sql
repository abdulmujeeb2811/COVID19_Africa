----TO Cull Out Death Records for African Countries
CREATE TABLE #AfricaDeaths
(Country  nvarchar(255),
Population int, 
P_density int,
life_expectancy  int, 
date datetime, 
new_cases  int, 
total_cases  int, 
new_deaths  int, 
total_deaths  int)
INSERT INTO #AfricaDeaths( Country, 

Population,
P_density, 
life_expectancy, 
date, 
new_cases, 
total_cases, 
new_deaths, 
total_deaths)
SELECT location,  population, population_density, life_expectancy, date, new_cases, total_cases, new_deaths, total_deaths
FROM PORTFOLIO_PROJECTS.dbo.['COVID DEATHS$']
WHERE continent = 'Africa'

--To Cull Out Vaccination Records for African Countries
DROP TABLE IF EXISTS #AfricaVaccinations
CREATE TABLE #AfricaVaccinations
(Country nvarchar(100),
 date datetime,
 new_vaccinations int,
 total_vaccinations int
)
INSERT INTO #AfricaVaccinations (Country, date, new_vaccinations, total_vaccinations)
SELECT location, date, new_vaccinations, total_vaccinations
FROM PORTFOLIO_PROJECTS..['COVID VACCINATIONS$']
WHERE continent = 'Africa'


--To find the percentage Death by infection in Africa (Ranked in Descending Order)
SELECT Country, 
MAX(total_cases) Total_Cases, 
MAX (total_deaths) as Total_Deaths, 
CAST (MAX (total_deaths) AS float)/CAST(MAX(total_cases) AS float)*100 as Percentage_Death
FROM #AfricaDeaths
GROUP BY Country
ORDER BY 4 DESC

--To find the percentage infection by population in Africa (Ranked in Descending Order)
SELECT 
Country, 
Population, 
MAX(total_cases) Total_Cases, 
CAST(MAX(total_cases) as float)/Population Perc_pop_Infected
FROM #AfricaDeaths
GROUP BY Country, Population


--African Countries with top ten infection rate
SELECT TOP (10)
Country, 
Population, 
MAX(total_cases) Total_Cases, 
CAST(MAX(total_cases) as float)/Population Perc_pop_Infected
FROM #AfricaDeaths
GROUP BY Country, Population
ORDER BY Perc_pop_Infected DESC

--Countries with the top ten deaths in Africa

SELECT TOP (10) Country, SUM(new_deaths) as DeathCount
FROM #AfricaDeaths
GROUP BY Country
ORDER BY DeathCount DESC

--Global Numbers of Infections and Deaths
SELECT SUM(new_cases) as Global_Infected, 
SUM(new_deaths) as Global_Deaths,
SUM(new_deaths)/SUM(new_cases)*100 GLobal_Mortality_Rate
FROM PORTFOLIO_PROJECTS..['COVID DEATHS$']
WHERE location = 'World'


--Examining total vaccinations for each country
SELECT Country, MAX(total_vaccinations) Total_Vaccinated
FROM #AfricaVaccinations
GROUP BY Country

--Check for the population and Percentage of the Population that is vaccinated
SELECT Vac.Country, 
Dea.Population,  
MAX(CONVERT(float,total_vaccinations))  Total_Vaccinated, 
MAX(CONVERT(float,total_vaccinations))/Population*100  Percentage_Vaccinated
FROM #AfricaVaccinations  Vac
JOIN #AfricaDeaths   Dea
ON Dea.Country = Vac.Country
GROUP BY Vac.Country, Population

--Examine the Death rate and Percentage Vaccination in each country.
SELECT Dea.Country,
Population,
MAX(CONVERT( float, Dea.total_deaths))/MAX(CONVERT(float,Dea.total_cases))*100 Death_Rate,
MAX(CONVERT(float, Vac.total_vaccinations))/Population *100  Percentage_Vaccination
FROM #AfricaDeaths  Dea
JOIN #AfricaVaccinations Vac
ON Dea.Country = Vac.Country
GROUP BY Dea.Country, Population

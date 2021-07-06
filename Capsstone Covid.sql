--Whole Table
SELECT *
FROM Capstone_Covid..Death_Covid$
ORDER BY 3,4


--Select the data to be used and ordering by location and date
SELECT  location, date, continent, total_cases, new_cases, total_deaths, population
FROM Capstone_Covid..Death_Covid$
order by 1,2

--deaths vs cases
--Percentage change of dying if yo get COVID
SELECT  location, date, continent, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
FROM Capstone_Covid..Death_Covid$
WHERE location = 'Nigeria'
order by 1,2

--Cases vs population
--Percentage case vs population
--Shockingly less than 1% percent of Nigerias population have covid19
SELECT  location, date, continent, total_cases, population, (total_cases/population)*100 as population_rate
FROM Capstone_Covid..Death_Covid$
WHERE location = 'Nigeria'
order by 1,2

--Countries with the highest Infection Count
SELECT  location, population, MAX(total_cases) AS Infection_Count, MAX((total_cases/population))*100 AS population_rate
FROM Capstone_Covid..Death_Covid$
WHERE location != 'World'
GROUP BY location,  population

ORDER BY population_rate DESC


--Countries with highest death count per population

SELECT  location, MAX(CAST(total_deaths AS int)) AS max_total_deaths
FROM Capstone_Covid..Death_Covid$
WHERE continent is not null 
GROUP BY location
ORDER BY max_total_deaths DESC

--death rate by continent
SELECT location, MAX(CAST(total_deaths AS int)) AS max_total_deaths
FROM Capstone_Covid..Death_Covid$
WHERE continent is null 
GROUP BY location
ORDER BY max_total_deaths DESC

SELECT  continent, MAX(CAST(total_deaths AS int)) AS max_total_deaths
FROM Capstone_Covid..Death_Covid$
WHERE continent is not null 
GROUP BY continent
ORDER BY max_total_deaths DESC

--deaths vs cases
--Percentage change of dying if yo get COVID
SELECT date, SUM(new_cases), SUM(cast(new_deaths as int))
FROM Capstone_Covid..Death_Covid$
WHERE continent is not null
GROUP BY date
order by 1,2


SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as death_percent

FROM Capstone_Covid..Death_Covid$
WHERE continent is not null
GROUP BY date
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as death_percent

FROM Capstone_Covid..Death_Covid$
WHERE continent is not null
order by 1,2

--Begin vaccination analysis
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) as Rolling_Vaccinations
FROM Capstone_Covid..Death_Covid$ dea
JOIN Capstone_Covid..Vaccinations_Covid$ vac
ON dea.location = vac.location
 and dea.date = vac.date

 where dea.continent is not null and dea.location = 'Canada'
   order by 1,2,3



--Use CTE
With PopvsVac (Continent, Location,Date, Population,new_vaccinations, Rolling_Vaccinations) 
as
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) as Rolling_Vaccinations
FROM Capstone_Covid..Death_Covid$ dea
JOIN Capstone_Covid..Vaccinations_Covid$ vac
ON dea.location = vac.location
 and dea.date = vac.date

 where dea.continent is not null --and dea.location = 'Canada'
   --order by 1,2,3
)
--FIND OUT PERCENTAGE VACCINATED
SELECT *, (Rolling_Vaccinations/Population)*100
FROM PopvsVac


--Temp Table

DROP Table if exists #PercentVaccinatedPop
Create Table #PercentVaccinatedPop
( Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  Rolling_vaccinations numeric
  )


Insert into #PercentVaccinatedPop
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) as Rolling_Vaccinations
FROM Capstone_Covid..Death_Covid$ dea
JOIN Capstone_Covid..Vaccinations_Covid$ vac
ON dea.location = vac.location
 and dea.date = vac.date

 where dea.continent is not null --and dea.location = 'Canada'
   --order by 1,2,3

   SELECT *, (Rolling_Vaccinations/Population)*100
FROM  #PercentVaccinatedPop


--create views

Create View PercentPopulationVaccination as

SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) as Rolling_Vaccinations
FROM Capstone_Covid..Death_Covid$ dea
JOIN Capstone_Covid..Vaccinations_Covid$ vac
ON dea.location = vac.location
 and dea.date = vac.date

 where dea.continent is not null --and dea.location = 'Canada'
   --order by 1,2,3
SELECT
	Date
	,total_cases
	,new_cases
	,total_deaths
	,population
FROM 
	CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country
SELECT
	Location
	,Date
	,total_cases
	,total_deaths
	,(total_deaths/total_cases)*100 AS DeathPercentage
FROM 
	CovidDeaths
WHERE Location LIKE '%Kingdom%'
	AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
--Shows percentage of population that got Covid

SELECT
	Location
	,Date
	,total_cases
	,(total_cases/population)*100 AS Casepopulation
FROM 
	CovidDeaths
--WHERE Location LIKE '%Kingdom%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection rate compared to population

SELECT
	Location
	,MAX(total_cases) AS HighestInfectionCount
	,MAX((total_cases/population))*100 AS PercentInfected
FROM 
	CovidDeaths
--WHERE Location LIKE '%Kingdom%'
Group by Location, Population
ORDER BY PercentInfected desc

-- Showing Countries with Highest Death Count per Population

SELECT
	Location
	,MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
FROM 
	CovidDeaths
--WHERE Location LIKE '%Kingdom%'
WHERE continent IS NOT NULL
Group by Location
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT
	location
	,MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
FROM 
	CovidDeaths
--WHERE Location LIKE '%Kingdom%'
WHERE continent IS NULL
Group by location
ORDER BY TotalDeathCount desc




--Showing continents with the highest death count per population

SELECT
	continent
	,MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
FROM 
	CovidDeaths
--WHERE Location LIKE '%Kingdom%'
WHERE continent IS NOT NULL
Group by continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

SELECT
	SUM(new_cases) AS TotalCases
	,SUM(CAST(new_deaths AS INT)) AS TotalDeaths
	,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM 
	CovidDeaths
--WHERE Location LIKE '%Kingdom%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

 

SELECT
	location
	,MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
FROM 
	CovidDeaths
--WHERE Location LIKE '%Kingdom%'
WHERE continent IS NOT NULL
Group by location
ORDER BY TotalDeathCount desc

-- Looking AT Total Population vs Vaccinations


SELECT 
	D.continent
	,D.location
	,D.date
	,D.population
	,v.new_vaccinations
	,SUM(CONVERT(INT, V.new_vaccinations)) OVER (Partition by D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
FROM 
	CovidDeaths AS D
JOIN 
	CovidVaccinations AS V
	ON D.location=V.location
	AND D.date=V.date
WHERE
	D.continent IS NOT NULL
ORDER BY
	2,3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS

(SELECT 
	D.continent
	,D.location
	,D.date
	,D.population
	,v.new_vaccinations
	,SUM(CONVERT(INT, V.new_vaccinations)) OVER (Partition by D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
FROM 
	CovidDeaths AS D
JOIN 
	CovidVaccinations AS V
	ON D.location=V.location
	AND D.date=V.date
WHERE
	D.continent IS NOT NULL
--ORDER BY 2,3 
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

--DROP TABLE if exists #PercentPopulationVacinated
CREATE TABLE #PercentPopulationVacinated
(
	Continent NVARCHAR(255)
	,Location NVARCHAR(255)
	,Date DATETIME
	,population NUMERIC
	,New_vaccinations NUMERIC
	,RollingPeopleVaccinated NUMERIC
)


INSERT INTO #PercentPopulationVacinated
SELECT 
	D.continent
	,D.location
	,D.date
	,D.population
	,v.new_vaccinations
	,SUM(CONVERT(BIGINT, V.new_vaccinations)) OVER (Partition by D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
FROM 
	CovidDeaths AS D
JOIN 
	CovidVaccinations AS V
	ON D.location=V.location
	AND D.date=V.date
WHERE
	D.continent IS NOT NULL
--ORDER BY 2,3 

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVacinated
ORDER BY 2,3 

-- Creating View to store data for later visualisations

CREATE VIEW PercentPopulationVacinated AS
SELECT 
	D.continent
	,D.location
	,D.date
	,D.population
	,v.new_vaccinations
	,SUM(CONVERT(BIGINT, V.new_vaccinations)) OVER (Partition by D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
FROM 
	CovidDeaths AS D
JOIN 
	CovidVaccinations AS V
	ON D.location=V.location
	AND D.date=V.date
WHERE
	D.continent IS NOT NULL

SELECT *
FROM PercentPopulationVacinated
--Confirmed Datasets

SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--Total Cases vs Total Deaths

SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--Total Cases vs Total Deaths (United States)

SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

--Total Cases vs Population (United States)
SELECT location, date, population,total_cases, (total_cases/population)*100 as population_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population,MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as percent_population_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY percent_population_infected DESC;

--Showing Countries with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths as int)) as total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC;

--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER by 1,2;


--Joining Vac/Death Datasets/ Total Pop vs Vax
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(int, vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaxxed
--(rolling_people_vaxxed/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null
ORDER BY 2,3

--CTE Population vs. Vaxxed
WITH PopsvsVax (continent, Location, Date, Population, new_vaccinations, rolling_people_vaxxed)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(int, vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaxxed
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null
)
SELECT *, (rolling_people_vaxxed/Population)*100
FROM PopsvsVax

--Temp Table
DROP TABLE IF exists #PercentPopVaxxed
CREATE TABLE #PercentPopVaxxed
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaxxed NUMERIC,
rolling_people_vaxxed numeric,
)

INSERT INTO #PercentPopVaxxed
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(int, vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaxxed
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null

SELECT *, (rolling_people_vaxxed/population)*100
FROM #PercentPopVaxxed

--VIEW for tableau
CREATE VIEW PercentPopVaxxed AS
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(int, vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaxxed
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null

--Accessing View
SELECT *
FROM PercentPopVaxxed
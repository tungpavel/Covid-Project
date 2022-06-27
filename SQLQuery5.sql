select *
from PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--Order by 3,4


--Select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total cases vs total deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'United Kingdom'
ORDER BY 1,2

-- Looking at Total Cases vs Population
SELECT Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'United Kingdom'
ORDER BY 1,2

-- Looking at highes infection rate compared to population
SELECT Location, MAX(total_cases) as HighesInfectionCount, population, max((total_cases/population))*100 as PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentOfPopulationInfected DESC

--Showing countries with highest deathcount per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathsCount DESC

-- Lets break things down by continent (Incl World)
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathsCount DESC

-- Lets break things down by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount DESC

-- breaking global numbers
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- looking at total pop vs vacs
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition BY dea.location order by dea.location, dea.date) as RollingPeopleVacsed 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--USE CTE
WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVacsed)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition BY dea.location order by dea.location, dea.date) as RollingPeopleVacsed 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVacsed/population)/100 as Total_vaccinated_percent
From PopvsVac

--temp table

drop table if exists PercentPopVacsed
Create Table PercentPopVacsed
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVacsed numeric
)
Insert Into PercentPopVacsed
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition BY dea.location order by dea.location, dea.date) as RollingPeopleVacsed 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3
SELECT *, (RollingPeopleVacsed/population)*100 as Total_vaccinated_percent
From PercentPopVacsed

-- creating View to store data for later visualizing 
CREATE VIEW PercentOfVacsed as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition BY dea.location order by dea.location, dea.date) as RollingPeopleVacsed 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

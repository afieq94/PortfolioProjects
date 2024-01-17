
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccintations
--order by 3,4

-- Select Data that we are going to be using

--Select Location, Date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeaths
--order by 1,2

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dyiing if you contract covid in your country
Select Location, Date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%malaysia%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got COvid

Select Location, Date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%malaysia%'
and continent is not null
order by 1,2


-- Looking at Country with Highest Infection rate compare to Population
SELECT
    Location,
    Population,
    MAX(total_cases) as HighestInfectionCount,
    MAX((total_cases / CAST(Population AS FLOAT))) * 100 as PercentagePopulationInfected
FROM
    PortfolioProject..CovidDeaths
--WHERE Location LIKE '%malaysia%'
GROUP BY
    Location, Population
ORDER BY
    PercentagePopulationInfected DESC;

-- Showing countries with Highest Death Count per Population

SELECT Location, MAX(CAST (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%malaysia%'
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(CAST (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%malaysia%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Showing continents with the hisghest death count per population

SELECT continent, MAX(CAST (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%malaysia%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;



--GLOBAL NUMBERS

SELECT
    Date,
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths AS INT)) as total_deaths,
    (SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0)) * 100 as DeathPercentage
FROM
    PortfolioProject..CovidDeaths
--WHERE location LIKE '%malaysia%'
WHERE continent IS NOT NULL
ORDER BY Date;

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (CONVERT (int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated, 
(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccintations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (CONVERT (int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccintations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) *100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (CONVERT (int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccintations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/NULLIF(Population, 0))*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccintations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
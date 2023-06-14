SELECT *
FROM PortfolioCess.dbo.CovidDeaths$
order by 3,4

--SELECT *
--FROM Portfolio.dbo.CovidVaccinations$
--order by 3,4

--Select data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioCess.dbo.CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioCess.dbo.CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at Total Cases Vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases,  (total_cases/population)*100 as PopulationInfected
FROM PortfolioCess.dbo.CovidDeaths$
Where location like '%states%' and  continent is not null 
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population

SELECT location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
FROM PortfolioCess.dbo.CovidDeaths$ 
Group by location, population
order by PercentofPopulationInfected desc

--Showing Countries with Highest Death Count per population
--Added Where clause due to data displaying death counts of continents
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioCess.dbo.CovidDeaths$
Where continent is not null 
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioCess.dbo.CovidDeaths$
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Possibly more accurate was of displaying death by continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioCess.dbo.CovidDeaths$
Where continent is null 
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

--Shows total number of world cases, total deaths, death percentage by date

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioCess.dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null
group by date
order by 1,2

--Shows total number of world cases, total deaths, death percentage 
SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioCess.dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2


--Looking at Total Population VS Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioCess..CovidDeaths$ dea
Join PortfolioCess..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Lets add  rolling count of people vaccinated to the query 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- CAN ALSO use SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location) 
FROM PortfolioCess..CovidDeaths$ dea
Join PortfolioCess..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE 
With PopvsVas (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)  as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- CAN ALSO use SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location) 
FROM PortfolioCess..CovidDeaths$ dea
Join test..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM  PopvsVas

--TEMP TABLE 
DROP table if exists #PercentPopulationVaccinated
--TO RUN TABLE WITH ALTERATIONS
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- CAN ALSO use SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location) 
FROM PortfolioCess..CovidDeaths$ dea
Join PortfolioCess..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM  #PercentPopulationVaccinated

--Creating View to store data for later Visualization 
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- CAN ALSO use SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location) 
FROM PortfolioCess..CovidDeaths$ dea
Join PortfolioCess..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated
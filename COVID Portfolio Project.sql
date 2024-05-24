SELECT *
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order By 3,4

--SELECT *
--From PortfolioProject.dbo.CovidVaccinations
--Order By 3,4

-- Data that I am going to be using 

Select location, Date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows likehood of dying if you contract covid in your country

Select location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Canada'
And continent is not null
Order by 1,2

-- Lokking at Total Cases Vs Population
-- Show what percentage of population got Covid

Select location, Date,  population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'Canada'
And continent is not null
Order by 1,2

-- Looking at Country with Highest Infaction Rate compared to Population 

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Let´s Breakdown by continent 
-- Showing continents with the hisghest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers

Select SUM(New_cases) as total_cases, SUM(cast(New_deaths as int)) as TotalDeaths, SUM(cast(New_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Loking at Total Population Vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) 
Over (Partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths  As Dea
Join PortfolioProject..CovidVaccinations As Vac
	ON Dea.location =Vac.location
	and Dea.date = Vac.date
Where dea.continent is not null
Order by 2,3

-- Using CTE
With Popvsvac(Continet, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) 
Over (Partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths  As Dea
Join PortfolioProject..CovidVaccinations As Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From Popvsvac

-- TEM Table
Drop Table if exists #PercentPopulationVaccunated
Create Table #PercentPopulationVaccunated
(
Continent nvarchar(250),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_Vacccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccunated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) 
Over (Partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths  As Dea
Join PortfolioProject..CovidVaccinations As Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccunated

-- Creating view to store data for later visualization

Create View PercentPopulationVaccunated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) 
Over (Partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths  As Dea
Join PortfolioProject..CovidVaccinations As Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
Where dea.continent is not null

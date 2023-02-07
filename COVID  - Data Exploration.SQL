
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


Select *
From PortfolioProject..CovidDeaths
where continent is not null

-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null


-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
Group by location,population
order by PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount DESC


--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2



--Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3


  -- Using CTE to perform Calculation on Partition By in previous query


  with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
  as
  (
  Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  )
  Select *, (RollingPeopleVaccinated/Population)*100
  From PopvsVac
  order by 2,3


 -- Using Temp Table to perform Calculation on Partition By in previous query

  Drop Table if exists #PercentPopulationVaccinated
  Create Table #PercentPopulationVaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_Vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

  Insert into #PercentPopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
 -- where dea.continent is not null
 

  Select *, (RollingPeopleVaccinated/Population)*100
  From #PercentPopulationVaccinated
  order by 2,3

  

  --Creating view to store data later for visualizations 
  
  Create View PercentPopulationVaccinated as 
  Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 

  
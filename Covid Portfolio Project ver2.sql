Select *
From ProtfolioProject..CovidDeaths$
Where continent is not null
Order by 3,4

Select total_deaths
From ProtfolioProject..CovidDeaths$

Select location, date, total_cases, new_cases, total_deaths, population
From ProtfolioProject..CovidDeaths$
Order by 1,2

--Looking at Total cases and Total Deaths
--Show likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProtfolioProject..CovidDeaths$
Where location like '%states%'
Order by 1,2

--Looking at Total cases vs Population
--Show what percentage of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From ProtfolioProject..CovidDeaths$
Where location like '%states%'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select location, population, max(total_cases) as HighestInfectionCout, Max(total_cases/population)*100 as PercentPopulationInfected
From ProtfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

--LET'S BREAK THINGS DOWN BY CONTINENT


Select continent, max(cast(total_deaths as int)) as TotalDeathCout
From ProtfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCout desc

--Showing continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCout
From ProtfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCout desc



--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From ProtfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

--Looking at Total Population vs Vaccincations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From ProtfolioProject..CovidDeaths$ dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From ProtfolioProject..CovidDeaths$ dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From ProtfolioProject..CovidDeaths$ dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From ProtfolioProject..CovidDeaths$ dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

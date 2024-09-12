

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Coviddeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Coviddeaths
Where total_cases <> 0 and (total_deaths <> 0 or location like '%states%')
order by 1,2

--Looking at Total_Cases vs Population
--Shows what percentage of population got Covid

Select location, date, Population, total_deaths, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..Coviddeaths
Where total_cases <> 0 and total_deaths <> 0 
order by 1,2 

--Looking at Countries with Highest Infection Rate compared to Population

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Coviddeaths
Group by location,Population
Order by PercentPopulationInfected DESC

--Showing Countries with Highest Death Count Per Population

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Coviddeaths
Where continent is  null
Group by continent
Order by TotalDeathCount DESC


--Showing the continents with the highest death count per population
Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Coviddeaths
Where continent is not null
Group by continent
Order by TotalDeathCount DESC



--GLOBAL NUMBERS
 
 Select  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths )/SUM(total_cases)*100 as DeathPercentage
From PortfolioProject..Coviddeaths
Where (total_cases <> 0 and total_deaths <> 0) and continent is not null
--Group by date 
order by 1,2


-- Looking at Total Population vs Vaccinations
With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,dea.date ) as RollingPeopleVaccinated
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 
 )
 Select *, (RollingPeopleVaccinated/Population)*100
 From PopvsVac


 --TEMP TABLE
 DROP TABLE #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated(
 continent nvarchar(255) , location nvarchar(255),
 date datetime,
 population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric)

 insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,dea.date ) as RollingPeopleVaccinated
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

 Select *, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated 

 --Creating view to store data for later visualization

 Create view PopulationVaccinated as 
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,dea.date ) as RollingPeopleVaccinated
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

SELECT * 
FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_NAME = 'PercentPopulationVaccinated';

--To remove view from master and place it in the appropriate database

USE master;
DROP VIEW IF EXISTS dbo.PercentPopulationVaccinated;

--Using the following procedure to get it placed in the appropriate database
USE PortfolioProject;  -- Replace with your intended database name
GO

CREATE VIEW dbo.PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date
    ) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..Coviddeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE  
    dea.continent IS NOT NULL;


Select *
From PercentPopulationVaccinated




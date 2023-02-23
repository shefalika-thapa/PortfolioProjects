/* Covid-19 Data Exploration using SQL
   Concepts used: CTEs,Joins,Temporary Tables,Aliases,Aggregate Functions,Views,Converting Data Types
*/

Select * 
FROM PortfolioProject..coviddeaths$
where continent is not null
ORDER BY 3,4


--Explore columns which are used for further analysis (Columns of importance)

Select location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..coviddeaths$
where continent is not null
order by 1,2


--Total Cases vs Total Deaths
--Likelihood of dying if you contract covid in your country

Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..coviddeaths$
where location like '%india%'
and continent is not null
order by 1,2

--Total Cases vs Population
--What percentage of population infected with Covid

Select location,date,population,total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..coviddeaths$
order by 1,2


--Countries with highest infection rate compared to population

Select location,population,max(total_cases) AS HighestInfectionCount, max((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..coviddeaths$
group by location,population
order by PercentPopulationInfected desc


--Countries with highest death count per population

Select location,max(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..coviddeaths$
where continent is NOT NULL
group by location
order by TotalDeathCount desc




--BREAK THINGS DOWN BY CONTINENT

--Continents with highest death count per population

Select continent,max(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..coviddeaths$
where continent is NULL
group by continent
order by TotalDeathCount desc



Select continent,max(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..coviddeaths$
--where location like '%states%'
where continent is NOT NULL
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage  --total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..coviddeaths$
where continent is not null
order by 1,2

--Total Population vs Vaccinations
--Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(bigint,vac.new_vaccinations)) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths$ dea
join PortfolioProject..covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated

from PortfolioProject..coviddeaths$ dea
join PortfolioProject..covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

)
Select *,(RollingPeopleVaccinated/population)
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths$ dea
join PortfolioProject..covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations

USE PortfolioProject
GO
create view PercentPopulationVaccinated3 as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated

from PortfolioProject..coviddeaths$ dea
join PortfolioProject..covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null


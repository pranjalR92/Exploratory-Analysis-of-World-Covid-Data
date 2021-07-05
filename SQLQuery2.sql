--select data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Poject Covid]..[Covid Deaths]
where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From [Portfolio Poject Covid]..[Covid Deaths]
Where location like '%India%'
where continent is not null
Order by 1,2

--Looking at Total Cases Vs Population
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Poject Covid]..[Covid Deaths]
Where location like '%India%'
where continent is not null
Order by 1,2

--Looking at countries with Highest Infection Rate Compared to Population
select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Poject Covid]..[Covid Deaths]
--Where location like '%India%'
where continent is not null
Group by population, location
Order by PercentPopulationInfected desc

--Showing countries with highest death count per population
select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From [Portfolio Poject Covid]..[Covid Deaths]
--Where location like '%India%'
where continent is not null
Group by location
Order by TotalDeathCount desc

--Breaking things down by Continent
select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From [Portfolio Poject Covid]..[Covid Deaths]
--Where location like '%India%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers
select SUM(new_cases) as TotalCases, SUM(Cast(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
From [Portfolio Poject Covid]..[Covid Deaths]
--Where location like '%India%'
Where continent is not null
Order by 1,2

--Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccination
From [Portfolio Poject Covid]..[Covid Deaths] dea
Join [Portfolio Poject Covid]..[Covid Vaccinations] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--USE CTE
WITH PopulationVsVaccination (continent, location, date, population, new_vaccinations, RollingCountOfVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccination
From [Portfolio Poject Covid]..[Covid Deaths] dea
Join [Portfolio Poject Covid]..[Covid Vaccinations] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select *, (RollingCountOfVaccination/population)*100 as VaccinationPercent
From PopulationVsVaccination


--CREATING TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingCountOfVaccination numeric,
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccination
From [Portfolio Poject Covid]..[Covid Deaths] dea
Join [Portfolio Poject Covid]..[Covid Vaccinations] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *, (RollingCountOfVaccination/population)*100 as VaccinationPercent
From #PercentPopulationVaccinated
Order by 2,3



--Creating view for Later Visualization
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccination
From [Portfolio Poject Covid]..[Covid Deaths] dea
Join [Portfolio Poject Covid]..[Covid Vaccinations] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null


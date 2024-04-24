Select *
From Portfolio_Project_Covid_1..Covid_deaths_Portfolio
Where continent is not null
order by 3,4

--Select *
--From Portfolio_Project_Covid_1..Covid_Vaccine_Portfolio
--order by 3,4

-- Select Data 

Select Location,date,total_cases, new_cases, total_deaths,population

From Portfolio_Project_Covid_1..Covid_deaths_Portfolio
order by 1,2


-- Looking at Total Cases vs Total Deaths in India

Select Location,date,total_cases,  total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project_Covid_1..Covid_deaths_Portfolio
Where location like '%India%'
order by 1,2

--Total Cases vs Population in India

Select Location,date,total_cases,  population,(total_cases/population)*100 as PopulationPercentage
From Portfolio_Project_Covid_1..Covid_deaths_Portfolio
Where location like '%India%'
order by 1,2

-- Now we need to find out which Country is effected with Highest Infection rate Compared to Population

Select Location,Population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project_Covid_1..Covid_deaths_Portfolio
Group by Location,Population
order by PercentPopulationInfected desc

-- Now we need to Filter out the Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_Project_Covid_1..Covid_deaths_Portfolio
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Let's Break things Down by Continent

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_Project_Covid_1..Covid_deaths_Portfolio
Where continent is null
Group by location
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From Portfolio_Project_Covid_1..Covid_deaths_Portfolio
--Where location like '%India%'
where continent is not null
--Group By date
order by 1,2

--Global Number for total deaths vs total cases and death percentage based in Dates.

Select date,SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From Portfolio_Project_Covid_1..Covid_deaths_Portfolio
--Where location like '%India%'
where continent is not null
Group By date
order by 1,2

--Looking at Total population vs vaccinations using Joins

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as TotalVaccinationBYdate
From Portfolio_Project_Covid_1..Covid_deaths_Portfolio dea
Join Portfolio_Project_Covid_1..Covid_Vaccine_Portfolio vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3

	 --Use CTE

	 With PopVsVac(Continent, Location, date,Population, New_Vaccinations, RollingPeopleVaccinated)
	 as
	 (
	 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as TotalVaccinationBYdate
From Portfolio_Project_Covid_1..Covid_deaths_Portfolio dea
Join Portfolio_Project_Covid_1..Covid_Vaccine_Portfolio vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 --order by 2,3
	 )
	 Select *,(RollingPeoplevaccinated/Population)*100
	 From PopVsVac

	 --Temp Table

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
,SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeoplevaccinated
From Portfolio_Project_Covid_1..Covid_deaths_Portfolio dea
Join Portfolio_Project_Covid_1..Covid_Vaccine_Portfolio vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 --where dea.continent is not null
	 --order by 2,3
	 
	 Select *,(RollingPeoplevaccinated/Population)*100
	 From #PercentPopulationVaccinated

-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From Portfolio_Project_Covid_1..Covid_deaths_Portfolio dea
JOIN Portfolio_Project_Covid_1..Covid_Vaccine_Portfolio vac
 ON dea.location = vac.location 
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 Select *
 From PercentPopulationVaccinated
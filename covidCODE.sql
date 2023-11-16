---covidDeaths Table

Select *
FROM Covid..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4


SELECT location, date,  total_cases, new_cases, total_deaths, population
FROM Covid..CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2

SELECT location, date,  total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
FROM Covid..CovidDeaths$
WHERE location like '%India%' and continent is not null
ORDER BY 1, 2

SELECT location, date,  total_cases,population, (total_cases/ population )*100 as covid_rate
FROM Covid..CovidDeaths$
WHERE location like '%India%' and continent is not null
ORDER BY 1, 2

SELECT location, population,MAX(total_cases) as MaxInfectionCount, (max(total_cases)/ population )*100 as covid_rate
FROM Covid..CovidDeaths$
WHERE continent is not null
GROUP BY Location, Population
ORDER BY covid_rate desc

SELECT location,MAX(cast(total_deaths as int)) as total_death_count
FROM Covid..CovidDeaths$
WHERE continent is not null
GROUP BY Location
ORDER BY total_death_count desc

SELECT location ,MAX(cast(total_deaths as int)) as total_death_count
FROM Covid..CovidDeaths$
WHERE continent is null
GROUP BY Location
ORDER BY total_death_count desc

SELECT continent ,MAX(cast(total_deaths as int)) as total_death_count
FROM Covid..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count desc

SELECT  date, SUM(new_cases) as cases_total, SUM(cast(new_deaths as int)) as deaths_total, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM Covid..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) as cases_total, SUM(cast(new_deaths as int)) as deaths_total, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as WorldsDeathPercentage
FROM Covid..CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2

----CovidDeaths joins CovidVaccinations


SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(INT, V.new_vaccinations)) 
OVER (PARTITION BY D.location 
	  ORDER BY D.location, D.date) as RollingPeopleVaccinated
FROM Covid..CovidDeaths$ D
JOIN Covid..CovidVaccinations$ V
	ON D.location =V.location 
	and D.date=V.date
WHERE D.continent is not null
ORDER BY 2,3

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(INT, V.new_vaccinations)) 
OVER (PARTITION BY D.location 
	  ORDER BY D.location, D.date) as RollingPeopleVaccinated
FROM Covid..CovidDeaths$ D
JOIN Covid..CovidVaccinations$ V
	ON D.location =V.location 
	and D.date=V.date
WHERE D.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
FROM PopVsVac


CREATE TABLE #PecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PecentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(INT, V.new_vaccinations)) 
OVER (PARTITION BY D.location 
	  ORDER BY D.location, D.date) as RollingPeopleVaccinated
FROM Covid..CovidDeaths$ D
JOIN Covid..CovidVaccinations$ V
	ON D.location =V.location 
	and D.date=V.date
WHERE D.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
FROM #PecentPopulationVaccinated



DROP TABLE if exists #PecentPopulationVaccinated
CREATE TABLE #PecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PecentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(INT, V.new_vaccinations)) 
OVER (PARTITION BY D.location 
	  ORDER BY D.location, D.date) as RollingPeopleVaccinated
FROM Covid..CovidDeaths$ D
JOIN Covid..CovidVaccinations$ V
	ON D.location =V.location 
	and D.date=V.date

SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
FROM #PecentPopulationVaccinated


--storing data for later visualizations

CREATE VIEW VaccinatedPopulationPercentage AS
SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    100.0 * SUM(CONVERT(INT, v.new_vaccinations)) 
              OVER (PARTITION BY d.location ORDER BY d.date) / d.population 
              AS PercentPopulationVaccinated
FROM
    Covid..CovidDeaths$ D
JOIN
    Covid..CovidVaccinations$ V ON D.location = V.location AND D.date = V.date
WHERE
    D.continent IS NOT NULL


SELECT *
FROM VaccinatedPopulationPercentage


--data used for tableau visualization

--1--
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid..CovidDeaths$
where continent is not null 
order by 1,2




--2--


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Covid..CovidDeaths$
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--3--

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc


--4--


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid..CovidDeaths$
Group by Location, Population, date
order by PercentPopulationInfected desc

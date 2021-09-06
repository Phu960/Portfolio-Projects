--Covid-19 Deaths
SELECT *
FROM project_a..[covid-deaths]
WHERE continent IS NOT NULL
ORDER BY location, date

--Select data that will be used
Select continent, location, date, total_cases, new_cases, total_deaths, population
From project_a..[covid-deaths]
order by location, date

--AUSTRALIA total cases vs total deaths 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM project_a..[covid-deaths]
WHERE location LIKE '%australia%'
ORDER BY date


--AUSTRALIA total cases vs population
SELECT date, total_cases, population, (total_cases/population)*100 AS infection_rate
FROM project_a..[covid-deaths]
WHERE location LIKE '%australia%' 
ORDER BY date

--Countries with the highest infection rate per population
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_population_infected
FROM project_a..[covid-deaths]
GROUP BY location, population
ORDER BY percent_population_infected DESC

--Continent with the highest death count
SELECT location AS continent, population, MAX(cast(total_deaths as int)) AS total_death_count
FROM project_a..[covid-deaths]
WHERE continent IS NULL
GROUP BY location, population
ORDER BY total_death_count DESC

--Countries with the highest death count
SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM project_a..[covid-deaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, 
SUM(cast(new_deaths AS INT))/(SUM(new_cases))*100 AS death_rate
FROM project_a..[covid-deaths]
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Covid-19 Vaccinations

-- Shows Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
FROM project_a..[covid-deaths] dea
JOIN project_a..[covid-vac] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- Using CTE to perform Calculation on Partition By in previous query to get percentage of vaccinations per population
WITH population_vaccinated (continent, location, date, population, new_vaccinations, total_vaccinations) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
FROM project_a..[covid-deaths] dea
JOIN project_a..[covid-vac] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (total_vaccinations/Population)*100 AS percent_vaccinated
FROM population_vaccinated

-- Creating View to store data for later visualizations
-- Percentage of vaccinations per population
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
FROM project_a..[covid-deaths] dea
JOIN project_a..[covid-vac] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


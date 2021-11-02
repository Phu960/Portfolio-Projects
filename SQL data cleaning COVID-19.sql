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
SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM project_a..[covid-deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

--Countries with the highest death count
SELECT location, MAX(CAST(total_deaths as int)) AS total_death_count
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

-- New vaccinations and cumulative sum of new vaccinations by country
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM project_a..[covid-deaths] dea
JOIN project_a..[covid-vac] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Percentage of vaccinations per population (Using temp table)
DROP TABLE IF exists #population_vaccinated
CREATE TABLE #population_vaccinated (
continent VARCHAR(100),
location VARCHAR(100),
date DATE,
population NUMERIC,
new_vaccinations NUMERIC,
rolling_people_vaccinated NUMERIC
)

INSERT INTO #population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM project_a..[covid-deaths] dea
JOIN project_a..[covid-vac] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (rolling_people_vaccinated / population)*100
FROM #population_vaccinated

--Percentage of vaccinations per population (Using CTE)
WITH population_vaccinated (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM project_a..[covid-deaths] dea
JOIN project_a..[covid-vac] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated / population)*100
FROM population_vaccinated

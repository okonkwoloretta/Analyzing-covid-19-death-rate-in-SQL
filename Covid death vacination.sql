--selecting data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PORTFOLIO PROJECT]..CovidDeaths
ORDER BY 1,2


--TOTAL CASES VS TOTAL DEATH PERCENT IN US
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)
*100 AS death_percent
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE location LIKE  '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

--TOTAL CASES VS POPULATION 
SELECT location, date, population,total_cases, (total_cases/population)*100 
AS death_percent
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE location LIKE  '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

--COUNTRY WITH HIGHEST COVID RATE
SELECT location, population,MAX(total_cases) AS max_total_cases, 
MAX((total_cases/population))*100 AS max_pop_percent
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_pop_percent DESC

--COUNTRY WITH HIGHEST DEATH COUNT
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_deaths_count 
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deaths_count DESC

--TOTAL DEATH BY LOCATION
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_deaths_count 
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_deaths_count DESC

--TOTAL DEATH BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_deaths_count 
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths_count DESC

--GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS INT)) 
AS total_new_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 
AS new_death_percent
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--joining coviddeath to covidvacination
SELECT *
FROM [PORTFOLIO PROJECT]..CovidDeaths Dea
JOIN [PORTFOLIO PROJECT]..CovidVaccinations Vac
   ON Dea.location = Vac.location
   AND Dea.date = Vac.date

--total population vs vacination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [PORTFOLIO PROJECT]..CovidDeaths Dea
JOIN [PORTFOLIO PROJECT]..CovidVaccinations Vac
   ON Dea.location = Vac.location
   AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--POPULATION VS NEW VACINATION
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS rolling_people_vacinated
FROM [PORTFOLIO PROJECT]..CovidDeaths dea
JOIN [PORTFOLIO PROJECT]..CovidVaccinations Vac
   ON dea.location = Vac.location
   AND dea.date = Vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--USING CTE
WITH PopvsVac (continent,location, date, population,new_vacinations, rolling_people_vacinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS rolling_people_vacinated
FROM [PORTFOLIO PROJECT]..CovidDeaths dea
JOIN [PORTFOLIO PROJECT]..CovidVaccinations Vac
   ON dea.location = Vac.location
   AND dea.date = Vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_people_vacinated/population)
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #Percentpopulationvacinated
CREATE TABLE #Percentpopulationvacinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacinations numeric,
rolling_people_vacinated numeric
)
INSERT INTO #Percentpopulationvacinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS rolling_people_vacinated
FROM [PORTFOLIO PROJECT]..CovidDeaths dea
JOIN [PORTFOLIO PROJECT]..CovidVaccinations Vac
   ON dea.location = Vac.location
   AND dea.date = Vac.date

SELECT *, (rolling_people_vacinated/population)
FROM #Percentpopulationvacinated

--CREATING VIEW FOR VISUALS

CREATE VIEW Percentpopulationvacinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS rolling_people_vacinated
FROM [PORTFOLIO PROJECT]..CovidDeaths dea
JOIN [PORTFOLIO PROJECT]..CovidVaccinations Vac
   ON dea.location = Vac.location
   AND dea.date = Vac.date
WHERE dea.continent IS NOT NULL 


-- Total Cases vs Total Deaths percentage in Poland

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths / total_cases) * 100, 2) AS pct_deaths
FROM covid_deaths
WHERE location = 'Poland'
ORDER BY 2;

-- New cases monthly

SELECT location,
       DATE_TRUNC('month', date)
         AS  production_to_month,
		 SUM(new_cases)
FROM covid_deaths
GROUP BY location, DATE_TRUNC('month', date)
ORDER BY 1, 2;

-- Probability of death for Covid infection in all locations on the last reported date in descending order

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths / total_cases) * 100, 2) AS pct_deaths
FROM covid_deaths
WHERE date = (SELECT MAX(date) FROM covid_deaths)
ORDER BY pct_deaths DESC NULLS LAST;

-- Percentage of the population infected with covid
 
SELECT location, population, MAX(total_cases) AS max_cases_count, MAX((ROUND((total_cases / population) * 100, 4))) AS pct_cases
FROM covid_deaths
GROUP BY population, location
ORDER BY pct_cases DESC NULLS LAST;

-- Percentage of the population deaths

SELECT location, population, MAX(total_deaths) AS total_deaths, MAX((ROUND((total_deaths / population) * 100, 4))) AS pct_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY pct_deaths DESC NULLS LAST;

-- Continents percentage of deaths

SELECT location, population, MAX(total_deaths) AS total_deaths, MAX((ROUND((total_deaths / population) * 100, 4))) AS pct_deaths
FROM covid_deaths
WHERE continent IS NULL AND location IN ('Asia', 'Africa', 'Europe', 'North America', 'South America', 'Oceania')
GROUP BY location, population
ORDER BY pct_deaths DESC NULLS LAST;

-- Number of cases in the world per day and deaths percentage

SELECT date, SUM(new_cases) AS cases_daily, SUM(new_deaths) AS deaths_daily, (ROUND((SUM(new_deaths) / SUM(new_cases)) * 100, 4)) AS pct_deaths_daily
FROM covid_deaths
WHERE continent IS NOT NULL AND new_cases IS NOT NULL
GROUP BY date
ORDER BY date;

-- Rolling sum of daily vaccination and people fully vaccinated

SELECT dea.location, dea.date, dea.total_cases, vac.new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date), people_fully_vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- Deaths percentage vs vaccinations percentage

SELECT dea.location, dea.date, dea.new_deaths, dea.new_cases, 
(CASE WHEN dea.new_cases > 0 THEN (ROUND(dea.new_deaths / dea.new_cases * 100, 4)) ELSE NULL END) AS new_cases_deaths_pct, 
ROUND((CAST(vac.people_fully_vaccinated AS numeric)) / dea.population * 100, 4) AS vaccination_pct
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

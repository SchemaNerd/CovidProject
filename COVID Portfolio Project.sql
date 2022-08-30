-- Queries used for Tableau Project

-- 1.

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(total_deaths)*100 AS DeathPercentage
FROM Portfolioproject.coviddeaths
-- WHERE location = Canada
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;

-- The second one includes 'International' location

-- SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(total_deaths)*100 AS DeathPercentage
-- FROM portfolioproject.coviddeaths
-- WHERE location = 'World'
-- GROUP BY date
-- ORDER BY 1,2;


-- 2.

-- We take these out as they are not included in the above queries and want to stay consistent
-- European Union is apart of Europe

SELECT location, SUM(new_deaths) AS TotalDeathCount
FROM Portfolioproject.coviddeaths
-- WHERE location = Canada
WHERE continent IS NULL
AND location NOT IN ('World', 'International', 'European Union', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- 3.

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Portfolioproject.coviddeaths
-- WHERE location = Canada
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- 4.

SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Portfolioproject.coviddeaths
-- WHERE location = Canada
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;



-- Queries originally created

SELECT *
FROM portfolioproject.coviddeaths
ORDER BY location, date;

-- SELECT *
-- FROM portfolioproject.covidvaccinations
-- ORDER BY 3,4;

-- Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs. Total Deaths
-- Shows the likelihood of dying if you contract Covid-19 in Canada
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM portfolioproject.coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at the Total Cases vs. Population
-- Shows what percentage of population contracted Covid-19 in Canada
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percent_Population_Infected
FROM portfolioproject.coviddeaths
WHERE location = 'Canada'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL
-- WHERE location = 'Canada'
GROUP BY location,population
ORDER BY Percent_Population_Infected DESC;

-- Showing the countries with the highest death count per population

SELECT location, MAX(total_deaths) AS Total_Death_Count
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL
-- WHERE location = 'Canada'
GROUP BY location
ORDER BY Total_Death_Count DESC;

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS Total_Death_Count
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL
-- WHERE location = 'Canada'
GROUP BY continent
ORDER BY Total_Death_Count DESC;

-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(New_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM portfolioproject.coviddeaths
-- WHERE location = 'Canada'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY date, total_cases;

-- Looking at Total Population vs. Vaccinations

SELECT *
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated,
(Rolling_People_Vaccinated/population)*100
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date;

-- Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
-- (Rolling_People_Vaccinated/population)*100
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY location, date
)
SELECT *, (Rolling_People_Vaccinated/population)*100
FROM PopvsVac;

-- TEMP Table

DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TABLE PercentPopulationVaccinated (
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date datetime,
	Population NUMERIC,
	New_Vaccinations NUMERIC,
	Rolling_People_Vaccinated NUMERIC
    );
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
-- (Rolling_People_Vaccinated/population)*100
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
-- ORDER BY location, date

SELECT *, (Rolling_People_Vaccinated/population)*100
FROM PercentPopulationVaccinated;

-- Creating view to store data for future visualizations (create multiple for practice)

CREATE VIEW PercentPopulationVaccinated1 AS
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
	-- (Rolling_People_Vaccinated/population)*100
	FROM portfolioproject.coviddeaths dea
	JOIN portfolioproject.covidvaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
-- ORDER BY location, date
;

SELECT * FROM PortfolioProject.percentpopulationvaccinated1;
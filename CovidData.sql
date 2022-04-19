# Queries used for Tableau Project


#1.

Select  
    SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM 
    `my-data-project0224.PortfolioProject.CovidDeaths`
WHERE    
    continent is not null 
ORDER BY 1,2


#2.

SELECT 
    location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM 
    `my-data-project0224.PortfolioProject.CovidDeaths`
WHERE
    continent is null 
AND
    location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 
    'Lower middle income', 'Low income')
GROUP BY
    location
ORDER BY
    TotalDeathCount DESC



#3. 

Select
    location, population, MAX(total_cases) as HighestInfectionCount, 
    Max((total_cases/population))*100 as PercentPopulationInfected
FROM 
    `my-data-project0224.PortfolioProject.CovidDeaths`
GROUP BY 
    location, population
ORDER BY 
    PercentPopulationInfected DESC



#4.


SELECT 
    location, population,date, MAX(total_cases) as HighestInfectionCount, 
    Max((total_cases/population))*100 as PercentPopulationInfected
FROM 
    `my-data-project0224.PortfolioProject.CovidDeaths`

GROUP BY 
    location, population, date
ORDER BY 
    PercentPopulationInfected DESC





/* Below mentioned queries where used by me to run different analysis and to understand the data better */





SELECT *

FROM `my-data-project0224.PortfolioProject.CovidDeaths`



# Select data that we are going to be using

SELECT location,date, total_cases, new_cases, total_deaths, population

FROM `my-data-project0224.PortfolioProject.CovidDeaths` 

WHERE continent is not null 

ORDER BY location, date



# Looking at total cases vs total deaths
# Show the likelihood of dying if you contract covid in your country

SELECT location,date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage

FROM `my-data-project0224.PortfolioProject.CovidDeaths` 

WHERE location = 'Canada'

AND continent is not null 

ORDER BY location, date 



# Looking at the total cases vs population
# show what percentage of population got covid

SELECT location,date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected

FROM `my-data-project0224.PortfolioProject.CovidDeaths` 

WHERE location = 'United States'

AND continent is not null 

ORDER BY location, date 



# looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected 

FROM `my-data-project0224.PortfolioProject.CovidDeaths` 

WHERE continent is not null 

GROUP BY location, population

ORDER BY PercentPopulationInfected DESC



# Showing contries with the hishest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount

FROM `my-data-project0224.PortfolioProject.CovidDeaths` 

WHERE continent is not null 

GROUP BY location

ORDER BY TotalDeathCount DESC



# Let's break it futher by continent
# Revied version of the above code

SELECT location, MAX(total_deaths) AS TotalDeathCount

FROM `my-data-project0224.PortfolioProject.CovidDeaths` 

WHERE continent is null 

GROUP BY location

ORDER BY TotalDeathCount DESC



# Showing the continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount

FROM `my-data-project0224.PortfolioProject.CovidDeaths` 

WHERE continent is not null 

GROUP BY continent

ORDER BY TotalDeathCount DESC



# Global Numbers

SELECT date, SUM(new_cases) AS total_cases_new, SUM(new_deaths) AS total_deaths_new, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage

FROM `my-data-project0224.PortfolioProject.CovidDeaths` 

WHERE continent is not null 

GROUP BY date

ORDER BY date, total_cases_new 



# Total Global Numbers in a row

SELECT SUM(new_cases) AS total_cases_new, SUM(new_deaths) AS total_deaths_new, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage

FROM `my-data-project0224.PortfolioProject.CovidDeaths` 

WHERE continent is not null 

ORDER BY total_cases_new 



# Now will start to explore the other table named COVIDVACCINATIONS

SELECT *

FROM `my-data-project0224.PortfolioProject.CovidVaccinations`



# Going to join two tables CovidDeaths and CovidVaccinations

SELECT *

FROM `my-data-project0224.PortfolioProject.CovidDeaths` dea

JOIN `my-data-project0224.PortfolioProject.CovidVaccinations` vac

ON dea.location = vac.location
AND dea.date = vac.date



#Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

FROM `my-data-project0224.PortfolioProject.CovidDeaths` dea

JOIN `my-data-project0224.PortfolioProject.CovidVaccinations` vac

ON dea.location = vac.location
AND dea.date = vac.date

WHERE dea.continent is not null 

ORDER BY dea.location, dea.date



# Going to an advanced function and partitioning it by location and date to sum up the number of vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated


FROM `my-data-project0224.PortfolioProject.CovidDeaths` dea

JOIN `my-data-project0224.PortfolioProject.CovidVaccinations` vac

ON dea.location = vac.location
AND dea.date = vac.date

WHERE dea.continent is not null 

ORDER BY dea.location, dea.date



# USE CTE

With PopvsVac 
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM `my-data-project0224.PortfolioProject.CovidDeaths` dea

JOIN `my-data-project0224.PortfolioProject.CovidVaccinations` vac

ON dea.location = vac.location
AND dea.date = vac.date

WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



# Temp Table

CREATE TABLE PopuVac 
(
    continent nvaarchar,
    location nvarchar,
    date datetime,
    population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric,
)

INSERT INTO PopuVac 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM `my-data-project0224.PortfolioProject.CovidDeaths` dea

JOIN `my-data-project0224.PortfolioProject.CovidVaccinations` vac

ON dea.location = vac.location
AND dea.date = vac.date

WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopuVac



#Temp table with other way


With PercentPopulationVaccinated 
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM `my-data-project0224.PortfolioProject.CovidDeaths` dea

JOIN `my-data-project0224.PortfolioProject.CovidVaccinations` vac

ON dea.location = vac.location
AND dea.date = vac.date

WHERE dea.continent is not null 

)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated





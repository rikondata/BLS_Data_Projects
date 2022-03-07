--DATA FROM COVID DEATH TABLE
 select *
 from Covid19..CovidDeaths$



SELECT *
From Covid19..CovidDeaths$
ORDER BY 3,4 ;

SELECT *
From Covid19..CovidDeaths$
where continent is not null
ORDER BY 3,4 ;




--SELECT * 
--From  Covid19..CovidVaccinations$
--ORDER BY 3,4 ;


 --Select Data we will be using 

 Select location,date,total_cases,new_cases,total_deaths,population
 From  Covid19..CovidDeaths$
 where continent is not null
 ORDER BY 1,2 ;


 -- Total Casses Vs Total Deaths

 Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
 From  Covid19..CovidDeaths$
 where continent is not null
 ORDER BY 1,2 ;



 -- Check specific county Covid deaths

 Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
 From  Covid19..CovidDeaths$
 WHERE location LIKE 'united kingdom%'
 and continent is not null
 ORDER BY 1,2 ;




 --Total Cases Vs Population ( Percentage of population that has died from covid )


 Select location,date, Population,total_cases,(total_cases/population)*100 as Percent_Population_Infected
 From  Covid19..CovidDeaths$
 WHERE location LIKE 'united kingdom%'
 and continent is not null
 ORDER BY 1,2 ;


 -- Countries with highest infection rates compared to population


 Select location, Population, MAX(total_cases) as Highest_Infection_Count, MAX(total_cases/population)*100 as Percent_Population_Infected
 From  Covid19..CovidDeaths$
 --WHERE location LIKE 'united kingdom%'
where continent is not null
 GROUP BY location, Population
 --ORDER BY 1,2 ;
 ORDER BY Percent_Population_Infected DESC


 -- Countries with Highest Death Count Per Population

 
 Select location, MAX(cast(Total_Deaths as int)) as Total_Death_Count
 From  Covid19..CovidDeaths$
 --WHERE location LIKE 'united kingdom%'
where continent is not null
 GROUP BY location
 --ORDER BY 1,2 ;
 ORDER BY Total_Death_Count DESC



 -- BREAKING DATA DOWN BY CONTINENT 

 --Show continent with highest death count per population
 
 Select continent, MAX(cast(Total_Deaths as int)) as Total_Death_Count
 From  Covid19..CovidDeaths$
 --WHERE location LIKE 'united kingdom%'
where continent is not null
 GROUP BY continent
 --ORDER BY 1,2 ;
 ORDER BY Total_Death_Count DESC


-- Show continent with highest death count per population

-- Select location, MAX(cast(Total_Deaths as int)) as Total_Death_Count
-- From  Covid19..CovidDeaths$
-- --WHERE location LIKE 'united kingdom%'
--where continent is  null
-- GROUP BY location
-- --ORDER BY 1,2 ;
-- ORDER BY Total_Death_Count DESC


 -- CHECK GLOBAL NUMBERS

 Select SUM(new_cases)as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths,SUM(cast(new_deaths as INT))/SUM(New_cases)*100 as Death_Percentage
 From  Covid19..CovidDeaths$
 --WHERE location LIKE 'united kingdom%'
 WHERE continent is not null
 ORDER BY 1,2 ;


 -- DATA FROM VACCINATION TABLE 
 
 select *
 from Covid19..CovidVaccinations$

 --JOINING DATA FROM TABLES  - show total ppulation vs vaccination


 
SELECT *
   
FROM
     Covid19..CovidDeaths$ cd
	 JOIN Covid19..CovidVaccinations$ cv
		ON cd.location = cv.location
		and cd.date =cv.date

--ORDER BY
    --product_name DESC;


	-- CHECK TOTAL VACCINATION PER POPULATION

SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
from Covid19..CovidDeaths$ cd
join Covid19..CovidVaccinations$ cv
	on cd.location = cv.location
	and cd.date =cv.date
 WHERE cd.continent is not null

 ORDER BY 1,2,3 ;  -- odedering startes with africa


 SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
from Covid19..CovidDeaths$ cd
join Covid19..CovidVaccinations$ cv
	on cd.location = cv.location
	and cd.date =cv.date
 WHERE cd.continent is not null

 ORDER BY 2,3 ;  -- ordering starts with Afganistan


SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.Date) 
from Covid19..CovidDeaths$ cd
join Covid19..CovidVaccinations$ cv
	on cd.location = cv.location
	and cd.date =cv.date
 WHERE cd.continent is not null

 ORDER BY 2,3 ;  -- ordering starts with Afganistan


 -- USE CTE  

 With Popvscv(Continent,Location,Date,Population,new_vaccinations,Rolling_People_Vaccinated)

 as
(
 SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.Date) as Rolling_People_Vaccinated
from Covid19..CovidDeaths$ cd
join Covid19..CovidVaccinations$ cv
	on cd.location = cv.location
	and cd.date =cv.date
 WHERE cd.continent is not null

 --ORDER BY 2,3  
)
select *
from Popvscv


-- EACH TIME YOU RUN SCRIPT U GET NEW CONTINENT AS RECORD 1



 With Popvscv(Continent,Location,Date,Population,new_vaccinations,Rolling_People_Vaccinated)

 as
(
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.Date) as Rolling_People_Vaccinated
from Covid19..CovidDeaths$ cd
join Covid19..CovidVaccinations$ cv
	on cd.location = cv.location
	and cd.date =cv.date
 WHERE cd.continent is not null

 --ORDER BY 2,3  
)
select *,(Rolling_People_Vaccinated/Population)*100 as Perecentage_Rolling_Number_Vaccinated
from Popvscv

--Continent,Location,Date,Population,new_vaccinations,Rolling_People_Vaccinated)

-- USING TEMP TABLE--

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #Percent_Populated_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric

)

INSERT INTO #Percent_Populated_Vaccinated
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.Date) as Rolling_People_Vaccinated
from Covid19..CovidDeaths$ cd
join Covid19..CovidVaccinations$ cv
	on cd.location = cv.location
	and cd.date =cv.date
 WHERE cd.continent is not null

 Select *, (Rolling_People_Vaccinated/Population)*100 as Perecentage_Rolling_Number_Vaccinated

From #Percent_Populated_Vaccinated


--select *,(Rolling_People_Vaccinated/Population)*100 as Perecentage_Rolling_Number_Vaccinated
--from #Percent_Populated_Vaccinated


--DROP TABLE #Percent_Populated_Vaccinated


-- Creating View to store data for later visualizations


Create View Percent_Population_Vaccinated as
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,cd.Date) as Rolling_People_Vaccinated
from Covid19..CovidDeaths$ cd
join Covid19..CovidVaccinations$ cv
	on cd.location = cv.location
	and cd.date =cv.date
 WHERE cd.continent is not null


 -- CREATE MORE VIEWS AND USE IN VISUALIZATION

 -- YOU CAN PUT YUR VIEWS INA TEMP WORK TABLE OR VIEW FOR EASY ACCESS

 -- cONNECT TABLEAU AND POWER BI TO VIEW

 -- 
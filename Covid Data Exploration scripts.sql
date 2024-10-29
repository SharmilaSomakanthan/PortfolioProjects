select * from coviddeaths where continent is null


select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2

--Shows Deathpercentage (Total cases vs total deaths)
select location, date, total_cases, total_deaths,
case when total_cases>0 then (total_deaths/total_cases)*100
end DeathPercentage
from coviddeaths
where location = 'India'
and continent is not null
order by 1,2



--Total cases vs population

select location, date, population, total_cases, (total_cases/population)*100 as percentpopulationinfected
from coviddeaths
where location = 'India'
and continent is not null
order by 1,2

--Showing countries with highest infection rate per population

select location, population, max(total_cases) as Highestinfectioncount, max(total_cases/population)*100 as percentpopulationinfected
from coviddeaths
where continent is not null
group by location, population
order by percentpopulationinfected desc


--Showing countries with highest death rate per population

select location, population, max(total_deaths) as Highestdeathcount
from coviddeaths
where continent is not null
group by location, population
order by Highestdeathcount desc


--Showing continents with highest death rate
select continent, max(total_deaths) as Highestdeathcount
from coviddeaths
where continent is not null
group by continent
order by Highestdeathcount desc

-- Global numbers

select date, sum(new_cases) as totalnewcasesperday, sum(new_deaths) as totalnewdeathsperday,
case when sum(new_cases)>0 then sum(new_deaths)/sum(new_cases::numeric)*100 end Deathpercentageperday
from coviddeaths
where continent is not null
group by date
order by date


--Totalcoviddeathrate

select sum(new_cases) as Totalcases, sum(new_deaths) as Totaldeaths,
sum(new_deaths)/sum(new_cases::numeric)*100 as TotalDeathpercent
from coviddeaths
where continent is not null


--JOINING Coviddeaths and Covidvaccinations

select *
from coviddeaths D
join covidvaccinations V
on D.location = V.location
and D.date = V.date

--Getting population vs new vaccinations
select D.location, D.date, population, new_vaccinations,
sum(new_vaccinations) over (partition by D.location) as totalvaccinationsperlocation
from coviddeaths D
join covidvaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not null
order by 1,2


--Using CTE
with popvsvac (location, date, population, new_vaccinations, rollingcountperlocation)
as(
select D.location, D.date, population, new_vaccinations,
sum(new_vaccinations) over (partition by D.location order by D.location,D.date) as rollingcountperlocation
from coviddeaths D
join covidvaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not null
order by 1,2
)
select *,(rollingcountperlocation/population)*100 as rollcountpercent from popvsvac

--Using TEMP table

create temporary table percentpopulationvaccinated
(
	location varchar,
	date date,
	population bigint,
	new_vaccinations bigint,
	rollingcountperlocation numeric
);

Insert into percentpopulationvaccinated (
select D.location, D.date, population, new_vaccinations,
sum(new_vaccinations) over (partition by D.location order by D.location,D.date) as rollingcountperlocation
from coviddeaths D
join covidvaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not null
order by 1,2
);

select *,(rollingcountperlocation/population)*100 as rollcountpercent from percentpopulationvaccinated;


--Using View
create view percentpopulationvaccinated_v
as(
select D.location, D.date, population, new_vaccinations,
sum(new_vaccinations) over (partition by D.location order by D.location,D.date) as rollingcountperlocation
from coviddeaths D
join covidvaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not null
order by 1,2
);

select *,(rollingcountperlocation/population)*100 as rollcountpercent from percentpopulationvaccinated_v;

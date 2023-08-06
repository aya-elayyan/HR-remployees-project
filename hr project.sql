create database HRproject;
use HRproject;

-- (FIRST) lets do some cleaning and pre-processing

-- 1) lets change the name of our table and the first column
set sql_safe_updates=0;
alter table `human resources` rename hr;
select * from hr;
alter table hr 
change column ï»¿id emp_id varchar(20);

-- 2) lets check if there is any duplicates
select emp_id, count(*)
from hr 
group by emp_id
having count(*) > 1; -- so we dont have any duplicates

-- 3) lets fix birthdate and hiredate columns format
select birthdate from hr;
select str_to_date(birthdate,"%m/%d/%Y"), str_to_date(birthdate,"%m-%d-%Y") from hr;

select birthdate,  case when birthdate like "%/%" then
 date_format(str_to_date(birthdate,"%m/%d/%Y"), "%Y-%m-%d") 
 when birthdate like "%-%" then 
  date_format(str_to_date(birthdate,"%m-%d-%Y"), "%Y-%m-%d")
  else null
  end as bd
  from hr;
  
  
  update hr 
  set birthdate = case when birthdate like "%/%" then
 date_format(str_to_date(birthdate,"%m/%d/%Y"), "%Y-%m-%d") 
 when birthdate like "%-%" then 
  date_format(str_to_date(birthdate,"%m-%d-%Y"), "%Y-%m-%d")
  else null
  end; 
   alter table hr
  modify column birthdate date;
  
   update hr 
  set hire_date = case when hire_date like "%/%" then
 date_format(str_to_date(hire_date,"%m/%d/%Y"), "%Y-%m-%d") 
 when hire_date like "%-%" then 
  date_format(str_to_date(hire_date,"%m-%d-%Y"), "%Y-%m-%d")
  else null
  end; 
   alter table hr
  modify column hire_date date;
  
  -- 4) lets fix termdate column formate
  select termdate from hr;
  update hr 
  set termdate= date(str_to_date(termdate,"%Y-%m-%d %H:%i:%s UTC"))
  where termdate is not null and termdate !="";
  
  update hr 
  set termdate= case when termdate in (null,"") 
  then "0000-00-00" else date(termdate) end;

SET sql_mode = 'ALLOW_INVALID_DATES';
  update hr 
  set termdate= case when termdate ="0000-00-00" then str_to_date(termdate,"%Y-%m-%d")
  else date(termdate) end;
 alter table hr 
  modify column termdate date;

-- 6) lets add column that tells the age of employees
alter table hr 
add column age int;

update hr 
set age= timestampdiff(year,birthdate,curdate());

	
delete from hr where age<18;

-- 7) lets add column that tells the age of employees:
select max(age), min(age) from hr;

select age, case when age>= 20 and age<=30 then"20-30"
when age >30 and age <= 40 then "31-40"
when age >40 and age<= 50 then "41-50"
when age >50 and age <= 60 then "51-60"
else null
end age_groups
from hr;

alter table hr 
add column age_groups text;

update hr 
set age_groups= case when age>= 20 and age<=30 then"20-30"
when age >30 and age <= 40 then "31-40"
when age >40 and age<= 50 then "41-50"
when age >50 and age <= 60 then "51-60"
else null
end;

-- 8) lets add column that tells the length of employment for those who got terminated:
alter table hr add column length_of_term int;
update hr 
set length_of_term= case when termdate!="0000-00-00" and termdate<=curdate()
then timestampdiff(year,hire_date,termdate) else null end;

-- (SECOND) lets analyze the data, therefor we are going to answer these questions:

-- 1) what is the gender breakdown of employees in the company?
select gender, count(*)
from hr 
where termdate ='0000-00-00'
group by gender;

-- 2) what is the race/ethnicity breakdown of employees in the company?
select race, count(*)
from hr 
where termdate ='0000-00-00'
group by race;

-- 3) what is age distribution of employees in the company?
select age_groups, count(*)
from hr
where termdate="0000-00-00"
group by age_groups;

-- 4) how many employees work at headquarters vs remote locations?
select location,count(*) from hr
where termdate= "0000-00-00"
group by location;

-- 5) regarding age groups how many employees in each gender?
select age_groups,gender,count(*)
from hr
where termdate="0000-00-00"
group by age_groups, gender;

-- 6) what is the avg. length of employment for employees who have terminated?
select avg(length_of_term) from hr;

-- 7) how does the gender distribution vary across departments and job titles?
select department, gender, count(*)
from hr 
where termdate='0000-00-00'
group by department, gender;

select jobtitle, gender, count(*)
from hr 
where termdate='0000-00-00'
group by jobtitle, gender;

-- 8) how many employees in every job title?
select jobtitle, count(*)
from hr 
where termdate='0000-00-00'
group by jobtitle;

-- 9) which department has the most turnover rate?
select department, count(length_of_term)/count(*) rate
from hr
group by department
order by rate desc
limit 1 ;

-- 10) what is the distribution of employees across locations by city?
select location_city, count(*) from hr
where termdate='0000-00-00'
group by location_city;

-- 11) what is the percentage of termination for every year?
select year(hire_date), (round(count(length_of_term)/count(*),2)*100) percentage
from hr 
group by year(hire_date);

-- 12) what is the percentage of employment for every year?
select year(hire_date), 100-(round(count(length_of_term)/count(*),2)*100) percentage
from hr 
group by year(hire_date);

select * from hr;
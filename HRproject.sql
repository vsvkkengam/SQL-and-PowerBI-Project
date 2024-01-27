#create database hr_data;

use hr_data;

#Renaming table
RENAME TABLE `human resources` TO hr;

select *
from hr;

#Renaming column
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

#Cheching the data formates
DESCRIBE hr;

SELECT birthdate FROM hr;

SET sql_safe_updates = 0;

#changing date formate of birthdate
UPDATE hr
SET birthdate = CASE
   WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
   WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
   ELSE NULL
END;

ALTER TABLE hr 
MODIFY COLUMN birthdate DATE;
   
UPDATE hr

#changing date formate of hire_date
SET hire_date = CASE
   WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
   WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
   ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

select hire_date from hr;

#changing date formate of termination date

UPDATE hr 
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC')) 
WHERE termdate IS NOT NULL  AND termdate!= '';


UPDATE hr
SET TERMDATE = IF(TERMDATE = '0000-00-00' OR TERMDATE IS NULL, NULL, STR_TO_DATE(TERMDATE, '%Y-%m-%d'));


ALTER TABLE hr 
MODIFY COLUMN termdate DATE;

#adding age column 
ALTER TABLE hr
ADD COLUMN age INT;

#calculating age
UPDATE hr
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());

SELECT 
  min(age) AS yougest,
  max(age) AS oldest
FROM hr;

SELECT count(*)
FROM hr
where age < 18;

select * from hr;

-- Questions
-- 1. what is the gender breakdown in the company?
SELECT gender, count(*) as count
FROM hr
WHERE age >= 18 AND termdate is null
GROUP BY gender;

-- 2. what is the race/ethnic breakdown in the company?
SELECT race, count(*) as count
FROM hr
WHERE age >= 18 AND termdate is null
GROUP BY race
ORDER BY count(*) DESC;

-- 3. what is the age distribution of the employees in the company?
SELECT age, count(*) as count
FROM hr
WHERE age >= 18 AND termdate is null
GROUP BY age
order by count(*) desc;

SELECT MIN(age) as youngest,
MAX(age) as oldest
FROM hr
WHERE age >= 18 and termdate is null;

SELECT 
  CASE
  WHEN age >= 18 AND age <= 24 THEN '18-24'
  WHEN age >= 25 AND age <= 34 THEN '25-34' 
  WHEN age >= 35 AND age <= 44 THEN '35-44'
  WHEN age >= 45 AND age <= 54 THEN '45-54'
  WHEN age >= 55 AND age <= 64 THEN '55-64'
  ELSE '65+'
  END AS  age_group, count(*) as count
FROM hr
WHERE age >= 18 AND termdate is null
GROUP BY age_group
ORDER BY age_group ASC;


SELECT 
  CASE
  WHEN age >= 18 AND age <= 24 THEN '18-24'
  WHEN age >= 25 AND age <= 34 THEN '25-34' 
  WHEN age >= 35 AND age <= 44 THEN '35-44'
  WHEN age >= 45 AND age <= 54 THEN '45-54'
  WHEN age >= 55 AND age <= 64 THEN '55-64'
  ELSE '65+'
  END AS  age_group, gender, count(*) as count
FROM hr
WHERE age >= 18 AND termdate is null
GROUP BY age_group, gender
ORDER BY age_group, gender ASC;

-- 4.  How many employees work at remote location vs office location?
select distinct(location)
from hr;

SELECT location, COUNT(emp_id) as count
FROM hr
WHERE age >= 18 AND termdate is null
GROUP BY location
ORDER BY count ASC;

-- 5. what is the average lenght of employment for employees for who have been terminated?
select *
from hr;

SELECT 
  ROUND(AVG(datediff(termdate, hire_date))/365,0) as avg_length_of_emplyoment
FROM hr
WHERE termdate <= curdate() AND termdate is not null AND age >= 18;

-- 6. How gender distribution vary across departments and job titles?

SELECT 
department, gender, count(*) as count
FROM hr
WHERE age >= 18 AND termdate is null
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of job titles accorss the company?
SELECT jobtitle, count(*) as count
FROM hr
WHERE age >= 18 AND termdate is null
GROUP BY jobtitle
ORDER BY jobtitle;

-- 8. Which department has the highest turnover rate?

SELECT
department, total_count, termination_count, round(termination_count/total_count,2) as termination_rate

FROM (
SELECT
  department, 
  count(*) AS total_count,
  SUM(CASE WHEN termdate is not null AND termdate <= curdate() THEN 1 ELSE 0 END) as termination_count
  FROM hr
  WHERE age >= 18 AND termdate is not null
  group by department ) AS subquery

ORDER BY termination_rate desc;

-- 9. What is the distribution of employees acorss city and state?

select *
from hr;
SELECT location_city, location_state, count(*) as count
FROM hr
WHERE age >= 18 AND termdate is null
GROUP BY location_city, location_state
order by count desc;

-- 10. How was the company's employee count changed over time based on hire and term dates?

SELECT 
year, 
hires, 
terminations,
(hires - terminations) as net_change,
round(((hires - terminations)/hires * 100),2) as change_percentage
FROM (
     SELECT
     YEAR(hire_date) as year,
     count(*) as hires,
     SUM( CASE WHEN termdate <= curdate() and termdate is not null THEN 1 ELSE 0 END) AS terminations
     FROM hr
     WHERE age >= 18
     GROUP BY YEAR(hire_date)
     ) AS subquery
ORDER BY year DESC;
     









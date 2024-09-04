USE parks_and_recreation;
SELECT * 
FROM employee_demographics;

SELECT * 
FROM employee_salary;

SELECT * 
FROM parks_departments;

# #####################################  GROUP BY/ALIASING/HAVING
SELECT occupation, AVG(salary) as avg_salary
FROM employee_salary
WHERE occupation LIKE '%manager%'
GROUP BY occupation
HAVING avg_salary>70000;

# ######################################  INNER JOIN/JOIN
SELECT *
FROM employee_demographics as d
JOIN employee_salary as s
	ON d.employee_id=s.employee_id;
    
# ##################################### LEFT JOIN
SELECT *
FROM employee_demographics as d
LEFT JOIN employee_salary as s
	ON d.employee_id=s.employee_id;
    
    
# RIGHT JOIN
SELECT *
FROM employee_demographics as d
RIGHT JOIN employee_salary as s
	ON d.employee_id=s.employee_id;
    
    
#multiple table join

SELECT dep.employee_id,dep.first_name,dep.last_name,dep.age,dep.gender,
		sal.occupation,sal.salary,sal.dept_id,
        p.department_name
FROM employee_demographics AS dep 
	JOIN employee_salary AS sal
		ON dep.employee_id = sal.employee_id
	JOIN parks_departments AS p
		ON sal.dept_id = p.department_id;
    
# UNION
SELECT first_name,last_name,'Old Lady' Label
	FROM employee_demographics 
    WHERE age>40 AND gender='female'
UNION 
SELECT first_name,last_name,'Old Man' Label
	FROM employee_demographics 
    WHERE age>40 AND gender='male'
UNION 
SELECT first_name,last_name,'Highly paid' Label
	FROM employee_salary 
    WHERE salary>70000
ORDER BY first_name;

-- -------------------------------string function
SELECT first_name,LENGTH(first_name) AS 'f_name_length', SUBSTRING(birth_date,6,2) AS birth_month
	FROM employee_demographics 
    ORDER BY 2;
    
SELECT first_name,last_name,
	CONCAT(first_name,' ',last_name) AS full_name
	FROM employee_demographics ;
    
-- -------------------------case statement
SELECT first_name,last_name, age,
CASE 
	WHEN age<=30 THEN 'Young' 
    WHEN age BETWEEN 31 and 50 THEN 'Old' 
END AS age_label
FROM employee_demographics;

SELECT first_name,last_name,occupation,salary,
CASE
	WHEN salary<50000 THEN salary+(0.05*salary)
    WHEN salary>50000 THEN salary+(0.07*salary)
END AS new_salary,
CASE
	WHEN dept_id=6 THEN salary+(0.1*salary)
END AS bonus
FROM employee_salary;


-- ---------------SUB QUERIES-----------------------------
SELECT employee_id, first_name, last_name
FROM employee_demographics
WHERE employee_id IN 
				(SELECT employee_id 
                FROM employee_salary
                WHERE dept_id=1);
                
SELECT gender,AVG(age),MIN(age),Max(age)
	FROM employee_demographics
	GROUP BY gender;
    
SELECT AVG(min_age),AVG(max_age)
FROM (SELECT gender,AVG(age) AS avg_age, MIN(age) as min_age,Max(age) as max_age
	FROM employee_demographics
	GROUP BY gender) AS agg_table;
    
-- ---------------------------USING WINDOW FUNCTION ---
SELECT gender, AVG(salary) 
FROM employee_demographics AS dem
JOIN employee_salary AS sal
ON dem.employee_id=sal.employee_id
GROUP BY gender;

# but by using window function we can make independent avg salary on basis of gender 
SELECT dem.first_name, dem.last_name,gender, AVG(salary) OVER(PARTITION BY gender) as avg_salary_by_gender
FROM employee_demographics AS dem
JOIN employee_salary AS sal
ON dem.employee_id=sal.employee_id;

# roling total : it is like cumulative frequency
SELECT dem.first_name, dem.last_name,gender, SUM(salary) OVER(PARTITION BY gender ORDER BY dem.employee_id) as rolling_total
FROM employee_demographics AS dem
JOIN employee_salary AS sal
ON dem.employee_id=sal.employee_id;


-- WINDOW FUNCTION: using row_number,rank,dense_rank
SELECT dem.first_name, dem.last_name,gender,salary,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary DESC) AS row_num,
RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS rank_num,
Dense_Rank() OVER(PARTITION BY gender ORDER BY salary DESC) AS rank_num
FROM employee_demographics AS dem
JOIN employee_salary AS sal
ON dem.employee_id=sal.employee_id;

-- ------------------------  CTE 
-- A Common Table Expression (CTE) is like a named subquery. 
-- It functions as a virtual table that only its main query can access. 
-- CTEs can help simplify, shorten, and organize your code.
-- used because it perform advanced calculation and also for readablility

WITH  CTE_EXAMPLE AS
(SELECT gender, AVG(salary) avg_sal ,MIN(salary) min_sal,MAX(salary) max_sal,COUNT(salary) count_sal
FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id=sal.employee_id
GROUP BY gender)
SELECT AVG(avg_sal) avg_sal_by_gender
FROM CTE_EXAMPLE;

-- Multiple CTE
WITH  CTE_EXAMPLE AS
	(SELECT employee_id,first_name,last_name,birth_date
	FROM employee_demographics
    WHERE birth_date>1985-01-01),
	CTE_EXAMPLE2 AS
	(SELECT employee_id, salary
	FROM employee_salary
    WHERE salary>50000)
SELECT * 
FROM CTE_EXAMPLE 
JOIN CTE_EXAMPLE2 
ON CTE_EXAMPLE.employee_id=CTE_EXAMPLE2.employee_id;
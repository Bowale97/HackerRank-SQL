-- Question on 'The Pad'
SELECT CONCAT(name, '(', substring(occupation, 1, 1), ')') AS names
FROM occupations
ORDER BY name;

SELECT CONCAT('There are a total of ', COUNT(occupation), ' ', LOWER(occupation), 's.')
FROM occupations
GROUP BY occupation
ORDER BY COUNT(occupation);




-- Question on 'Occupation'
WITH main_table AS (
    SELECT * 
    FROM occupations
    ORDER BY name
), doctor AS (
    SELECT ROW_NUMBER() OVER () id, name
    FROM main_table
    WHERE occupation LIKE 'Doctor'
), professor AS (
    SELECT ROW_NUMBER() OVER () id, name
    FROM main_table
    WHERE occupation LIKE 'Professor'
), singer AS (
    SELECT ROW_NUMBER() OVER () id, name
    FROM main_table
    WHERE occupation LIKE 'Singer'
), actor AS (
    SELECT ROW_NUMBER() OVER () id, name
    FROM main_table
    WHERE occupation LIKE 'Actor'
)

-- Select cluase when Null should be in string
/*
SELECT CASE WHEN (d.name IS Null) THEN 'Null' ELSE d.name END Doctor,
     p.name Professor, 
     CASE WHEN (s.name IS Null) THEN 'Null' ELSE s.name END Singer,
     CASE WHEN (a.name IS Null) THEN 'Null' ELSE a.name END Actor
*/
-- Select cluase when it should be Null
SELECT d.name Doctor, p.name Professor, s.name Singer, a.name Actor
FROM professor p
LEFT JOIN doctor d
ON p.id = d.id
LEFT JOIN singer s
ON p.id = s.id
LEFT JOIN actor a
ON p.id = a.id;





-- Question on Binary Tree Node
SELECT n, CASE WHEN (p IS Null) THEN 'Root' 
               WHEN (n IN (SELECT DISTINCT p FROM BST)) THEN 'Inner' 
               ELSE 'Leaf' 
               END type
FROM BST
ORDER BY n;





-- Question on 'SQL Project Planning'
-- Approach 1
SELECT Start_Date, MIN(End_Date) 
FROM (
    SELECT Start_Date FROM Projects WHERE Start_Date NOT IN (SELECT End_Date FROM Projects)
) AS s,
(
    SELECT End_Date FROM Projects WHERE End_Date NOT IN (SELECT Start_Date FROM Projects)
) AS e
WHERE Start_Date < End_Date
GROUP BY Start_Date
ORDER BY DATEDIFF(MIN(End_Date), Start_Date), Start_Date;

-- Approach 2
Select Start_Date, MIN(End_Date)
From (
    Select b.Start_Date
    From Projects as a
    RIGHT Join Projects as b
    ON b.Start_Date = a.End_Date
    WHERE a.Start_Date IS NULL
    ) sd,
    (Select a.End_Date
    From Projects as a
    Left Join Projects as b
    ON b.Start_Date = a.End_Date
    WHERE b.End_Date IS NULL
    ) ed
Where Start_Date < End_Date
GROUP BY Start_Date
ORDER BY datediff(MIN(End_Date), Start_Date), Start_Date



-- Medium - New Companies
SELECT c.company_code, c.founder, COUNT(DISTINCT e.lead_manager_code) total_lm,
    COUNT(DISTINCT e.senior_manager_code) total_sm,
    COUNT(DISTINCT e.manager_code) total_m,
    COUNT(DISTINCT e.employee_code) total_emp
FROM Employee e
JOIN Company c
ON c.company_code = e.company_code
GROUP BY 1, 2
ORDER BY 1;



-- Medium - 
SELECT CASE WHEN ((A + B) <= C) OR ((B + C) <= A) OR ((A + C) <= B) THEN 'Not A Triangle'
            WHEN (A = B) AND (B = C)  THEN 'Equilateral'
            WHEN (A = B) OR (B = C) OR (A = C) THEN 'Isosceles'
            ELSE 'Scalene' END AS Types
FROM triangles;


-- https://www.hackerrank.com/challenges/weather-observation-station-18/problem
SELECT ROUND((MAX(lat_n) - MIN(lat_n)) + (MAX(long_w) - MIN(long_w)), 4) s
FROM station;


SELECT ROUND(SQRT(POWER((MAX(lat_n) - MIN(lat_n)), 2) + POWER((MAX(long_w) - MIN(long_w)), 2)), 4) s
FROM station;


SELECT CEILING(AVG(salary) - AVG(CAST(REPLACE(CONCAT(salary, ''), '0', '') AS SIGNED)))
FROM employees;
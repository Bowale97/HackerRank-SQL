SELECT * 
FROM geeksforgeeks;

SELECT CourseName, PROGRAMMING, INTERVIEWPREPARATION
FROM geeksforgeeks 
PIVOT ( 
	SUM(Price) 
	FOR CourseCategory IN (PROGRAMMING, INTERVIEWPREPARATION ) 
) AS PivotTable;





WITH main_table AS (
	SELECT s.name sales_rep, r.name region
	FROM sales_reps s
	JOIN region r
	ON s.region_id = r.id
	ORDER BY 1
), northeast AS (
	SELECT ROW_NUMBER() OVER () id, sales_rep
    FROM main_table
    WHERE region LIKE 'Northeast'
), midwest AS (
	SELECT ROW_NUMBER() OVER () id, sales_rep
    FROM main_table
    WHERE region LIKE 'Midwest'
), southeast AS (
	SELECT ROW_NUMBER() OVER () id, sales_rep
    FROM main_table
    WHERE region LIKE 'Southeast'
), west AS (
	SELECT ROW_NUMBER() OVER () id, sales_rep
    FROM main_table
    WHERE region LIKE 'West'
)

SELECT n.sales_rep Northeast,
 	CASE WHEN (m.sales_rep IS Null) THEN 'Null' ELSE m.sales_rep END MidWest, 
 	CASE WHEN (s.sales_rep IS Null) THEN 'Null' ELSE s.sales_rep END Southeast,
 	CASE WHEN (w.sales_rep IS Null) THEN 'Null' ELSE w.sales_rep END West
FROM northeast n
LEFT JOIN midwest m
ON n.id = m.id
LEFT JOIN southeast s
ON n.id = s.id
LEFT JOIN west w
ON n.id = w.id;



-- CREATING PERSISTENT DERIVED TABLE
BEGIN;

CREATE TABLE test_table AS (
	SELECT n.sales_rep Northeast,
		m.sales_rep MidWest, 
		s.sales_rep Southeast,
		w.sales_rep West
	FROM (
		SELECT ROW_NUMBER() OVER () id, sales_rep
		FROM (
			SELECT s.name sales_rep, r.name region
			FROM sales_reps s
			JOIN region r
			ON s.region_id = r.id
			ORDER BY 1
		) sub
		WHERE region LIKE 'Northeast'
	) n
	LEFT JOIN (
		SELECT ROW_NUMBER() OVER () id, sales_rep
		FROM (
			SELECT s.name sales_rep, r.name region
			FROM sales_reps s
			JOIN region r
			ON s.region_id = r.id
			ORDER BY 1
		) sub
		WHERE region LIKE 'Midwest'
	) m
	ON n.id = m.id
	LEFT JOIN (
		SELECT ROW_NUMBER() OVER () id, sales_rep
		FROM (
			SELECT s.name sales_rep, r.name region
			FROM sales_reps s
			JOIN region r
			ON s.region_id = r.id
			ORDER BY 1
		) sub
		WHERE region LIKE 'Southeast'
	) s
	ON n.id = s.id
	LEFT JOIN (
		SELECT ROW_NUMBER() OVER () id, sales_rep
		FROM (
			SELECT s.name sales_rep, r.name region
			FROM sales_reps s
			JOIN region r
			ON s.region_id = r.id
			ORDER BY 1
		) sub
		WHERE region LIKE 'West'
	) w
	ON n.id = w.id
);

COMMIT;




SELECT *
FROM profile
WHERE email LIKE '%_@__%.__%'; 



SELECT DISTINCT r.name region, s.name sales_rep, SUM(o.total_amt_usd) sum_total
	FROM sales_reps s
	JOIN region r
	ON s.region_id = r.id
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id = a.id
	GROUP BY 1, 2
	ORDER BY 3 DESC
	LIMIT 4


SELECT DISTINCT region, sales_rep, sum_total
FROM (
	SELECT r.name region, s.name sales_rep, SUM(o.total_amt_usd) sum_total
	FROM sales_reps s
	JOIN region r
	ON s.region_id = r.id
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id = a.id
	GROUP BY 1, 2
	ORDER BY 3 DESC
) sub1;



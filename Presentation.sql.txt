/*
    SQL Basics
        - How to get data from tables
        - Select statements 
        - FROM clause
        - WHERE clause
                Common symbols used in WHERE statements include:
            > (greater than)
            < (less than)
            >= (greater than or equal to)
            <= (less than or equal to)
            = (equal to)
            != (not equal to)
        - LIKE operator
        - IN operator
        - NOT LIKE
        - NOT IN
        - AND / BETWEEN
        - OR 
*/


/*
    SQL JOINs
        - A way of combining two tables information
        - JOIN ON clause
        - Multiple filters with JOIN clause
            JOIN region r
            ON r.id = s.region_id
            AND r.name = 'Midwest'
            AND s.name LIKE '% K%'


        -- SELECT DISTINCT
*/



/*
    SQL AGREGATIONS
        - Performing an operation on multiple rows in the table
        - AGREGATION FUNCTIONS
        -   SUM
        -   MIN
        -   MAX
        -   AVG
        -   COUNT
        - GROUP BY clause (A way of segmenting data based on columns provided)

        - WORKING WITH DATES
        -   DATE_TRUNC()
        -   DATE_PART()

        - CASE WHEN
*/



/*
    SQL SUB_QUERIES AND TEMP TABLES
        - WITH AS table () - FOR TEMP TABLES
*/




/* 
    SQL DATA_CLEANING
        - LEFT()
        - RIGHT()
        - LENGTH()
        - POSITION()
        - STRPOS()
        - SUBSTRING() | SUBSTR()
        - REPLACE()
        - LOWER()
        - UPPER()
        - CONCAT()
        - CAST()
        - COLASCE()
*/




/* 
    SQL WINDOWS FUNCTION
        - OVER: is the main clause for the windows function
        - PARTITION BY: tells how the data is to be partitioned or grouped, if not specified, it treates all the rows as belonging to one group
        - ORDER BY: This orders the table by the specified column and also performs the specified aggregation function on all the data above a 
                specific row. If not specified, then it performs the aggregation function for the whole rows in the partition.
        - ROW_NUMBER()
        - RANK()
        - DENSE_RANK()

        - LAG() AND LEAD() - USEFUL FOR ROW COMPARISION
        - NTILE()

        - -- A valid windows function syntax.
        --   You can specify the windows required by aliasing. Goes between the WHERE clause and the GROUP BY clause.
        --   You can only use windows function in SELECT clause and ORDER BY clause and no where else.
        
            SELECT account_id, COUNT(account_id) OVER w
            FROM orders
            WINDOW w AS (PARTITION BY account_id ORDER BY id),
                w2 AS (PARTITION BY account_id)
            ORDER BY COUNT(account_id) OVER w DESC, 1
*/




/* 
    SQL ADVANCED JOINS AND PERFORMANCE TUNING
        - FULL JOIN
        - LEFT JOIN
        - RIGHT JOIN
        - CROSS JOIN

        - WEBSITE WITH DIAGRAM OF JOIN

        - UNION () - NO DUPLICATES IN BOTH TABLES
        - UNION ALL() - STACKS EVERYTHING

        - PERFOMANCE TUNING 
        -   PERFORM AGREGATION BEFORE JOINING
        -   LIMIT YOUR DATA WHEN TESTING, THEN BRING IN EVERYTHING AFTERWARDS 
*/

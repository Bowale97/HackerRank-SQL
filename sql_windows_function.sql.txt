/* So far we have seen the OVER, PARTITION BY and ORDER BY functions
    OVER: is the main clause for the windows function
    PARTITION BY: tells how the data is to be partitioned or grouped, if not specified, it treates all the rows as belonging to one group
    ORDER BY: This orders the table by the specified column and also performs the specified aggregation function on all the data above a 
            specific row. If not specified, then it performs the aggregation function for the whole rows in the partition.
*/


-- EXAMPLE 1 (Note the RANK() function used to rank row values)
SELECT id, standard_qty, RANK() OVER (ORDER BY standard_qty DESC) windows
FROM orders
LIMIT 20;

SELECT standard_amt_usd, DATE_TRUNC('month', occurred_at), 
    SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('month', occurred_at) ORDER BY occurred_at) windows
FROM orders
LIMIT 500;

-- QUESTION 1. Using Derek's previous video as an example, create another running total. This time, create a running total of standard_amt_usd
--  (in the orders table) over order time with no date truncation. Your final table should have two columns: one with the amount being added
--  for each new row, and a second with the running total.
SELECT standard_amt_usd, SUM(standard_amt_usd) OVER (ORDER BY occurred_at) running_total
FROM orders
LIMIT 500;

-- QUESTION 2. Now, modify your query from the previous quiz to include partitions. Still create a running total of standard_amt_usd (in the
--  orders table) over order time, but this time, date truncate occurred_at by year and partition by that same year-truncated occurred_at
--  variable. Your final table should have three columns: One with the amount being added for each row, one for the truncated date, and a
--  final column with the running total within each year.
SELECT standard_amt_usd, DATE_TRUNC('year', occurred_at), 
    SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at) running_total
FROM orders;

/* Ranking Total Paper Ordered by Account
  Select the id, account_id, and total variable from the orders table, then create a column called total_rank that ranks this total amount of
  paper ordered (from highest to lowest) for each account using a partition. Your final table should have these four columns.
*/
SELECT id, account_id, total, RANK() OVER (PARTITION BY account_id ORDER BY total DESC)total_rank
FROM orders;


-- AGGREGATION WITH WINDOWS FUNCTION
SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS max_std_qty
FROM orders;

-- COMPARE

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id) AS max_std_qty
FROM orders;

-- OBSERVATION: With the omission of the ORDER BY clause, the result of the windows function is calculated across all rows within the 
-- PARTITION window.

/*
Aggregates in Window Functions with and without ORDER BY
The ORDER BY clause is one of two clauses integral to window functions. The ORDER and PARTITION define what is referred to as the
“window”—the ordered subset of data over which calculations are made. Removing ORDER BY just leaves an unordered partition; in our query's
case, each column's value is simply an aggregation (e.g., sum, count, average, minimum, or maximum) of all the standard_qty values in its
respective account_id.

As Stack Overflow user mathguy explains:

The easiest way to think about this - leaving the ORDER BY out is equivalent to "ordering" in a way that all rows in the partition are
"equal" to each other. Indeed, you can get the same effect by explicitly adding the ORDER BY clause like this: ORDER BY 0 (or "order by"
any constant expression), or even, more emphatically, ORDER BY NULL.
*/


-- SHORTENING WINDOWS FUNCTION WITH ALIASING
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER account_year_window AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at));



-- LAG AND LEAD FUNCTIONS
-- USEFUL FOR ROW COMPARISON
SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM (
    SELECT account_id,
        SUM(standard_qty) AS standard_sum
    FROM orders 
    GROUP BY 1
 ) sub;

 /* In the previous video, Derek outlines how to compare a row to a previous or subsequent row. This technique can be useful when analyzing
 time-based events. Imagine you're an analyst at Parch & Posey and you want to determine how the current order's total revenue ("total"
 meaning from sales of all types of paper) compares to the next order's total revenue.

 Modify Derek's query from the previous video in the SQL Explorer below to perform this analysis. You'll need to use occurred_at and
 total_amt_usd in the orders table along with LEAD to do so. In your query results, there should be four columns: occurred_at, total_amt_usd,
lead, and lead_difference.
*/
SELECT occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) - total_amt_usd AS lead_difference
FROM (
    SELECT occurred_at,
        SUM(total_amt_usd) AS total_amt_usd
    FROM orders 
    GROUP BY 1
) sub;


-- ON PERCENTILE USING THE NTILE FUNCTION
-- QUESTION 1. Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty for their orders.
--  Your resulting table should have the account_id, the occurred_at time for each order, the total amount of standard_qty paper purchased,
--  and one of four levels in a standard_quartile column.
SELECT account_id, occurred_at, standard_qty,
     NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
FROM orders;

-- QUESTION 2. Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders.
--  Your resulting table should have the account_id, the occurred_at time for each order, the total amount of gloss_qty paper purchased,
--  and one of two levels in a gloss_half column.
SELECT account_id, occurred_at, gloss_qty,
     NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS gloss_half
FROM orders;

-- QUESTION 3. Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of total_amt_usd
--  for their orders. Your resulting table should have the account_id, the occurred_at time for each order, the total amount of total_amt_usd
--  paper purchased, and one of 100 levels in a total_percentile column.
SELECT account_id, occurred_at, total_amt_usd,
     NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
FROM orders
ORDER BY 1 DESC;


-- There is another important concept associated with window functions: for each row, there is a set of rows within its partition called
--  its window frame. Many (but not all) window functions act only on the rows of the window frame, rather than of the whole partition. 
--  By default, if ORDER BY is supplied then the frame consists of all rows from the start of the partition up through the current row, 
--  plus any following rows that are equal to the current row according to the ORDER BY clause. When ORDER BY is omitted the default frame 
--  consists of all rows in the partition. [1] Here is an example using sum:

-- A valid windows function syntax.
--   You can specify the windows required by aliasing. Goes between the WHERE clause and the GROUP BY clause.
--   You can only use windows function in SELECT clause and ORDER BY clause and no where else.
SELECT account_id, COUNT(account_id) OVER w
FROM orders
WINDOW w AS (PARTITION BY account_id ORDER BY id),
	w2 AS (PARTITION BY account_id)
ORDER BY COUNT(account_id) OVER w DESC, 1



-- SOME WINDOWS FUNCTION
-- 1. ROW_NUMBER()
    -- This numbers the rows in the table and works with the arguement specified in the ORDER BY of the windows function.
    -- More than one arguement can be stated in the ORDER BY clause of the windows function.

-- 2. RANK()
    -- Ranks rows in a table according to what is stated in the ORDER BY clause of the windows function.
    -- Skips a couple of count when two or more rows have the same value in the ORDER BY clause columns. This skips is to make
    -- up for the rows with same values

-- 3. DENSE_RANK()
    -- Like rank() but with no skipping

-- 4. LAG(column)
    -- It returns the value from a previous row to the current row in the table.

-- 5. LEAD(column)
    -- Return the value from the row following the current row in the table.

SELECT *, 
	LAG(sum_total) OVER w lag_sum_total, 
	LEAD(sum_total) OVER w lead_sum_total,
	ABS(LEAD(sum_total) OVER w - LAG(sum_total) OVER w) row_diff
FROM (
	SELECT account_id, sum(total) sum_total
	FROM orders
	GROUP BY 1
) sub
WINDOW w AS (ORDER BY account_id);

-- Test run of LAG() and LEAD(). Also absolute value function ABS().

-- NTILE(number of buckets)
    -- It is used to specify with percentile the row falls in by.
SELECT account_id, occurred_at, total_amt_usd,
    NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
FROM orders
ORDER BY 1 DESC;


-- 1. Find the total amount of poster_qty paper ordered in the orders table.
SELECT SUM(poster_qty) total
FROM orders;

-- 2. Find the total amount of standard_qty paper ordered in the orders table.
SELECT SUM(standard_qty) total
FROM orders;

-- 3. Find the total dollar amount of sales using the total_amt_usd in the orders table.
SELECT SUM(total_amt_usd) total
FROM orders;

-- 4. Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order in the orders table. 
-- This should give a dollar amount for each order in the table.
SELECT standard_amt_usd + gloss_amt_usd total_standard_gloss 
FROM orders;

-- 5. Find the standard_amt_usd per unit of standard_qty paper. Your solution should use both an aggregation and a mathematical operator.
SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_price_per_unit
FROM orders;


-- MIN MAX AVG AND MEDIAN

-- 1. When was the earliest order ever placed? You only need to return the date.
SELECT MIN(occurred_at) earliest_order_date
FROM orders;

-- 2. Try performing the same query as in question 1 without using an aggregation function.
SELECT occurred_at earliest_order_date
FROM orders
ORDER BY occurred_at
LIMIT 1;

-- 3. When did the most recent (latest) web_event occur?
SELECT MAX(occurred_at) latest_web_event_date
FROM web_events;

-- 4. Try to perform the result of the previous query without using an aggregation function.
SELECT occurred_at latest_web_event_date
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

-- 5. Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount of each paper type purchased per order.
--  Your final answer should have 6 values - one for each paper type for the average number of sales, as well as the average amount.
SELECT AVG(standard_amt_usd) avg_standard_amt,
	   AVG(gloss_amt_usd) avg_gloss_amt,
       AVG(poster_amt_usd) avg_poster_amt,
       AVG(standard_qty) avg_standard,
       AVG(gloss_qty) avg_gloss,
       AVG(poster_qty) avg_poster
FROM orders;

-- 6. Via the video, you might be interested in how to calculate the MEDIAN. Though this is more advanced than what we have covered so far 
--  try finding - what is the MEDIAN total_usd spent on all orders?
SELECT AVG(total_amt_usd) median_value
FROM (
	SELECT *
    FROM (
        SELECT total_amt_usd
        FROM orders
        ORDER BY total_amt_usd
        LIMIT 3457	
    ) AS Table2
    ORDER BY total_amt_usd DESC
    LIMIT 2	
) AS Table3;

/*                                              GROUP BY 
GROUP BY can be used to aggregate data within subsets of the data. For example, grouping for different accounts, different regions, 
or different sales representatives.


Any column in the SELECT statement that is not within an aggregator must be in the GROUP BY clause.


The GROUP BY always goes between WHERE and ORDER BY.


ORDER BY works like SORT in spreadsheet software.

GROUP BY - Expert Tip
Before we dive deeper into aggregations using GROUP BY statements, it is worth noting that SQL evaluates the aggregations before the 
LIMIT clause. If you don’t group by any columns, you’ll get a 1-row result—no problem there. If you group by a column with enough unique 
values that it exceeds the LIMIT number, the aggregates will be calculated, and then some rows will simply be omitted from the results.

This is actually a nice way to do things because you know you’re going to get the correct aggregates. If SQL cuts the table down to 100 rows,
 then performed the aggregations, your results would be substantially different. The above query’s results exceed 100 rows, so it’s a perfect 
 example. In the next concept, use the SQL environment to try removing the LIMIT and running it again to see what changes.
*/

-- 1. Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.
-- Agregation solution
SELECT a.name account_name,  MIN(o.occurred_at) date
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
ORDER BY date 
LIMIT 1;
-- No agregation solution - BEST FOR ME
SELECT a.name account_name, o.occurred_at order_date
FROM orders o
JOIN accounts a
ON o.account_id = a.id
ORDER BY order_date 
LIMIT 1;

-- 2. Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and 
--  the company name.
SELECT a.name account_name, SUM(o.total_amt_usd) total_sales_usd
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name;

-- 3. Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? Your query should return 
--  only three values - the date, channel, and account name.
-- No agregation solution - BEST FOR ME
SELECT a.name account_name, w.channel channel, w.occurred_at event_date
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
ORDER BY event_date DESC
LIMIT 1;
-- Agregation solution
SELECT a.name account_name, w.channel channel, MAX(w.occurred_at) event_date
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
GROUP BY a.name, w.channel
ORDER BY event_date DESC
LIMIT 1;

-- 4. Find the total number of times each type of channel from the web_events was used. Your final table should have two columns - 
--  the channel and the number of times the channel was used.
SELECT channel, COUNT(channel) number_of_times_used
FROM web_events
GROUP BY channel;

-- 5. Who was the primary contact associated with the earliest web_event?
SELECT a.primary_poc
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at
LIMIT 1;

-- 6. What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name 
--  and the total usd. Order from smallest dollar amounts to largest.
SELECT a.name account, MIN(o.total_amt_usd) total_usd
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name
ORDER BY total_usd;

-- 7. Find the number of sales reps in each region. Your final table should have two columns - the region and the number 
--  of sales_reps. Order from fewest reps to most reps.
SELECT r.name region, COUNT(s.region_id) number_of_reps
FROM sales_reps s
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
ORDER BY number_of_reps;


--              GROUP BY II
-- 1. For each account, determine the average amount of each type of paper they purchased across their orders. Your result should have 
--  four columns - one for the account name and one for the average quantity purchased for each of the paper types for each account.
SELECT a.name, AVG(o.standard_qty) avg_standard, AVG(o.gloss_qty) avg_gloss, AVG(o.poster_qty) avg_poster
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name;

-- 2. For each account, determine the average amount spent per order on each paper type. Your result should have four columns - one for the
--  account name and one for the average amount spent on each paper type.
SELECT a.name, AVG(o.standard_amt_usd) avg_standard, AVG(o.gloss_amt_usd) avg_gloss, AVG(o.poster_amt_usd) avg_poster
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name;

-- 3. Determine the number of times a particular channel was used in the web_events table for each sales rep. Your final table should have 
--  three columns - the name of the sales rep, the channel, and the number of occurrences. Order your table with the highest number of 
--  occurrences first.
SELECT s.name, w.channel, COUNT(w.channel) channel_count -- or COUNT(*)
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name, w.channel
ORDER BY s.name, channel_count DESC;

-- 4. Determine the number of times a particular channel was used in the web_events table for each region. Your final table should have three 
--  columns - the region name, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.
SELECT r.name, w.channel, COUNT(w.channel) channel_count -- or COUNT(*)
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY r.name, channel_count DESC;


--              SELECT DISTINCE
-- 1. Use DISTINCT to test if there are any accounts associated with more than one region.
SELECT DISTINCT a.name account, r.name region
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
ORDER BY account;
-- NO

-- 2. Have any sales reps worked on more than one account?
SELECT DISTINCT s.name rep, a.name account
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
ORDER BY rep;
-- YES

-- SOLUTION IN CLASS ALSO GREAT (LESSON 2 - Agregation(21. Solution DISTINCT))

--          HAVING 
-- 1. How many of the sales reps have more than 5 accounts that they manage?
SELECT COUNT(*)
FROM (
	SELECT s.name, COUNT(*) number_of_account
    FROM sales_reps s
    JOIN accounts a
    ON a.sales_rep_id = s.id
    GROUP BY s.name
    HAVING COUNT(*) > 5
) AS Table1;

-- 2. How many accounts have more than 20 orders?
SELECT COUNT(*)
FROM (
	SELECT a.name, COUNT(*) number_of_orders
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    GROUP BY a.name
    HAVING COUNT(*) > 20
) AS Table1;

-- 3. Which account has the most orders?
SELECT * -- Not nescessary
FROM (
	SELECT a.name, COUNT(*) number_of_orders
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    GROUP BY a.name
    HAVING COUNT(*) > 20
) AS Table1
ORDER BY number_of_orders DESC
LIMIT 1;

-- Basically
SELECT a.name, COUNT(*) number_of_orders
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name
HAVING COUNT(*) > 20
ORDER BY number_of_orders DESC
LIMIT 1;

-- 4. Which accounts spent more than 30,000 usd total across all orders?
SELECT a.name account, SUM(o.total_amt_usd) total_spent -- RIGHT
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY SUM(o.total_amt_usd) DESC;

SELECT a.name, o.total_amt_usd -- WRONG
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE o.total_amt_usd > 30000;

-- 5. Which accounts spent less than 1,000 usd total across all orders?
SELECT a.name account, SUM(o.total_amt_usd) total_spent -- RIGHT
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY SUM(o.total_amt_usd);

SELECT a.name, o.total_amt_usd -- WRONG
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE o.total_amt_usd < 1000;

-- 6. Which account has spent the most with us?
SELECT a.name account, SUM(o.total_amt_usd) total_spent -- RIGHT
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY SUM(o.total_amt_usd) DESC
LIMIT 1;

SELECT a.name, o.total_amt_usd -- WRONG
FROM orders o
JOIN accounts a
ON a.id = o.account_id
ORDER BY o.total_amt_usd DESC
LIMIT 1;

-- 7. Which account has spent the least with us?
SELECT a.name account, SUM(o.total_amt_usd) total_spent -- RIGHT
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY SUM(o.total_amt_usd)
LIMIT 1;

SELECT a.name, o.total_amt_usd
FROM orders o
JOIN accounts a
ON a.id = o.account_id
ORDER BY o.total_amt_usd
LIMIT 1; -- Produced zero

SELECT a.name, o.total_amt_usd -- One with an actual ammount spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE o.total_amt_usd > 0
ORDER BY o.total_amt_usd
LIMIT 1;

-- 8. Which accounts used facebook as a channel to contact customers more than 6 times?
SELECT a.name, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.name, w.channel
HAVING w.channel = 'facebook' AND COUNT(*) > 6;

-- 9. Which account used facebook most as a channel?
SELECT a.name, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.name, w.channel
HAVING w.channel = 'facebook'
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 10. Which channel was most frequently used by most accounts?
SELECT w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY w.channel
ORDER BY COUNT(*) DESC
LIMIT 1;
-- CHECK CLASS SOLUTION AS WELL


--                      WORKING WITH DATES

-- So using the DATE_PART(date, 'dow') actually gives the day of the week so we can know if an event happened on Sunday or Monday
-- from the events timestamp, amazing.

-- 1. Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. 
--  Do you notice any trends in the yearly sales totals?
SELECT DATE_TRUNC('year', occurred_at) sales_year, SUM(total_amt_usd) total_dollars
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
-- A trend noticed was that the sales where increase with time, probably in the 1st quater of the year 2017 hence the small sales 
SELECT DATE_TRUNC('year', occurred_at) AS sales_year, MIN(occurred_at) date_of_first_transaction, MAX(occurred_at) date_of_last_transaction, SUM(total_amt_usd) total_sales_usd
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
-- Shows better information on the second part of the question

-- 2. Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly represented by the dataset?
-- A part
SELECT DATE_PART('month', occurred_at) sales_month, SUM(total_amt_usd) total_sales_usd
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
-- B part (Seems to be evenly distributed)
SELECT DATE_TRUNC('month', occurred_at) sales_month, SUM(total_amt_usd) total_sales_usd
FROM orders
WHERE DATE_PART('month', DATE_TRUNC('month', occurred_at)) = 1
GROUP BY 1
ORDER BY 2 DESC;
-- From the video, because of uneven data in the year 2013 and 2017, we remove the both of them
SELECT DATE_PART('month', occurred_at) ord_month, SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC; 

-- 3. Which year did Parch & Posey have the greatest sales in terms of total number of orders? Are all years evenly represented by the dataset?
SELECT DATE_TRUNC('year', occurred_at) sales_year, SUM(total) total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
-- For the second part  of the question, it looks so to me. But lets for understand what it means to be evenly represented
-- Again, 2016 by far has the most amount of orders, but again 2013 and 2017 are not evenly represented to the other years in the dataset.

-- 4. Which month did Parch & Posey have the greatest sales in terms of total number of orders? Are all months evenly represented by the dataset?
SELECT DATE_PART('month', occurred_at) sales_month, SUM(total) total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
--  To make a fair comparison from one month to another 2017 and 2013 data were removed.
SELECT DATE_PART('month', occurred_at) ord_month, COUNT(*) total_sales
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC; 

-- 5. In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
SELECT DATE_TRUNC('month', o.occurred_at) sales_month, SUM(o.gloss_amt_usd) total_sales
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC;


--              CASE
-- 1. Write a query to display for each order, the account ID, total amount of the order, and the level of the order - ‘Large’ or ’Small’ - depending
--  on if the order is $3000 or more, or smaller than $3000.
SELECT account_id, total_amt_usd, 
		CASE WHEN total_amt_usd > 3000 THEN 'Large'
            ELSE 'Small' END AS order_level
FROM orders;

-- 2. Write a query to display the number of orders in each of three categories, based on the total number of items in each order. The three categories 
--  are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'
SELECT CASE WHEN total >= 2000 THEN 'Atleast 2000'
			WHEN total < 2000 AND total >= 1000 THEN 'Between 2000 and 1000'
            ELSE 'Less than 1000' END AS order_category, 
    COUNT(*) number_of_orders
FROM orders
GROUP BY 1;

-- 3. We would like to understand 3 different levels of customers based on the amount associated with their purchases. The top level includes
--  anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. The second level is between 200,000 and 100,000 usd.
--  The lowest level is anyone under 100,000 usd. Provide a table that includes the level associated with each account. You should provide
--  the account name, the total sales of all orders for the customer, and the level. Order with the top spending customers listed first.
SELECT a.name account, SUM(o.total_amt_usd) total_sales, 
	CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'top'
		WHEN SUM(o.total_amt_usd) > 100000 THEN 'middle'
        ELSE 'low' END AS order_level
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC;

-- 4. We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent by customers only in 2016
--  and 2017. Keep the same levels as in the previous question. Order with the top spending customers listed first.
SELECT DATE_PART('year', occurred_at) sales_year, a.name account, SUM(o.total_amt_usd) total_sales, 
	CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'top'
		WHEN SUM(o.total_amt_usd) > 100000 THEN 'middle'
        ELSE 'low' END AS order_level
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE DATE_PART('year', occurred_at) IN (2016, 2017)
GROUP BY 1, 2
ORDER BY 3 DESC;
-- LESSON SOLUTION
SELECT a.name, SUM(total_amt_usd) total_spent, 
     CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
     WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
     ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at > '2015-12-31' 
GROUP BY 1
ORDER BY 2 DESC;

-- 5. We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders. Create a table with
--  the sales rep name, the total number of orders, and a column with top or not depending on if they have more than 200 orders. Place the
--  top sales people first in your final table.
SELECT s.name rep, COUNT(*) number_of_orders, 
	CASE WHEN COUNT(*) > 200 THEN 'top'
        ELSE 'not' END AS performance
FROM orders o
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY 1
ORDER BY 2 DESC;

-- 6. The previous didn't account for the middle, nor the dollar amount associated with the sales. Management decides they want to see these
--  characteristics represented as well. We would like to identify top performing sales reps, which are sales reps associated with more than
--  200 orders or more than 750000 in total sales. The middle group has any rep with more than 150 orders or 500000 in sales. Create a table
--  with the sales rep name, the total number of orders, total sales across all orders, and a column with top, middle, or low depending on
--  this criteria. Place the top sales people based on dollar amount of sales first in your final table. You might see a few upset sales
--  people by this criteria!
SELECT s.name rep, COUNT(*) number_of_orders, SUM(o.total_amt_usd) total_sales,
	CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
    	WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
        ELSE 'low' END AS performance
FROM orders o
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY 1
ORDER BY 3 DESC;



-- THERE IS A FUNCTION COUNT(DISTINCT column)


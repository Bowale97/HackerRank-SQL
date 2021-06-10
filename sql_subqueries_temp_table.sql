-- QUIZE 1
SELECT channel, AVG(number_of_events)
FROM (
  SELECT DATE_TRUNC('day', occurred_at) event_day, channel, COUNT(*) number_of_events
  FROM web_events
  GROUP BY 1, 2
) AS sub1
GROUP BY 1
ORDER BY 2 DESC;

-- QUIZE 2
SELECT AVG(standard_qty) standard_avg, AVG(gloss_qty) gloss_avg, AVG(poster_qty) poster_avg, SUM(total_amt_usd) total_spent
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = (
    SELECT DATE_TRUNC('month', MIN(occurred_at)) min_date
    FROM orders
);

-- QUIZE 3
-- 1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales
SELECT s.name rep, r.name region, o.total_amt_usd -- MISTAKE
FROM sales_reps s
JOIN region r
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
WHERE o.total_amt_usd IN (
  	SELECT MAX(total_amt_usd)
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    JOIN sales_reps s
    ON s.id = a.sales_rep_id
    JOIN region r
    ON r.id = s.region_id
    GROUP BY r.name
)
ORDER BY 3 DESC;

SELECT * -- MAIN
FROM (
	SELECT r.name region, s.name rep, a.sales_rep_id rep_id, SUM(o.total_amt_usd) total_sum
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    JOIN sales_reps s
    ON s.id = a.sales_rep_id
    JOIN region r
    ON r.id = s.region_id
    GROUP BY 1, 2, 3
) sub0
WHERE total_sum IN (
	SELECT MAX(total_sum) 
    FROM (
        SELECT r.name region, s.name rep, a.sales_rep_id rep_id, SUM(o.total_amt_usd) total_sum
        FROM orders o
        JOIN accounts a
        ON a.id = o.account_id
        JOIN sales_reps s
        ON s.id = a.sales_rep_id
        JOIN region r
        ON r.id = s.region_id
        GROUP BY 1, 2, 3
    ) sub
    GROUP BY region
)
ORDER BY total_sum DESC;

SELECT t3.rep_name, t3.region_name, t3.total_amt -- FROM LESSON
FROM(SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;


-- 2. For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?
SELECT r.name region, COUNT (*) order_count
FROM orders o
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
WHERE r.name = (
    SELECT region
    FROM (
        SELECT r.name region, SUM(total_amt_usd)
        FROM orders o
        JOIN accounts a
        ON a.id = o.account_id
        JOIN sales_reps s
        ON s.id = a.sales_rep_id
        JOIN region r
        ON r.id = s.region_id
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 1
    ) sub
)
GROUP BY r.name;

SELECT r.name, COUNT(o.total) total_orders -- LESSON SOLUTION
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) sub);

-- 3. How many accounts had more total purchases than the account name which has bought the most standard_qty paper 
--  throughout their lifetime as a customer?
SELECT *
FROM (
    SELECT a.name account, SUM(total) total_purchase
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    GROUP BY 1
) sub1
WHERE total_purchase > (
	SELECT SUM(total) 
    FROM orders
    WHERE account_id = (
        SELECT account_id
        FROM (
            SELECT account_id, SUM(standard_qty) total_standard_purchased
            FROM orders
            GROUP BY 1
            ORDER BY 2 DESC
            LIMIT 1	
        ) sub1
    )
);

SELECT COUNT(*) -- LESSON SOLUTION
FROM (SELECT a.name
       FROM orders o
       JOIN accounts a
       ON a.id = o.account_id
       GROUP BY 1
       HAVING SUM(o.total) > (SELECT total 
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) inner_tab)
             ) counter_tab;

-- 4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they
--  have for each channel?
SELECT a.name account, w.channel, COUNT(*)
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
WHERE account_id = (
  	SELECT account_id
  	FROM (
      	SELECT account_id, SUM(total_amt_usd) total_spent
        FROM orders 
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 1
    ) AS sub1
)
GROUP BY 1, 2
ORDER BY 3 DESC;

SELECT a.name, w.channel, COUNT(*) -- LESSON SOLUTION
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                     FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                           FROM orders o
                           JOIN accounts a
                           ON a.id = o.account_id
                           GROUP BY a.id, a.name
                           ORDER BY 3 DESC
                           LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
SELECT a.name, o.account_id, AVG(o.total_amt_usd) -- MISTAKE
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE o.account_id IN (
	SELECT account_id
  	FROM (
    	SELECT account_id, SUM(total_amt_usd) total_spend
        FROM orders 
        GROUP BY account_id
        ORDER BY 2 DESC
        LIMIT 10
    ) AS sub
)
GROUP BY 1, 2
ORDER BY 2 DESC;

SELECT AVG(total_spend) -- MAIN
FROM (
    SELECT account_id, SUM(total_amt_usd) total_spend
    FROM orders 
    GROUP BY account_id
    ORDER BY 2 DESC
    LIMIT 10
) sub;

SELECT AVG(tot_spent) -- LESSON SOLUTION
FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
       LIMIT 10) temp;

-- 6. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more 
--  per order, on average, than the average of all orders.
SELECT account_id, AVG(total_amt_usd) -- MISTAKE
FROM orders
WHERE account_id IN (
	SELECT account_id
    FROM (
        SELECT account_id, total_amt_usd/3 avg_spending_per_order
        FROM orders
    ) AS sub
    WHERE avg_spending_per_order > (
        SELECT AVG(total_amt_usd) avg_all_orders
        FROM orders
    )
)
GROUP BY 1
ORDER BY 2 DESC;

SELECT AVG(total_amt_usd) lifetime_avg -- KINDA SEEMS MY AVERAGE MIGHT BE MORE ACCURATE THAN HIS (NOT SAME RESULT WITH LESSON)
FROM orders
WHERE account_id IN (
	SELECT account_id
    FROM (
        SELECT account_id, AVG(total_amt_usd)
        FROM orders
        GROUP BY 1
        HAVING AVG(total_amt_usd) > (
            SELECT AVG(total_amt_usd) gen_average
            FROM orders
        )
    ) sub
);

SELECT AVG(total_amt_usd) -- KINDA SEEMS MY AVERAGE MIGHT BE MORE ACCURATE THAN HIS (NOT SAME RESULT WITH LESSON)
FROM orders
WHERE account_id IN (
	SELECT account_id
    FROM (
        SELECT account_id, AVG(total_amt_usd) avg_spending_per_order
        FROM orders
        GROUP BY 1
    ) AS sub
    WHERE avg_spending_per_order > (
        SELECT AVG(total_amt_usd) avg_all_orders
        FROM orders
    )
);

SELECT AVG(top_acc_avg) lifetime_avg -- SAME AS LESSON AVERAGE
FROM (
  	SELECT account_id, AVG(total_amt_usd) top_acc_avg
    FROM orders
    GROUP BY 1
    HAVING AVG(total_amt_usd) > (
        SELECT AVG(total_amt_usd) gen_average
        FROM orders
    )
) sub;

SELECT AVG(avg_amt)
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                                   FROM orders o)) temp_table;


-- THE WITH STATEMENT
-- The WITH statement is often called a Common Table Expression or CTE
-- 1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
WITH table1 AS (
	SELECT s.name rep, r.name region, SUM(o.total_amt_usd) total_sales
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    JOIN sales_reps s
    ON s.id = a.sales_rep_id
    JOIN region r
    ON r.id = s.region_id
    GROUP BY 1, 2
),
table2 AS (
	SELECT region, MAX(total_sales) max_sales
    FROM table1
    GROUP BY 1
)

SELECT t1.rep, t1.region, t2.max_sales 
FROM table1 t1
JOIN table2 t2
ON t1.region = t2.region AND t1.total_sales = t2.max_sales
ORDER BY 3 DESC;

-- 2. For the region with the largest sales total_amt_usd, how many total orders were placed?
WITH table1 AS (
	SELECT r.name region, SUM(o.total_amt_usd) total_sales
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    JOIN sales_reps s
    ON s.id = a.sales_rep_id
    JOIN region r
    ON r.id = s.region_id
    GROUP BY 1
  	ORDER BY 2 DESC
),
table2 AS (
	SELECT region
    FROM table1
    LIMIT 1
)

SELECT t2.region, COUNT(*)
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id
JOIN table2 t2
ON t2.region = r.name
GROUP BY 1;

-- 3. How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their
--  lifetime as a customer?
WITH table1 AS ( -- Okay solution
    SELECT a.id account_id, a.name account, SUM(o.total) total_purchase
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    GROUP BY 1, 2
), table2 AS(
    SELECT account_id, SUM(standard_qty) total, SUM(total) total_purchase
    FROM orders
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 1
)
SELECT *
FROM table1
WHERE total_purchase > (
	SELECT t1.total_purchase
    FROM table1 t1
    JOIN table2 t2
    ON t1.account_id = t2.account_id
);

WITH table1 AS ( -- Better solution
    SELECT account_id, SUM(standard_qty) total, SUM(total) total_purchase
    FROM orders
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 1
), table2 AS(
  	SELECT a.id account_id, a.name account, SUM(o.total) total_purchase
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    GROUP BY 1, 2
    HAVING SUM(o.total) > (SELECT total_purchase FROM table1)
)
SELECT *
FROM table2

WITH t1 AS ( -- LESSON 
  SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1), 
t2 AS (
  SELECT a.name
  FROM orders o
  JOIN accounts a
  ON a.id = o.account_id
  GROUP BY 1
  HAVING SUM(o.total) > (SELECT total FROM t1))
SELECT COUNT(*)
FROM t2;


-- 4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have
--  for each channel?
WITH t1 AS (
    SELECT account_id, SUM(total_amt_usd) total_spent
    FROM orders 
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 1
)   
SELECT a.name, w.channel, COUNT(*) total_web_event
FROM web_events w
JOIN t1 
ON t1.account_id = w.account_id
JOIN accounts a
ON a.id = w.account_id
GROUP BY 1, 2
ORDER BY 2 DESC;

WITH t1 AS ( -- LESSON SOLUTION
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.id, a.name
   ORDER BY 3 DESC
   LIMIT 1)
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;


-- 5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
WITH t1 AS ( -- MISUNDERSTANDING (Was looking for the average amount spent per order instead of the average amount spent all of the)
    SELECT account_id, SUM(total_amt_usd) total_spent
    FROM orders 
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 10
)
SELECT AVG(total_amt_usd)
FROM orders 
WHERE account_id IN (SELECT account_id FROM t1);

WITH t1 AS ( -- RIGHT ANSWER
    SELECT account_id, SUM(total_amt_usd) total_spent
    FROM orders 
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 10
)
SELECT AVG(total_spent)
FROM t1;

WITH t1 AS ( -- lesson
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.id, a.name
   ORDER BY 3 DESC
   LIMIT 10)
SELECT AVG(tot_spent)
FROM t1;

-- 6. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order,
--  on average, than the average of all orders.
WITH t1 AS (
    SELECT account_id
    FROM orders
    GROUP BY 1
    HAVING AVG(total_amt_usd) > (SELECT AVG(total_amt_usd) FROM orders)
), t2 AS (
    SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
    FROM orders o
    JOIN t1 
    ON t1.account_id = o.account_id
    GROUP BY 1
    ORDER BY 2 DESC
)
SELECT AVG(avg_amt)
FROM t2;


WITH t1 AS ( -- LESSON
   SELECT AVG(o.total_amt_usd) avg_all
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id),
t2 AS (
   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
   FROM orders o
   GROUP BY 1
   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;
/*
            A QUICK NOTE TO SELF

    So basically behind the scene, performs an O(n^2) time and space complexity operation when it picks one row in the first table and compares
    it with every row in the second table and returns the row if the two match. (Note what is compared is the column specified in the on clause)

    This is the reason why trying the join on self will produce a table that is N^2 of it's original size if no inequalities or filtering
    is done on the data.

    {It is possible though that the operation of the JOIN clause is not nescessarily be  O(n^2), but from the results I have seen, that's what
    it seems like}.
*/


/*
    Finding Matched and Unmatched Rows with FULL OUTER JOIN
You’re not likely to use FULL JOIN (which can also be written as FULL OUTER JOIN) too often, but the syntax is worth practicing anyway.
LEFT JOIN and RIGHT JOIN each return unmatched rows from one of the tables—FULL JOIN returns unmatched rows from both tables. FULL JOIN is
commonly used in conjunction with aggregations to understand the amount of overlap between two tables.

Say you're an analyst at Parch & Posey and you want to see:

* each account who has a sales rep and each sales rep that has an account (all of the columns in these returned rows will be full)
* but also each account that does not have a sales rep and each sales rep that does not have an account (some of the columns in these
  returned rows will be empty)

This type of question is rare, but FULL OUTER JOIN is perfect for it. In the following SQL Explorer, write a query with FULL OUTER JOIN to fit
the above described Parch & Posey scenario (selecting all of the columns in both of the relevant tables, accounts and sales_reps) then answer 
the subsequent multiple choice quiz.
*/
SELECT a.id accounts_id, s.id sales_reps_id
FROM accounts a
FULL OUTER JOIN sales_reps s
ON s.id = a.sales_rep_id
WHERE a.sales_rep_id IS NULL OR s.id IS NULL;

/* 
    Inequality JOINs
The query in Derek's video was pretty long. Let's now use a shorter query to showcase the power of joining with comparison operators.

Inequality operators (a.k.a. comparison operators) don't only need to be date times or numbers, they also work on strings! You'll see how 
this works by completing the following quiz, which will also reinforce the concept of joining with comparison operators.

In the following SQL Explorer, write a query that left joins the accounts table and the sales_reps tables on each sale rep's ID number 
and joins it using the < comparison operator on accounts.primary_poc and sales_reps.name, like so:

accounts.primary_poc < sales_reps.name

The query results should be a table with three columns: the account name (e.g. Johnson Controls), the primary contact name (e.g. Cammy 
Sosnowski), and the sales representative's name (e.g. Samuel Racine). Then answer the subsequent multiple choice question.
*/
SELECT a.name account, a.primary_poc, s.name sales_rep
FROM accounts a
LEFT JOIN sales_reps s
ON a.sales_rep_id = s.id AND a.primary_poc < s.name;


/*
    Self JOINs
One of the most common use cases for self JOINs is in cases where two events occurred, one after another. As you may have noticed in the 
previous video, using inequalities in conjunction with self JOINs is common.

Modify the query from the previous video, which is pre-populated in the SQL Explorer below, to perform the same interval analysis except 
for the web_events table. Also:

 * change the interval to 1 day to find those web events that occurred after, but not more than 1 day after, another web event
 * add a column for the channel variable in both instances of the table in your query
*/
SELECT w1.id AS w1_id,
       w1.account_id AS w1_account_id,
       w1.occurred_at AS w1_occurred_at,
       w1.channel AS w1_channel,
       w2.id AS w2_id,
       w2.account_id AS w2_account_id,
       w2.occurred_at AS w2_occurred_at,
       w2.channel AS w2_channel
  FROM web_events w1
 LEFT JOIN web_events w2
   ON w1.account_id = w2.account_id
  AND w2.occurred_at > w1.occurred_at
  AND w2.occurred_at <= w1.occurred_at + INTERVAL '1 days'
ORDER BY w1.account_id, w1.occurred_at;


--                                    UNION | UNION ALL
/*    Appending Data via UNION
Write a query that uses UNION ALL on two instances (and selecting all columns) of the accounts table. Then inspect the results and answer 
the subsequent quiz.
*/
SELECT *
FROM accounts 

UNION ALL

SELECT *
FROM accounts;


/* 
Nice! UNION only appends distinct values. More specifically, when you use UNION, the dataset is appended, and any rows in the appended table 
that are exactly identical to rows in the first table are dropped. If you’d like to append all the values from the second table, use UNION ALL. 
You’ll likely use UNION ALL far more often than UNION.
*/



/*      Pretreating Tables before doing a UNION
Add a WHERE clause to each of the tables that you unioned in the query above, filtering the first table where name equals Walmart and 
filtering the second table where name equals Disney. Inspect the results then answer the subsequent quiz.
*/
SELECT *
FROM accounts 
WHERE name = 'Walmart'

UNION ALL

SELECT *
FROM accounts
WHERE name = 'Disney';


/*        Performing Operations on a Combined Dataset
Perform the union in your first query (under the Appending Data via UNION header) in a common table expression and name it double_accounts. 
Then do a COUNT the number of times a name appears in the double_accounts table. If you do this correctly, your query results should have a 
count of 2 for each name.
*/
WITH double_accounts AS (
	SELECT *
    FROM accounts 

    UNION ALL

    SELECT *
    FROM accounts
)
SELECT name,
 COUNT(*) AS name_count
 FROM double_accounts 
GROUP BY 1
ORDER BY 2 DESC;



--        A LITTLE OPTIMIZED QUERY
SELECT COALESCE(orders.date, web_events.date) date, 
	orders.active_sales_rep, 
    orders.orders,
    web_events.web_visits
FROM (
    SELECT DATE_TRUNC('day', o.occurred_at) AS date,
           COUNT(a.sales_rep_id) active_sales_rep,
           COUNT(o.id) AS orders
    FROM   accounts a
    JOIN   orders o
    ON     o.account_id = a.id
    GROUP BY 1
) orders
FULL JOIN (
    SELECT DATE_TRUNC('day', we.occurred_at) AS date,
        COUNT (we.id) web_visits
    FROM   web_events we
    GROUP BY 1
) web_events
ON orders.date = web_events.date
ORDER BY date DESC;





-- NOTE ON JOINS
-- This basically joins two tables depending on the columns specified on the ON clause. So for each row in the first table, 
-- all the rows of the second column is created leading to an O(N**2) space and time complexity operation. Now filtering is now
-- done base on whether it is a LEFT JOIN, RIGHT JOIN, INNER JOIN or OUTTER JOIN or based on the inequalities in the ON clause.

--  CROSS JOIN
/*
The SQL CROSS JOIN produces a result set which is the number of rows in the first table multiplied by the number of rows in the 
second table if no WHERE clause is used along with CROSS JOIN.This kind of result is called as Cartesian Product.

If WHERE clause is used with CROSS JOIN, it functions like an INNER JOIN.

An alternative way of achieving the same result is to use column names separated by commas after SELECT and mentioning the 
table names involved, after a FROM clause.
*/
SELECT * 
FROM table1 
CROSS JOIN table2;

-- OR

SELECT * 
FROM table1, table2;

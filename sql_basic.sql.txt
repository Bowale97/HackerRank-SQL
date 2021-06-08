/* So far I have learnt the SELECT, FROM and LIMIT commands for sql. I have seen that SQL is case insensitive, but best practices 
 require that commands be written in upper case while others in lower case. 

 NB: Text data in a table in the database can be upper and lower and in this case, SQL is case sensitive.

 Best practices also require that table and columes names should be written without spaces to avoid the complexities in reading from them.

 SQL ignores spaces, but it is good to write readable code.

 Semi colon at the end of each statements, although not must in some environments but it is a best practice and allows to run multiple queries
 at once if the enviroment allows this.
 */

-- Using the limit clause. Make the pulling faster and easier for analysis instead of waiting for 100s of millions of data to pulled when 
-- you only need to see the first few rows of data
SELECT id, account_id, occurred_at 
FROM orders
LIMIT 15;

 /* Using the ORDER BY clause. This helps you order your data with respect to a certain column in ascending order by default of descending 
 when the DESC command is used. Not the order is only for the result fetched and the column in the database is not altered in anyway by 
 this. The order of the SQL statments are SELECT -> FROM -> ORDER BY (DESC) -> LIMIT 
 (The LIMIT command always comes last when present in the statement). The clause must be written in this order or the query won't run.
 */
-- 1. Write a query to return the 10 earliest orders in the orders table. Include the id, occurred_at, and total_amt_usd.
SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY occurred_at
LIMIT 10;

-- 2. Write a query to return the top 5 orders in terms of largest total_amt_usd. Include the id, account_id, and total_amt_usd.
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC
LIMIT 5;

-- 3. Write a query to return the lowest 20 orders in terms of smallest total_amt_usd. Include the id, account_id, and total_amt_usd.
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd
LIMIT 20;

/* We can also ORDER BY more than one column at a time. When we provide a list of columns in an ORDER BY command,
 the sorting occurs using the leftmost column in your list first, then the next column from the left, and so on. We still have the 
 ability to flip the way we order using DESC.
*/

-- 1. Write a query that displays the order ID, account ID, and total dollar amount for all the orders, sorted first by the account ID
--  (in ascending order), and then by the total dollar amount (in descending order).
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY account_id, total_amt_usd DESC;

-- 2. Now write a query that again displays order ID, account ID, and total dollar amount for each order, but this time sorted first by total 
-- dollar amount (in descending order), and then by account ID (in ascending order).
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC, account_id;

-- 3. Compare the results of these two queries above. How are the results different when you switch the column you sort on first?
/* In the first case, the data was sorted by the account ids in asc and then by the total dollar amount for each account, but for 
 the second case, the data was sorted by the total dollar amount and I didn't see any sort by account Id. An explanation to this
 would be that an account didn't make multiple orders at the same total dollar amount, unlike the first case where we have multiple
 orders from the same account.

 In query #1, all of the orders for each account ID are grouped together, and then within each of those groupings, the orders appear
 from the greatest order amount to the least. In query #2, since you sorted by the total dollar amount first, the orders appear from greatest
 to least regardless of which account ID they were from. Then they are sorted by account ID next. (The secondary sorting by account ID is
 difficult to see here, since only if there were two orders with equal total dollar amounts would there need to be any sorting by account ID.)
 */

 /* Using the WHERE statement, we can display subsets of tables based on conditions that must be met. You can also think of the WHERE command as filtering the data.
    This video above shows how this can be used, and in the upcoming concepts, you will learn some common operators that are useful with the WHERE' statement.
    Common symbols used in WHERE statements include:
    > (greater than)
    < (less than)
    >= (greater than or equal to)
    <= (less than or equal to)
    = (equal to)
    != (not equal to)

    The order of the statement is SELECT -> FROM -> WHERE -> ORDER BY (DESC) -> LIMIT 
*/

-- 1. Pulls the first 5 rows and all columns from the orders table that have a dollar amount of gloss_amt_usd greater than or equal to 1000.
SELECT * 
FROM orders
WHERE gloss_amt_usd >= 1000
LIMIT 5;

-- 2. Pulls the first 10 rows and all columns from the orders table that have a total_amt_usd less than 500.
SELECT * 
FROM orders
WHERE total_amt_usd < 500
LIMIT 10;

/* 
SELECT id, account_id, occurred_at, total_amt_usd
FROM orders
WHERE total_amt_usd < 500
ORDER BY occurred_at
LIMIT 10;

Sorting the data aswell*/


/* The WHERE statement can also be used with non-numeric data. We can use the = and != operators here.
 You need to be sure to use single quotes (just be careful if you have quotes in the original text) with the text data, not double quotes.

 Commonly when we are using WHERE with non-numeric data fields, we use the LIKE, NOT, or IN operators. We will see those before the end of this lesson!
*/

-- 1. Filter the accounts table to include the company name, website, and the primary point of contact (primary_poc) just for the Exxon Mobil company in the accounts table.
SELECT name, website, primary_poc
FROM accounts
WHERE name = 'Exxon Mobil';


/*Derived Columns
 Creating a new column that is a combination of existing columns is known as a derived column (or "calculated" or "computed" column).
 Usually you want to give a name, or "alias," to your new column using the AS keyword.

 This derived column, and its alias, are generally only temporary, existing just for the duration of your query. The next time you run a query
 and access this table, the new column will not be there. 
*/

-- 1. Create a column that divides the standard_amt_usd by the standard_qty to find the unit price for standard paper for each order. 
-- Limit the results to the first 10 orders, and include the id and account_id fields.
SELECT id, account_id, standard_amt_usd, standard_qty, standard_amt_usd/standard_qty AS standard_unit_price
FROM orders
LIMIT 10;


--        LOGICAL OPERATORS

-- THE LIKE OPERATOR
-- Use the accounts table to find

-- 1. All the companies whose names start with 'C'.
SELECT * 
FROM accounts
WHERE name LIKE 'C%';

-- 2. All companies whose names contain the string 'one' somewhere in the name.
SELECT * 
FROM accounts
WHERE name LIKE '%one%';

-- 3. All companies whose names end with 's'.
SELECT * 
FROM accounts
WHERE name LIKE '%s';

-- THE IN OPERATOR
-- 1. Use the accounts table to find the account name, primary_poc, and sales_rep_id for Walmart, Target, and Nordstrom.
SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart', 'Target', 'Nordstrom');

-- 2. Use the web_events table to find all information regarding individuals who were contacted via the channel of organic or adwords.
SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords');


-- THE NOT OPERATOR
-- 1. Use the accounts table to find the account name, primary poc, and sales rep id for all stores except Walmart, Target, and Nordstrom.
SELECT name, primary_poc, sales_rep_id
FROM accounts 
WHERE name NOT IN ('Walmart', 'Target', 'Nordstrom');

-- 2. Use the web_events table to find all information regarding individuals who were contacted via any method except using organic or adwords methods.
SELECT *
FROM web_events 
WHERE channel NOT IN ('organic', 'adwords');

-- Use the accounts table to find:
-- 1. All the companies whose names do not start with 'C'.
SELECT *
FROM accounts 
WHERE name NOT LIKE 'C%';

-- 2. All companies whose names do not contain the string 'one' somewhere in the name.
SELECT *
FROM accounts 
WHERE name NOT LIKE '%one%';

-- 3. All companies whose names do not end with 's'.
SELECT *
FROM accounts 
WHERE name NOT LIKE '%s';


--  THE AND/BETWEEN OPERATOR
-- 1. Write a query that returns all the orders where the standard_qty is over 1000, the poster_qty is 0, and the gloss_qty is 0.
SELECT *
FROM orders
WHERE standard_qty > 1000 AND poster_qty = 0 AND gloss_qty = 0;

-- 2. Using the accounts table, find all the companies whose names do not start with 'C' and end with 's'.
SELECT *
FROM accounts
WHERE name NOT LIKE 'C%' AND name NOT LIKE '%s';

/* 3. When you use the BETWEEN operator in SQL, do the results include the values of your endpoints, or not? 
 Figure out the answer to this important question by writing a query that displays the order date and gloss_qty data for all orders where 
 gloss_qty is between 24 and 29. Then look at your output to see if the BETWEEN operator included the begin and end values or not.
*/
SELECT occurred_at, gloss_qty
FROM orders
WHERE gloss_qty BETWEEN 24 AND 29;
-- YES IT DOES INCLUDE THE ENDPOINTS

-- 4. Use the web_events table to find all information regarding individuals who were contacted via the organic or adwords channels,
--  and started their account at any point in 2016, sorted from newest to oldest.
SELECT *
FROM web_events
-- WHERE channel IN ('organic', 'adwords') AND occurred_at >= '2016-01-01' AND occurred_at < '2017-01-01'
-- Another way could be to use the BETWEEN AND OPERATOR
WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC;
/* You will notice that using BETWEEN is tricky for dates! While BETWEEN is generally inclusive of endpoints, 
it assumes the time is at 00:00:00 (i.e. midnight) for dates. This is the reason why we set the right-side endpoint of the period at 
'2017-01-01'.
*/


--  THE OR OPERATOR
-- 1. Find list of orders ids where either gloss_qty or poster_qty is greater than 4000. Only include the id field in the resulting table.
SELECT id
FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000;

-- 2. Write a query that returns a list of orders where the standard_qty is zero and either the gloss_qty or poster_qty is over 1000.
SELECT *
FROM orders
WHERE standard_qty = 0 AND (gloss_qty > 1000 OR poster_qty > 1000);

-- 3. Find all the company names that start with a 'C' or 'W', and the primary contact contains 'ana' or 'Ana', but it doesn't contain 'eana'.
SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%') AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%') AND primary_poc NOT LIKE '%eana%');
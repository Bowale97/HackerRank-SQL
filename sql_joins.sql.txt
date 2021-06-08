/* 1. Provide a table for all web_events associated with account name of Walmart. There should be three columns.
 Be sure to include the primary_poc, time of the event, and the channel for each event. Additionally, you might choose 
 to add a fourth column to assure only Walmart events were chosen.
*/
SELECT a.name, a.primary_poc, w.occurred_at, w.channel
FROM web_events w
JOIN accounts AS a
ON w.account_id = a.id
WHERE a.name LIKE 'Walmart';
-- Note the order of all the clauses
-- Also note that the alias can be added with the AT clause as in the JOIN statement or not as in the FROM statement

/* 2. Provide a table that provides the region for each sales_rep along with their associated accounts. 
 Your final table should include three columns: the region name, the sales rep name, and the account name. 
 Sort the accounts alphabetically (A-Z) according to account name.
*/
SELECT a.name account_name, s.name sales_rep_name, r.name AS region_name
FROM sales_reps AS s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON s.id = a.sales_rep_id
ORDER BY a.name;

/* 3. Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) 
 for the order. Your final table should have 3 columns: region name, account name, and unit price. A few accounts have 0 for total,
 so I divided by (total + 0.01) to assure not dividing by zero.
*/
SELECT o.id order_id, r.name AS region_name, a.name account_name, o.total_amt_usd/(o.total + 0.01) AS unit_price
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON s.region_id = r.id;

/* 4. Provide a table that provides the region for each sales_rep along with their associated accounts. 
 This time only for the Midwest region. Your final table should include three columns: the region name, 
 the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.
*/
SELECT a.name account, s.name sales_rep, r.name region
FROM sales_reps s
JOIN region r
ON r.id = s.region_id
AND r.name = 'Midwest'
JOIN accounts a
ON s.id = a.sales_rep_id
ORDER BY a.name;

/* 5. Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for accounts 
 where the sales rep has a first name starting with S and in the Midwest region. Your final table should include three columns: 
 the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.
*/
-- CASE 1
SELECT a.name account, s.name sales_rep, r.name region
FROM sales_reps s
JOIN region r
ON r.id = s.region_id
AND r.name = 'Midwest'
AND s.name LIKE 'S%'
JOIN accounts a
ON s.id = a.sales_rep_id
ORDER BY a.name; 

-- CASS 2
SELECT a.name account, s.name sales_rep, r.name region
FROM sales_reps s
JOIN region r
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
WHERE r.name = 'Midwest' AND s.name LIKE 'S%'
ORDER BY a.name;

/* Case 1: Reduces the row before combining the tables
        Looks like it would be faster

   Case 2: This case occurs after the joins occur   
*/

/* 6. Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for accounts where 
 the sales rep has a last name starting with K and in the Midwest region. Your final table should include three columns: the region name,
 the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.
*/
SELECT a.name account, s.name sales_rep, r.name region
FROM sales_reps s
JOIN region r
ON r.id = s.region_id
AND r.name = 'Midwest'
AND s.name LIKE '% K%'
JOIN accounts a
ON s.id = a.sales_rep_id
ORDER BY a.name;

/* 7. Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total)
 for the order. However, you should only provide the results if the standard order quantity exceeds 100. Your final table should have 3
 columns: region name, account name, and unit price. In order to avoid a division by zero error, adding .01 to the denominator here is 
 helpful total_amt_usd/(total+0.01).
*/
SELECT r.name region, a.name account, o.total_amt_usd/(o.total+0.01) unit_price
FROM orders o
JOIN accounts a
ON o.account_id = a.id
AND o.standard_qty > 100
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id;

/* 8. Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) 
 for the order. However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity 
 exceeds 50. Your final table should have 3 columns: region name, account name, and unit price. Sort for the smallest unit price first. 
 In order to avoid a division by zero error, adding .01 to the denominator here is helpful (total_amt_usd/(total+0.01).
*/
SELECT r.name region, a.name account, o.total_amt_usd/(o.total+0.01) unit_price
FROM orders o
JOIN accounts a
ON o.account_id = a.id
AND o.standard_qty > 100
AND o.poster_qty > 50
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
ORDER BY unit_price;

/* 9. Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) 
 for the order. However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 
 50. Your final table should have 3 columns: region name, account name, and unit price. Sort for the largest unit price first. In order to 
 avoid a division by zero error, adding .01 to the denominator here is helpful (total_amt_usd/(total+0.01).
*/
SELECT r.name region, a.name account, o.total_amt_usd/(o.total+0.01) unit_price
FROM orders o
JOIN accounts a
ON o.account_id = a.id
AND o.standard_qty > 100
AND o.poster_qty > 50
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
ORDER BY unit_price DESC;

/* 10. What are the different channels used by account id 1001? Your final table should have only 2 columns: account name and the 
 different channels. You can try SELECT DISTINCT to narrow down the results to only the unique values.
*/
SELECT a.name account, w.channel channels
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
AND w.account_id = 1001;

-- USING SELECT DISTINCT
SELECT DISTINCT a.name, w.channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE a.id = '1001';
-- Selects only distinct values instead of all and eveything 

/* 11. Find all the orders that occurred in 2015. Your final table should have 4 columns: occurred_at, account name, order total, 
 and order total_amt_usd.
*/
SELECT o.occurred_at, a.name account, o.total, o.total_amt_usd
FROM orders o
JOIN accounts a
ON o.account_id = a.id
AND o.occurred_at BETWEEN '2015-01-01' AND '2016-01-01'
ORDER BY o.occurred_at DESC;
-- 1. n the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address
--  they are using. A list of extensions (and pricing) is provided here. Pull these extensions and provide how many of each website type
--  exist in the accounts table.
WITH t1 AS (
    SELECT name, website, RIGHT(website, 4) website_ext
    FROM accounts
)
SELECT website_ext, COUNT(*)
FROM t1
GROUP BY 1;

SELECT RIGHT(website, 3) extensions, COUNT(*) count_extension
FROM accounts
GROUP BY 1;

SELECT RIGHT(website, 3) AS domain, COUNT(*) num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

-- 2. There is much debate about how much the name (or even the first letter of a company name) matters. Use the accounts table to pull
--  the first letter of each company name to see the distribution of company names that begin with each letter (or number).
WITH t1 AS (
    SELECT name, LEFT(name, 1) first_letter 
    FROM accounts
)
SELECT first_letter, COUNT(*)
FROM t1
GROUP BY 1
ORDER BY 2 DESC;

SELECT LEFT(name, 1) AS first_letter, COUNT(*) distribution
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

SELECT LEFT(UPPER(name), 1) AS first_letter, COUNT(*) num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

-- 3. Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number and a second
--  group of those company names that start with a letter. What proportion of company names start with a letter?
WITH t1 AS (
 	SELECT name, CASE WHEN (LEFT(name, 1) BETWEEN 'A' AND 'Z') OR (LEFT(name, 1) BETWEEN 'a' AND 'z') THEN 'Letter'
        WHEN (LEFT(name, 1) BETWEEN '0' AND '9') THEN 'Number' END category
    FROM accounts
)
SELECT category, COUNT(*)
FROM t1
GROUP BY 1; 


SELECT comparator, COUNT(*)
FROM (
	SELECT LEFT(UPPER(name), 1) letter, 
		CASE WHEN LEFT(UPPER(name), 1) SIMILAR TO '[A-Z]' THEN 'Letters'
			 WHEN LEFT(UPPER(name), 1) SIMILAR TO '[0-9]' THEN 'Numbers'
			 ELSE 'Not sure' END comparator
	FROM accounts
) sub
GROUP BY 1;


SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                       THEN 1 ELSE 0 END AS num, 
         CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                       THEN 0 ELSE 1 END AS letter
      FROM accounts) t1;


-- 4. Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?
WITH t1 AS (
 	SELECT name, CASE WHEN LEFT(name, 1) IN ('A', 'E', 'I', 'O', 'U', 'a', 'e', 'i', 'o', 'u') THEN 'Vowel'
	ELSE 'Other' END category
    FROM accounts
)
SELECT category, COUNT(*)
FROM t1
GROUP BY 1; 


SELECT comparator, COUNT(*)
FROM (
	SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A', 'E', 'I', 'O', 'U') THEN 'Vowels'
					  ELSE 'Anything Else' END comparator
	FROM accounts
) sub
GROUP BY 1;


SELECT SUM(vowels) vowels, SUM(other) other
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                        THEN 1 ELSE 0 END AS vowels, 
          CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                       THEN 0 ELSE 1 END AS other
         FROM accounts) t1;


-- POSITION AND STRPOS
-- 1. Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.
SELECT name, primary_poc, LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) first_name,
     RIGHT(primary_poc, LENGTH(primary_poc) -STRPOS(primary_poc, ' ')) last_name
FROM accounts;

SELECT primary_poc, LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) first_name, 
	   RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) last_name
FROM accounts;

-- 2. Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last name columns.
SELECT name, LEFT(name, POSITION(' ' IN name) - 1) first_name, RIGHT(name, LENGTH(name) -STRPOS(name, ' ')) last_name
FROM sales_reps;

SELECT name, LEFT(name, STRPOS(name, ' ') - 1) first_name, 
	   RIGHT(name, LENGTH(name) - POSITION(' ' IN name)) last_name
FROM sales_reps;


-- CONCATNATION
-- 1. Each company in the accounts table wants to create an email address for each primary_poc. The email address should be the first name
--  of the primary_poc . last name primary_poc @ company name .com.
SELECT name, LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) || '.' || RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) 
    || '@' || name || '.com' email
FROM accounts;

SELECT name, LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) || '.' ||
	   RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) ||
	   '@' || name || '.com' AS email
FROM accounts;


WITH t1 AS ( -- LESSON
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com')
FROM t1;


-- 2. You may have noticed that in the previous solution some of the company names include spaces, which will certainly not work in an email
--  address. See if you can create an email address that will work by removing all of the spaces in the account name, but otherwise your
--  solution should be just as in question 1. 
SELECT name, LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) || '.' || RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' '))
    || '@' || REPLACE(name, ' ', '') || '.com' email
FROM accounts;

SELECT name, REPLACE(email, ' ', '') email
FROM (
	SELECT name, LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) || '.' ||
		   RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) ||
		   '@' || name || '.com' AS email
	FROM accounts
) sub;

WITH t1 AS ( -- LESSON
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', REPLACE(name, ' ', ''), '.com')
FROM  t1;

-- 3. We would also like to create an initial password, which they will change after their first log in. The first password will be the first
--  letter of the primary_poc's first name (lowercase), then the last letter of their first name (lowercase), the first letter of their last
--  name (lowercase), the last letter of their last name (lowercase), the number of letters in their first name, the number of letters in
--  their last name, and then the name of the company they are working with, all capitalized with no spaces.
WITH t1 AS (
  	SELECT name, LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) first_name, RIGHT(primary_poc, LENGTH(primary_poc) -STRPOS(primary_poc, ' ')) last_name
    FROM accounts
)
SELECT name, first_name || '.' || last_name || '@' || REPLACE(name, ' ', '') || '.com' email, LEFT(LOWER(first_name), 1) 
    || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) 
    || UPPER(REPLACE(name, ' ', '')) email_password
FROM t1;

WITH t1 AS ( -- LESSON
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com'), LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '')
FROM t1;


--  CASTING 
-- SEEMS in the code below, the TO_DATE(month, 'month') doesn't work for all ENVIRONMNENT

SELECT 'April' AS month, TO_DATE('April', 'month') to_datee; -- TO_DATE function

WITH t1 AS (
	SELECT day_of_week, 'January' month_date
  	FROM sf_crime_data
  	LIMIT 20
)
SELECT DATE_PART('month', TO_DATE(month_date, 'month')) as clean_month
FROM t1;

WITH t AS(
  	SELECT date, 'January'::text date_month
    FROM sf_crime_data
    LIMIT 10
)
-- TO_DATE(date_month, 'month')
--SELECT *, TO_DATE(date_month, 'month') clean_month
--FROM t
--LIMIT 10;
SELECT *, TO_DATE('1290','yymmdd')
FROM t;


-- 1.
SELECT date, (SUBSTR(date, 7, 4) || '-' || SUBSTRING(date, 1, 2) || '-' || SUBSTR(date, 4, 2))::DATE formated_date
FROM sf_crime_data
LIMIT 10;


SELECT date, CONCAT(SUBSTR(date, 7, 4), '-', SUBSTR(date, 1, 2), '-', SUBSTR(date, 4, 2), ' ', SUBSTR(date, 12, 8))::DATE date_date,
 CONCAT(SUBSTR(date, 7, 4), '-', SUBSTR(date, 1, 2), '-', SUBSTR(date, 4, 2), ' ', SUBSTR(date, 12, 8))::TIMESTAMP timestamp_date
FROM sf_crime_data
LIMIT 10;


-- COALESCE
SELECT COALESCE(o.id, a.id) f_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, o.id,
 COALESCE(o.account_id, a.id) f_account_id, occurred_at, COALESCE(standard_qty, 0) standard_qty, COALESCE(gloss_qty, 0) gloss_qty,
 COALESCE(poster_qty, 0) poster_qty, COALESCE(total, 0) total, COALESCE(standard_amt_usd, 0) standard_amt_usd,
 COALESCE(gloss_amt_usd, 0) gloss_amt_usd, COALESCE(poster_amt_usd, 0) poster_amt_usd, COALESCE(total_amt_usd, 0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

-- IF & CASE WHEN
SELECT *
    (CASE WHEN x+y > z THEN 'Yes' ELSE 'No' END) traingle
ROM Triangle

SELECT *, IF(x>y, 'Yes', 'No') as triangle FROM Triangle 

--Leetcode 180 Joining Multiple Tables Together 
SELECT DISTINCT L1.num AS ConsecutiveNums
FROM Logs1 L1, Logs L2, Logs L3
WHERE L1.id = L2.id -1 
AND L2.id = L3.id - 1
AND L1.num = L2.num
AND L2.num = L3.num


-- lEETCODE 1164 
-- The COALESCE(col1, col2, ...) function returns the first non-null value in a list.
-- Window(col1) OVER (PARTITION BY col2 ORDER BY col3 DESC) AS col_new 
--For product that has no price change before the cutoff date, there is no data entry in the data. Thus, we will replace null with the original price of 10.
SELECT DISTINCT(P1.product_id), COALESCE(P2.price,10) AS price 
FROM Products AS P1
LEFT JOIN (
SELECT DISTINCT product_id, 
-- We group by product_id and order the change date in descending order to find out the latest price 
FIRST_VALUE(new_price) OVER (PARTITION BY product_id ORDER BY change_date DESC) AS price
FROM Products
WHERE change_date <= '2019-08-16'
) AS P2 ON P1.product_id = P2.product_id 


-- LEETCODE 1204
-- Use window function, order function to find the last person that can broad the bus 
SELECT T1.person_name
FROM(
SELECT person_name,
SUM(weight) OVER (ORDER BY turn) AS weight_sum
FROM Query
) AS T1
WHERE weight_sum <= 1000
ORDER BY weight_sum DESC
LIMIT 1


--LEETCODE 1907
-- Create a reference table 
(
SELECT 'A' AS category
UNION ALL
SELECT 'B'
UNION ALL
SELECT 'C'
)
-- Mulltiple If statements
SELECT account_id,
    (CASE 
    WHEN income < 10000 THEN 'Low'
    WHEN income > 10000 AND income < 50000 THEN 'Middle'
    ELSE WHEN income > 50000 THEN 'High' END) AS 'category'
FROM Table


-- LEETCODE 176
-- LAG() VS. OFFSET()
-- SYNTAX DIFF
    -- OFFSET(): works with LIMIT & ORDER BY --> Can return a single row 
    -- LAG(): works with OVER([PARTITION BY ...] [ORDER BY ...]) --> return a column for each row --> good for comparison
SELECT (SELECT DISTINCT salary FROM Employee ORDER BY salary DESC LIMIT 1 OFFSET 1) AS SecondHighestSalary

-- LEETCODE 626
-- Multiple CASE WHEN Statement 
-- Extract single value from a column and use in a condition
SELECT 
    (CASE
    WHEN (id == (SELECT MAX(id) FROM Seat) AND (id % 2 <> 0) THEN id 
    WHEN (id % 2 <> 0) THEN id+1
    ELSE id - 1 END) AS id, 
    student
FROM Seat 
ORDER BY id;

-- LEETCODE 1341
-- UNION ALL to merge results together 
(SELECT name AS results -- This determine the title for the output 
FROM Users AS U
LEFT JOIN (
    SELECT user_id, COUNT(movie_id) AS num_movie
    FROM MovieRating
    GROUP BY user_id
) AS M ON U.user_id = M.user_id
ORDER BY num_movie DESC, name
LIMIT 1)
UNION ALL
(SELECT M.title
FROM Movies AS M
LEFT JOIN (
    SELECT movie_id, AVG(rating) AS rating_avg
    FROM MovieRating
    WHERE YEAR(created_at) = 2020 AND MONTH(created_at) = 2
    GROUP BY movie_id
) AS R ON M.movie_id = R.movie_id
ORDER BY R.rating_avg DESC, M.title
LIMIT 1)


-- LEETCODE 1321
-- 1. We first filter the original table to get the rows we want to do calculation on
-- 2. Then we use the aggregate function, and then we attach the calculated value back to the original table
-- 2.1 Because we first filter, then aggregate, this will only return the last row of data
-- 2.2 Therefore, when we attached back, we don't need to worry about the in between rows 

-- INNER SELECT FROM THE TABLE ITSELF
-- FILTER THE ROWS USING WHERE & BETWEEN CLAUSE ON DATE
-- DATE_SUB([DATE], INTERVAL X DAY); DATE_ADD([DATE], INTERVAL X DAY)
SELECT 
    visited_on,
    (
        SELECT SUM(amount)
        FROM Customer
        -- MAKE SURE WE AGGREGATE THE AMOUNT USING DATES FROM THE OUTER TABLE 
        -- WITHOUT C1. WE ARE JUST CALCULATING THE TOTAL SUM AMOUNT
        WHERE visited_on BETWEEN DATE_SUB(C1.visited_on, INTERVAL 6 DAY) AND C1.visited_on
    ) AS amount,
    ROUND(
        (
            SELECT SUM(amount) / 7
            FROM Customer
            -- USE AS A FILTER TO EXTRACT THE 7 ROWS 
            WHERE visited_on BETWEEN DATE_SUB(C1.visited_on, INTERVAL 6 DAY) AND C1.visited_on
        ),
        2
    ) AS average_amount
FROM Customer AS C1
WHERE visited_on >= (
    -- WE NEED TO REMOVE THE FIRST 6 DAYS
    SELECT DATE_ADD(MIN(visited_on), INTERVAL 6 DAY)
    FROM Customer
)
GROUP BY visited_on

-- VERSES ROLLING_AVG
-- THIS WILL GIVE RESULT FOR EACH ROW 
SELECT visited_on,
AVG(amount) OVER (
    ORDER BY visited_on
    RANGE BETWEEN INTERVAL 7 DAY PRECEDING AND CURRENT ROW
) AS ROLLING_AVG
FROM Customer


-- LEETCODE 602
-- Use UNION ALL to stack two tables with the same columns on top of each other 
-- Then we can use some aggregate functions to find the results 

WITH TOTAL AS

(SELECT 
    requester_id AS id,
    COUNT(*) AS num_friend
FROM RequestAccepted
GROUP BY id

UNION ALL

SELECT 
    accepter_id AS id,
    COUNT(*) AS num_friend
FROM RequestAccepted
GROUP BY id)

SELECT id, SUM(num_friend) AS num
FROM TOTAL
GROUP BY id
ORDER BY num DESC
LIMIT 1

-- INTERSECT, UNION, UNION ALL
-- INTERSECT: return the shared rows
-- UNION: return the union without duplicates identifier 
-- UNION ALL: return all records from both table 



-- LEETCODE 585
-- Use WHERE( [col] IN ()) to filter the table 
-- Use GROUP BY & HAVING to filter the table 
SELECT ROUND(SUM(tiv_2016),2) AS tiv_2016
FROM Insurance AS I
WHERE
(I.pid IN (SELECT pid FROM Insurance GROUP BY lat, lon HAVING  COUNT(*) = 1)) 
AND
(I.tiv_2015 IN (SELECT tiv_2015 FROM Insurance GROUP BY tiv_2015 HAVING(COUNT(*)>1)))



-- LEETCODE 185
-- RANK() OVER (PARTITION BY [COL] ORDER BY [COL2])
-- DENSE_RANK() OVER (PARTITION BY [COL] ORDER BY [COL2])
-- RANK() will give tied ranks the same number: 1,2,2,4
-- DENSE_RANK() will give consecuitive rank: 1,2,3,4
SELECT D.name AS Department, T1.name AS Employee, T1.salary AS Salary
FROM (
    SELECT departmentId, name, salary,
    DENSE_RANK() OVER (PARTITION BY departmentId ORDER BY salary DESC) AS RANK_
    FROM Employee
) AS T1
RIGHT JOIN Department AS D ON T1.departmentId = D.id
WHERE T1.RANK_ < 4


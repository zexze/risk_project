
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
ORDER BY id 









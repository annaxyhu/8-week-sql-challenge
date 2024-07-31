/* Danny's Diner Case Study

All information regarding this case study is sourced from DataWithDanny's 8 Week SQL Challenge.

Background: Danny's Diner is a restaurant that sells sushi, curry and ramen. The restaurant has 
captured some very basic data from their few months of operation but have no idea how to use their 
data to help them run the business.

Problem Statement: Danny wants to use the data to answer a few simple questions about his customers,
especially about their visiting patterns, and use this insight to help him decide whether he should 
expand the existing customer loyalty program. 

Skills Targetted: Common Table Expressions, Group By Aggregates, Window Functions for ranking, Table Joins

*/
-- 1. Database and Table Creation
CREATE TABLE sales(
	customer_id VARCHAR(1),
	order_date DATE,
	product_id INT
);

CREATE TABLE menu(
	product_id INT,
	product_name VARCHAR(5),
	price INT
);

CREATE TABLE members(
	customer_id VARCHAR(1),
	join_date TIMESTAMP 
);

SHOW TABLES;

INSERT INTO sales(customer_id, order_date, product_id)
VALUES
	('A', '2021-01-01', 1),
	('A', '2021-01-01', 2),
	('A', '2021-01-07', 2),
	('A', '2021-01-10', 3),
	('A', '2021-01-11', 3),
	('A', '2021-01-11', 3),
	('B', '2021-01-01', 2),
	('B', '2021-01-02', 2),
	('B', '2021-01-04', 1),
	('B', '2021-01-11', 1),
	('B', '2021-01-16', 3),
	('B', '2021-02-01', 3),
	('C', '2021-01-01', 3),
	('C', '2021-01-01', 3),
	('C', '2021-01-07', 3);

SELECT *
FROM sales;

INSERT INTO menu(product_id, product_name, price)
VALUES
	(1, 'sushi', 10),
	(2, 'curry', 15),
	(3, 'ramen', 12);

SELECT *
FROM menu;

INSERT INTO members(customer_id, join_date)
VALUES
	('A', '2021-01-07 00:00:00'),
	('B', '2021-01-09 00:00:00');

SELECT *
FROM members;

/* 
Case Study Questions
*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
	customer_id, 
	SUM(price) as total_amt_spent
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) AS visits_days
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

WITH purchase_order AS (
SELECT 
	customer_id,
	order_date,
	s.product_id as s_product_id,
	m.product_id as m_product_id,
	product_name,
	price,
	RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS order_rank
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
)
SELECT DISTINCT customer_id, product_name
FROM purchase_order
WHERE order_rank = 1
;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name, COUNT(*) AS most_purchased
FROM menu m
JOIN sales s
	ON m.product_id = s.product_id 
GROUP BY m.product_name
ORDER BY COUNT(*) DESC
LIMIT 1
;

-- 5. Which item was the most popular for each customer?

WITH total_sales AS (
SELECT 
	s.customer_id as customer, 
	m.product_name as product, 
	COUNT(*) AS purchased_times,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) as ranking
FROM sales s
JOIN menu m 
	ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
)
SELECT customer, product
FROM total_sales
WHERE ranking = 1
;

-- 6. Which item was purchased first by the customer after they became a member?

SELECT customer_id, product_name
FROM (SELECT
		s.customer_id,
		s.order_date,
		m.product_name,
		mem.join_date,
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) as ranking
	FROM sales s
	JOIN menu m ON s.product_id = m.product_id
	JOIN members mem ON s.customer_id = mem.customer_id
	WHERE DATE(join_date) < order_date
    ) AS sales_after_joining
WHERE ranking = 1;

-- 7. Which item was purchased just before the customer became a member?

SELECT customer_id, product_name
FROM (SELECT
		s.customer_id,
		s.order_date,
		m.product_name,
		mem.join_date,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date DESC) as ranking
	FROM sales s
	JOIN menu m ON s.product_id = m.product_id
	JOIN members mem ON s.customer_id = mem.customer_id
	WHERE DATE(join_date) > order_date
    ) AS sales_before_joining
WHERE ranking = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

WITH orders_before_join AS (
SELECT
	s.customer_id,
	s.order_date,
	m.product_name,
	mem.join_date,
    m.price
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mem ON s.customer_id = mem.customer_id
WHERE DATE(join_date) > order_date OR join_date IS NULL
)
SELECT customer_id, COUNT(product_name) as total_items, SUM(price) AS total_spent
FROM orders_before_join
GROUP BY customer_id;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- (Solution assumes purchases on join date are not included in the points calculation)

WITH purchases AS (
SELECT
	s.customer_id,
	m.product_name,
	m.price,
	mem.join_date,
	CASE 
		WHEN (m.product_name = 'sushi' AND join_date IS NOT NULL) THEN 20
		WHEN ((m.product_name = 'curry' OR m.product_name = 'ramen') AND join_date IS NOT NULL) THEN 10
		ELSE 0
	END AS multiplier
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mem ON s.customer_id = mem.customer_id
WHERE DATE(join_date) < order_date OR join_date IS NULL
)
SELECT customer_id, SUM(price*multiplier) AS total_points
FROM purchases
GROUP BY customer_id;
   
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-- (Solution assumes that the 2x active period ends 7 afters after the join date (ex. active from 2021-01-09 to 2021-01-16 inclusive))

WITH purchases AS (
SELECT
	s.customer_id,
	s.order_date,
	m.product_name,
	m.price,
	mem.join_date,
	CASE
		WHEN mem.join_date IS NULL THEN 0
		WHEN m.product_name = 'sushi' THEN 20
		WHEN DATEDIFF(s.order_date, DATE(mem.join_date)) <= 7 AND DATEDIFF(s.order_date, DATE(mem.join_date)) >= 0 THEN 20
        	ELSE 10
	END AS multiplier
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mem ON s.customer_id = mem.customer_id
WHERE order_date >= '2021-01-01' AND order_date < '2021-01-31'
)
SELECT customer_id, SUM(multiplier*price) as total_points
FROM purchases
GROUP BY customer_id;


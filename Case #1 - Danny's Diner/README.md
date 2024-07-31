# Case Study #1: Danny's Diner
## Introduction

This case study is sourced from DataWithDanny's 8 Week SQL Challenge. For more information on this case, refer to the following link: [Danny’s Diner](https://8weeksqlchallenge.com/case-study-1/). 

**Key Skills Targeted:** Common Table Expressions, Group By Aggregates, Window Functions for Ranking, Table Joins

This case is divided into the following sections:
1. [Case Background](#case-background)
2. [Danny's Questions and Solutions](#dannys-questions-and-solutions)
3. [Insights and Recommendations](#insights-and-recommendations)

## Case Background

**Business Background:** Danny's Diner is a restaurant that sells sushi, curry and ramen. The restaurant has captured some very basic data from their few months of operation, but have no idea how to use their data to help them run the business.

**Problem Statement:** Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. These insights will be used to help him decide whether he should expand the existing customer loyalty program.

**Entity-Relationship Diagram:** Danny has shared 3 key datasets (sales, menu and members) as shown below.
<p align="center">
  <img src="https://github.com/annaxyhu/8-week-sql-challenge/blob/main/Case%20%231%20-%20Danny's%20Diner/Case1-ER-diagram.png"/>
</p>

## Danny's Questions and Solutions

**1. What is the total amount each customer spent at the restaurant?**

```sql
SELECT 
  customer_id, 
  SUM(price) as total_spend
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
GROUP BY customer_id;
```
Answer: 
```sql
| customer_id | total_spend |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |
```
***
**2. How many days has each customer visited the restaurant?**
```sql
SELECT customer_id, COUNT(DISTINCT order_date) AS visits_days
FROM sales
GROUP BY customer_id;
```
Answer: 
```sql
| customer_id | visit_days |
| ----------- | ---------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |
```
***
**3. What was the first item from the menu purchased by each customer?**
```sql
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
WHERE order_rank = 1;
```
Answer: 
```sql
| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | curry        |
| C           | ramen        |
```
***
**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

```sql
SELECT m.product_name, COUNT(*) AS most_purchased
FROM menu m
JOIN sales s
	ON m.product_id = s.product_id 
GROUP BY m.product_name
ORDER BY COUNT(*) DESC
LIMIT 1;
```
Answer: 
```sql
| product_name | most_purchased |
| ------------ | -------------- |
| ramen        | 8              |
```

***
**5. Which item was the most popular for each customer?**
```sql
WITH total_sales AS
(
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
WHERE ranking = 1;
```
Answer: 
```sql
| customer | product |
| -------- | ------- |
| A        | ramen   |
| B        | curry   |
| B        | sushi   |
| B        | ramen   |
| C        | ramen   |
```
***
**6. Which item was purchased first by the customer after they became a member?**
```sql
SELECT customer_id, product_name
FROM (
  SELECT
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
```
Answer: 
```sql
| customer_id | product_name |
| ----------- | ------------ |
| A           | ramen        |
| B           | sushi        |
```
***
**7. Which item was purchased just before the customer became a member?**

```sql
SELECT customer_id, product_name
FROM (
	SELECT
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
```

Answer: 
```sql
| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| B           | sushi        |
```
***
**8. What is the total items and amount spent for each member before they became a member?**
```sql
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
SELECT customer_id, COUNT(product_name) as total_items, SUM(price) as total_spent
FROM orders_before_join
GROUP BY customer_id;
```

Answer: 
```sql
| customer_id | total_items | total_spent |
| ----------- | ----------- | ----------- |
| A           | 2           | 25          |
| B           | 3           | 40          |
| C           | 3           | 36          |
```
***
**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

Assumptions:
- Only members can collect points
- Items purchased on the join date are not counted for points
  
```sql
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
```
Answer: 
```sql
| customer_id | total_points |
| ----------- | ------------ |
| A           | 360          |
| B           | 440          |
| C           | 0            |
```
***
**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

Assumptions:
- The 2x points multiplier is valid for 7 days after the join date
- Ex. Active from 2021-01-09 to 2021-01-16 (inclusive)

```sql
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
WHERE customer_id IN ('A', 'B')
GROUP BY customer_id;
```
Answer: 
```sql
| customer_id | total_points |
| ----------- | ------------ |
| A           | 1370         |
| B           | 940          |
```

## Insights and Recommendations



















# Case Study #2: Pizza Runner
## Introduction

This case study is sourced from DataWithDanny's 8 Week SQL Challenge. For more information on this case, refer to the following link: [Pizza Runner](https://8weeksqlchallenge.com/case-study-2/). 

**Key Skills Targeted:** Common Table Expressions, Group By Aggregates, Table Joins, String Transformations, NULL Values, Regular Expressions

This case is divided into the following sections:
1. [Case Background](#case-background)
2. [Data Cleaning](#data-cleaning)
3. [Questions and Solutions](#dannys-questions-and-solutions)
4. [Insights and Recommendations](#insights-and-recommendations)

## Case Background

**Business Background:** Danny recently launched Pizza Runner - a pizza store where he 'uberizes' pizza delivery by hiring 'runners' to deliver fresh pizza. 

**Problem Statement:** Danny is very aware very aware that data collection was going to be critical for his business’ growth. He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations.

**Entity-Relationship Diagram:** Danny has shared his pizza_runner database schema, with the following ER diagram: 
<p align="center">
  <img src="https://github.com/annaxyhu/8-week-sql-challenge/blob/main/Case%20%232%20-%20Pizza%20Runner/Case2-ER-diagram.png"/>
</p>

## Data Cleaning



## Part A: Pizza Metrics

**1. How many pizzas were ordered?**

```sql
SELECT COUNT(*) num_pizzas
FROM customer_orders_staging;
```
Answer: 
```sql
| num_pizzas |
| ---------- |
| 14         |
```
***
**2. How many unique customer orders were made?**
```sql
SELECT COUNT(DISTINCT order_id) unique_orders
FROM customer_orders_staging;
```
Answer: 
```sql
| unique_orders |
| ------------- |
| 10            |
```
***
**3. How many successful orders were delivered by each runner?**
```sql
SELECT runner_id, COUNT(*) AS successful_orders
FROM runner_orders_staging
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;
```
Answer: 
```sql
| runner_id | successful_orders |
| --------- | ----------------- |
| 1         | 4                 |
| 2         | 3                 |
| 3         | 1                 |
```
***
**4. How many of each type of pizza was delivered?**

```sql
WITH successful_orders AS (
	SELECT order_id
	FROM runner_orders_staging
	WHERE pickup_time IS NOT NULL
)
SELECT pizza_id, COUNT(*) as num_pizza
FROM customer_orders_staging
JOIN successful_orders 
	USING(order_id)
GROUP BY pizza_id;
```
Answer: 
```sql
| pizza_id | num_pizza |
| -------- | --------- |
| 1        | 9         |
| 2        | 3         |
```

***
**5. How many Vegetarian and Meatlovers were ordered by each customer?**
```sql
SELECT customer_id, pizza_name, COUNT(*) as num_pizza
FROM pizza_names p
JOIN customer_orders_staging c
	ON p.pizza_id = c.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id, pizza_name;
```
Answer: 
```sql
| customer_id |  pizza_name  | num_pizza |
| ----------- | ------------ | --------- |
| 101         | Meatlovers   | 2         |
| 101         | Vegetarian   | 1         |
| 102         | Meatlovers   | 2         |
| 102         | Vegetarian   | 1         |
| 103         | Meatlovers   | 3         |
| 103         | Vegetarian   | 1         |
| 104         | Meatlovers   | 3         |
| 105         | Vegetarian   | 1         |
```
***
**6. What was the maximum number of pizzas delivered in a single order?**
```sql
SELECT COUNT(*) max_pizzas
FROM customer_orders_staging
GROUP BY order_id
ORDER BY COUNT(*) DESC
LIMIT 1;
```
Answer: 
```sql
| max_pizzas | 
| ---------- |
| 3          |

```
***
**7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**

```sql
SELECT 
	customer_id, 
	SUM(CASE 
			WHEN exclusions != '' OR extras != '' THEN 1
			ELSE 0
		END) at_least_1_change,
	SUM(CASE 
			WHEN exclusions = '' AND extras = '' THEN 1
			ELSE 0
		END) no_changes
FROM customer_orders_staging c
JOIN (SELECT order_id
	  FROM runner_orders_staging
	  WHERE pickup_time IS NOT NULL) AS r
	ON c.order_id = r.order_id
GROUP BY customer_id;
```

Answer: 
```sql
| customer_id |  at_least_1_change | no_changes |
| ----------- | ------------------ | ---------- |
| 101         | 0                  | 2          |
| 102         | 0                  | 3          |
| 103         | 3                  | 0          |
| 104         | 2                  | 1          |
| 105         | 1                  | 0          |
```
***
**8. How many pizzas were delivered that had both exclusions and extras?**
```sql
SELECT COUNT(*) AS cnt_exclusion_and_extra
FROM customer_orders_staging c
JOIN (SELECT order_id
	  FROM runner_orders_staging
	  WHERE pickup_time IS NOT NULL) AS r
	ON c.order_id = r.order_id
WHERE exclusions != '' AND extras != '';
```

Answer: 
```sql
| cnt_exclusion_and_extra |
| ----------------------- |
| 1                       |

```
***
**9. What was the total volume of pizzas ordered for each hour of the day?**

```sql
SELECT
	HOUR(order_time) AS hour_of_day,
    COUNT(*) AS pizzas_ordered
FROM customer_orders_staging
GROUP BY HOUR(order_time)
ORDER BY hour_of_day;
```
Answer: 
```sql
| hour_of_day |  pizzas_ordered |
| ----------- | --------------- |
| 11          | 1               |
| 13          | 3               |
| 18          | 3               | 
| 19          | 1               | 
| 21          | 3               |
| 23          | 3               | 

```
***
**10. What was the volume of orders for each day of the week?**

```sql
SELECT
	DAYOFWEEK(order_time) AS day_of_week,
    COUNT(*) AS pizzas_ordered
FROM customer_orders_staging
GROUP BY DAYOFWEEK(order_time)
ORDER BY day_of_week;
```
Answer: 
```sql
| day_of_week |  pizzas_ordered |
| ----------- | --------------- |
| 4          | 1               |
| 5          | 3               |
| 6          | 3               | 
| 7          | 1               | 

```
## Part B: Runner and Customer Experience
**1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**

```sql
SELECT WEEK(pickup_time) AS period, COUNT(DISTINCT runner_id) AS runner_signup
FROM runner_orders_staging
WHERE pickup_time IS NOT NULL
GROUP BY WEEK(pickup_time);

```
Answer: 
```sql
| period | runner_signup |
| ------ | ------------- |
| 0      | 2             |
| 1      | 3             |
```
***
**2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
```sql
WITH durations AS (
	SELECT DISTINCT r.order_id, runner_id, order_time, pickup_time
	FROM runner_orders_staging r
	JOIN customer_orders c USING (order_id)
    WHERE pickup_time IS NOT NULL
)
SELECT AVG(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)) as avg_mins
FROM durations;
```
Answer: 
```sql
| avg_mins |
| -------- |
| 15.6250  |
```
***
**3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**
```sql
SELECT num_pizzas, ROUND(AVG(prep_time),0) AS avg_prep_time
FROM (
SELECT r.order_id, 
		COUNT(pizza_id) AS num_pizzas, 
        AVG(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)) AS prep_time
FROM runner_orders_staging r
JOIN customer_orders c USING (order_id)
WHERE pickup_time IS NOT NULL
GROUP BY r.order_id
) AS order_prep_time
GROUP BY num_pizzas;
```
Answer: 
```sql
| num_pizzas | avg_prep_time |
| ---------- | ------------- |
| 1          | 12            |
| 2          | 18            |
| 3          | 29            |
```
***
**4. What was the average distance travelled for each customer?**

```sql
SELECT customer_id, ROUND(AVG(distance), 2) AS avg_distance_km
FROM customer_orders_staging
JOIN runner_orders_staging
USING (order_id)
GROUP BY customer_id;
```
Answer: 
```sql
| customer_id | avg_distance_km |
| ----------- | --------------- |
| 101         | 20              |
| 102         | 16.73           |
| 103         | 23.4            |
| 104         | 10              |
| 105         | 25              |

```

***
**5. What was the difference between the longest and shortest delivery times for all orders?**
```sql
SELECT MAX(duration)-MIN(duration) AS difference
FROM runner_orders_staging;
```
Answer: 
```sql
| difference |
| ---------- |
| 30         |
```
***
**6. What was the average speed for each runner for each delivery and do you notice any trend for these values?**
```sql
SELECT runner_id, ROUND(AVG(distance/duration*60),2) AS avg_speed_km_per_hr
FROM runner_orders_staging
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;
```
Answer: 
```sql
| runner_id | avg_speed_km_per_hr |
| --------- | ------------------- |
| 1         | 45.54               |
| 2         | 62.9                |
| 3         | 40                  |

```
***
**7. What is the successful delivery percentage for each runner?**

```sql
SELECT runner_id, 
  	CONCAT(ROUND((SUM(
    CASE
		WHEN pickup_time IS NOT NULL THEN 1
		ELSE 0
	END)/COUNT(*))*100,0), '%') AS success_rate
FROM runner_orders_staging
GROUP BY runner_id;
```

Answer: 
```sql
| runner_id | success_rate |
| --------- | ------------ |
| 1         | 100%         |
| 2         | 75%          |
| 3         | 50%           |
```
***

## Part C: Ingredient Optimisation

## Part D: Pricing and Ratings

## Insights and Recommendations

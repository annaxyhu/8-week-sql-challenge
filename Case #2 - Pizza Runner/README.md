# Case Study #2: Pizza Runner
## Introduction

This case study is sourced from DataWithDanny's 8 Week SQL Challenge. For more information on this case, refer to the following link: [Pizza Runner](https://8weeksqlchallenge.com/case-study-2/). 

**Key Skills Targeted:** Common Table Expressions, Group By Aggregates, Table Joins, String Transformations, NULL Values, Regular Expressions

This case is divided into the following sections:
1. [Case Background](#case-background)
2. [Dataset Structure](#dataset-structure)
3. [Data Cleaning](#data-cleaning)
4. [Part A: Pizza Metrics](#part-a-pizza-metrics)
5. [Part B: Runner and Customer Experience](#part-b-runner-and-customer-experience)
6. [Part C: Ingredient Optimization](#part-c-ingredient-optimization)
7. [Part D: Pricing and Ratings](#part-d-pricing-and-ratings)
8. [Insights and Recommendations](#insights-and-recommendations)

## Case Background

**Business Background:** Danny recently launched Pizza Runner - a pizza store where he 'uberizes' pizza delivery by hiring 'runners' to deliver fresh pizza. 

**Problem Statement:** Danny is very aware very aware that data collection was going to be critical for his business’ growth. He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations.

**Entity-Relationship Diagram:** Danny has shared his pizza_runner database schema, with the following ER diagram: 
<p align="center">
  <img src="https://github.com/annaxyhu/8-week-sql-challenge/blob/main/Case%20%232%20-%20Pizza%20Runner/Case2-ER-diagram.png"/>
</p>

## Dataset Structure

**Table 1: runners**
```sql
CREATE TABLE runners (
	runner_id INTEGER,
	registration_date DATE
);

INSERT INTO runners (runner_id, registration_date)
VALUES
	(1, '2021-01-01'),
	(2, '2021-01-03'),
	(3, '2021-01-08'),
	(4, '2021-01-15');
```
***

**Table 2: customer_orders**
```sql
CREATE TABLE customer_orders (
	order_id INTEGER,
	customer_id INTEGER,
	pizza_id INTEGER,
	exclusions VARCHAR(4),
	extras VARCHAR(4),
	order_time TIMESTAMP
);

INSERT INTO customer_orders
	(order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
	('1', '101', '1', '', '', '2020-01-01 18:05:02'),
	('2', '101', '1', '', '', '2020-01-01 19:00:52'),
	('3', '102', '1', '', '', '2020-01-02 23:51:23'),
	('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
	('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
	('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
	('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
	('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
	('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
	('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
	('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
	('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
	('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
	('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');
```
***

**Table 3: runner_orders**
```sql
CREATE TABLE runner_orders(
	order_id INT,
	runner_id INT,
	pickup_time VARCHAR(19),
	distance VARCHAR(7),
	duration VARCHAR(10),
	cancellation VARCHAR(23)
);

INSERT INTO runner_orders
	(order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
	('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
	('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
	('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
	('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
	('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
	('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
	('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
	('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
	('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
	('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

```
***

**Table 4: pizza_names**
```sql
CREATE TABLE pizza_names(
	pizza_id INT, 
	pizza_name TEXT
);

INSERT INTO pizza_names
	(pizza_id, pizza_name)
VALUES
	(1, 'Meatlovers'),
	(2, 'Vegetarian');
```
***

**Table 5: pizza_recipes**
```sql
CREATE TABLE pizza_recipes(
	pizza_id INT, 
	toppings TEXT
);

INSERT INTO pizza_recipes
	(pizza_id, toppings)
VALUES
	(1, '1, 2, 3, 4, 5, 6, 8, 10'),
	(2, '4, 6, 7, 9, 11, 12');
```
***
**Table 6: pizza_toppings**
```sql
CREATE TABLE pizza_toppings(
	topping_id INT,
    topping_name TEXT
);

INSERT INTO pizza_toppings
	(topping_id, topping_name)
VALUES
	(1, 'Bacon'),
	(2, 'BBQ Sauce'),
	(3, 'Beef'),
	(4, 'Cheese'),
	(5, 'Chicken'),
	(6, 'Mushrooms'),
	(7, 'Onions'),
	(8, 'Pepperoni'),
	(9, 'Peppers'),
	(10, 'Salami'),
	(11, 'Tomatoes'),
	(12, 'Tomato Sauce');
```

## Data Cleaning

**Table: customer_orders**

Changes:
- Created a new staging table customer_orders_staging
- Set all 'nulls' or blanks to NULL

```sql
CREATE TABLE `customer_orders_staging` (
  `order_id` int DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `pizza_id` int DEFAULT NULL,
  `exclusions` varchar(4) DEFAULT NULL,
  `extras` varchar(4) DEFAULT NULL,
  `order_time` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO customer_orders_staging
(SELECT * FROM customer_orders);

UPDATE customer_orders_staging
SET exclusions = ''
WHERE exclusions = 'null';

UPDATE customer_orders_staging
SET extras = ''
WHERE extras = 'null' OR extras IS NULL;

```
***
**Table: runner_orders**

Changes:
- Created a new staging table runner_orders_staging
- Set all blanks to NULL
- Remove 'km' from distance
- Remove anything after the numbers from duration
- Changed Datatypes:
  - pickup_time to `DATETIME`
  - distance to `FLOAT`
  - duration to `INT`

```sql
CREATE TABLE `runner_orders_staging` (
  `order_id` int DEFAULT NULL,
  `runner_id` int DEFAULT NULL,
  `pickup_time` varchar(19) DEFAULT NULL,
  `distance` varchar(7) DEFAULT NULL,
  `duration` varchar(10) DEFAULT NULL,
  `cancellation` varchar(23) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO runner_orders_staging
(SELECT * FROM runner_orders);

UPDATE runner_orders_staging
SET duration = NULL
WHERE duration = '';

UPDATE runner_orders_staging
SET cancellation = ''
WHERE cancellation = 'null' OR cancellation IS NULL;

UPDATE runner_orders_staging
SET distance = REPLACE(distance, 'km', ' ');

UPDATE runner_orders_staging
SET duration = LEFT(duration, 2);

ALTER TABLE runner_orders_staging
MODIFY pickup_time DATETIME,
MODIFY distance FLOAT,
MODIFY duration INT;
```
***
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

## Part C: Ingredient Optimization

## Part D: Pricing and Ratings

## Insights and Recommendations

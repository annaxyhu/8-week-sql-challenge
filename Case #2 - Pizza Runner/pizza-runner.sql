/* Pizza Runner Case Study
Author: Anna Hu
Date: July 31st, 2024

All information regarding this case study is sourced from DataWithDanny's 8 Week SQL Challenge.

Background: Danny recently launched Pizza Runner - a business model where he 'uberizes' pizza
delivery by hiring 'runners' to deliver fresh pizza. 

Problem Statement: Danny is very aware very aware that data collection was going to be 
critical for his business’ growth. He has prepared for us an entity relationship diagram of his 
database design but requires further assistance to clean his data and apply some basic 
calculations so he can better direct his runners and optimise Pizza Runner’s operations.

*/

-- Create dataset tables

CREATE SCHEMA pizza_runner;

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

CREATE TABLE pizza_names(
	pizza_id INT, 
    pizza_name TEXT
);

INSERT INTO pizza_names
	(pizza_id, pizza_name)
VALUES
	(1, 'Meatlovers'),
    (2, 'Vegetarian');

CREATE TABLE pizza_recipes(
	pizza_id INT, 
    toppings TEXT
);

INSERT INTO pizza_recipes
	(pizza_id, toppings)
VALUES
	(1, '1, 2, 3, 4, 5, 6, 8, 10'),
    (2, '4, 6, 7, 9, 11, 12');

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


-- Data Cleaning

-- Table: customer_orders
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
SET exclusions = NULL
WHERE exclusions = 'null' OR exclusions = '';

UPDATE customer_orders_staging
SET extras = NULL
WHERE extras = 'null' OR extras = '';

SELECT *
FROM customer_orders_staging;

-- Table: runner_orders
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

-- pizza-recipes IN THE WORKS: Splitting comma delimited lists into rows
CREATE TABLE `pizza_recipes_staging` (
  `pizza_id` int DEFAULT NULL,
  `toppings` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/* 
Case Study Questions Include the Following Topics:
- Part A: Pizza Metrics
- Part B: Runner and Customer Experience
- Part C: Ingredient Optimization
- Part D: Pricing and Ratings
- Part E: Bonus DML Challenge

*/

-- Part A: Pizza Metrics

-- 1. How many pizzas were ordered?
SELECT COUNT(*) num_pizzas
FROM customer_orders_staging;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) unique_orders
FROM customer_orders_staging;

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(*) AS successful_orders
FROM runner_orders_staging
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered? 
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

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id, pizza_name, COUNT(*) as num_pizza
FROM pizza_names p
JOIN customer_orders_staging c
	ON p.pizza_id = c.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id, pizza_name;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT COUNT(*) max_pizzas
FROM customer_orders_staging
GROUP BY order_id
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
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

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(*) AS cnt_exclusion_and_extra
FROM customer_orders_staging c
JOIN (SELECT order_id
	  FROM runner_orders_staging
	  WHERE pickup_time IS NOT NULL) AS r
	ON c.order_id = r.order_id
WHERE exclusions != '' AND extras != '';

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
	HOUR(order_time) AS hour_of_day,
    COUNT(*) AS pizzas_ordered
FROM customer_orders_staging
GROUP BY HOUR(order_time)
ORDER BY hour_of_day;

-- 10. What was the volume of orders for each day of the week?
SELECT
	DAYOFWEEK(order_time) AS day_of_week,
    COUNT(*) AS pizzas_ordered
FROM customer_orders_staging
GROUP BY DAYOFWEEK(order_time)
ORDER BY day_of_week;

-- Part B: Runner and Customer Experience

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT WEEK(pickup_time) AS period, COUNT(DISTINCT runner_id) AS runner_signup
FROM runner_orders_staging
WHERE pickup_time IS NOT NULL
GROUP BY WEEK(pickup_time);

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH durations AS (
	SELECT DISTINCT r.order_id, runner_id, order_time, pickup_time
	FROM runner_orders_staging r
	JOIN customer_orders c USING (order_id)
    WHERE pickup_time IS NOT NULL
)
SELECT AVG(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)) as avg_mins
FROM durations;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
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

-- 4. What was the average distance travelled for each customer?
SELECT customer_id, ROUND(AVG(distance), 2) AS avg_distance_km
FROM customer_orders_staging
JOIN runner_orders_staging
USING (order_id)
GROUP BY customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration)-MIN(duration) AS difference
FROM runner_orders_staging;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, ROUND(AVG(distance/duration*60),2) AS avg_speed_km_per_hr
FROM runner_orders_staging
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;

-- 7. What is the successful delivery percentage for each runner?
SELECT runner_id, 
  	CONCAT(ROUND((SUM(
    CASE
		WHEN pickup_time IS NOT NULL THEN 1
		ELSE 0
	END)/COUNT(*))*100,0), '%') AS success_rate
FROM runner_orders_staging
GROUP BY runner_id;

-- PART C: Ingredient Optimization

-- 1. What are the standard ingredients for each pizza?
WITH toppings_cte AS (
SELECT 
	pizza_recipes.pizza_id,
	TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pizza_recipes.toppings, ',', numbers.n), ',', -1)) AS toppings
FROM (SELECT 1 n 
    UNION ALL SELECT 2
	UNION ALL SELECT 3 
	UNION ALL SELECT 4
    UNION ALL SELECT 5
    UNION ALL SELECT 6
) AS numbers
JOIN pizza_recipes
	ON CHAR_LENGTH(pizza_recipes.toppings)
         -CHAR_LENGTH(REPLACE(pizza_recipes.toppings, ',', ''))>=numbers.n-1
ORDER BY pizza_id, n
)
SELECT p.topping_name, count(t.pizza_id) AS pizzas
FROM toppings_cte t
JOIN pizza_toppings p
	ON t.toppings = p.topping_id
GROUP BY p.topping_name
HAVING pizzas = 2
;

-- 2. What was the most commonly added extra?

WITH extra_CTE AS (
SELECT 
	order_id,
	TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', numbers.n), ',', -1)) AS extra
FROM (SELECT 1 n 
    UNION ALL SELECT 2
) AS numbers
JOIN customer_orders_staging
	ON CHAR_LENGTH(extras)
         -CHAR_LENGTH(REPLACE(extras, ',', ''))>=numbers.n-1
ORDER BY order_id, n
)
SELECT topping_name, COUNT(*) order_times
FROM extra_CTE e
JOIN pizza_toppings p
	ON e.extra = p.topping_id
GROUP BY topping_name
ORDER BY order_times DESC
LIMIT 1;

-- 3. What was the most common exclusion?
WITH exclusion_CTE AS (
SELECT 
	order_id,
	TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', numbers.n), ',', -1)) AS exclusion
FROM (SELECT 1 n 
    UNION ALL SELECT 2
) AS numbers
JOIN customer_orders_staging
	ON CHAR_LENGTH(exclusions)
         -CHAR_LENGTH(REPLACE(exclusions, ',', ''))>=numbers.n-1
ORDER BY order_id, n
)
SELECT topping_name, COUNT(*) exclusion_times
FROM exclusion_CTE e
JOIN pizza_toppings p
	ON e.exclusion = p.topping_id
GROUP BY topping_name
ORDER BY exclusion_times DESC
LIMIT 1;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
	-- Meat Lovers
    -- Meat Lovers - Exclude Beef
    -- Meat Lovers - Extra Bacon
    -- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
SELECT 
	order_id,
	TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', numbers.n), ',', -1)) AS extra
FROM (SELECT 1 n 
    UNION ALL SELECT 2
) AS numbers
JOIN customer_orders_staging
	ON CHAR_LENGTH(extras)
         -CHAR_LENGTH(REPLACE(extras, ',', ''))>=numbers.n-1
;

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients.
	-- Ex. "Meat Lovers: 2xBacon, Beef, ... , Salami"

    
-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

-- PART D: Ingredient Optimization

-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
WITH order_amt AS (
	SELECT 
		p.pizza_name, 
		CASE
			WHEN pizza_name = 'Meatlovers' THEN 12
            ELSE 10
		END AS price		
    FROM runner_orders_staging r
    JOIN customer_orders_staging c
		USING(order_id)
    JOIN pizza_names p
		USING(pizza_id)
    WHERE r.pickup_time IS NOT NULL
)
SELECT SUM(price) AS revenue
FROM order_amt;
	
-- 2. What if there was an additional $1 charge for any pizza extras?



-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset?
	-- Generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
CREATE TABLE ratings (
	order_id INT,
    customer_id INT,
    runner_id INT,
	rating INT
);

INSERT INTO ratings (order_id, customer_id, runner_id, rating)
SELECT *, FLOOR( RAND() * (5-1) + 1) as rating
FROM (
	SELECT 
		DISTINCT order_id,
		customer_id,
		runner_id
	FROM runner_orders_staging r
	JOIN customer_orders_staging c
		USING(order_id)
) AS rand_ratings;

-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
	-- customer_id, order_id, runner_id, rating, order_time, pickup_time, Time between order and pickup, Delivery duration, Average speed, Total number of pizzas
SELECT 
	c.customer_id, c.order_id, r.runner_id, ra.rating, 
    c.order_time, r.pickup_time, 
    TIMESTAMPDIFF(MINUTE, order_time, pickup_time) AS time_to_pickup,
    r.duration,
    ROUND(distance/duration*60,2) AS speed_km_per_hr
FROM customer_orders_staging c
JOIN runner_orders_staging r
	USING(order_id)
JOIN ratings ra
	USING(order_id)
GROUP BY c.customer_id, c.order_id,r.runner_id, ra.rating, c.order_time, 
    r.pickup_time, time_to_pickup, r.duration,speed_km_per_hr;

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
WITH CTE AS(
SELECT 
		r.order_id,
		p.pizza_name,
        distance,
		COUNT(*) num_ordered, 
		CASE
			WHEN pizza_name = 'Meatlovers' THEN 12
            ELSE 10
		END AS price
    FROM runner_orders_staging r
    JOIN customer_orders_staging c
		USING(order_id)
    JOIN pizza_names p
		USING(pizza_id)
    WHERE r.pickup_time IS NOT NULL
    GROUP BY r.order_id, p.pizza_name, distance
), CTE2 AS (
SELECT order_id, distance, SUM(num_ordered*price) AS revenue, distance*0.3 AS cost
FROM CTE
GROUP BY order_id, distance
)
SELECT ROUND(SUM(revenue)-SUM(cost),2) AS profit
FROM CTE2;




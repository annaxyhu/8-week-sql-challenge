# Case Study #3: Foodie-Fi
## Introduction

This case study is sourced from DataWithDanny's 8 Week SQL Challenge. For more information on this case, refer to the following link: [Foodie-Fi](https://8weeksqlchallenge.com/case-study-3/). 

This case is divided into the following sections:
1. [Case Background](#case-background)
2. [Dataset Structure](#dataset-structure)
4. [Part A: Customer Journey](#part-a-customer-journey)
5. [Part B: Data Analysis Questions](#part-b-data-analysis-questions)
6. [Part C: Challenge Payment Question](#part-c-challenge-payment-question)
7. [Part D: Outside The Box Questions](#part-d-outside-the-box-questions)

## Case Background

**Business Background:** Subscription based businesses are super popular and Danny realised that there was a large gap in the market - Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

**Problem Statement:** Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.

**Entity-Relationship Diagram:** Danny has shared his pizza_runner database schema, with the following ER diagram: 
<p align="center">
  <img src="https://github.com/annaxyhu/8-week-sql-challenge/blob/main/Case%20%233%20-%20Foodie-Fi/Case3-ER-diagram.png"/>
</p>

## Dataset Structure

**Table 1: plans**
```sql
CREATE TABLE plans (
	plan_id INT,
    plan_name TEXT,
    price FLOAT
);

INSERT INTO plans
  (plan_id, plan_name, price)
VALUES
  ('0', 'trial', '0'),
  ('1', 'basic monthly', '9.90'),
  ('2', 'pro monthly', '19.90'),
  ('3', 'pro annual', '199'),
  ('4', 'churn', null);
```
***

**Table 2: subscriptions**
```sql
CREATE TABLE subscriptions (
	customer_id INT,
    plan_id TEXT,
    start_date DATE
);

INSERT INTO subscriptions
  (customer_id, plan_id, start_date)
VALUES
  ('1', '0', '2020-08-01'),
  ('1', '1', '2020-08-08'),
  ('2', '0', '2020-09-20'),
  ('2', '3', '2020-09-27'),
  ('3', '0', '2020-01-13'),
  ('3', '1', '2020-01-20'),
  ('4', '0', '2020-01-17'),
  ...
```
***
## Part A: Customer Journey

Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.


## Part B: Data Analysis Questions
**1. How many customers has Foodie-Fi ever had?**

```sql
SELECT COUNT(DISTINCT customer_id) AS customers
FROM subscriptions;
```
Answer: 
```sql
| customers |
| --------- |
| 1000      |

```
***
**2. What is the monthly distribution of trial plan start_date values for our dataset? Use the start of the month as the group by value**
```sql
SELECT MONTH(start_date) AS month, YEAR(start_date) AS year, COUNT(*) AS num_trials
FROM subscriptions
WHERE plan_id = 0
GROUP BY month, year
ORDER BY month, year;
```
Answer: 

![image](https://github.com/user-attachments/assets/8fada58d-92cf-4677-80ab-39cf65415197)

***
**3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.**
```sql
SELECT plan_id, COUNT(*) AS amt_after_2020
FROM subscriptions 
WHERE YEAR(start_date) > 2020
GROUP BY plan_id
ORDER BY plan_id;
```
Answer: 

![image](https://github.com/user-attachments/assets/2a9b0c78-679c-462f-82ae-862946efac61)

***
**4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**

```sql
SELECT 
	COUNT(*) AS cust_count,
    ROUND(COUNT(*)/(SELECT COUNT(DISTINCT customer_id) AS total_cust FROM subscriptions)*100,1) AS churn_percentage
FROM subscriptions
WHERE plan_id = 4;
```
Answer: 
```sql
| cust_count | churn_percentage |
| ---------- | ---------------- |
| 307        | 30.7             |

```

***
**5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?**
```sql
WITH CTE AS (
	SELECT *, 
		LEAD(plan_id,1) OVER( PARTITION BY customer_id ORDER BY plan_id) As next_plan
	FROM subscriptions
)
SELECT COUNT(*) AS num_churn,
	ROUND(COUNT(*)/(SELECT COUNT(DISTINCT customer_id) AS total_cust FROM subscriptions)*100,0) AS percentage_churn
FROM CTE
WHERE plan_id = 0 AND next_plan = 4;
```
Answer: 
```sql
| num_churn | percentage_churn |
| --------- | ---------------- |
| 92        | 9                |
```
***
**6. What is the number and percentage of customer plans after their initial free trial?**
```sql
WITH CTE AS (
	SELECT *, 
		LEAD(plan_id,1) OVER( PARTITION BY customer_id ORDER BY plan_id) As next_plan
	FROM subscriptions
)
SELECT 
	plan_name, 
	COUNT(*) AS num_customers, 
    ROUND(COUNT(*)/(SELECT COUNT(DISTINCT customer_id) AS total_cust FROM subscriptions)*100,2) AS percentage
FROM CTE
JOIN plans
	ON CTE.next_plan = plans.plan_id
WHERE CTE.plan_id = 0 AND next_plan != 0
GROUP BY plan_name;
```
Answer: 

![image](https://github.com/user-attachments/assets/8600792e-2ff3-4d76-b6a8-92911cc2b664)

***
**7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?**

```sql
WITH CTE AS (
SELECT *, 
	LEAD(start_date,1) OVER(PARTITION BY customer_id ORDER BY plan_id) As next_start_date
FROM subscriptions
)
SELECT 
	plan_id,
    plan_name,
	COUNT(*) AS customer_count,
    ROUND(COUNT(*)/(SELECT COUNT(DISTINCT customer_id) AS total_cust FROM subscriptions)*100,1) AS percentage
FROM CTE
JOIN plans USING (plan_id)
WHERE start_date <= '2020-12-31' AND (next_start_date >= '2020-12-31' OR next_start_date IS NULL)
GROUP BY plan_id, plan_name
ORDER BY plan_id;

```

Answer: 

![image](https://github.com/user-attachments/assets/90b01568-b387-4c99-93e7-8bc02322bc6a)

***
**8. How many customers have upgraded to an annual plan in 2020?**

```sql
SELECT COUNT(*) AS num_customers
FROM subscriptions
WHERE plan_id = 3 AND YEAR(start_date) = '2020';
```
Answer:
```sql
| num_customers |
| ------------- |
| 195           |
```

***
**9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?**

```sql
WITH trial_start AS (
	SELECT customer_id, plan_name, start_date
	FROM subscriptions
	JOIN plans USING (plan_id)
	WHERE plan_name = 'trial'
), annual_start AS (
	SELECT customer_id, plan_name, start_date
	FROM subscriptions
	JOIN plans USING (plan_id)
	WHERE plan_name = 'pro annual'
)
SELECT ROUND(AVG(DATEDIFF(a.start_date, t.start_date)),2) AS average_days
FROM trial_start t
JOIN annual_start a USING (customer_id);
```
Answer:
```sql
| average_days |
| ------------ |
| 104.62       |
```
***
**10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)?**

```sql
WITH trial_start_CTE AS (
	SELECT customer_id, plan_name, start_date
	FROM subscriptions
	JOIN plans USING (plan_id)
	WHERE plan_name = 'trial'
), annual_start_CTE AS (
	SELECT customer_id, plan_name, start_date
	FROM subscriptions
	JOIN plans USING (plan_id)
	WHERE plan_name = 'pro annual'
), day_diff_CTE AS (
	SELECT DATEDIFF(a.start_date, t.start_date) AS day_diff
	FROM trial_start_CTE t
	JOIN annual_start_CTE a USING (customer_id)
), group_days_cte AS (
	SELECT *, FLOOR(day_diff/30) AS group_days
    FROM day_diff_CTE
)
SELECT 
	CONCAT((group_days*30)+1, '-', (group_days+1)*30, ' days') AS days,
	COUNT(group_days) as number_days
FROM group_days_cte
GROUP BY group_days
ORDER BY group_days;
```
Answer:

![image](https://github.com/user-attachments/assets/bae54957-d5b0-4498-8450-28669bd51952)

***
**11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**

```sql
WITH CTE AS(
	SELECT *, 
		LEAD(plan_id,1) OVER( PARTITION BY customer_id ORDER BY plan_id) AS next_plan,
        LEAD(start_date,1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS next_start_date
	FROM subscriptions
)
SELECT COUNT(*) as num_customers
FROM CTE
WHERE plan_id = 2 AND next_plan = 1 AND YEAR(next_start_date) = '2020';

```
Answer:
```sql
| num_customers |
| ------------- |
| 0             |
```


***
## Part C: Challenge Payment Question

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by 
each customer in the subscriptions table with the following requirements:

- Monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- Upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- Upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- Once a customer churns they will no longer make payments

## Part D: Outside The Box Questions
1. How would you calculate the rate of growth for Foodie-Fi?
2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?




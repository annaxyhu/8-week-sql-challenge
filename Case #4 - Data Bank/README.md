# Case Study #4: Data Bank
## Introduction

This case study is sourced from DataWithDanny's 8 Week SQL Challenge. For more information on this case, refer to the following link: [Data Bank](https://8weeksqlchallenge.com/case-study-4/). 

This case is divided into the following sections:
1. [Case Background](#case-background)
2. [Dataset Structure](#dataset-structure)
4. [Part A: Customer Nodes Exploration](#part-a-customer-nodes-exploration)
5. [Part B: Customer Transactions](#part-b-customer-transactions)
6. [Part C: Data Allocation Challenge](#part-c-data-allocation-challenge)
7. [Part D: Extra Challenge](#part-d-extra-challenge)

## Case Background

**Business Background:** Danny thought that there should be some sort of intersection between these new age banks, cryptocurrency and the data world…so he decides to launch a new initiative - Data Bank! Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team need your help!

**Problem Statement:** The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need. This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments. 

**Entity-Relationship Diagram:** Danny has shared his data_bank database schema, with the following ER diagram: 
<p align="center">
  <img src="https://github.com/annaxyhu/8-week-sql-challenge/blob/main/Case%20%234%20-%20Data%20Bank/Case4-ER-diagram.png"/>
</p>

## Dataset Structure

## Part A
-- 1. How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id) unique_nodes
FROM customer_nodes;

-- 2. What is the number of nodes per region?
SELECT region_name, COUNT(DISTINCT node_id) num_nodes
FROM customer_nodes
JOIN regions USING (region_id)
GROUP BY region_name;

-- 3. How many customers are allocated to each region?
SELECT region_id, region_name, COUNT(DISTINCT customer_id) num_customers
FROM customer_nodes
JOIN regions USING (region_id)
GROUP BY region_id, region_name
ORDER BY region_id;

-- 4. How many days on average are customers reallocated to a different node?
SELECT DISTINCT start_date
FROM customer_nodes;

SELECT DISTINCT end_date
FROM customer_nodes;

SELECT ROUND(AVG(DATEDIFF(end_date, start_date)),2) avg_days
FROM customer_nodes
WHERE end_date != '9999-12-31';

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

--Q16 - Product Market Share
-- Hard, Amazon, Shopify


--Write a query to find the Market Share at the Product Brand level 
-- for each Territory, for Time Period Q4-2021. 

-- Market Share is the number of Products of a certain Product Brand brand 
-- sold in a territory, divided by the total number of Products sold in this Territory.
--Output the ID of the Territory, name of the Product Brand and the 
-- corresponding Market Share in percentages. 
-- Only include these Product Brands that had at least one sale in a given territory.

--Tables: fct_customer_sales, map_customer_territory, dim_product


-- solution:

-- market_share at the product brand level for each territory
-- market share = no. of product brand sold in  a territory / total no. of products sold in this territtory

-- territory_id | name of product brand | market share in percentages



-- solution:

-- Step 1: Filter the data for Q4-2021 and join the relevant tables to get the required fields
WITH filtered_data AS (
    SELECT 
        m.territory_id, 
        d.prod_brand,
        f.prod_sku_id
    FROM 
        fct_customer_sales f
    JOIN 
        map_customer_territory m ON f.cust_id = m.cust_id
    JOIN 
        dim_product d ON d.prod_sku_id = f.prod_sku_id
    WHERE 
        DATEPART(QUARTER, f.order_date) = 4
        AND DATEPART(YEAR, f.order_date) = 2021
)

-- Step 2: Calculate the total number of products sold per territory
, total_products AS (
    SELECT 
        territory_id,
        COUNT(prod_sku_id) AS total_products_sold
    FROM 
        filtered_data
    GROUP BY 
        territory_id
)

-- Step 3: Calculate the number of products sold per brand in each territory
, brand_sales AS (
    SELECT 
        territory_id, 
        prod_brand, 
        COUNT(prod_sku_id) AS brand_products_sold
    FROM 
        filtered_data
    GROUP BY 
        territory_id, 
        prod_brand
)

-- Step 4: Compute the market share for each product brand within each territory
SELECT 
    b.territory_id,
    b.prod_brand,
    CAST(1.0 * b.brand_products_sold / t.total_products_sold * 100 AS DECIMAL(5, 2))  AS market_share
FROM 
    brand_sales b
JOIN 
    total_products t ON b.territory_id = t.territory_id
WHERE 
    b.brand_products_sold > 0
ORDER BY 
    b.territory_id, 
    b.prod_brand;




-- solution 2:

SELECT * FROM map_customer_territory;

WITH filtered_data AS (
SELECT f.prod_sku_id,
	   m.territory_id,
	   d.prod_brand
FROM fct_customer_sales f
JOIN map_customer_territory m ON f.cust_id = m.cust_id
JOIN dim_product d ON d.prod_sku_id = f.prod_sku_id
	WHERE DATEPART(YEAR, order_date) = 2021
	  AND DATEPART(QUARTER, order_date) = 4
)
-- get the total products sold per territory
, cte_total_sales AS (
SELECT territory_id, 
	   COUNT(prod_sku_id) AS total_sales
FROM filtered_data
GROUP BY territory_id
)
, cte_brand_sales AS (
-- calculate the no of products sold per brand
SELECT territory_id,
	   prod_brand,
	   COUNT(prod_sku_id) AS product_brand_sales
FROM filtered_data
GROUP BY territory_id, prod_brand
)
-- joining both cte_total_sales table with cte_brand_sales 
-- we will have for every territory, a corresponding row that has the
-- total sales for that territory, so that we can perform our division easily
-- for market share, multiply first by a floating point number 1.0 to turn 
-- product_brand_sales to floating point number as well, before the division,
-- then CAST as DECIMAL(5, 2)
SELECT
		t.territory_id,
		b.prod_brand AS product_brand,
		CAST(1.0 * product_brand_sales/total_sales * 100 AS DECIMAL(5,2)) AS market_share
FROM cte_total_sales t
JOIN cte_brand_sales b
ON t.territory_id = b.territory_id
WHERE b.product_brand_sales > 0
ORDER BY t.territory_id, b.product_brand_sales;



-- Output:

--territory_id	product_brand	market_share
--T1	JBL	16.67
--T1	Apple	33.33
--T1	Samsung	50.00
--T2	Apple	25.00
--T2	Samsung	75.00
--T3	Canon	12.50
--T3	Dell	12.50
--T3	JBL	12.50
--T3	GoPro	25.00
--T3	Apple	37.50
--T4	Dell	8.33
--T4	GoPro	8.33
--T4	Samsung	41.67
--T4	Apple	41.67
--T5	Dell	9.09
--T5	Samsung	18.18
--T5	JBL	18.18
--T5	Apple	27.27
--T5	GoPro	27.27
  




-- Q17 - Name to Medal Connection
--Hard, ESPN


--Find the connection between the number of letters in the athlete's 
--first name and the number of medals won for each type for medal, 
--including no medals. Output the length of the name along with the 
--corresponding number of no medals, bronze medals, silver medals, and gold medals.

--Table: olympics_athletes_events


WITH cte_first_name AS (
  SELECT
    id,
    CASE
      WHEN CHARINDEX(' ', name) > 0 THEN SUBSTRING(name, 1, CHARINDEX(' ', name) - 1)
      ELSE name END AS first_name
  FROM
    olympics_athletes_events
)
SELECT
  LEN(first_name) AS first_name_length,
  SUM(CASE WHEN medal IS NULL THEN 1 ELSE 0 END) AS total_no_medals,
  SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS total_bronze_medals,
  SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS total_silver_medals,
  SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS total_gold_medals
FROM
  cte_first_name
  LEFT JOIN olympics_athletes_events oae ON cte_first_name.id = oae.id
GROUP BY
  LEN(first_name)
ORDER BY
  first_name_length;


-- Output:

--first_name_length	total_gold_medals	total_silver_medals	total_bronze_medals	total_no_medals
--2	0	1	0	5
--3	3	1	3	12
--4	6	9	8	27
--5	12	7	2	52
--6	13	12	6	85
--7	5	8	3	35
--8	4	2	3	25
--9	6	3	0	42
--10	0	1	2	3
--12	0	1	0	0
--13	0	0	0	1








--Q18 - Olympic Medals By Chinese Athletes
--Hard, ESPN


--Find the number of medals earned in each category by Chinese athletes 
--from the 2000 to 2016 summer Olympics. For each medal category, 
-- calculate the number of medals for each olympic games along with the 
-- total number of medals across all years. 
-- Sort records by total medals in descending order.

--Table: olympics_athletes_events


-- Step 1: Filter data for Chinese athletes in the summer Olympics between 2000 and 2016, who have won medals
WITH filtered_data AS (
    SELECT 
        medal,
        year
    FROM 
        olympics_athletes_events
    WHERE 
        team = 'China'         -- Filter for athletes from China
        AND season = 'Summer'  -- Filter for summer Olympics
        AND year BETWEEN 2000 AND 2016  -- Filter for the years between 2000 and 2016
        AND medal IS NOT NULL  -- Only consider records where the athlete won a medal
),

-- Step 2: Calculate the number of medals won per year per medal type
medal_count_per_year AS (
    SELECT 
        medal,
        year,
        COUNT(*) AS medal_count  -- Count the number of medals for each type and year
    FROM 
        filtered_data
    GROUP BY 
        medal, year  -- Group by medal type and year to get counts for each combination
),

-- Step 3: Calculate the total number of medals for each type across all years
total_medal_count AS (
    SELECT 
        medal,
        SUM(medal_count) AS total_medal_count  -- Sum the medal counts to get total medals for each type
    FROM 
        medal_count_per_year
    GROUP BY 
        medal  -- Group by medal type to get total counts
)

-- Step 4: Select the required columns and sort the results
SELECT 
    mcp.year,              -- Year of the Olympic games
    mcp.medal,             -- Type of medal (Gold, Silver, Bronze)
    mcp.medal_count,       -- Number of medals for that year and type
    tmc.total_medal_count  -- Total number of medals for that type across all years
FROM 
    medal_count_per_year mcp  -- Join the yearly medal counts with total counts
JOIN 
    total_medal_count tmc
ON 
    mcp.medal = tmc.medal  -- Join on the medal type to include total counts in the results
ORDER BY 
    tmc.total_medal_count DESC,  -- Sort by total medals in descending order
    mcp.year,                    -- Then sort by year
    mcp.medal;                   -- Finally sort by medal type




-- Output:

--year	medal	medal_count	total_medal_count
--2016	Bronze	2	2
--2016	Gold	1	1





-- Q19 - From Microsoft to Google
--Hard, LinkedIn

--Consider all LinkedIn users who, at some point, worked at Microsoft. 
-- For how many of them was Google their next employer right 
-- after Microsoft (no employers in between)?

--Table: linkedin_users


-- Solution 1:

SELECT COUNT(DISTINCT L1.user_id) AS users_moved_from_microsoft_to_google
FROM linkedin_users L1
JOIN 
linkedin_users L2
ON L1.user_id = L2.user_id AND L1.end_date = L2.start_date
WHERE L1.employer = 'Microsoft'
AND L2.employer = 'Google';


-- Output:

--users_moved_from_microsoft_to_google
--1



-- Solution 2:

-- Step 1: Filter for users who have worked at Microsoft and get their Microsoft job details
WITH microsoft_jobs AS (
    SELECT 
        user_id, 
        employer, 
        position, 
        start_date, 
        end_date
    FROM 
        linkedin_users
    WHERE 
        employer = 'Microsoft'
)

-- Step 2: Find the next job after Microsoft for each user
, next_jobs AS (
    SELECT 
        mj.user_id, 
        mj.end_date AS microsoft_end_date,
        nj.employer AS next_employer,
        nj.start_date AS next_start_date
    FROM 
        microsoft_jobs mj
    JOIN 
        linkedin_users nj
    ON 
        mj.user_id = nj.user_id
        AND mj.end_date = nj.start_date
)

-- Step 3: Filter the next jobs to keep only those at Google
SELECT 
    COUNT(DISTINCT user_id) AS users_moved_from_microsoft_to_google
FROM 
    next_jobs
WHERE 
    next_employer = 'Google';







--Q20 - Completed Trip within 168 Hours
--Hard, Uber


--An event is logged in the events table with a timestamp each time 
--a new rider attempts a signup (with an event name 'attempted_su') or 
-- successfully signs up (with an event name of 'su_success').

--For each city and date, determine the percentage of successful signups 
--in the first 7 days of 2022 that completed a trip within 168 hours of the 
--signup date. HINT: driver id column corresponds to rider id column

--Tables: uber_signup_events, uber_trip_details


-- Solution:


-- Notes:
-- Using CAST to extract the date part is generally more efficient than FORMAT.


-- Step 1: Extract relevant data, calculate hours after signup, and filter by completed status and date range
WITH completed_trips AS
(
SELECT s.rider_id, s.city_id, 
	   CAST(s.timestamp AS DATE) AS signup_date,  -- Extracting date part
	   t.actual_time_of_arrival AS arrival_time,
	   t.status AS ride_status,
	   DATEDIFF(HOUR, s.timestamp, t.actual_time_of_arrival) AS hrs_after_signup -- calculating the difference of completed and signup
FROM uber_signup_events s
JOIN uber_trip_details t
ON s.rider_id = t.driver_id
WHERE event_name = 'su_success' 
AND t.status = 'completed' 
AND s.timestamp BETWEEN '2022-01-01 00:00:00' AND '2022-01-07 23:59:59'
)
-- Step 2: Aggregate data by city and date, calculate trips within 168 hours and total completed signups
, cte_hours AS (
SELECT city_id, 
	   signup_date,
	   SUM(CASE WHEN hrs_after_signup <= 168 THEN 1 ELSE 0 END) AS within_168_hours,
	   COUNT(*) AS total_completed_signups
FROM completed_trips
GROUP BY city_id, signup_date
)
-- Step 3: Calculate the percentage of trips completed within 168 hours for each city and date
SELECT city_id,
	   signup_date,
	   CAST(1.0 * within_168_hours / total_completed_signups * 100 AS DECIMAL(5, 2)) AS percentage_within_168_hours
FROM cte_hours
ORDER BY city_id;



-- Output:

--city_id	signup_date	percentage_within_168_hours
--c001	2022-01-01	100.00
--c001	2022-01-02	61.54
--c001	2022-01-04	66.67
--c001	2022-01-05	100.00
--c001	2022-01-06	91.67
--c001	2022-01-07	50.00
--c002	2022-01-01	60.00
--c002	2022-01-02	100.00
--c002	2022-01-03	33.33
--c002	2022-01-04	50.00
--c002	2022-01-05	33.33
--c002	2022-01-06	100.00
--c002	2022-01-07	0.00





--Q21 - Negative Reviews in New Locations
--Hard, Instacart

-- Find stores that were opened in the second half of 2021 with 
-- more than 20% of their reviews being negative. A review is considered 
-- negative when the score given by a customer is below 5. 
-- Output the names of the stores together with the ratio of negative reviews to positive ones.

--Tables: instacart_reviews, instacart_stores


-- Solution:


WITH cte_new_stores AS (
SELECT s.name AS store, 
	   SUM(CASE WHEN r.score < 5 THEN 1 ELSE 0 END) AS negative_reviews,
	   SUM(CASE WHEN r.score >= 5 THEN 1 ELSE 0 END) AS positive_reviews,
	   COUNT(*) AS total_reviews
FROM instacart_reviews r
JOIN instacart_stores s
ON r.store_id =  s.id
WHERE s.opening_date BETWEEN '2021-07-01' AND '2021-12-31'
GROUP BY s.name
)
SELECT store, 
	   CAST(1.0 * negative_reviews/positive_reviews AS DECIMAL(5, 2)) AS negative_to_positive_ratio  
FROM cte_new_stores
WHERE 1.0 * negative_reviews/total_reviews > 0.2
ORDER BY negative_to_positive_ratio DESC;



-- Output:

--store	negative_to_positive_ratio
--Target	4.00
--Best Buy	2.00
--Costco	1.50


-- Explanation:

-- This CTE performs the following:
-- 1. Joins the instacart_reviews and instacart_stores tables to get the store name and review information.
-- 2. Filters the stores that were opened in the second half of 2021 (opening_date between '2021-07-01' and '2021-12-31').
-- 3. Calculates the number of negative reviews (score < 5), positive reviews (score >= 5), and total reviews.
-- 4. Groups the results by store name.

-- The main query:
-- 1. Selects the store name and calculates the ratio of negative reviews to positive reviews.
-- 2. Filters the stores where the ratio of negative reviews to total reviews is greater than 0.2 (20%).
-- 3. Casts the negative_to_positive_ratio as a decimal with 5 digits and 2 decimal places.
-- 4. Orders the results by negative_to_positive_ratio in descending order.







--Q22 - Trips in Consecutive Months
--Hard, Uber

--Find the IDs of the drivers who completed at least one trip a month for at least two months in a row.

--Table: uber_trips



-- Step 1: Calculate monthly trips for each driver
-- Truncate trip_date to the first day of the month using DATETRUNC
-- Count the number of completed trips for each driver in each month
-- Only consider completed trips
-- Group by the truncated month


WITH monthly_trips AS (
    SELECT 
        driver_id, 
        DATETRUNC(month, trip_date) AS month,
        COUNT(*) AS trip_count
    FROM uber_trips
    WHERE is_completed = 1 
    GROUP BY 
        driver_id, 
        DATETRUNC(month, trip_date)
)
-- Step 2: Assign row numbers to each month for each driver
-- Assign a row number to each month for each driver, ordered by month
, ranked_trips AS (
    SELECT 
        driver_id,
        month,
        ROW_NUMBER() OVER (PARTITION BY driver_id ORDER BY month) AS rn
    FROM monthly_trips
)
-- Step 3: Join the table with itself to find consecutive months
-- Join on the driver_id
SELECT DISTINCT t1.driver_id
FROM ranked_trips t1
JOIN ranked_trips t2
ON t1.driver_id = t2.driver_id  
AND t1.rn = t2.rn - 1  -- Ensure we are comparing the current month with the next month in the sequence
AND DATEDIFF(month, t1.month, t2.month) = 1;  -- Check if the two months are consecutive


-- Output:

--driver_id
--1
--4



/*
Explanation of specific steps and functions:

1. DATETRUNC(month, trip_date):
   - Truncates the `trip_date` to the first day of the specified unit, 
   in this case, the month.
   - Purpose: This ensures all dates within the same month are 
   treated as the same value, allowing for easy grouping and comparison of months.

2. ROW_NUMBER() OVER (PARTITION BY driver_id ORDER BY month):
   - ROW_NUMBER() assigns a unique sequential integer to rows 
   within the partition of each driver, ordered by month.
   - Purpose: This provides a way to uniquely identify the sequence 
   of months for each driver, enabling the detection of consecutive months.

3. Joining ranked_trips with itself:
   - The self-join on ranked_trips is used to compare each 
   month with the subsequent month for each driver.
   - t1.rn = t2.rn - 1: Ensures that we are comparing the 
   current month (t1) with the next month (t2) in the sequence.

   - DATEDIFF(month, t1.month, t2.month) = 1: Checks if the 
   difference between the two months is exactly one, confirming they are consecutive.
   
   - Purpose: This step identifies drivers who have trips in at 
   least two consecutive months by leveraging the row numbers and checking the month difference.

By following these steps, the query identifies drivers who have completed 
at least one trip in each of at least two consecutive months.
*/






--Q23 - Minimum Number of Platforms
--Hard, Goldman Sachs, Deloitte


--You are given a day worth of scheduled departure and arrival 
--times of trains at one train station. One platform can only 
--accommodate one train from the beginning of the minute it's 
--scheduled to arrive until the end of the minute it's scheduled to depart. 

--Find the minimum number of platforms necessary to accommodate the entire scheduled traffic.

--Tables: train_arrivals, train_departures


-- Note:
-- use time(0) while importing table in SQL server to show as HH:mm:ss


-- 1. Create a combined table with arrival and departure times, along with a flag for arrival or departure
WITH train_events AS (
  SELECT arrival_time AS event_time, 
		 'arrival' AS event_type,  -- adding a literal column or label 
		 train_id
  FROM train_arrivals
  UNION ALL
  SELECT departure_time AS event_time, 
		 'departure' AS event_type, 
		 train_id
  FROM train_departures
)
-- 2. Sort the events by event_time
, sorted_events AS (
  SELECT event_time, 
		 event_type, 
		 train_id,
         ROW_NUMBER() OVER (ORDER BY event_time) AS row_num  -- ordering the trains present by event_time
  FROM train_events
)
-- 3. Calculate the number of trains present at each event time
, train_count AS (
  SELECT *,
         SUM(CASE WHEN event_type = 'arrival' THEN 1 ELSE -1 END) OVER (ORDER BY row_num) AS trains_present
  FROM sorted_events
)
-- 4. Find the maximum value of trains_present, which is the minimum number of platforms required
SELECT MAX(trains_present) AS minimum_platforms_required
FROM train_count;



-- Output:

--minimum_platforms_required
--5





--Q24 - Find The Most Profitable Location
--Hard, Uber, Noom



--Find the most profitable location. Write a query that calculates 
--the average signup duration and average transaction amount for each 
--location, and then compare these two measures together by taking the 
--ratio of the average transaction amount and average duration for each location.

--Your output should include the location, average duration, average transaction amount, 
--and ratio. Sort your results from highest ratio to lowest.

--Tables: signups, transactions


SELECT s.location, 
       AVG(DATEDIFF(DAY, s.signup_start_date, s.signup_stop_date)) AS avg_duration, 
       AVG(t.amt) AS avg_trans_amt,
       CAST(AVG(t.amt) / AVG(DATEDIFF(DAY, s.signup_start_date, s.signup_stop_date)) AS DECIMAL(5, 2)) AS ratio
FROM signups s
JOIN transactions t
ON s.signup_id = t.signup_id
GROUP BY s.location
ORDER BY ratio DESC;


-- Output:

--location	avg_duration	avg_trans_amt	ratio
--Rio De Janeiro	84	40.525000	0.48
--Mexico City	140	47.627272	0.34
--Houston	92	22.566666	0.25
--Las Vegas	115	25.163157	0.22
--New Jersey	133	29.900000	0.22
--Mendoza	143	24.483333	0.17
--New York	121	18.081818	0.15
--Luxembourg	142	16.718181	0.12





--Q25 - New And Existing Users
--Hard, Microsoft, Apple, IBM


--Calculate the share of new and existing users for each month in the table. 
--Output the month, share of new users, and share of existing users as a ratio.

--New users are defined as users who started using services in the current month 
--(there is no usage history in previous months). Existing users are users who 
--used services in current month, but they also used services in any previous month.

--Assume that the dates are all from the year 2020.
--HINT: Users are contained in user_id column

--Table: fact_events



-- 1. Create a CTE to get distinct user-month combinations
WITH user_months AS (
    SELECT DISTINCT
        user_id,
        DATETRUNC(MONTH, time_id) AS month
    FROM fact_events
)

-- 2. Create a CTE to identify the first month for each user
, user_first_month AS (
    SELECT
        user_id,
        MIN(month) AS first_month
    FROM user_months
    GROUP BY user_id
)

-- 3. Create a CTE to calculate new and existing users for each month
, monthly_users AS (
    SELECT
        um.month,
        COUNT(DISTINCT um.user_id) AS total_users,
        COUNT(DISTINCT CASE WHEN um.month = ufm.first_month THEN um.user_id END) AS new_users,
        COUNT(DISTINCT CASE WHEN um.month > ufm.first_month THEN um.user_id END) AS existing_users
    FROM user_months um
    LEFT JOIN user_first_month ufm ON um.user_id = ufm.user_id
    GROUP BY um.month
)

-- 4. Calculate the final results
SELECT
    FORMAT(month, 'MMMM') AS month,
    CAST(1.0 * new_users / total_users AS DECIMAL(5,2)) AS share_new_users,
    CAST(1.0 * existing_users / total_users AS DECIMAL(5,2)) AS share_existing_users
FROM monthly_users
ORDER BY month;



-- Output:

--month	share_new_users	share_existing_users
--April	0.14	0.86
--February	1.00	0.00
--March	0.29	0.71






--Q26 - 3rd Most Reported Health Issues
--Hard, City of Los Angeles


--Each record in the table is a reported health issue and its 
--classification is categorized by the facility type, size, risk score 
--which is found in the pe_description column.

--If we limit the table to only include businesses with Cafe, Tea, 
--or Juice in the name, find the 3rd most common category (pe_description). 
--Output the name of the facilities that contain 3rd most common category.

--Table: los_angeles_restaurant_health_inspections


SELECT * INTO larhi
FROM los_angeles_restaurant_health_inspections;

WITH filtered_data AS
(
SELECT pe_description, facility_name FROM larhi
WHERE facility_name LIKE '%cafe%'
OR facility_name LIKE '%tea%'
OR facility_name LIKE '%juice%'
)
, ranked_data AS (
SELECT pe_description, 
	   COUNT(facility_name) AS issue_count,
	   RANK() OVER (ORDER BY COUNT(facility_name) DESC) AS rank
FROM filtered_data
GROUP BY pe_description
)
SELECT fd.facility_name AS third_most_common_facilities
FROM filtered_data fd
JOIN ranked_data rd
ON fd.pe_description = rd.pe_description
AND rd.rank = 3;



-- Output:

--third_most_common_facilities
--CAFE SPOT
--SILVER LAKE JUICE BAR
--CONCERT HALL CAFE
--THE COFFEE BEAN & TEA LEAF






--
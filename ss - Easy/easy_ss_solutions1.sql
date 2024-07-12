--Q1: Top Monthly Sellers
-- Easy, Amazon


--You are provided with a transactional dataset from Amazon that contains detailed 
-- information about sales across different products and marketplaces. 
-- Your task is to list the top 3 sellers in each product category for January.

-- The output should contain 'seller_id' , 'total_sales' ,'product_category' , 'market_place', and 'month'.

-- Table: sales_data


WITH AggregatedSales AS (
    SELECT
        seller_id, product_category, market_place,
        SUM(total_sales) AS total_sales,
        month
    FROM
        sales_data
    WHERE
        DATENAME(month, month) = 'January'
    GROUP BY
        seller_id, product_category, market_place, month
),
RankedSellers AS (
    SELECT
        seller_id,
        total_sales,
        product_category,
        market_place,
        month,
        RANK() OVER (PARTITION BY product_category ORDER BY total_sales DESC) AS sales_rank
    FROM
        AggregatedSales
)
SELECT
    seller_id, total_sales, product_category, market_place, month
FROM
    RankedSellers
WHERE
    sales_rank <= 3
ORDER BY
    product_category,
    sales_rank;



-- Output:

--seller_id	total_sales	product_category	market_place	month
--s195	59932.35	books	de	2024-01-01
--s728	29158.51	books	us	2024-01-01
--s918	24286.4	books	uk	2024-01-01
--s483	49361.62	clothing	uk	2024-01-01
--s790	31050.13	clothing	in	2024-01-01
--s375	18107.08	clothing	de	2024-01-01
--s891	48847.68	electronics	de	2024-01-01
--s863	46652.67	electronics	us	2024-01-01
--s486	37009.18	electronics	us	2024-01-01
--s712	43739.86	toys	in	2024-01-01
--s830	39169.01	toys	us	2024-01-01
--s749	36277.83	toys	de	2024-01-01
--s123	36277.83	toys	uk	2024-01-01


-- Explanation:

-- Step 1: Create a Common Table Expression (CTE) named AggregatedSales to aggregate the total sales
-- Group by seller_id, product_category, market_place, and month

-- Step 2: Create a CTE named RankedSellers to rank sellers within each product category

--The RANK() window function is used to assign a rank to each seller within 
--their respective product category, ordering by total_sales in descending order. 
--This accounts for ties by assigning the same rank to sellers with identical sales figures.

-- Step 3: Select the top 3 sellers for each product category

-- Order the results by product category
-- Then order by the rank within each product category






--Q2: Aggregate Listening Data
--Easy, Spotify


--You're tasked with analyzing a Spotify-like dataset that captures user listening habits.
--For each user, calculate the total listening time and the count of unique songs 
-- they've listened to. In the database duration values are displayed in seconds. 
-- Round the total listening duration to the nearest whole minute.

--The output should contain three columns: 'user_id', 'total_listen_duration', 
--and 'unique_song_count'.

--Table: listening_habits



SELECT user_id, 
	   ROUND((SUM(listen_duration) / 60), 0) AS total_listen_duration, 
	   COUNT(DISTINCT song_id) AS unique_song_count
FROM listening_habits
GROUP BY user_id;


-- Output:

--user_id	total_listen_duration	unique_song_count
--101	8	2
--102	5	2
--103	6	1
--104	6	2
--105	4	1
--106	3	1
--107	4	1
--108	9	2
--109	0	1



-- Explanation:
-- Calculate the total listen duration in hours, rounded to the nearest integer
-- Count the number of unique songs listened by each user
-- The DISTINCT keyword is used within the COUNT function to ensure 
-- that only unique song_id values are counted for each user.
-- This means that even if a user has listened to the same song multiple 
-- times, each song will only be counted once in the unique_song_count column
-- Group the results by user_id




--Q3 - Movie Duration Match
--Easy, Amazon

--As a data scientist at Amazon Prime Video, you are tasked 
-- with enhancing the in-flight entertainment experience for 
-- Amazon’s airline partners. 

-- Your challenge is to develop a feature that suggests individual 
-- movies from Amazon's content database that fit within a given 
-- flight's duration. 

-- For flight 101, find movies whose runtime is less than 
-- or equal to the flight's duration.


--The output should list suggested movies for the flight, 
-- including 'flight_id', 'movie_id', and 'movie_duration'."

--Tables: entertainment_catalog, flight_schedule
 

-- Step 1: Select movies that fit within the flight's duration
SELECT 
    fs.flight_id, 
    ec.movie_id,  
    ec.duration  
FROM 
    entertainment_catalog ec
JOIN 
    flight_schedule fs  
ON 
    ec.duration <= fs.flight_duration -- Join condition: movie duration should be less than or equal to flight duration
WHERE 
    fs.flight_id = 101; -- Filter the results to only include the flight with ID 101


-- Output:

--flight_id	movie_id	duration
--101	1	120
--101	2	90
--101	3	60
--101	4	150
--101	5	110
--101	6	95
--101	7	100
--101	8	85
--101	9	75
--101	10	105



/*
Explanation:
	JOIN Clause:
   - `ec.movie_duration <= fs.flight_duration`: This condition ensures that only 
   - the movies with a duration less than or equal to the flight duration are considered.
*/






--Q4 - Peak Online Time
--Easy, Amazon


--You are given a dataset from Amazon that tracks and aggregates 
--user activity on their platform in certain time periods. 
--For each device type, find the time period with the highest number of active users.

--The output should contain 'user_count', 'time_period', and 'device_type', 
--where 'time_period' is a concatenation of 'start_timestamp' and 'end_timestamp', 
--like ; "start_timestamp to end_timestamp".

--Table: user_activity


-- Step 1: Create a CTE (Common Table Expression) to find the maximum user count for each device type
WITH max_cte AS (
    SELECT 
        device_type, 
        MAX(user_count) AS max_user_count 
    FROM user_activity 
    GROUP BY device_type
)
-- Step 2: Select the user count, concatenated time period, and device type
-- Join on rows where the user count matches the maximum user count for that device type.
-- Join on the device type.
SELECT 
    u.user_count, 
    CONCAT(u.start_timestamp, ' to ', u.end_timestamp) AS time_period, 
    u.device_type
FROM 
    max_cte m
JOIN 
    user_activity u
ON 
    m.device_type = u.device_type
AND 
    m.max_user_count = u.user_count; 
	

--	user_count	time_period	device_type
--100	Jan 25 2024  5:18AM to Jan 25 2024  6:06AM	tablet
--100	Jan 25 2024  1:22AM to Jan 25 2024  3:13AM	tablet
--100	Jan 25 2024  4:38PM to Jan 25 2024  6:07PM	mobile
--100	Jan 25 2024 10:14AM to Jan 25 2024 11:04AM	desktop







--
--Q1. Friday's Likes Count
-- Medium , Meta

--You have access to Facebook's database which includes several tables relevant to user interactions. 
--For this task, you are particularly interested in tables that store data about 
--user posts, friendships, and likes. 
--Calculate the total number of likes made on friend posts on Friday.

--The output should contain two different columns 'likes' and 'date'.

-- Tables: user_posts, friendships, likes



SELECT 
    COUNT(*) AS likes, 
    FORMAT(l.date_liked, 'yyyy-MM-dd') AS date
FROM 
    likes l
JOIN 
    user_posts u ON l.post_id = u.post_id
JOIN 
    friendships f ON f.user_name1 = l.user_name AND f.user_name2 = u.user_name
WHERE 
    FORMAT(l.date_liked, 'dddd') = 'Friday'
GROUP BY l.date_liked;



-- Output:

--likes	date
--2	2024-01-05
--1	2024-01-12
--1	2024-01-19




-- Explanation:

-- JOIN friendships f ON u.user_name = f.user_name2

--By joining likes, user_posts, and friendships:

--l.user_name represents the user who liked the post.
--u.user_name represents the user who posted the post.
--The join condition f.user_name1 = l.user_name AND f.user_name2 = u.user_name 
--checks if there is a row in the friendships table where f.user_name1 is the liker 
--and f.user_name2 is the poster, indicating that the liker is friends with the poster.


--COUNT(*) AS likes: Counts the number of likes.
--FORMAT(l.date_liked, 'dddd') AS date: Formats the date of the like to get the day of the week.
--JOIN user_posts u ON l.post_id = u.post_id: Joins likes with the posts they liked.
--JOIN friendships f ON f.user_name1 = l.user_name AND f.user_name2 = u.user_name: 
-- Checks if the liker and the poster are friends.


--WHERE FORMAT(l.date_liked, 'dddd') = 'Friday': Filters the likes to only those made on Fridays.
--GROUP BY l.date_liked: Groups the results by the date of the like.
--This ensures that only likes made by friends on Fridays are counted.


-- More Explanations:

--In other words, it's looking for a row where the first user (f.user_name1) 
--is the one who liked the post (l.user_name), 
--and the second user (f.user_name2) is the one who posted the post (u.user_name).

--So, it's not about a specific order of poster or liker inside the friendships table. 
--It's more about ensuring that there is a row in the friendships table where 
--the two users mentioned are connected as friends, regardless of their position 
--in the user_name1 and user_name2 columns. This allows for flexibility in how 
--friendships are stored and checked in the database





--Q2: Population Density
-- Medium, Deloitte


--You are working on a data analysis project at Deloitte where you need 
-- to analyze a dataset containing information
-- about various cities. Your task is to calculate the population density 
-- of these cities, rounded to the nearest integer, and identify the cities 
-- with the minimum and maximum densities.
--The population density should be calculated as (Population / Area).


--The output should contain 'city', 'country', 'density'.

--Table: cities_population



WITH cte AS
(
SELECT city, country,
       CASE WHEN area = 0 THEN NULL ELSE ROUND(population / area, 0) END AS density
FROM cities_population
)
SELECT city, country, density
FROM cte
WHERE density = (SELECT MIN(density) FROM cte)
   OR density = (SELECT MAX(density) FROM cte);


-- Output:

--city	country	density
--Gotham	Islander	5000
--Rivertown	Plainsland	20
--Lakecity	Forestland	20



-- Explanation:

-- This SQL query calculates the density (population per unit area) for each city in the cities_population table.
-- use a common table expression (CTE) named 'cte' is used to calculate the density for each city.
-- It selects the city, country, and calculates the density using the population and area columns.
-- If the area is 0, it assigns NULL to density to avoid division by zero errors.
-- Otherwise, it calculates the density by dividing the population by the area and rounds it to the nearest integer.

-- The main query selects cities from the CTE where the density is either the minimum or maximum density.
-- It selects city, country, and density columns from the CTE.
-- To retrieve the minimum and maximum densities for cities, use a subquery with MIN and MAX functions.
-- It filters rows where the density is equal to the minimum or maximum density calculated in the CTE
-- This gives us the rows representing cities with the minimum and maximum densities.






-- Q3: Common Friends Script
--Medium, Google


--You are analyzing a social network dataset at Google. 
-- Your task is to find mutual friends between two users, Karl and Hans. 
-- There is only one user named Karl and one named Hans in the dataset.

-- The output should contain 'user_id' and 'user_name' columns.

-- Tables: users, friends


-- Step 1: Identify the user IDs for Karl and Hans
WITH KarlID AS (
    SELECT user_id
    FROM users
    WHERE user_name = 'Karl'
),
HansID AS (
    SELECT user_id
    FROM users
    WHERE user_name = 'Hans'
)
-- Step 2: Find mutual friends
SELECT u.user_id, u.user_name
FROM friends f1
JOIN friends f2 ON f1.friend_id = f2.friend_id
JOIN users u ON f1.friend_id = u.user_id
WHERE f1.user_id = (SELECT user_id FROM KarlID)
AND f2.user_id = (SELECT user_id FROM HansID);


-- Output:

--user_id	user_name
--3	Emma



-- Explanation:

-- The CTEs KarlID and HansID store the user IDs of Karl and Hans.

--Find mutual friends:

--The friends table is aliased as f1 to represent the friends of Karl 
-- and f2 to represent the friends of Hans.
--We join f1 and f2 on friend_id to find common friends between Karl and Hans.
--The users table is joined with f1 to get the user details of the mutual friends.
--The WHERE clause ensures that f1 is filtering friends of Karl and f2 is filtering friends of Hans.

-- Why Two friends Tables?
--friends f1: Represents the friends of Karl.
--friends f2: Represents the friends of Hans.
--By joining f1 and f2 on friend_id, we are looking for friends who are 
--common to both Karl and Hans.

-- This approach is effective for finding mutual friends between two users 
--by using a self-join on the friends table.





--Q4 - Expensive Projects
--Medium, Microsoft


--Given a list of projects and employees mapped to each project, 
--calculate by the amount of project budget allocated to each employee . 
--The output should include the project title and the project budget 
--rounded to the closest integer. Order your list by projects with 
--the highest budget per employee first.


-- Tables: ms_projects, ms_emp_projects


SELECT p.title AS project_title, 
	   ROUND((p.budget / COUNT(e.emp_id)), 0) AS budget_per_employee
FROM ms_projects p
JOIN ms_emp_projects e
ON p.id = e.project_id
GROUP BY p.title, p.budget
ORDER BY budget_per_employee DESC;


-- Output:

--project_title	budget_per_employee
--Project8	24642
--Project49	24387
--Project15	24058
--Project10	23793
--Project19	22493
--Project47	22386
--Project45	22265
--Project3	21954
--Project28	21828
--Project13	21619
--Project40	21470
--Project31	20990
--Project48	20814
--Project23	20807
--Project6	20805
--Project25	19454
--Project5	18134
--Project26	18095
--Project7	17001
--Project2	16243
--Project9	16170
--Project33	15055
--Project14	15007
--Project1	14749
--Project39	12971
--Project43	12872
--Project41	12693
--Project42	12467
--Project21	12165
--Project30	12005
--Project35	11965
--Project44	11442
--Project38	10822
--Project16	9961
--Project20	9748
--Project17	9530
--Project50	9457
--Project22	9295
--Project34	8172
--Project4	7888
--Project27	6307
--Project32	6178
--Project24	5959
--Project11	5852
--Project29	5467
--Project12	5234
--Project18	5151
--Project46	4912
--Project37	4403
--Project36	2338






--Q5 - Email Details Based On Sends
--Medium, Google


--Find all records from days when the number of distinct users receiving emails 
--was greater than the number of distinct users sending emails

--Table: google_gmail_emails



WITH senders AS (
    SELECT day, COUNT(DISTINCT from_user) AS distinct_senders
    FROM google_gmail_emails
    GROUP BY day
),
receivers AS (
    SELECT day, COUNT(DISTINCT to_user) AS distinct_receivers
    FROM google_gmail_emails
    GROUP BY day
)
SELECT s.day
FROM senders s
JOIN receivers r ON s.day = r.day
WHERE r.distinct_receivers > s.distinct_senders;


-- Output:

--day
--1
--4
--6
--8
--9





-- Explanation:
-- Step 1: Count distinct users receiving emails each day
-- Step 2: Count distinct users sending emails each day
-- Step 3: Compare the counts and find the days where receivers > senders






-- Q6 - Highest Priced Wine In The US
--Medium, Wine Magazine



--Find the highest price in US country for each variety produced in 
--English speaking regions, but not in Spanish speaking regions, with taking 
--into consideration varieties that have earned a minimum of 90 points for every country 
--they're produced in.
--Output both the variety and the corresponding highest price.

--Let's assume the US is the only English speaking region in the dataset, 
--and Spain, Argentina are the only Spanish speaking regions in the dataset. 

--Let's also assume that the same variety might be listed under several countries 
--so you'll need to remove varieties that show up in both the US and in Spanish speaking countries.

--Table: winemag_p1




-- Solution 1:


-- Step 1: Find varieties that have a minimum of 90 points in every country they are produced in
WITH min_90_points AS (
    SELECT variety
    FROM winemag_p1
    GROUP BY variety
    HAVING MIN(points) >= 90
),
-- Step 2: Identify varieties that are produced in Spanish speaking countries (Spain, Argentina)
spanish_varieties AS (
    SELECT DISTINCT variety
    FROM winemag_p1
    WHERE country IN ('Spain', 'Argentina')
),
-- Step 3: Filter out varieties that are produced in Spanish speaking countries
non_spanish_varieties AS (
    SELECT variety
    FROM min_90_points
    WHERE variety NOT IN (SELECT variety FROM spanish_varieties)
)
-- Step 4: Find the highest price in the US for each variety that is not produced in Spanish speaking countries
-- and has earned a minimum of 90 points in every country it is produced in
SELECT variety, MAX(price) AS highest_price
FROM winemag_p1
WHERE country = 'US'
  AND variety IN (SELECT variety FROM non_spanish_varieties)
GROUP BY variety;



-- Output:

--variety	highest_price
--Semillon	20
--Zinfandel	26



-- Solution 2:

-- Step 1: Create a CTE to retrieve the relevant columns from the wine dataset

WITH wine_data AS (
    SELECT country, points, price, variety
    FROM winemag_p1
),

-- Step 2: Create a CTE that filters out Spanish speaking countries
excluded_spanish_countries AS (
    SELECT * FROM wine_data
    WHERE country NOT IN ('Spain', 'Argentina')
),

-- Step 3: Identify varieties present in both US and Spanish-speaking countries
common_varieties AS (
    SELECT DISTINCT us.variety
    FROM wine_data us
    JOIN wine_data sp
    ON us.variety = sp.variety
    WHERE us.country = 'US'
      AND sp.country IN ('Spain', 'Argentina')
),

-- Step 4: Create a CTE to filter varieties that are not common with Spanish-speaking countries
-- and have a minimum of 90 points
required_varieties AS (
    SELECT variety
    FROM excluded_spanish_countries
    WHERE variety NOT IN (SELECT variety FROM common_varieties)
    GROUP BY variety
    HAVING MIN(points) >= 90
)
-- Step 5: Select the highest price for each required variety in the US
	SELECT wd.variety AS variety, 
		   MAX(wd.price) AS highest_price
	FROM wine_data wd
	JOIN required_varieties rv
	ON wd.variety = rv.variety
	WHERE wd.country = 'US'
	GROUP BY wd.variety;





-- Q7 - Most Active Users On Messenger
--Medium, Meta


--Meta/Facebook Messenger stores the number of messages between users 
--in a table named 'fb_messages'. 
--In this table 'user1' is the sender, 'user2' is the receiver, and 'msg_count' 
--is the number of messages exchanged between them.
--Find the top 10 most active users on Meta/Facebook Messenger by counting 
--their total number of messages sent and received. 

--Your solution should output usernames and the count of the 
--total messages they sent or received

--Table: fb_messages


-- Solution 1:


WITH sent_messages AS 
(
SELECT user1 AS fb_user, SUM(msg_count) AS total_msg_sent
FROM fb_messages
GROUP BY user1
)
, received_messages AS (
SELECT user2 AS fb_user, SUM(msg_count) AS total_msg_received
FROM fb_messages
GROUP BY user2
)
, combined_messages AS (
SELECT 
        COALESCE(s.fb_user, r.fb_user) AS fb_user, 
        COALESCE(total_msg_sent, 0) AS total_msg_sent, 
        COALESCE(total_msg_received, 0) AS total_msg_received,
        COALESCE(total_msg_sent, 0) + COALESCE(total_msg_received, 0) AS total_msg
    FROM sent_messages s
    FULL OUTER JOIN received_messages r
    ON s.fb_user = r.fb_user
)
SELECT TOP 10 fb_user, 
	   total_msg
	FROM combined_messages
	ORDER BY total_msg DESC;


-- Explanation:

-- The COALESCE function in SQL returns the first non-NULL value 
-- from the list of arguments provided. It can be used with 
-- any data type, not just numerical values


-- We also Combine the sent and received messages using a 
-- FULL OUTER JOIN to ensure all users are included, 
-- whether they only sent or only received messages.


-- Output:

--fb_user	total_msg
--tanya26	57
--johnmccann	47
--craig23	43
--herringcarlos	37
--wangdenise	36
--trobinson	35
--lindsey38	31
--lfisher	29
--jennifer11	28
--ucrawford	26


-- Solution 2:

SELECT TOP 10 fb_user, SUM(total_msgs) AS total_messages
FROM (
    SELECT user1 AS fb_user, SUM(msg_count) AS total_msgs
    FROM fb_messages
    GROUP BY user1
    UNION ALL
    SELECT user2 AS fb_user, SUM(msg_count) AS total_msgs
    FROM fb_messages
    GROUP BY user2
) combined_messages
GROUP BY fb_user
ORDER BY total_messages DESC;



-- step 1: calculate the total number of messages sent by each user.
-- step 2: calculate the total number of messages received by each user
-- step 3: combine the results of the two subqueries, stacking them on top of each other using UNION ALL
-- step 4: Group the combined results by fb_user and sums up the total messages for each user.






-- Q8 - Find whether the number of seniors works at Meta/Facebook is higher 
-- than its number of USA based employees
--Medium, Meta


--Find whether the number of senior workers (i.e., more experienced) at Meta/Facebook 
-- is higher than number of USA based employees at Facebook/Meta.
--If the number of seniors is higher then output as 'More seniors'. 
-- Otherwise, output as 'More USA-based'.

--Table: facebook_employees


SELECT 
	 CASE WHEN no_of_seniors > no_of_usa_employees THEN 'More Seniors' ELSE 'More USA-based' END AS result
FROM
(
	SELECT SUM(CASE WHEN location = 'USA' THEN 1 ELSE 0 END) AS no_of_usa_employees,
		   SUM(CASE WHEN is_senior = 1 THEN 1 ELSE 0 END) AS no_of_seniors
	FROM fb_employees) emp_counts;


-- Output:

--result
--More Seniors




--Q9 - Departments With Less Than 4 Employees
--Medium, Amazon


--Find departments with less than 4 employees.

--Output the department along with the corresponding number of workers.

--Table: worker

SELECT department, no_of_workers
FROM
(
SELECT department, COUNT(*) AS no_of_workers 
FROM worker
GROUP BY department
) worker_count
WHERE no_of_workers < 4



-- Output:

--department	no_of_workers
--Account	3




-- Q10 - Macedonian Vintages

--Medium, Wine Magazine


--Find the vintage years of all wines from the country of Macedonia. 
--The year can be found in the 'title' column. Output the wine (i.e., the 'title') 
--along with the year. The year should be a numeric or int data type.

--Table: winemag_p2


SELECT title, 
	   CAST(
			SUBSTRING(title, PATINDEX('%[0-9][0-9][0-9][0-9]%', title), 4) 
				AS INT) AS year
FROM winemag_p2
WHERE country = 'Macedonia';



-- Output:

--title	year
--Macedon 2010 Pinot Noir (Tikves)	2010
--Stobi 2011 Macedon Pinot Noir (Tikves)	2011
--Stobi 2011 Veritas Vranec (Tikves)	2011
--Bovin 2008 Chardonnay (Tikves)	2008
--Stobi 2014 uilavka (Tikves)	2014


--Explanation:

--PATINDEX('%[0-9][0-9][0-9][0-9]%', title): Finds the position of the first 
--occurrence of a four-digit number in the wine_name column. [0-9] matches any digit, 
--and [0-9][0-9][0-9][0-9] matches exactly four digits in a row.

--SUBSTRING(title, position, 4): Extracts a substring starting at the position 
--found by PATINDEX and with a length of 4 characters (the year).




--Q11 - Find the month which had the lowest number of inspections across all years
--Medium, City of Los Angeles


--Find the month which had the lowest number of inspections across all years.
--Output the number of inspections along with the month.

--Table: los_angeles_restaurant_health_inspections

SELECT TOP 1 FORMAT(activity_date, 'yyyy-MMMM') AS date, 
	   COUNT(*) AS no_of_inspections 
FROM larhi
GROUP BY FORMAT(activity_date, 'yyyy-MMMM')
ORDER BY no_of_inspections ASC;


-- Output:

--date	no_of_inspections
--2017-September	3





-- Q12 - Caller History
--Medium, Amazon, Etsy


--Given a phone log table that has information about callers' 
--call history, find out the callers whose first and last calls were 
--to the same person on a given day. Output the caller ID, recipient ID, and the date called.

--Table: caller_history


-- Step 1: Identify the first and last call times for each caller on each day
WITH call_times AS (
    SELECT 
        caller_id, 
        recipient_id,
        CAST(date_called AS DATE) AS call_date,
        MIN(date_called) AS first_call,
        MAX(date_called) AS last_call
    FROM 
        caller_history
    GROUP BY 
        caller_id, 
        recipient_id,
        CAST(date_called AS DATE)
),

-- Step 2: Check if the recipient for the first and last call is the same
matching_calls AS (
    SELECT 
        c1.caller_id, 
        c1.recipient_id AS first_recipient,
        c2.recipient_id AS last_recipient,
        c1.call_date
    FROM 
        call_times c1
    JOIN 
        call_times c2
    ON 
        c1.caller_id = c2.caller_id
        AND c1.call_date = c2.call_date
        AND c1.first_call = c2.last_call
)

-- Step 3: Output the caller ID, recipient ID, and the date called
SELECT 
    caller_id, 
    first_recipient AS recipient_id,
    call_date
FROM 
    matching_calls
WHERE 
    first_recipient = last_recipient
ORDER BY 
    caller_id, 
    call_date;


-- Output:

--caller_id	recipient_id	call_date
--1	2	2022-01-01
--1	3	2022-01-01
--1	4	2022-01-01
--2	3	2022-07-05
--2	5	2022-07-06
--2	5	2022-08-02




--
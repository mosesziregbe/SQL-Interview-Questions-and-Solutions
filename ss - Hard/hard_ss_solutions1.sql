
--Q1: Friday Purchases
--Hard, IBM


--IBM is working on a new feature to analyze user purchasing behavior for 
--all Fridays in the first quarter of the year. For each Friday separately, 
--calculate the average amount users have spent per order. The output should 
-- contain the week number of that Friday and average amount spent.

--Table: user_purchases


SELECT DATEPART(WEEK, date) AS week_number,
       AVG(amount_spent) AS average_amount_spent
FROM user_purchases
WHERE DATEPART(WEEKDAY, date) = 6 -- 6 corresponds to Friday
      AND DATEPART(QUARTER, date) = 1 -- First quarter of the year
      AND YEAR(date) = 2023 -- Year of interest
GROUP BY DATEPART(WEEK, date)
ORDER BY week_number;


-- Output:

-- week_number	average_amount_spent
--2	742.5
--4	424
--5	590
--8	554
--11	650



-- Explanations:

--We're selecting the week number using DATEPART(WEEK, date) and 
--calculating the average amount spent using AVG(amount_spent).
--The WHERE clause filters the data for Fridays (DATEPART(WEEKDAY, date) = 6), 
--the first quarter of the year (DATEPART(QUARTER, date) = 1), and the year 2023 (YEAR(date) = 2023).
--We're grouping the results by the week number and ordering them by the week number.
--Remember to adjust the year in the WHERE clause according to your dataset's year range






-- Q2: - Days At Number One
-- Hard, Spotify



--Find the number of days a US track has stayed in the 1st position for both 
-- the US and worldwide rankings on the same day. 
-- Output the track name and the number of days in the 1st position. 
-- Order your output alphabetically by track name.

--If the region 'US' appears in dataset, it should be included in the worldwide ranking.

--Tables: spotify_daily_rankings_2017_us, spotify_worldwide_daily_song_ranking


SELECT 
    d.trackname, 
    COUNT(*) AS number_of_days
FROM 
    spotify_daily_rankings d
JOIN 
    spotify_worldwide_rankings w
ON 
    d.date = w.date 
    AND d.trackname = w.trackname
WHERE 
    d.position = 1 
    AND w.position = 1
GROUP BY 
    d.trackname
ORDER BY 
    d.trackname;



-- Output:

--trackname	number_of_days
--Bad and Boujee (feat. Lil Uzi Vert)	1
--HUMBLE.	3


-- Explanation:
--Join the spotify_daily_rankings_2017_us and spotify_worldwide_daily_song_ranking tables 
--on date and track_name.

--Ensure that both positions are 1 (indicating that the track is in the 
--1st position in both rankings on the same day).

--Group the results by track_name and count the occurrences (number of days).
--Order the results by track_name




--Q3 - Comments Distribution
--Hard, Meta

-- Write a query to calculate the distribution of comments by the count of users 
-- that joined Meta/Facebook between 2018 and 2020, for the month of January 2020.


--The output should contain a count of comments and the corresponding 
--number of users that made that number of comments in Jan-2020. 
--For example, you'll be counting how many users made 1 comment, 2 comments, 3 comments, 4 comments, 
-- etc in Jan-2020. 

-- Your left column in the output will be the number of comments while 
--your right column in the output will be the number of users. 
--Sort the output from the least number of comments to highest.

--To add some complexity, there might be a bug where a user post is dated 
--before the user join date. You'll want to remove these posts from the result.



-- my solution


WITH valid_comments AS
(
SELECT c.user_id, COUNT(*) AS comments_count
FROM fb_comments c
JOIN fb_users u
ON c.user_id = u.id
WHERE
    DATEPART(MONTH, c.created_at) = 1 -- January
    AND YEAR(c.created_at) = 2020 -- Year 2020
	AND c.created_at >= u.joined_at
	AND YEAR(u.joined_at) BETWEEN 2018 AND 2020
GROUP BY c.user_id
),
comment_distribution AS
(
SELECT comments_count, COUNT(user_id) AS user_counts
FROM valid_comments
GROUP BY comments_count
)
SELECT comments_count AS number_of_comments,
user_counts AS number_of_users
FROM comment_distribution
ORDER BY number_of_comments;



-- Output:

--number_of_comments	number_of_users
--1	4
--2	6
--3	1
--4	1
--6	1



-- Explanation:

--  valid_comments CTE:

--This CTE retrieves the count of comments for each user by joining 
--the fb_comments and fb_users tables.

--The WHERE clause applies several filters:

--u.joined_at <= c.created_at: Ensures that the comment's creation date 
--is after or equal to the user's join date (excludes comments made before the user joined).
--DATEPART(MONTH, c.created_at) = 1: Filters for comments made in January.
--YEAR(c.created_at) = 2020: Filters for comments made in the year 2020.
--YEAR(u.joined_at) BETWEEN 2018 AND 2020: Filters for users who joined between 2018 and 2020.


--The GROUP BY c.user_id clause aggregates the comments for each user, 
--and the COUNT(*) function calculates the number of comments per user.


--comment_distribution CTE:

--This CTE calculates the distribution of comments by counting the 
-- number of users for each distinct comment_count value from the ValidComments CTE.
--The GROUP BY comment_count clause groups the rows by the comment_count value.
--The COUNT(user_id) function counts the number of distinct user_id values 
-- for each comment_count group, giving the count of users who made that number of comments.


--Final SELECT statement:

--This statement selects the comment_count as number_of_comments 
-- and user_count as number_of_users from the CommentDistribution CTE.
--The ORDER BY number_of_comments clause sorts the results by the 
--number of comments in ascending order.



--The output will have two columns:

--number_of_comments: The number of comments made by users.
--number_of_users: The count of users who made that number of comments in January 2020.






--Q4 - Find the genre of the person with the most number of oscar winnings
--Hard, Netflix

--Find the genre of the person with the most number of oscar winnings.
--If there are more than one person with the same number of oscar wins, 
-- return the first one in alphabetic order based on their name. 
-- Use the names as keys when joining the tables.

--Tables: oscar_nominees, nominee_information



WITH oscar_cte AS 
(
SELECT o.nominee, 
	   n.top_genre,
	   SUM(CASE WHEN o.winner = 1 THEN 1 ELSE 0 END) AS no_of_winnings
FROM oscar_nominees o
JOIN nominee_information n
ON o.nominee = n.name
GROUP BY o.nominee, n.top_genre
)
SELECT TOP 1 nominee, top_genre 
FROM oscar_cte
WHERE no_of_winnings = (SELECT MAX(no_of_winnings) FROM oscar_cte);


-- Output:

--nominee	top_genre
--Christoph Waltz	Drama





--Q5 -  Algorithm Performance
--Hard, Meta

-- Meta/Facebook is developing a search algorithm that will allow users 
-- to search through their post history. You have been assigned to evaluate 
-- the performance of this algorithm.


--We have a table with the user's search term, search result positions, 
--and whether or not the user clicked on the search result.


--Write a query that assigns ratings to the searches in the following way:

--•	If the search was not clicked for any term, assign the search with rating=1
--•	If the search was clicked but the top position of clicked terms 
-- was outside the top 3 positions, assign the search a rating=2

--•	If the search was clicked and the top position of a clicked term 
-- was in the top 3 positions, assign the search a rating=3


--As a search ID can contain more than one search term, select 
-- the highest rating for that search ID. 
-- Output the search ID and its highest rating.


--Example: The search_id 1 was clicked (clicked = 1) and its position 
-- is outside of the top 3 positions (search_results_position = 5), therefore its rating is 2.

-- Table: fb_search_events

SELECT * FROM fb_search_events;

WITH search_rankings AS
(
  SELECT *,
  CASE WHEN clicked = 0 THEN 1
       WHEN clicked = 1 AND search_results_position > 3 THEN 2
       WHEN clicked = 1 AND search_results_position <= 3 THEN 3
  END AS rating
  FROM fb_search_events
)
SELECT search_id, MAX(rating) AS highest_ratings
FROM search_rankings
GROUP BY search_id;


SELECT 
  search_id,
  MAX(CASE WHEN clicked = 0 THEN 1
          WHEN clicked = 1 AND search_results_position > 3 THEN 2
          WHEN clicked = 1 AND search_results_position <= 3 THEN 3
          ELSE 0 END) AS highest_rating
FROM 
  fb_search_events
GROUP BY 
  search_id;



-- Output:

--search_id	highest_rating
--1	2
--2	2
--3	3
--5	3
--6	3
--10	1
--11	1
--14	3
--17	1
--18	3
--38	1
--40	2
--41	1
--42	2
--43	1
--44	2
--50	1
--51	2
--52	3
--53	3
--56	1
--57	3
--59	1
--60	1
--63	3
--65	1
--68	3
--69	3
--70	2
--74	1
--76	3
--77	2
--80	1
--81	1
--82	2
--83	2
--84	3
--85	1
--87	1
--90	3
--91	2
--92	1
--93	2
--96	1
--97	3
--99	3
--120	3
--123	3
--182	1
--321	1
--331	2
--368	3
--649	1
--670	2
--696	1
--720	3
--738	3
--739	1
--857	1
--953	2





-- Q6 -  Find the number of employees who received the bonus and who didn't
--Hard, Dell, Microsoft


--Find the number of employees who received the bonus and who didn't. 
--Bonus values in employee table are corrupted so you should use 
--values from the bonus table. 
--Be aware of the fact that employee can receive more than one bonus.
--Output value inside has_bonus column (1 if they had bonus, 0 if not) 
--along with the corresponding number of employees for each.

-- Tables: employee, bonus


SELECT COUNT(*) AS num_employees,
	   CASE WHEN b.worker_ref_id IS NULL THEN 0
	   ELSE 1 END AS has_bonus
FROM employee e
LEFT JOIN (SELECT DISTINCT worker_ref_id 
			FROM bonus) b
	   ON b.worker_ref_id = e.id
GROUP BY 
	CASE WHEN b.worker_ref_id IS NULL THEN 0 ELSE 1 END;



-- Output:

--num_employees	has_bonus
--27	0
--3	1



-- Explanation:

--The subquery SELECT DISTINCT worker_ref_id FROM bonus retrieves the distinct 
--worker_ref_id values from the bonus table. This subquery is aliased as b.
--The employee table (e) is left joined with the subquery b on the condition 
--e.id = b.worker_ref_id. This ensures that all employees are included in the result, 
--whether they received a bonus or not.

--In the SELECT clause:

--CASE WHEN b.worker_ref_id IS NULL THEN 0 ELSE 1 END AS has_bonus: 
--This CASE expression assigns a value of 0 if the worker_ref_id is NULL 
--(indicating the employee did not receive a bonus), or 1 if the worker_ref_id 
--is not NULL (indicating the employee received a bonus).

--COUNT(*) AS num_employees: This counts the number of employees for each group, 
--which will give the count of employees who received a bonus and who did not.


--The GROUP BY clause groups the rows based on the CASE expression, 
--effectively separating the employees into two groups: those who received 
--a bonus and those who did not.

--The output of this query will have two columns:

--has_bonus: This column will have values of 0 or 1, indicating whether 
--the employees received a bonus or not.
--num_employees: This column will show the count of employees for 
--each value of has_bonus (0 or 1).





-- Q7 - Cum Sum Energy Consumption
--Hard, Meta


--Calculate the running total (i.e., cumulative sum) energy consumption of 
--the Meta/Facebook data centers in all 3 continents by the date. 
--Output the date, running total energy consumption, and 
--running total percentage rounded to the nearest whole number.

--Tables: fb_eu_energy, fb_na_energy, fb_asia_energy


WITH combined_data AS (
    SELECT date, SUM(consumption) AS total_consumption
    FROM (
        SELECT date, consumption
        FROM fb_eu_energy
        UNION ALL
        SELECT date, consumption
        FROM fb_na_energy
        UNION ALL
        SELECT date, consumption
        FROM fb_asia_energy
    ) AS combined
    GROUP BY date
)
SELECT
    date,
    SUM(total_consumption) OVER (ORDER BY date) AS running_total_consumption,
    ROUND(
        CAST(100.0 * SUM(total_consumption) OVER (ORDER BY date) / (
            SELECT SUM(total_consumption)
            FROM combined_data
        ) AS DECIMAL(5, 2)), 0
    ) AS running_total_percentage
FROM combined_data
ORDER BY date;


-- Output:

-- date	running_total_consumption	running_total_percentage
--2020-01-01	1050	13.00
--2020-01-02	2175	27.00
--2020-01-03	3275	40.00
--2020-01-04	4450	55.00
--2020-01-05	5650	69.00
--2020-01-06	6900	85.00
--2020-01-07	8150	100.00


-- Explanation:

-- Use UNION ALL to Combine the rows from all three tables without removing duplicates
-- Group the combined rows by date and sums the consumption for each date
-- Use window function SUM() OVER(ORDER BY) to calculate the cumulative sum of total_consumption ordered by date


-- SUM(total_consumption) OVER (ORDER BY date) AS running_total_consumption: 
-- This line calculates the cumulative sum of total_consumption for each row, 
-- ordered by the date column. The OVER clause specifies the window function, 
-- which takes the running sum of total_consumption values, ordered by date.


-- SELECT SUM(total_consumption) FROM combined_data: This subquery calculates the 
-- overall total energy consumption by summing the total_consumption values from the combined_data CTE.

-- ORDER BY date: This line orders the final output rows by the date column, 
-- ensuring that the running totals and percentages are calculated in the correct chronological order.






--Q8 - Maximum Number of Employees Reached
--Hard, Uber


--Write a query that returns every employee that has ever worked for the company. 
--For each employee, calculate the greatest number of employees that worked for the 
--company during their tenure and the first date that number was reached. 
--The termination date of an employee should not be counted as a working day.

--Your output should have the employee ID, greatest number of employees 
--that worked for the company during the employee's tenure, and first date that number was reached.

--Table: uber_employees


WITH events AS (
    SELECT hire_date AS event_date, 1 AS change
    FROM uber_employees
    UNION ALL
    SELECT DATEADD(DAY, 1, termination_date) AS event_date, -1 AS change
    FROM uber_employees
    WHERE termination_date IS NOT NULL
),
daily_employees AS (
    SELECT event_date,
           SUM(change) OVER (ORDER BY event_date) AS num_employees
    FROM events
),
max_employees_per_employee AS (
    SELECT e.id,
           e.hire_date,
           e.termination_date,
           MAX(de.num_employees) AS max_employees,
           MIN(de.event_date) AS first_date_max_employees
    FROM uber_employees e
    JOIN daily_employees de
    ON de.event_date BETWEEN e.hire_date AND DATEADD(DAY, -1, COALESCE(e.termination_date, GETDATE()))
    GROUP BY e.id, e.hire_date, e.termination_date
)
SELECT id, max_employees, first_date_max_employees
FROM max_employees_per_employee
ORDER BY id;


-- Output:

--id	max_employees	first_date_max_employees
--1	59	2009-02-03
--2	60	2009-02-03
--3	60	2009-02-03
--4	48	2009-04-15
--5	60	2009-02-03
--6	57	2009-06-20
--7	59	2009-07-20
--8	60	2009-08-13
--9	60	2009-09-25
--10	60	2009-10-09
--11	60	2009-11-22
--12	59	2009-12-23
--13	59	2010-01-20
--14	59	2010-02-03
--15	59	2010-02-12
--16	59	2010-03-20
--17	60	2010-04-15
--18	60	2010-05-22
--19	60	2010-07-20
--20	60	2010-08-13
--21	60	2010-09-25
--22	60	2010-10-09
--23	60	2010-11-22
--24	60	2010-12-23
--25	60	2011-05-22
--26	60	2011-07-20
--27	60	2011-08-13
--28	60	2011-09-25
--29	60	2011-10-09
--30	60	2011-11-22
--31	60	2011-12-23
--32	60	2012-01-20
--33	60	2012-02-03
--34	42	2012-03-14
--35	43	2012-03-20
--36	48	2012-04-15
--37	60	2012-04-15
--38	60	2012-05-22
--39	60	2012-07-20
--40	60	2013-04-15
--41	60	2013-05-22
--42	60	2013-05-22
--43	60	2013-07-20
--44	60	2013-08-13
--45	60	2013-09-10
--46	57	2013-09-10
--47	57	2013-09-25
--48	59	2013-10-09
--49	59	2013-11-22
--50	60	2013-12-23
--51	60	2014-01-20
--52	60	2014-01-22
--53	55	2014-02-03
--54	56	2014-03-20
--55	56	2014-05-20
--56	56	2014-08-13
--57	59	2014-09-25
--58	59	2014-10-09
--59	59	2014-11-22
--60	59	2014-12-23
--61	59	2015-01-20
--62	60	2015-02-03
--63	60	2015-03-14
--64	60	2015-04-10
--65	60	2015-04-10
--66	60	2015-07-20
--67	60	2015-09-10
--68	60	2015-09-10
--69	60	2016-01-20
--70	60	2016-03-20
--71	60	2016-04-15
--72	60	2016-07-20
--73	60	2016-07-20
--74	59	2016-10-09
--75	59	2016-12-23
--76	60	2017-01-22
--77	60	2017-02-03
--78	60	2017-04-15
--79	60	2017-05-22
--80	60	2017-07-20
--81	60	2017-09-25
--82	60	2017-09-25
--83	60	2017-09-25
--84	57	2017-11-22
--85	57	2018-04-15
--86	57	2018-05-20
--87	57	2018-05-22
--88	56	2018-08-13
--89	56	2018-11-22
--90	56	2018-11-22
--91	54	2018-12-23
--92	54	2018-12-23
--93	51	2019-01-20
--94	50	2019-03-20
--95	50	2019-05-22
--96	47	2019-08-13
--97	37	2019-11-22
--98	41	2019-10-09
--99	41	2019-10-09
--100	37	2019-11-22









-- Q9 - Employees With Same Birth Month
--Hard, Block


--Identify the number of employees within each department that share 
--the same birth month. Your output should list the department, birth month, 
--and the number of employees from that department who were born in that month. 
--If a month has no employees born in it within a specific department, report 
--this month as having 0 employees. The "profession" column stores the 
--department names of each employee.

--Table: employee_list



-- Step 1: Generate a list of months
WITH months AS (
    SELECT 1 AS month_num UNION ALL
    SELECT 2 UNION ALL
    SELECT 3 UNION ALL
    SELECT 4 UNION ALL
    SELECT 5 UNION ALL
    SELECT 6 UNION ALL
    SELECT 7 UNION ALL
    SELECT 8 UNION ALL
    SELECT 9 UNION ALL
    SELECT 10 UNION ALL
    SELECT 11 UNION ALL
    SELECT 12
),
-- Step 2: Generate a distinct list of departments
departments AS (
    SELECT DISTINCT profession AS department
    FROM employee_list
),
department_months AS (
-- Step 3: Create a cartesian product of departments and months
    SELECT d.department, m.month_num
    FROM departments d
    CROSS JOIN months m
)
-- Step 4 and Step 5: Perform a LEFT JOIN with the employee list, group by department and month, and count employees
SELECT
	dm.department AS department,
	dm.month_num AS birth_month,
	COUNT(e1.employee_id) AS num_of_employees
FROM department_months dm
LEFT JOIN 
		(SELECT profession,
				birth_month,
				employee_id
		 FROM employee_list) e1
ON dm.department = e1.profession AND dm.month_num = e1.birth_month
GROUP BY dm.department, 
		 dm.month_num
ORDER BY department,
		 birth_month;


-- Output:

--department	birth_month	num_of_employees
--Accountant	1	0
--Accountant	2	0
--Accountant	3	1
--Accountant	4	0
--Accountant	5	0
--Accountant	6	1
--Accountant	7	1
--Accountant	8	1
--Accountant	9	1
--Accountant	10	0
--Accountant	11	0
--Accountant	12	0
--Doctor	1	3
--Doctor	2	0
--Doctor	3	3
--Doctor	4	1
--Doctor	5	2
--Doctor	6	0
--Doctor	7	3
--Doctor	8	4
--Doctor	9	1
--Doctor	10	1
--Doctor	11	3
--Doctor	12	0
--Engineer	1	0
--Engineer	2	2
--Engineer	3	1
--Engineer	4	2
--Engineer	5	4
--Engineer	6	3
--Engineer	7	0
--Engineer	8	3
--Engineer	9	1
--Engineer	10	2
--Engineer	11	0
--Engineer	12	1
--Lawyer	1	2
--Lawyer	2	0
--Lawyer	3	0
--Lawyer	4	1
--Lawyer	5	0
--Lawyer	6	0
--Lawyer	7	0
--Lawyer	8	0
--Lawyer	9	1
--Lawyer	10	0
--Lawyer	11	0
--Lawyer	12	1
--Manager	1	2
--Manager	2	0
--Manager	3	3
--Manager	4	0
--Manager	5	2
--Manager	6	0
--Manager	7	0
--Manager	8	2
--Manager	9	3
--Manager	10	1
--Manager	11	2
--Manager	12	0
--Nurse	1	0
--Nurse	2	0
--Nurse	3	1
--Nurse	4	0
--Nurse	5	0
--Nurse	6	2
--Nurse	7	0
--Nurse	8	1
--Nurse	9	0
--Nurse	10	1
--Nurse	11	0
--Nurse	12	0
--Software Dev.	1	1
--Software Dev.	2	1
--Software Dev.	3	0
--Software Dev.	4	0
--Software Dev.	5	2
--Software Dev.	6	1
--Software Dev.	7	2
--Software Dev.	8	2
--Software Dev.	9	2
--Software Dev.	10	0
--Software Dev.	11	1
--Software Dev.	12	2
--Teacher	1	0
--Teacher	2	2
--Teacher	3	1
--Teacher	4	0
--Teacher	5	1
--Teacher	6	0
--Teacher	7	1
--Teacher	8	1
--Teacher	9	2
--Teacher	10	2
--Teacher	11	1
--Teacher	12	4



-- Explanation:

-- first we need to generate a list of months (1 to 12) in a cte
-- next we need to get the distinct department (profession) in another table
-- next we need to cross join the month and department in a table so that for every department
-- you get a list of month between 1 to 12.
-- we need this cross join so that in the next stage we can left join the table with
-- the employee_list table on birth_month and dept, count(employees) and group it by department.


--A CROSS JOIN in SQL is used to generate a Cartesian product of two tables. 
--This means it combines each row from the first table with every row from the second table. 
--The result set contains all possible combinations of rows from the two tables.

--In the context of this problem, we need to ensure that every department has an 
--entry for each month (from 1 to 12) so that we can report the number of employees 
--born in each month, including those months where no employees were born. 
--To achieve this, we use a CROSS JOIN between a list of all months and a list of all departments. 
--This guarantees that we have a complete set of department-month pairs.


--The CROSS JOIN is used here to ensure that:

--Every department is paired with each month of the year (1 to 12).
--We can later LEFT JOIN this complete set with the actual employee 
--data to count the number of employees born in each month for each department.
--If no employees were born in a particular month for a department, 
--the count will be zero, fulfilling the requirement to report months with zero employees.







--Q10 - Positive Ad Channels
--Hard, Uber

--Find the advertising channel with the smallest maximum yearly spending 
-- that still brings in more than 1500 customers each year.

--Table: uber_advertising


WITH filtered_data AS (
	SELECT 
		year, 
		advertising_channel,
		money_spent,
		customers_acquired
	FROM uber_advertising
	WHERE customers_acquired > 1500
),
max_spending_per_channel AS
(
	SELECT 
		advertising_channel,
		MAX(money_spent) AS max_yearly_spending
		FROM filtered_data
	GROUP BY advertising_channel
)
SELECT
	TOP 1 
	advertising_channel,
    max_yearly_spending
FROM
    max_spending_per_channel
ORDER BY
    max_yearly_spending ASC;


-- Output:

--advertising_channel	max_yearly_spending
--tv	500000



-- Explanation:

--Step 1: Filter Data
--We need to filter the records to include only those where customers_acquired > 1500.

--Step 2: Calculate Maximum Yearly Spending
--For each advertising channel, calculate the maximum amount of money spent in any given year.

--Step 3: Find the Smallest Maximum Yearly Spending
--Among these maximum spendings, find the smallest value







-- Q11 - Top 3 Wineries In The World
--Hard, Wine Magazine


--Find the top 3 wineries in each country based on the average points earned. 
--In case there is a tie, order the wineries by winery name in ascending order. 
--Output the country along with the best, second best, and third best wineries. 
--If there is no second winery (NULL value) output 'No second winery' 
--and if there is no third winery output 'No third winery'. 
--For outputting wineries format them like this: "winery (avg_points)"

--Table: winemag_p1


WITH avg_points AS (
    SELECT
        country,
        winery,
        AVG(points) AS avg_points
    FROM winemag_p1
    GROUP BY country, winery
),

ranked_wineries AS (
    SELECT
        country,
        winery,
        avg_points,
        RANK() OVER (PARTITION BY country ORDER BY avg_points DESC, winery ASC) AS rank
    FROM avg_points
)

,top_wineries AS (
    SELECT
        country,
        winery,
        avg_points,
        rank
    FROM ranked_wineries
    WHERE rank <= 3
)
SELECT
    country,
    COALESCE(MAX(CASE WHEN rank = 1 THEN CONCAT(winery, ' (', avg_points, ')') END), 'No first winery') AS best_winery,
    COALESCE(MAX(CASE WHEN rank = 2 THEN CONCAT(winery, ' (', avg_points, ')') END), 'No second winery') AS second_best_winery,
    COALESCE(MAX(CASE WHEN rank = 3 THEN CONCAT(winery, ' (', avg_points, ')') END), 'No third winery') AS third_best_winery
FROM top_wineries
GROUP BY country;


-- Output:


--country	best_winery	second_best_winery	third_best_winery
--Argentina	Bodega Noemaa de Patagonia (89)	Bodega Norton (86)	Rutini (86)
--Australia	Madison Ridge (84)	No second winery	No third winery
--Austria	Schloss Gobelsburg (93)	Hopler (83)	No third winery
--Bulgaria	Targovishte (84)	No second winery	No third winery
--Chile	Altaa�r (85)	Francois Lurton (85)	Santa Carolina (85)
--France	Domaine Faiveley (94)	Roche de Bellene (92)	Alain Jaume et Fils (89)
--Germany	Maximin Granhauser (92)	Bollig-Lehnert (91)	A. Christmann (89)
--Greece	Santo Wines (90)	No second winery	No third winery
--Italy	Roagna (93)	Il Mosnel (91)	Ca' du Rabaja� (90)
--Moldova	Vinaria din Vale (88)	No second winery	No third winery
--New Zealand	Peregrine (90)	Catalina Sounds (88)	Dashwood (87)
--Portugal	Aveleda (91)	Quinta do Boicao (89)	Messias (84)
--South Africa	The Berrio (87)	No second winery	No third winery
--Spain	Jaspi (87)	Atalayas de Golba?n (85)	Grandes Vinos y Vinedos (85)
--Turkey	Camlibag (86)	No second winery	No third winery
--US	Niebaum-Coppola (97)	Yao Ming (97)	Joseph Phelps (96)



-- Explanation:

-- Retrieve relevant columns and group by winery in each country

-- Step 1: calculate the average points for each winery in each country.
-- Step 2: Rank the winery by average_points in each country, from the highest
-- to the lowest average point, where there is a tie in average points (same rank) 
-- then order the wineries alphabetically

-- Step 3: filter to get only the top 3 wineries
-- Step 4: Retrieve the top 3 wineries in each country, 
-- use CASE statements to get the best 3 wineries in the required output of - winery(average_point)
-- Use COALESCE function to handle cases where there are fewer than three wineries in a country.






-- Q12 - Most Expensive And Cheapest Wine
--https://platform.stratascratch.com/coding/10041-most-expensive-and-cheapest-wine?code_type=5

--Interview Question Date: March 2020

--Wine Magazine
--Hard
--ID 10041

--30

--Find the cheapest and the most expensive variety in each region. 
--Output the region along with the corresponding most expensive 
-- and the cheapest variety. Be aware that there are 2 region columns, 
-- the price from that row applies to both of them.

--Note: The results set contains no ties.

--Table: winemag_p1



-- Solution 1:

-- Step 1: Extract the region-price pairs and combine region_1 and region_2
WITH combined_regions AS (
    SELECT region_1 AS region, variety, price
    FROM winemag_p1
    WHERE region_1 IS NOT NULL AND price IS NOT NULL
    UNION ALL
    SELECT region_2 AS region, variety, price
    FROM winemag_p1
    WHERE region_2 IS NOT NULL AND price IS NOT NULL
)
,

-- Step 2: Calculate the minimum and maximum prices for each region
region_prices AS (
    SELECT 
        region, 
        MAX(price) AS max_price, 
        MIN(price) AS min_price
    FROM combined_regions
    GROUP BY region
), 
-- retriev the variety names
max_variety_names AS 
(
	SELECT cr.region,
		   max_price,
		   cr.variety AS max_variety
	FROM region_prices rp
	JOIN combined_regions cr
	ON rp.max_price = cr.price AND rp.region = cr.region
),
min_variety_names AS
(
	SELECT cr.region,
		   rp.min_price,
		   cr.variety AS min_variety
	FROM region_prices rp
	JOIN combined_regions cr
	ON rp.min_price = cr.price AND rp.region = cr.region
)
SELECT DISTINCT max_v.region,
	   max_variety AS most_expensive_variety,
	   min_variety AS cheapest_variety
FROM max_variety_names max_v
JOIN min_variety_names min_v
ON max_v.region = min_v.region
ORDER BY max_v.region;




-- Solution 2:

-- Step 1: Extract the region-price pairs and combine region_1 and region_2
WITH combined_regions AS (
    SELECT region_1 AS region, variety, price
    FROM winemag_p1
    WHERE region_1 IS NOT NULL AND price IS NOT NULL
    UNION ALL
    SELECT region_2 AS region, variety, price
    FROM winemag_p1
    WHERE region_2 IS NOT NULL AND price IS NOT NULL
),

-- Step 2: Calculate the minimum and maximum prices for each region
region_prices AS (
    SELECT 
        region, 
        MAX(price) AS max_price, 
        MIN(price) AS min_price
    FROM combined_regions
    GROUP BY region
),

-- Step 3: Identify the variety corresponding to the maximum and minimum prices
variety_prices AS (
    SELECT 
        cr.region,
        cr.variety AS max_variety,
        rp.max_price
    FROM combined_regions cr
    JOIN region_prices rp
    ON cr.region = rp.region AND cr.price = rp.max_price
),
min_variety_prices AS (
    SELECT 
        cr.region,
        cr.variety AS min_variety,
        rp.min_price
    FROM combined_regions cr
    JOIN region_prices rp
    ON cr.region = rp.region AND cr.price = rp.min_price
)

-- Step 4: Combine the results to get the final output
SELECT 
    vp.region, 
    vp.max_variety AS most_expensive_variety, 
    mvp.min_variety AS cheapest_variety
FROM variety_prices vp
JOIN min_variety_prices mvp
ON vp.region = mvp.region
ORDER BY vp.region;




-- Output:


--region	most_expensive_variety	cheapest_variety
--Alexander Valley	Cabernet Sauvignon	Merlot
--Anderson Valley	Pinot Noir	Pinot Noir
--Barbaresco	Nebbiolo	Nebbiolo
--Brunello di Montalcino	Sangiovese	Sangiovese
--California	Pinot Noir	Sauvignon Blanc
--California Other	Pinot Noir	Sauvignon Blanc
--Carinena	Red Blend	Red Blend
--Central Coast	Pinot Noir	Pinot Noir
--Chablis	Chardonnay	Chardonnay
--Chalone	Pinot Noir	Pinot Noir
--Champagne	Champagne Blend	Champagne Blend
--Chianti Classico	Sangiovese	Sangiovese
--Columbia Valley	Syrah	Gewarztraminer
--Columbia Valley (WA)	Merlot	Gewarztraminer
--Conegliano Valdobbiadene	Glera	Glera
--Diamond Mountain District	Cabernet Sauvignon	Cabernet Sauvignon
--Edna Valley	Pinot Noir	Pinot Noir
--Forla�	Sauvignon Blanc	Sauvignon Blanc
--Franciacorta	Chardonnay	Sparkling Blend
--Long Island	Merlot	Merlot
--Luja?n de Cuyo	Malbec	Malbec
--Mazis-Chambertin	Pinot Noir	Pinot Noir
--Mendocino/Lake Counties	Pinot Noir	Pinot Noir
--Mendoza	Malbec	Cabernet Sauvignon
--Meursault	Chardonnay	Chardonnay
--Montsant	Red Blend	Red Blend
--Napa	Cabernet Sauvignon	Moscato
--Napa Valley	Cabernet Sauvignon	Moscato
--North Fork of Long Island	Merlot	Merlot
--Oakville	Cabernet Sauvignon	Cabernet Sauvignon
--Paso Robles	Cabernet Sauvignon	Cabernet Sauvignon
--Pays d'Oc	Merlot	Merlot
--Pouilly-Fuisse	Chardonnay	Chardonnay
--Prosecco di Valdobbiadene	Prosecco	Prosecco
--Rao Negro Valley	Malbec	Malbec
--Rasteau	Rhone-style Red Blend	Rhone-style Red Blend
--Ribera del Duero	Red Blend	Red Blend
--Rioja	Tempranillo	Tempranillo
--Russian River Valley	Pinot Noir	Zinfandel
--Rutherford	Red Blend	Cabernet Sauvignon
--San Juan	Malbec	Malbec
--San Luis Obispo County	Pinot Noir	Pinot Noir
--Shenandoah Valley (CA)	Sangiovese	Sangiovese
--Sicilia	Nero d'Avola	Nero d'Avola
--Sierra Foothills	Sangiovese	Sangiovese
--Soave Classico	Garganega	Garganega
--Sonoma	Pinot Noir	Merlot
--Sonoma Coast	Pinot Noir	Pinot Noir
--Sonoma County	Sauvignon Blanc	Sauvignon Blanc
--South Eastern Australia	Chardonnay	Chardonnay
--Sta. Rita Hills	Pinot Noir	Pinot Noir
--The Hamptons, Long Island	Merlot	Merlot
--Uco Valley	Viognier	Viognier
--Valpolicella Classico	Corvina, Rondinella, Molinara	Corvina, Rondinella, Molinara
--Vin Mousseux	White Blend	White Blend
--Virginia	Merlot	Merlot
--Walla Walla Valley (WA)	Syrah	Semillon
--Washington	Cabernet Sauvignon	Cabernet Sauvignon
--Washington Other	Cabernet Sauvignon	Cabernet Sauvignon
--Willamette Valley	Riesling	Riesling







-- Q13 - Find Favourite Wine Variety
--Hard, Wine Magazine

--Find each taster's favorite wine variety.
--Consider that favorite variety means the variety that has been tasted by most of the time.
--Output the taster's name along with the wine variety.

--Table: winemag_p2


-- Solution:

-- Step 1: Count the number of times each taster has tasted each variety
WITH tasting_counts AS (
    SELECT 
        taster_name, 
        variety, 
        COUNT(*) AS tasting_count
    FROM winemag_p2
    GROUP BY taster_name, variety
),

-- Step 2: Rank the varieties for each taster based on the count of tastings
ranked_varieties AS (
    SELECT 
        taster_name, 
        variety, 
        tasting_count,
        RANK() OVER (PARTITION BY taster_name ORDER BY tasting_count DESC) AS rank
    FROM tasting_counts
)

-- Step 3: Select the variety with the highest rank (most frequently tasted) for each taster
SELECT 
    taster_name, 
    variety AS favorite_variety
FROM ranked_varieties
WHERE rank = 1
AND taster_name IS NOT NULL;


-- Output:


--taster_name	favorite_variety
--Anna Lee C. Iijima	Pinot Noir
--Anna Lee C. Iijima	Riesling
--Anne KrebiehlMW	Gruner Veltliner
--Anne KrebiehlMW	Sylvaner
--Jeff Jenssen	uilavka
--Jeff Jenssen	Vranec
--Jeff Jenssen	Pinot Noir
--Jim Gordon	Zinfandel
--Jim Gordon	Rhane-style Red Blend
--Joe Czerwinski	Rhane-style Red Blend
--Joe Czerwinski	Sauvignon Blanc
--Joe Czerwinski	Rosa
--Joe Czerwinski	Pinot Noir
--Joe Czerwinski	Mataro
--Joe Czerwinski	Champagne Blend
--Joe Czerwinski	Cabernet Sauvignon
--Kerin O'Keefe	Red Blend
--Matt Kettmann	G-S-M
--Matt Kettmann	Pinot Noir
--Matt Kettmann	Chardonnay
--Matt Kettmann	Viognier
--Matt Kettmann	Red Blend
--Matt Kettmann	Rhane-style White Blend
--Matt Kettmann	Sauvignon Blanc
--Matt Kettmann	Syrah
--Michael Schachner	Malbec
--Paul Gregutt	White Blend
--Paul Gregutt	Pinot Noir
--Paul Gregutt	Merlot
--Paul Gregutt	Pinot Gris
--Paul Gregutt	Chardonnay
--Roger Voss	Bordeaux-style Red Blend
--Roger Voss	Pinot Noir
--Roger Voss	Portuguese Red
--Roger Voss	Riesling
--Sean P. Sullivan	Bordeaux-style Red Blend
--Sean P. Sullivan	Sauvignon Blanc
--Susan Kostrzewa	White Blend
--Susan Kostrzewa	Chardonnay
--Virginie Boone	Pinot Noir






-- Solution Checker for ties in taster's favorite variety


-- Step 1: Count the number of times each taster have tasted a variety
WITH count_table AS
(
SELECT taster_name, variety, COUNT(variety) AS no_of_times
FROM winemag_p2
WHERE taster_name IS NOT NULL
GROUP BY taster_name, variety
)
-- step 2: Retrieve the highest count for each taster in a cte
, max_table AS (
SELECT taster_name, MAX(no_of_times) AS max_count
FROM count_table
GROUP BY taster_name
)
-- Join the count_table with the max_table on the maximum count for each taster
SELECT c.taster_name, STRING_AGG(CONCAT(c.variety, ' (', m.max_count, ')'), ',  ') AS favorite_variety 
FROM count_table c
JOIN max_table m
ON c.no_of_times = m.max_count
WHERE c.taster_name = m.taster_name
GROUP BY c.taster_name, m.max_count
ORDER BY m.max_count DESC;



-- Output:

--taster_name	favorite_variety
--Virginie Boone	Pinot Noir (4)
--Michael Schachner	Malbec (3)
--Roger Voss	Bordeaux-style Red Blend (3),  Riesling (3),  Portuguese Red (3),  Pinot Noir (3)
--Anna Lee C. Iijima	Riesling (2),  Pinot Noir (2)
--Kerin O'Keefe	Red Blend (2)
--Anne KrebiehlMW	Gruner Veltliner (1),  Sylvaner (1)
--Jeff Jenssen	Vranec (1),  uilavka (1),  Pinot Noir (1)
--Jim Gordon	Rhane-style Red Blend (1),  Zinfandel (1)
--Joe Czerwinski	Mataro (1),  Pinot Noir (1),  Champagne Blend (1),  Cabernet Sauvignon (1),  Sauvignon Blanc (1),  Rosa (1),  Rhane-style Red Blend (1)
--Matt Kettmann	Syrah (1),  Viognier (1),  Rhane-style White Blend (1),  Red Blend (1),  Sauvignon Blanc (1),  G-S-M (1),  Pinot Noir (1),  Chardonnay (1)
--Paul Gregutt	Merlot (1),  Pinot Gris (1),  Pinot Noir (1),  Chardonnay (1),  White Blend (1)
--Sean P. Sullivan	Sauvignon Blanc (1),  Bordeaux-style Red Blend (1)
--Susan Kostrzewa	Chardonnay (1),  White Blend (1)







-- Q14: - Best Selling Item
--Hard, Amazon, Ebay, Best Buy


--Find the best selling item for each month (no need to separate months by year) 
--where the biggest total invoice was paid. The best selling item is calculated 
--using the formula (unitprice * quantity). 

-- Output the month, the description of the item along with the amount paid.

--Table: online_retail



-- Step 1: Extract relevant data and calculate the amount paid for each transaction
WITH filtered_data AS 
(
SELECT MONTH(invoicedate) AS month, 
       description, 
       ABS(unitprice * quantity) AS amount_paid
FROM online_retail
)
-- Step 2: Aggregate the data to get the total amount paid per item per month
, monthly_totals AS (
SELECT month, 
       description, 
       SUM(amount_paid) AS total_amount_paid
FROM filtered_data
GROUP BY month, description
)
-- Step 3: Rank the items within each month based on the total amount paid
, ranked_items AS (
SELECT month, 
       description, 
       total_amount_paid, 
       RANK() OVER(PARTITION BY month ORDER BY total_amount_paid DESC) AS rank
FROM monthly_totals
)
-- Step 4: Select the top-ranked item for each month
SELECT 
    month,
    description,
    total_amount_paid AS amount_paid
FROM ranked_items
WHERE rank = 1
ORDER BY month;


-- Output:

--month	description	amount_paid
--1	LUNCH BAG SPACEBOY DESIGN	74.2600
--2	REGENCY CAKESTAND 3 TIER	38.2500
--3	PAPER BUNTING WHITE LACE	102.0000
--4	SPACEBOY LUNCH BOX	23.4000
--5	PAPER BUNTING WHITE LACE	51.0000
--6	Dotcomgiftshop Gift Voucher £50.00	41.6700
--7	BASKET OF TOADSTOOLS	432.4800
--8	LUNCH BAG PINK POLKADOT	16.5000
--9	RED RETROSPOT PEG BAG	34.7200
--10	CHOCOLATE HOT WATER BOTTLE	102.0000
--11	RED WOOLLY HOTTIE WHITE HEART.	228.2500
--12	PAPER BUNTING RETROSPOT	35.4000









-- Q15 - More Than 100 Dollars
--Hard, Salesforce, DoorDash



--The company for which you work is reviewing its 2021 monthly sales.
--For each month of 2021, calculate what percentage of restaurants 
-- have reached at least 100$ or more in monthly sales.

--Note: Please remember that if an order has a blank value for 
-- actual_delivery_time, it has been canceled and therefore does not count towards monthly sales.

--Tables: delivery_orders, order_value


WITH cte_monthly_sales AS (
    SELECT
        restaurant_id,
        DATENAME(MONTH, order_placed_time) AS month,
        SUM(v.sales_amount) AS total_sales
    FROM
        delivery_orders d
    JOIN
        order_value v ON d.delivery_id = v.delivery_id
    WHERE
        actual_delivery_time IS NOT NULL
        AND YEAR(order_placed_time) = 2021
    GROUP BY
        restaurant_id,
        DATENAME(MONTH, order_placed_time)
), cte_restaurant_count AS (
    SELECT
        month,
        COUNT(CASE WHEN total_sales >= 100 THEN 1 END) AS restaurants_with_sales_gte_100,
        COUNT(*) AS total_restaurants
    FROM
        cte_monthly_sales
    GROUP BY
        month
)
SELECT
    month,
    CAST(1.0 * restaurants_with_sales_gte_100 / total_restaurants * 100 AS DECIMAL(5, 2)) AS percentage
FROM
    cte_restaurant_count
ORDER BY
    month;



-- Output:

--month	percentage
--December	42.86
--November	50.00





-
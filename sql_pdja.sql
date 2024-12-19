-- select * from job_postings_fact limit 100
-- DATA TYPE CONVERSION --

-- select 
--     '2023-02-19' :: DATE,
--     '123':: INTEGER,
--     'true':: BOOLEAN,
--     '3.14'::REAL;
/*
#####################
##  Data and Time  ##
#####################
*/
-- select 
--     job_title_short as title,
--     job_location as location,
--     job_posted_date at time zone 'UTC' at time zone 'EST' as date,
--     EXTRACT(DAY from job_posted_date) as date_day,
--     EXTRACT(MONTH from job_posted_date) as date_month,
--     EXTRACT(YEAR from job_posted_date) as date_year
-- FROM job_postings_fact

-- select 
--     count(job_postings_fact) as job_posted_count,
--     EXTRACT(MONTH from job_posted_date) as month

-- from 
--     job_postings_fact
-- where 
--     job_title_short = 'Data Engineer'
-- GROUP BY
--     month
-- ORDER BY 
--     job_posted_count DESC;

---- Practice Problem 1  ---
/* 
    Write a query to find average salary both yearly(salary_year_avg) 
    and hourly(salary_hour_avg) for job postings that were after june 1, 2023.
    Group the result by job schedule type.
*/


-- select avg(salary_year_avg) as yearly_avg, avg(salary_hour_avg) as hourly_avg, job_posted_date
-- from job_postings_fact
-- where job_posted_date > '2023-06-01'
-- GROUP BY salary_hour_avg, salary_year_avg, job_posted_date



---- Practice Problem 2  ---
/* Write a query to count the number of job postings for each month in 2023,
   adjusting the jos_posted_date to be in 'America, New_Yokr' time zone before extracting
   (hint) the month.
   Assume the job_posted_date is stored in UTC. Group by and order by the month.
*/

-- select 
-- count(job_postings_fact)
--     job_posted_date at time zone 'UTC' at time zone 'EST' as date,
-- from job_postings_fact

-- select
--     EXTRACT(MONTH from job_posted_date) as month,
--     count(job_title) as job_count_per_month

-- from 
--     job_postings_fact
-- GROUP BY MONTH
-- order by MONTH DESC

-- Practice Problem 3  ---
/* Write a query to find companies (including company name) that have posted offiring health insurance,
   where these postings were made in the second quarter of 2023. Use date extraction to filter by quarter
*/

-- SELECT DISTINCT c.name, jp.job_health_insurance
-- FROM job_postings_fact jp
-- JOIN company_dim c ON jp.company_id = c.company_id
-- WHERE jp.job_posted_date >= '2023-04-01' 
--   AND jp.job_posted_date < '2023-07-01'
--   and jp.job_health_insurance is TRUE


--- Problem 6 ---
-- January
-- CREATE TABLE january_jobs as 
--     select * 
--     FROM job_postings_fact
--     where EXTRACT(MONTH from job_posted_date) = 1;
 
-- -- February
-- CREATE TABLE february_jobs as 
--     select * 
--     FROM job_postings_fact
--     where EXTRACT(MONTH from job_posted_date) = 2;


-- -- March
-- CREATE TABLE march_jobs as 
--     select * 
--     FROM job_postings_fact
--     where EXTRACT(MONTH from job_posted_date) = 3;


--  select * from january_jobs

/*
#######################
##  CASE EXPRESSION  ##
#######################
*/

/*
    Label new column as follows:
    - 'Anywhere' jobs as 'Remote'
    - 'New York, NY' as 'Local'
    - Otherwise 'Onsite'
*/

-- SELECT 
--     job_title_short, 
--     job_location,
--     CASE
--         WHEN job_location ='Anywhere' THEN 'Remote'
--         WHEN job_location ='New York, NY' THEN 'Local'
--         ELSE 'Onsite'
--     END AS location_category
-- FROM job_postings_fact;


-- SELECT 
--     count(job_id) as number_of_jobs,
--     CASE
--         WHEN job_location ='Anywhere' THEN 'Remote'
--         WHEN job_location ='New York, NY' THEN 'Local'
--         ELSE 'Onsite'
--     END AS location_category
-- FROM job_postings_fact
-- where
--     job_title_short = 'Data Engineer'
-- GROUP BY
--     location_category;


-- Problem 1 ----

/*
    I want to categorize the salaries for each job posting. To see if it fits in my desired salry range.
    - Put salary into different buckets
    - Define what's a high, standard, or low salry with our own condition
    - Why? It is easy to determine which job postings are worth looking at based on salary.
    Bucketing is a common practice in data analysis when viewing categories.
    - I only want to look at data analyst roles
    - Order from highest to lowest

*/

-- select salary_hour_avg,
--     CASE
--         when salary_hour_avg >= 70 then 'High Pay'
--         when salary_hour_avg >= 60 and salary_hour_avg < 70 then'Standard Pay'
--         else 'Low Pay'
--     END AS salary_range
-- from
--     job_postings_fact
-- where
--     salary_hour_avg is NOT NULL
--     and job_title_short = 'Data Analyst'
-- order by 
--     salary_hour_avg DESC

/*
#########################
##  SUBQUERIES & CTEs  ##
#########################
*/
-- Select * 
-- FROM (
--         select * 
--         FROM 
--             job_postings_fact
--         where 
--             EXTRACT(MONTH from job_posted_date ) = 1
--     ) as january_jobs


-- WITH january_jobs as ( -- CTE definition starts here
--     select *
--     from
--         job_postings_fact
--     where
--         EXTRACT(month from job_posted_date) = 1
-- ) -- CTE definition ends here

-- select * from january_jobs;


/*
    Practice on Subqueries
*/
-- select 
--     company_id, name as company_name
-- from 
--     company_dim
-- where company_id in (
--     select 
--         company_id
--     FROM
--         job_postings_fact
--     where 
--         job_no_degree_mention = TRUE
--     ORDER BY company_id ASC
--     )


/*
    Practice on CTEs

    Find the companies that have the most job openings.
    - Get the total number of job postings per company is
    - Return the total number of jobs with company name
*/
-- with company_job_count as (
--     select
--         company_id,
--         count(*) as total_jobs
--     from 
--         job_postings_fact 
--     GROUP BY 
--         company_id
-- )

-- select 
--     company_dim.name as company_name,
--     company_job_count.total_jobs
-- from 
--     company_dim
-- LEFT JOIN 
--     company_job_count 
--     on company_job_count.company_id = company_dim.company_id
-- ORDER BY
--     total_jobs DESC

/*
    PRACTICAL PROBLEM 1

    Identify the top 5 skills that are most freqently mentioned in job postings.
    Use a subqeury to find the skills IDs with the hightest counts in the skills_job_dim table
    and then join this result with skills_dim table to get the skill names. 
*/
-- SELECT 
--     sjd.skill_id,
--     sd.skills as skill_name,
--     COUNT(*) as frequency
-- FROM 
--     skills_job_dim sjd
-- LEFT JOIN skills_dim sd on sjd.skill_id = sd.skill_id
-- GROUP BY 
--     sjd.skill_id, sd.skills
-- ORDER BY 
--     frequency DESC
-- LIMIT 5;



-- select * from skills_dim



/*
    PRACTICAL PROBLEM 2

    Determine the size category ('Small', 'Medium', or 'Large') for each company by identifying 
    the number of job postings they have. Use a subquery to calculate the total job posting per company. 
    A company is considered 'Small' if it has less than 10 job postings, 'Medium' if the number of job postings is 
    between 10 and 50, and 'Large' if it has more than 50 job postings.
    Implement a subquery to aggregate job counts per company before classinfyng them based on size. 
*/
-- select 
--     cd.name, 
--     count(cd.name) as frequency, 
--     jpf.job_title,
--     CASE
--         when count(cd.name) < 10 then 'Small'
--         when count(cd.name) > 10 and count(cd.name) < 50 then 'Medium'
--         ELSE
--             'Large'

--     End as frequency_range

-- from company_dim cd
-- join job_postings_fact jpf on cd.company_id = jpf.company_id
-- GROUP BY cd.name, jpf.job_title
-- ORDER BY frequency DESC
-- limit 20
------------------------------------------------------------------------
-- USING SUBQUERY ---
-- SELECT 
--     cd.name, 
--     jpf.job_title,
--     CASE
--         WHEN s.total_jobs < 10 THEN 'Small'
--         WHEN s.total_jobs BETWEEN 10 AND 50 THEN 'Medium'
--         ELSE 'Large'
--     END as frequency_range
-- FROM 
--     company_dim cd
-- JOIN 
--     job_postings_fact jpf ON cd.company_id = jpf.company_id
-- JOIN 
--     (
--         SELECT 
--             company_id,
--             COUNT(*) as total_jobs
--         FROM 
--             job_postings_fact
--         GROUP BY 
--             company_id
--     ) s ON cd.company_id = s.company_id
-- ORDER BY 
--     s.total_jobs DESC;
------------------------------------------------------------------------
-- USING CTE ---
-- WITH job_counts AS (
--     SELECT 
--         cd.name,
--         COUNT(jpf.job_id) as total_jobs
--     FROM 
--         company_dim cd
--     JOIN 
--         job_postings_fact jpf ON cd.company_id = jpf.company_id
--     GROUP BY 
--         cd.name
-- ),
-- company_sizes AS (
--     SELECT 
--         name,
--         CASE
--             WHEN total_jobs < 10 THEN 'Small'
--             WHEN total_jobs BETWEEN 10 AND 50 THEN 'Medium'
--             ELSE 'Large'
--         END as size_category
--     FROM 
--         job_counts
-- )
-- SELECT 
--     cs.name, 
--     cs.total_jobs,
--     cs.size_category
-- FROM 
--     company_sizes cs
-- ORDER BY 
--     total_jobs DESC;


-- select * job_postings_fact limit 2


/*
    PRACTICAL PROBLEM 3

    Find the count of the number of remote job postings per skill
    - Display the top 5 skills by their demand in remote jobs
    - Include skill ID, name, and count of postings requiring skill 
-- */
-- with remote_job_skills as (
--     select 
--         skill_id,
--         count(*) as skill_count

--     from 
--         skills_job_dim as skills_to_job
--     INNER JOIN job_postings_fact as job_postings on job_postings.job_id = skills_to_job.job_id
--     WHERE
--         job_postings.job_work_from_home = TRUE and 
--         job_postings.job_title_short = 'Data Analyst'
--     GROUP BY
--         skill_id
-- )

-- select
--     skills.skill_id,
--     skills as skill_name,
--     skill_count
-- from
--     remote_job_skills
-- INNER JOIN skills_dim as skills on skills.skill_id = remote_job_skills.skill_id
-- ORDER BY skill_count DESC
-- limit 5

/*
#########################
##  UNION OPERATORS  ##
#########################
*/
/*
    Find job postings from the quarter that have a salary greater than $70K
    - Combine job postings tables from the first quarter of 2023 (Jan-Mar)
    - Gets job postings with an average yearlysalary > $70000
*/
SELECT
    quarter1_job_postings.job_title_short,
    quarter1_job_postings.job_location,
    quarter1_job_postings.job_via,
    quarter1_job_postings.job_posted_date::date,
    quarter1_job_postings.salary_year_avg
FROM (
    SELECT *
    from january_jobs
    UNION ALL
    select *
    from february_jobs
    UNION ALL
    select *
    FROM march_jobs
) as quarter1_job_postings
where quarter1_job_postings.salary_year_avg > 70000 and 
quarter1_job_postings.job_title_short = 'Data Engineer'
ORDER BY by salary_year_avg
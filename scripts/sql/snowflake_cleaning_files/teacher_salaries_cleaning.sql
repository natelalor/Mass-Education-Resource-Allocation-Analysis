-- SQL script to fully clean, sanitize, prepare teacher_salaries.csv for analytical investigation

CREATE OR REPLACE TABLE school_information.clean.teacher_salaries AS
-- CTE 1: dedup - for deduplication & checks
WITH dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY district_code -- natural key: unique per district
            ORDER BY district_name -- tiebreaker if duplicates exist
        ) AS rn
    FROM school_information.raw.teacher_salaries
    QUALIFY rn = 1
),

-- CTE 2: stripped - trimming, null handling, cleaning of the data
stripped AS (
    SELECT
        NULLIF(TRIM(district_name), '')              AS district_name,
        NULLIF(TRIM(district_code), '')               AS district_code,   -- retain leading zeroes for unique
 
        -- currency fields: strip $ and , before casting
        NULLIF(TRIM(REPLACE(REPLACE(salary_totals, '$', ''), ',', '')), '')  AS salary_totals_stripped,
        NULLIF(TRIM(REPLACE(REPLACE(average_salary, '$', ''), ',', '')), '') AS avg_salary_stripped,
 
        -- numeric field: strip commas (e.g. "4,384.6") and trim
        NULLIF(TRIM(REPLACE(fte_count, ',', '')), '')  AS fte_count_stripped
 
    FROM dedup
),

-- CTE 3: typed - for datatype casting after sufficient cleaning
typed AS (
    SELECT
        district_name,
        district_code,
        TRY_TO_DECIMAL(salary_totals_stripped, 15, 2)  AS salary_totals,
        TRY_TO_DECIMAL(avg_salary_stripped, 15, 2)     AS average_salary,
        TRY_TO_DECIMAL(fte_count_stripped, 10, 1)      AS fte_count
    FROM stripped
)
 
SELECT * FROM typed;
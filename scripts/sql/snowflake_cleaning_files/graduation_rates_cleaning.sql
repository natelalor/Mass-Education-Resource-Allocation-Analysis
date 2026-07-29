-- SQL script to fully clean, sanitize, prepare graduation_rates.csv for analytical investigation

CREATE OR REPLACE TABLE school_information.clean.graduation_rates AS

-- CTE 1: dedup - for deduplication & checks
WITH dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY district_code -- natural key: unique per district
            ORDER BY district_name -- tiebreaker if duplicates exist
        ) AS rn
    FROM school_information.raw.graduation_rates
    QUALIFY rn = 1
),

-- CTE 2: stripped - trimming, null handling, cleaning of the data
stripped AS (
    SELECT
        NULLIF(TRIM(district_name), '')               AS district_name,
        NULLIF(TRIM(district_code), '')               AS district_code,   -- retain leading zeroes for unique

        -- these are all decimal values currently cast as VARCHARS
        NULLIF(TRIM(REPLACE(total_students, ',', '')), '')                     AS total_students_stripped,
        NULLIF(TRIM(REPLACE(percentage_graduated, ',', '')), '')               AS percentage_graduated_stripped,
        NULLIF(TRIM(REPLACE(percentage_still_in_school, ',', '')), '')         AS percentage_still_in_school_stripped,
        NULLIF(TRIM(REPLACE(percentage_non_graduate_completors, ',', '')), '') AS percentage_non_graduate_completors_stripped,
        NULLIF(TRIM(REPLACE(percentage_hs_equivalent, ',', '')), '')           AS percentage_hs_equivalent_stripped,
        NULLIF(TRIM(REPLACE(percentage_dropped_out, ',', '')), '')             AS percentage_dropped_out_stripped,
        NULLIF(TRIM(REPLACE(percentage_permanently_excluded, ',', '')), '')    AS percentage_permanently_excluded_stripped,
        -- not including percentage_dropped_out_float from original csv because data not needed & insufficient value conversion

    FROM dedup
),

-- CTE 3: typed - for datatype casting after sufficient cleaning
typed AS (
    SELECT
        district_name,
        district_code,
        TRY_CAST(total_students_stripped AS INT) AS total_students,
        TRY_TO_DECIMAL(percentage_graduated_stripped, 5, 2) AS percentage_graduated,
        TRY_TO_DECIMAL(percentage_still_in_school_stripped, 5, 2) AS percentage_still_in_school,
        TRY_TO_DECIMAL(percentage_non_graduate_completors_stripped, 5, 2) AS percentage_non_graduate_completors,
        TRY_TO_DECIMAL(percentage_hs_equivalent_stripped, 5, 2) AS percentage_hs_equivalent,
        TRY_TO_DECIMAL(percentage_dropped_out_stripped, 5, 2) AS percentage_dropped_out,
        TRY_TO_DECIMAL(percentage_permanently_excluded_stripped, 5, 2) AS percentage_permanently_excluded
        
    FROM stripped
)
 
SELECT * FROM typed;
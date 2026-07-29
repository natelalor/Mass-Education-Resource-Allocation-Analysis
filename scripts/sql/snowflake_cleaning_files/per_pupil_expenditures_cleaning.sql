-- SQL script to fully clean, sanitize, prepare graduation_rates.csv for analytical investigation

CREATE OR REPLACE TABLE school_information.clean.per_pupil_expenditures AS

-- CTE 1: deduplication & checks
WITH dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY district_code ORDER BY district_name) AS rn
        FROM school_information.raw.per_pupil_expenditures
        QUALIFY rn = 1
),

-- CTE 2: trimming, stripping, cleaning
stripped AS (
    SELECT
        NULLIF(INITCAP(TRIM(district_name)), '') AS district_name,
        NULLIF(TRIM(district_code), '') AS district_code,
        TRIM(REPLACE(REPLACE(in_district_expenditures, '$', ''), ',', '')) AS in_district_expenditures_stripped,
        TRIM(REPLACE(REPLACE(total_in_district_ftes, '$', ''), ',', '')) AS total_in_district_ftes_stripped,
        TRIM(REPLACE(REPLACE(in_district_expenditures_per_pupil, '$', ''), ',', '')) AS in_district_expenditures_per_pupil_stripped,
        TRIM(REPLACE(REPLACE(total_expenditures, '$', ''), ',', '')) AS total_expenditures_stripped,
        TRIM(REPLACE(REPLACE(total_pupil_ftes, '$', ''), ',', '')) AS total_pupil_ftes_stripped,
        TRIM(REPLACE(REPLACE(total_expenditures_per_pupil, '$', ''), ',', '')) AS total_expenditures_per_pupil_stripped
    FROM dedup
),

-- CTE 3: datatype casting & polishing prep
typed AS (
    SELECT
        district_name,
        district_code,
        TRY_TO_DECIMAL(in_district_expenditures_stripped, 20, 2) AS in_district_expenditures,
        TRY_TO_DECIMAL(total_in_district_ftes_stripped, 20, 2) AS total_in_district_ftes,
        TRY_TO_DECIMAL(in_district_expenditures_per_pupil_stripped, 20, 2) AS in_district_expenditures_per_pupil,
        TRY_TO_DECIMAL(total_expenditures_stripped, 20, 2) AS total_expenditures,
        TRY_TO_DECIMAL(total_pupil_ftes_stripped, 20, 2) AS total_pupil_ftes,
        TRY_TO_DECIMAL(total_expenditures_per_pupil_stripped, 20, 2) AS total_expenditures_per_pupil
    FROM stripped
)

SELECT * FROM typed;
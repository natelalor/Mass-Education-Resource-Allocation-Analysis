-- Student attendance cleaning: dedup, trim, cast, and order by district/staff_type

CREATE OR REPLACE TABLE school_information.clean.student_attendance AS

-- CTE 1: deduplication & checks
WITH dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY district_code ORDER BY district_name) AS rn
        FROM school_information.raw.student_attendance
        QUALIFY rn = 1
),

-- CTE 2: trimming, stripping, cleaning
stripped AS (
    SELECT
        NULLIF(TRIM(district_name), '') AS district_name,
        NULLIF(TRIM(district_code), '') AS district_code,
        NULLIF(TRIM(attendance_rate), '') AS attendance_rate_stripped,
        NULLIF(TRIM(average_number_absences), '') AS average_number_absences_stripped,
        NULLIF(TRIM(absent_10_or_more_days), '') AS absent_10_or_more_days_stripped,
        NULLIF(TRIM(absent_10_percent_or_more), '') AS absent_10_percent_or_more_stripped,
        NULLIF(TRIM(absent_20_percent_or_more), '') AS absent_20_percent_or_more_stripped,
        NULLIF(TRIM(unexcused_over_9_days), '') AS unexcused_over_9_days_stripped
    FROM dedup
),

-- CTE 3: datatype conversion & polishing prep
typed AS (
    SELECT
        district_name,
        district_code,
        TRY_TO_DECIMAL(attendance_rate_stripped, 5, 1) AS attendance_rate,
        TRY_TO_DECIMAL(average_number_absences_stripped, 5, 1) AS average_number_absences,
        TRY_TO_DECIMAL(absent_10_or_more_days_stripped, 5, 1) AS absent_10_or_more_days,
        TRY_TO_DECIMAL(absent_10_percent_or_more_stripped, 5, 1) AS absent_10_percent_or_more,
        TRY_TO_DECIMAL(absent_20_percent_or_more_stripped, 5, 1) AS absent_20_percent_or_more,
        TRY_TO_DECIMAL(unexcused_over_9_days_stripped, 5, 1) AS unexcused_over_9_days
    FROM stripped
)
SELECT * FROM typed;
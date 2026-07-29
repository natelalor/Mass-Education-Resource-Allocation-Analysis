-- Staff attendance cleaning: dedup, trim, cast, and order by district/staff_type

CREATE OR REPLACE TABLE school_information.clean.staff_attendance AS

-- CTE 1: deduplication & checks
WITH dedup AS (
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY district_code, staff_type ORDER BY district_name) AS rn
    FROM school_information.raw.staff_attendance
    QUALIFY rn = 1
),

-- CTE 2: trimming, stripping, varchar cleaning & datatype prep
stripped AS (
    SELECT
        NULLIF(TRIM(district_name), '') AS district_name,
        NULLIF(TRIM(district_code), '') AS district_code,
        staff_type,
        NULLIF(TRIM(REPLACE(total_number_of_staff, ',', '')), '') AS total_number_of_staff_stripped,
        NULLIF(TRIM(attendance_rate_percentage), '') AS attendance_rate_percentage_stripped,
        NULLIF(TRIM(average_number_of_absences), '') AS average_number_of_absences_stripped
        
    FROM dedup
),

-- CTE 3: datatype casting & polishing
typed AS (
    SELECT
        district_name,
        district_code,
        staff_type,
        TRY_CAST(total_number_of_staff_stripped AS INT) AS total_number_of_staff,
        TRY_TO_DECIMAL(attendance_rate_percentage_stripped, 5, 1) AS attendance_rate_percentage,
        TRY_TO_DECIMAL(average_number_of_absences_stripped, 5, 1) AS average_number_of_absences
        
    FROM stripped
)

SELECT * FROM typed
ORDER BY district_name,
    CASE staff_type
        WHEN 'Teachers' THEN 1
        WHEN 'Administrators' THEN 2
        WHEN 'All Staff' THEN 3
    END;
-- SQL script to clean and type-cast art_courses for analytical investigation


CREATE OR REPLACE TABLE school_information.clean.art_courses AS

-- -- CTE 1: dedup - for deduplication & checks
WITH dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY district_code
            ORDER BY district_name
        ) AS rn
    FROM school_information.raw.art_courses
    QUALIFY rn = 1
),

-- CTE 2: stripped - trimming, null handling, cleaning of the data
stripped AS (
    SELECT
        TRIM(district_name) AS district_name,
        TRIM(district_code) AS district_code,

        NULLIF(TRIM(REPLACE(kindergarten, ',', '')), '') AS kindergarten_stripped,
        NULLIF(TRIM(REPLACE(first_grade, ',', '')), '') AS first_grade_stripped,
        NULLIF(TRIM(REPLACE(second_grade, ',', '')), '') AS second_grade_stripped,
        NULLIF(TRIM(REPLACE(third_grade, ',', '')), '') AS third_grade_stripped,
        NULLIF(TRIM(REPLACE(fourth_grade, ',', '')), '') AS fourth_grade_stripped,
        NULLIF(TRIM(REPLACE(fifth_grade, ',', '')), '') AS fifth_grade_stripped,
        NULLIF(TRIM(REPLACE(sixth_grade, ',', '')), '') AS sixth_grade_stripped,
        NULLIF(TRIM(REPLACE(seventh_grade, ',', '')), '') AS seventh_grade_stripped,
        NULLIF(TRIM(REPLACE(eighth_grade, ',', '')), '') AS eighth_grade_stripped,
        NULLIF(TRIM(REPLACE(ninth_grade, ',', '')), '') AS ninth_grade_stripped,
        NULLIF(TRIM(REPLACE(tenth_grade, ',', '')), '') AS tenth_grade_stripped,
        NULLIF(TRIM(REPLACE(eleventh_grade, ',', '')), '') AS eleventh_grade_stripped,
        NULLIF(TRIM(REPLACE(twelveth_grade, ',', '')), '') AS twelveth_grade_stripped,
        NULLIF(TRIM(REPLACE(all_grades, ',', '')), '') AS all_grades_stripped,
        NULLIF(TRIM(REPLACE(total_students, ',', '')), '') AS total_students_stripped

    FROM dedup
),

-- CTE 3: typed - for datatype casting after sufficient cleaning
typed AS (
    SELECT 
        district_name,
        district_code,
        
        TRY_CAST(kindergarten_stripped AS INT) AS kindergarten,
        TRY_CAST(first_grade_stripped AS INT) AS first_grade,
        TRY_CAST(second_grade_stripped AS INT) AS second_grade,
        TRY_CAST(third_grade_stripped AS INT) AS third_grade,
        TRY_CAST(fourth_grade_stripped AS INT) AS fourth_grade,
        TRY_CAST(fifth_grade_stripped AS INT) AS fifth_grade,
        TRY_CAST(sixth_grade_stripped AS INT) AS sixth_grade,
        TRY_CAST(seventh_grade_stripped AS INT) AS seventh_grade,
        TRY_CAST(eighth_grade_stripped AS INT) AS eighth_grade,
        TRY_CAST(ninth_grade_stripped AS INT) AS ninth_grade,
        TRY_CAST(tenth_grade_stripped AS INT) AS tenth_grade,
        TRY_CAST(eleventh_grade_stripped AS INT) AS eleventh_grade,
        TRY_CAST(twelveth_grade_stripped AS INT) AS twelveth_grade,
        TRY_CAST(all_grades_stripped AS INT) AS all_grades,
        TRY_CAST(total_students_stripped AS INT) AS total_students

    FROM stripped
)

SELECT * FROM typed;
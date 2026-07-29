-- SQL script to clean and type-cast standardized_testing_results for analysis
-- Co-authored with CoCo

CREATE OR REPLACE TABLE school_information.clean.standardized_testing_results AS

-- CTE 1: deduplication & checks
WITH dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY district_code, subject ORDER BY district_name) AS rn
        FROM school_information.raw.standardized_testing_results
        QUALIFY rn = 1
),

-- CTE 2: trimming, stripping, preparing datatype casting & NULL handling
stripped AS (
    SELECT
        NULLIF(TRIM(district_name), '') AS district_name,
        NULLIF(TRIM(district_code), '') AS district_code,
        NULLIF(UPPER(TRIM(subject)), '') AS subject_stripped,
        
        NULLIF(TRIM(REPLACE(m_e_number, ',', '')), '') AS m_e_number_stripped,
        NULLIF(TRIM(m_e_percentage), '') AS m_e_percentage_stripped,
        
        NULLIF(TRIM(REPLACE(e_number, ',', '')), '') AS e_number_stripped,
        NULLIF(TRIM(e_percentage), '') AS e_percentage_stripped,
        
        NULLIF(TRIM(REPLACE(m_number, ',', '')), '') AS m_number_stripped,
        NULLIF(TRIM(m_percentage), '') AS m_percentage_stripped,

        NULLIF(TRIM(REPLACE(p_m_number, ',', '')), '') AS p_m_number_stripped,
        NULLIF(TRIM(p_m_percentage), '') AS p_m_percentage_stripped,
        
        NULLIF(TRIM(REPLACE(n_m_number, ',', '')), '') AS n_m_number_stripped,
        NULLIF(TRIM(n_m_percentage), '') AS n_m_percentage_stripped,

        NULLIF(TRIM(REPLACE(total_students_included, ',', '')), '') AS total_students_included_stripped,
        NULLIF(TRIM(participation_rate_percentage), '') AS participation_rate_percentage_stripped,
        NULLIF(TRIM(REPLACE(average_scaled_score, ',', '')), '') AS average_scaled_score_stripped,
        NULLIF(TRIM(REPLACE(sgp, ',', '')), '') AS sgp_stripped,
        NULLIF(TRIM(REPLACE(total_students_included_in_sgp, ',', '')), '') AS total_students_included_in_sgp_stripped,
        
    FROM dedup
),

-- CTE 3: datatype conversion, polish & prep
typed AS (
    SELECT
        district_name,
        district_code,
        subject_stripped AS subject,
        TRY_CAST(m_e_number_stripped AS INTEGER) AS m_e_number,
        TRY_CAST(m_e_percentage_stripped AS INTEGER) AS m_e_percentage,
        TRY_CAST(e_number_stripped AS INTEGER) AS e_number,
        TRY_CAST(e_percentage_stripped AS INTEGER) AS e_percentage,
        TRY_CAST(m_number_stripped AS INTEGER) AS m_number,
        TRY_CAST(m_percentage_stripped AS INTEGER) AS m_percentage,
        TRY_CAST(p_m_number_stripped AS INTEGER) AS p_m_number,
        TRY_CAST(p_m_percentage_stripped AS INTEGER) AS p_m_percentage,
        TRY_CAST(n_m_number_stripped AS INTEGER) AS n_m_number,
        TRY_CAST(n_m_percentage_stripped AS INTEGER) AS n_m_percentage,
        TRY_CAST(total_students_included_stripped AS INTEGER) AS total_students_included,
        TRY_CAST(participation_rate_percentage_stripped AS INTEGER) AS participation_rate_percentage,
        TRY_CAST(average_scaled_score_stripped AS INTEGER) AS average_scaled_score,
        TRY_CAST(sgp_stripped AS INTEGER) AS sgp,
        TRY_CAST(total_students_included_in_sgp_stripped AS INTEGER) AS total_students_included_in_sgp,
        
    FROM stripped
)

SELECT * 
FROM typed
ORDER BY district_name,
    CASE subject
        WHEN 'ELA' THEN 1
        WHEN 'MATH' THEN 2
        WHEN 'SCI' THEN 3
    END;
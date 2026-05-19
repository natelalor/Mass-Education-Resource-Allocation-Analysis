
/* sanitize raw datasets for uniformity and completion */

/* temporary query slice: */

CREATE TABLE `education-resource-analysis.resource_analysis.cleaned_teacher_salaries` AS
SELECT
  string_field_0 AS district_name,
  string_field_1 AS district_code,
  CAST(REPLACE(REPLACE(string_field_2, '$', ''), ',', '') AS INT64) AS salary_totals,
  CAST(REPLACE(REPLACE(string_field_3, '$', ''), ',', '') AS INT64) AS average_salary,
  CAST(string_field_4 AS FLOAT64) AS fte_count
FROM `education-resource-analysis.resource_analysis.teacher_salaries`
WHERE string_field_0 NOT IN ('District Name', '2023-24 Teacher Salaries Report');



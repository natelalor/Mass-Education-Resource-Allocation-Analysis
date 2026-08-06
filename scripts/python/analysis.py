import pandas as pd
import numpy as np
from pathlib import Path

art_courses_df = pd.read_csv("./data/clean_csv/art_courses.csv", dtype={"DISTRICT_CODE": str})
graduation_rates_df = pd.read_csv("./data/clean_csv/graduation_rates.csv", dtype={"DISTRICT_CODE": str})
per_pupil_expenditures_df = pd.read_csv("./data/clean_csv/per_pupil_expenditures.csv", dtype={"DISTRICT_CODE": str})
staff_attendance_df = pd.read_csv("./data/clean_csv/staff_attendance.csv", dtype={"DISTRICT_CODE": str})
standardized_testing_results_df = pd.read_csv("./data/clean_csv/standardized_testing_results.csv", dtype={"DISTRICT_CODE": str})
student_attendance_df = pd.read_csv("./data/clean_csv/student_attendance.csv", dtype={"DISTRICT_CODE": str})
teacher_salaries_df = pd.read_csv("./data/clean_csv/teacher_salaries.csv", dtype={"DISTRICT_CODE": str})

# print(art_courses_df.head())
# print(list(art_courses_df.columns))

print(len(art_courses_df) + len(graduation_rates_df) + len(per_pupil_expenditures_df) + len(staff_attendance_df) + len(standardized_testing_results_df) + len(student_attendance_df) + len(teacher_salaries_df))
import pandas as pd
import numpy as np
from pathlib import Path

art_courses_df = pd.read_csv(
    "./data/clean_csv/art_courses.csv", dtype={"DISTRICT_CODE": str}
)
graduation_rates_df = pd.read_csv(
    "./data/clean_csv/graduation_rates.csv", dtype={"DISTRICT_CODE": str}
)
per_pupil_expenditures_df = pd.read_csv(
    "./data/clean_csv/per_pupil_expenditures.csv", dtype={"DISTRICT_CODE": str}
)
staff_attendance_df = pd.read_csv(
    "./data/clean_csv/staff_attendance.csv", dtype={"DISTRICT_CODE": str}
)
standardized_testing_results_df = pd.read_csv(
    "./data/clean_csv/standardized_testing_results.csv", dtype={"DISTRICT_CODE": str}
)
student_attendance_df = pd.read_csv(
    "./data/clean_csv/student_attendance.csv", dtype={"DISTRICT_CODE": str}
)
teacher_salaries_df = pd.read_csv(
    "./data/clean_csv/teacher_salaries.csv", dtype={"DISTRICT_CODE": str}
)

def explore(df, name):
    print(f"\n{'='*20} {name} {'='*20}")
    df.info()
    print(df.head())
    print(df.shape)
    print(df.dtypes)
    print("isnull sum:\n", df.isnull().sum())
    print("duplicated sum: ", df.duplicated().sum())
    print("unique districts: ", df["DISTRICT_CODE"].nunique())

# explore(art_courses_df, "Art Courses")
explore(graduation_rates_df, "Graduation Rates")
# explore(per_pupil_expenditures_df, "Per Pupil Expenditures")
# explore(staff_attendance_df, "Staff Attendance")
# explore(standardized_testing_results_df, "Standardized Testing Results")
# explore(student_attendance_df, "Student Attendance")
# explore(teacher_salaries_df, "Teacher Salaries")
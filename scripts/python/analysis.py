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
    print(f"\n{'='*10} {name} {'='*10}")
    # df.info()
    # print(df.head())
    # print(df.shape)
    # print(df.dtypes)
    # print("isnull sum:\n", df.isnull().sum())
    # print("duplicated sum: ", df.duplicated().sum())
    # print("unique districts: ", df["DISTRICT_CODE"].nunique())
    # print(df["DISTRICT_NAME"].unique())        
    # print(df["DISTRICT_NAME"].value_counts())  
    # print(df["DISTRICT_NAME"].describe()) 

# explore(art_courses_df, "Art Courses")
# explore(graduation_rates_df, "Graduation Rates")
# explore(per_pupil_expenditures_df, "Per Pupil Expenditures")
# explore(staff_attendance_df, "Staff Attendance")
# explore(standardized_testing_results_df, "Standardized Testing Results")
# explore(student_attendance_df, "Student Attendance")
# explore(teacher_salaries_df, "Teacher Salaries")

dfs = {
    "art": art_courses_df,
    "grad": graduation_rates_df,
    "ppe": per_pupil_expenditures_df,
    "staff_att": staff_attendance_df,
    "testing": standardized_testing_results_df,
    "student_att": student_attendance_df,
    "salaries": teacher_salaries_df,
}

# for name, df in dfs.items():
    # print(name, df["DISTRICT_CODE"].nunique())



all_codes = set(art_courses_df["DISTRICT_CODE"]) | set(per_pupil_expenditures_df["DISTRICT_CODE"])
grad_codes = set(graduation_rates_df["DISTRICT_CODE"])

missing_from_grad = all_codes - grad_codes
# print(len(missing_from_grad))

# pull district names for the missing ones from another df
# print(per_pupil_expenditures_df[per_pupil_expenditures_df["DISTRICT_CODE"].isin(missing_from_grad)]["DISTRICT_NAME"].unique())

# graduation_rates_df is the "meat" of this analysis, as we've aligned district codes
graduation_rates_df["has_high_school"] = True
all_districts = per_pupil_expenditures_df[["DISTRICT_CODE", "DISTRICT_NAME"]].drop_duplicates()
all_districts = all_districts.merge(graduation_rates_df, on="DISTRICT_CODE", how="left")
all_districts["has_high_school"] = all_districts["has_high_school"].fillna(False)

def merge_on_district(base_df, new_df, name):
    cols_to_add = [c for c in new_df.columns if c not in base_df.columns or c == "DISTRICT_CODE"]
    return base_df.merge(new_df[cols_to_add], on="DISTRICT_CODE", how="left", suffixes=("", f"_{name}"))

merged = graduation_rates_df.copy()
merged = merge_on_district(merged, per_pupil_expenditures_df, "ppe")
merged = merge_on_district(merged, teacher_salaries_df, "salaries")
merged = merge_on_district(merged, student_attendance_df, "student_att")
merged = merge_on_district(merged, staff_attendance_df, "staff_att")
merged = merge_on_district(merged, art_courses_df, "art")
merged = merge_on_district(merged, standardized_testing_results_df, "testing")

print(merged.shape)
merged.isnull().sum().sort_values(ascending=False)
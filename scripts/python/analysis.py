import pandas as pd
import numpy as np
from pathlib import Path
from scipy.stats import pearsonr
import matplotlib.pyplot as plt

# python file to gather clean, sanitized data from SQL to now organize, prep, & analyze using Pandas

def main():

    # ============================================================== #
    #      DATA IMPORT / SANITZATION VERIFICATION / PREPARATION      #
    # ============================================================== #

    # import cleaned csv files as their respective dataframes
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
        "./data/clean_csv/standardized_testing_results.csv",
        dtype={"DISTRICT_CODE": str},
    )
    student_attendance_df = pd.read_csv(
        "./data/clean_csv/student_attendance.csv", dtype={"DISTRICT_CODE": str}
    )
    teacher_salaries_df = pd.read_csv(
        "./data/clean_csv/teacher_salaries.csv", dtype={"DISTRICT_CODE": str}
    )

    # rename art_courses_df grade columns so they're unambiguous once merged
    # (e.g. KINDERGARTEN -> ART_KINDERGARTEN), since these represent ART COURSE
    # enrollment per grade, not TOTAL DISTRICT enrollment per grade
    art_grade_cols = [
        "KINDERGARTEN",
        "FIRST_GRADE",
        "SECOND_GRADE",
        "THIRD_GRADE",
        "FOURTH_GRADE",
        "FIFTH_GRADE",
        "SIXTH_GRADE",
        "SEVENTH_GRADE",
        "EIGHTH_GRADE",
        "NINTH_GRADE",
        "TENTH_GRADE",
        "ELEVENTH_GRADE",
        "TWELVETH_GRADE",
        "ALL_GRADES",
    ]
    art_courses_df = art_courses_df.rename(
        columns={col: f"ART_{col}" for col in art_grade_cols}
    )

    # 1 row per district_code rather than 3
    # (for staff, administrators, all, its just the "all" row)
    staff_attendance_all = staff_attendance_df[
        staff_attendance_df["STAFF_TYPE"] == "All Staff"
    ].drop(columns=["STAFF_TYPE"])

    # transforms standardized_testing_results into 1 row per district_code (wide --> long)
    # this df had 3 respective rows per district code, for each test type respectively: ELA, SCI, & MATH
    metric_cols = [
        c
        for c in standardized_testing_results_df.columns
        if c not in ["DISTRICT_NAME", "DISTRICT_CODE", "SUBJECT"]
    ]

    testing_wide = standardized_testing_results_df.pivot_table(
        index="DISTRICT_CODE",
        columns="SUBJECT",
        values=metric_cols,
        aggfunc="first",  # each district/subject pair is exactly one row, so this just grabs it, no actual aggregation happening
    ).reset_index()

    # flatten the MultiIndex columns: ('AVERAGE_SCALED_SCORE', 'MATH') -> MATH_AVERAGE_SCALED_SCORE
    testing_wide.columns = [
        f"{subject}_{metric}" if subject else metric
        for metric, subject in testing_wide.columns
    ]

    # combine dfs -- use graduation_rates_df as the "meat" or the "spine" of the analysis
    # that's why we prepped other dfs above, to prepare for merge with graduation_rates_df
    merged = graduation_rates_df.copy()
    merged = merge_on_district(merged, per_pupil_expenditures_df, "ppe")
    merged = merge_on_district(merged, teacher_salaries_df, "salaries")
    merged = merge_on_district(merged, student_attendance_df, "student_att")
    merged = merge_on_district(merged, staff_attendance_all, "staff_att")
    merged = merge_on_district(merged, art_courses_df, "art")
    merged = merge_on_district(merged, testing_wide, "testing")

    # build a comparable "art access" metric: % of district students enrolled in an art course
    merged["ART_PARTICIPATION_RATE"] = (
        merged["ART_ALL_GRADES"] / merged["TOTAL_STUDENTS"]
    )

    # ============================================================== #
    #      ANALYSIS - CORRELATIONS, RELATIONSHIPS, INSIGHTS          #
    # ============================================================== #

    # correlations to graduation rate numbers
    numeric_cols = merged.select_dtypes(include=[np.number]).columns
    corr_matrix = merged[numeric_cols].corr()

    # statistical significance of correlations
    results = []
    for col in numeric_cols:
        if col == "PERCENTAGE_GRADUATED":
            continue
        valid = merged[["PERCENTAGE_GRADUATED", col]].dropna()
        if len(valid) > 2:
            r, p = pearsonr(valid["PERCENTAGE_GRADUATED"], valid[col])
            results.append({"column": col, "r": r, "p": p, "n": len(valid)})

    results_df = pd.DataFrame(results).sort_values("r", ascending=False)

    # export our findings, preparing for Tableau
    merged.to_csv("./data/insights/merged_insights.csv", index=False)
    results_df.to_csv("./data/insights/correlation_results.csv", index=False)
    print("Successfully created:\n- merged_insights.csv\n- correlation_results.csv\nAnd saved in data/insights directory.")

# ========================= #
#     HELPER FUNCTIONS
# ========================= #

# helper function "explore"
# initial data digging, ensuring exportation went smoothy, getting a sense of the data we're working with
def explore(df, name):
    print(f"\n{'='*10} {name} {'='*10}")
    df.info()
    print(df.head())
    print(df.shape)
    print(df.dtypes)
    print("isnull sum:\n", df.isnull().sum())
    print("duplicated sum: ", df.duplicated().sum())
    print("unique districts: ", df["DISTRICT_CODE"].nunique())
    print(df["DISTRICT_NAME"].unique())
    print(df["DISTRICT_NAME"].value_counts())
    print(df["DISTRICT_NAME"].describe())

# helper function "merge_on_district"
# to facilitate merging all of the dfs on the base df (graduation_rates)
def merge_on_district(base_df, new_df, name):
    # Only bring in columns that don't already exist in base_df (plus the join key),
    # so repeated columns like DISTRICT_NAME don't collide across merges
    cols_to_add = [
        c for c in new_df.columns if c not in base_df.columns or c == "DISTRICT_CODE"
    ]
    return base_df.merge(
        new_df[cols_to_add], on="DISTRICT_CODE", how="left", suffixes=("", f"_{name}")
    )

if __name__ == "__main__":
    main()
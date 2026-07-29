# May 18, 2026
# Python script using Pandas library to convert the xlsx filetypes within given directory to csv files so they are supported filetypes for BigQuery SQL query analysis

import pandas as pd
from pathlib import Path

# outline file I/O pathing
input_file_path = Path("./data/raw_xlsx")
output_file_path = Path("./data/raw_csv")
output_file_path.mkdir(exist_ok=True)

# for each xlsx file in directory, convert to csv file, give user confirmation
for xlsx_file in input_file_path.glob("*.xlsx"):
    # skip 1 row because it's the large header i.e. "2024 Salaries Report" - not needed
    # dtype forces pandas to read all columns as strings, will reformat schema with SQL
    temp_dataframe = pd.read_excel(xlsx_file, skiprows=1, dtype=str)
    temp_dataframe.to_csv(output_file_path / f"{xlsx_file.stem}.csv", index=False)
    print(f"Converted: {xlsx_file.name}")

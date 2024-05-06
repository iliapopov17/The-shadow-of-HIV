import pandas as pd
import sys


def filter_contaminants(input_file, output_file):
    # Load the data
    data = pd.read_csv(input_file)

    # Extract the date from 'Sample_id'
    data["Date"] = data["Sample_id"].apply(lambda x: x.split("_")[0])

    # Identify numeric columns (those that can be converted to float)
    numeric_cols = []
    for col in data.columns:
        if col not in ["Sample_id", "Date"]:
            try:
                data[col] = pd.to_numeric(data[col], errors="raise")
                numeric_cols.append(col)
            except ValueError:
                print(
                    f"Column {col} cannot be converted to numeric and will be ignored."
                )

    # Group by 'Date' and sum up the counts for each taxon
    taxa_by_date = data.groupby("Date")[numeric_cols].sum()

    # Identify taxa that appear exclusively on a specific date and are absent on others
    exclusive_taxa = (taxa_by_date > 0).sum(axis=0) == 1  # Taxa found on only one date
    taxa_to_remove = exclusive_taxa[
        exclusive_taxa
    ].index.tolist()  # List of taxa to remove

    # Filter out the identified contaminants
    filtered_data = data.drop(columns=taxa_to_remove + ["Date"])

    # Save the filtered data
    filtered_data.to_csv(output_file, index=False)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            "Usage: python filter_possible_contaminants.py {PATH_TO_INPUT_FILE} {PATH_TO_FILTERED_FILE}"
        )
    else:
        input_path = sys.argv[1]
        output_path = sys.argv[2]
        filter_contaminants(input_path, output_path)

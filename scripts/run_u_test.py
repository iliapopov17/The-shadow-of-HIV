import sys
import pandas as pd
from scipy.stats import mannwhitneyu
from statsmodels.stats.multitest import multipletests


def run_u_test(metadata_path, counts_path):
    # Load the datasets
    counts_df = pd.read_csv(counts_path)
    metadata_df = pd.read_csv(metadata_path)

    # Merge datasets on sample identifiers
    merged_df = pd.merge(
        counts_df, metadata_df, left_on="Sample_id", right_on="sample_id"
    )

    # Drop redundant column after merge
    merged_df.drop("Sample_id", axis=1, inplace=True)

    # Prepare results dictionary
    results = {}

    # Separate the dataset into HIV positive and negative
    positive_group = merged_df[merged_df["HIV_status"] == "positive"]
    negative_group = merged_df[merged_df["HIV_status"] == "negative"]

    # Perform Mann-Whitney U test for each bacterial species
    for column in counts_df.columns[1:]:  # exclude the 'Sample_id' column
        u_stat, p_value = mannwhitneyu(
            positive_group[column], negative_group[column], alternative="two-sided"
        )
        results[column] = p_value

    # Convert results dictionary to DataFrame for better visualization
    results_df = pd.DataFrame(list(results.items()), columns=["Organism", "P_value"])

    # Adjust P-values for multiple comparisons using Benjamini-Hochberg
    _, results_df["Adjusted_P_value"], _, _ = multipletests(
        results_df["P_value"], method="fdr_bh"
    )

    results_df.sort_values(
        by="Adjusted_P_value", inplace=True
    )  # Sort by adjusted P-values

    # Save the entire DataFrame to a CSV file
    output_file_name = counts_path.split("/")[-1].replace(".csv", "_p_values.csv")
    results_df.to_csv(output_file_name, index=False)
    print(f"Results have been saved to {output_file_name}")

    # Output the top 10 results
    print("Top 10 significant differences:")
    print(results_df.head(10))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: ./run_u_test.py <metadata_path> <counts_path>")
        sys.exit(1)

    metadata_path = sys.argv[1]
    counts_path = sys.argv[2]
    run_u_test(metadata_path, counts_path)

import sys
import pandas as pd
import numpy as np
from scipy.stats import mannwhitneyu


def load_data(metadata_path, counts_path):
    metadata = pd.read_csv(metadata_path)
    counts = pd.read_csv(counts_path)
    counts.rename(columns={"Sample_id": "sample_id"}, inplace=True)
    merged_data = pd.merge(metadata, counts, on="sample_id")
    return merged_data


def perform_tests(data, num_iterations, sample_size):
    species_columns = data.columns[
        2:
    ]  # assuming first two columns are sample_id and HIV_status
    p_values_df = pd.DataFrame(columns=species_columns)

    for _ in range(num_iterations):
        sample_group = data.sample(n=sample_size)
        rest_group = data.drop(sample_group.index)

        iteration_p_values = []
        for column in species_columns:
            _, p_val = mannwhitneyu(
                sample_group[column], rest_group[column], alternative="two-sided"
            )
            iteration_p_values.append(p_val)

        p_values_df.loc[len(p_values_df)] = iteration_p_values

    return p_values_df.median()


def main():
    if len(sys.argv) != 5:
        print(
            "Usage: %run randomizer.py {sample_size} {num_iterations} {metadata_path} {counts_path}"
        )
        sys.exit(1)

    sample_size = int(sys.argv[1])
    num_iterations = int(sys.argv[2])
    metadata_path = sys.argv[3]
    counts_path = sys.argv[4]

    # Load and prepare data
    data = load_data(metadata_path, counts_path)
    hiv_negative_data = data[data["HIV_status"] == "negative"]

    # Perform Mann-Whitney U tests and calculate median p-values
    median_p_values = perform_tests(hiv_negative_data, num_iterations, sample_size)
    print(median_p_values)


if __name__ == "__main__":
    main()

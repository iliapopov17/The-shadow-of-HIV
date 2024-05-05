import pandas as pd
import matplotlib.pyplot as plt
import sys


def load_data(file_path):
    # Load the CSV file into a DataFrame
    data_df = pd.read_csv(file_path)
    return data_df


def calculate_total_counts(data_df):
    # Calculate total counts across all columns except the first (assuming it's an ID or similar non-numeric)
    data_df["total_counts"] = data_df.iloc[:, 1:].sum(axis=1)
    return data_df


def plot_distribution(data_df, level):
    # Plotting the distribution of total counts
    plt.figure(figsize=(10, 6))
    plt.hist(data_df["total_counts"], bins=50, color="lightblue", edgecolor="black")
    plt.title(f"Distribution of Total Counts per Sample on {level} level")
    plt.xlabel("Total Counts")
    plt.ylabel("Frequency")
    plt.grid(True)
    plt.show()


def main(file_path, level):
    # Main function to load data, calculate total counts, and plot distribution
    data_df = load_data(file_path)
    data_df = calculate_total_counts(data_df)
    summary_stats = data_df["total_counts"].describe()
    print(summary_stats)
    plot_distribution(data_df, level)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python describe.py {PATH_TO_COUNTS_FILE} {LEVEL}")
        sys.exit(1)
    file_path = sys.argv[1]
    level = sys.argv[2]
    main(file_path, level)

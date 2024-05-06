import pandas as pd
import sys
import matplotlib.pyplot as plt
import seaborn as sns


def load_data(counts_path, metadata_path):
    counts_df = pd.read_csv(counts_path)
    metadata_df = pd.read_csv(metadata_path)
    merged_df = pd.merge(
        counts_df, metadata_df, left_on="Sample_id", right_on="sample_id"
    )
    return merged_df


def analyze_organism(merged_df, organism_name):
    organism_presence = merged_df[organism_name] > 0
    frequency = (
        merged_df[organism_presence].groupby("HIV_status").size()
        / merged_df.groupby("HIV_status").size()
    )
    stats = merged_df[organism_name].describe()
    mode = merged_df[organism_name].mode()[0]
    stats["mode"] = mode

    # Calculate burden for HIV positive and negative samples
    hiv_positive_samples = merged_df[merged_df["HIV_status"] == "positive"]
    hiv_negative_samples = merged_df[merged_df["HIV_status"] == "negative"]

    burden_hiv_positive = hiv_positive_samples[organism_name].sum()
    average_burden_hiv_positive = burden_hiv_positive / hiv_positive_samples.shape[0]
    burden_hiv_negative = hiv_negative_samples[organism_name].sum()
    average_burden_hiv_negative = burden_hiv_negative / hiv_negative_samples.shape[0]

    # Count of samples with the organism in the HIV positive and negative groups
    count_samples_with_organism_hiv_positive = (
        hiv_positive_samples[organism_name].gt(0).sum()
    )
    count_samples_with_organism_hiv_negative = (
        hiv_negative_samples[organism_name].gt(0).sum()
    )

    return (
        frequency,
        stats,
        burden_hiv_positive,
        average_burden_hiv_positive,
        burden_hiv_negative,
        average_burden_hiv_negative,
        count_samples_with_organism_hiv_positive,
        count_samples_with_organism_hiv_negative,
    )


def create_visualizations(merged_df, organism_name):
    fig, axs = plt.subplots(2, 2, figsize=(15, 12))

    # Histogram of Organism Counts
    sns.histplot(merged_df[organism_name], kde=False, ax=axs[0, 0])
    axs[0, 0].set_title("Histogram of " + organism_name + " Counts")

    # Boxplots for Organism Counts by HIV Status
    sns.boxplot(x="HIV_status", y=organism_name, data=merged_df, ax=axs[0, 1])
    axs[0, 1].set_title("Boxplot of " + organism_name + " by HIV Status")

    # Bar Graphs of Total Burdens
    burdens = [
        merged_df.loc[merged_df["HIV_status"] == "positive", organism_name].sum(),
        merged_df.loc[merged_df["HIV_status"] == "negative", organism_name].sum(),
    ]
    axs[1, 0].bar(["HIV Positive", "HIV Negative"], burdens)
    axs[1, 0].set_title("Total Burden of " + organism_name)

    # Frequency Distribution Pie Chart
    frequencies = merged_df[organism_name].gt(0).groupby(merged_df["HIV_status"]).mean()
    axs[1, 1].pie(
        frequencies, labels=frequencies.index, autopct="%1.1f%%", startangle=90
    )
    axs[1, 1].set_title("Frequency Distribution of " + organism_name)

    plt.tight_layout()
    plt.show()


def main(counts_path, metadata_path, organism_name):
    merged_df = load_data(counts_path, metadata_path)
    (
        frequency,
        stats,
        total_burden_positive,
        average_burden_positive,
        total_burden_negative,
        average_burden_negative,
        count_samples_with_organism_hiv_positive,
        count_samples_with_organism_hiv_negative,
    ) = analyze_organism(merged_df, organism_name)
    print("Frequency of", organism_name, "by HIV Status:", frequency)
    print("Detailed Statistics for", organism_name, ":", stats)
    print(
        "Total Burden of",
        organism_name,
        "in HIV Positive Samples:",
        total_burden_positive,
    )
    print("Average Burden per HIV Positive Sample:", average_burden_positive)
    print(
        "Total Burden of",
        organism_name,
        "in HIV Negative Samples:",
        total_burden_negative,
    )
    print("Average Burden per HIV Negative Sample:", average_burden_negative)
    print(
        "Number of samples with",
        organism_name,
        "in HIV Positive group:",
        count_samples_with_organism_hiv_positive,
    )
    print(
        "Number of samples with",
        organism_name,
        "in HIV Negative group:",
        count_samples_with_organism_hiv_negative,
    )
    create_visualizations(merged_df, organism_name)


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print(
            "Usage: python evil_face.py {organism_name} {counts_path} {metadata_path}"
        )
        sys.exit(1)
    organism_name = sys.argv[1]
    counts_path = sys.argv[2]
    metadata_path = sys.argv[3]
    main(counts_path, metadata_path, organism_name)

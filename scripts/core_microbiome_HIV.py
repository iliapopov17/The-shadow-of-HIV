import sys
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

def convert_to_percentage(counts_file, metadata_file, status):
    counts_df = pd.read_csv(counts_file)
    metadata_df = pd.read_csv(metadata_file)
    
    merged_df = pd.merge(counts_df, metadata_df, left_on="Sample_id", right_on="sample_id")
    merged_df.drop("Sample_id", axis=1, inplace=True)
    
    include_columns = merged_df.columns[:-2]
    
    df_taxonomy = merged_df.loc[merged_df['HIV_status'] == status]
    
    df_percentage = df_taxonomy[include_columns].div(df_taxonomy[include_columns].sum(axis=1), axis=0)
    
    return df_percentage

def filter_taxa(converted_data, percentage):
    filtered_species = converted_data.mean().to_frame().reset_index()
    filtered_columns = list(filtered_species[filtered_species[0] > percentage]['index'])
    filtered_df_percentage = converted_data[filtered_columns]

    return filtered_df_percentage


def create_share_matrix(filtered_df_percentage):
    samples_share_range = np.arange(0.1, 1.1, 0.1)
    taxons = filtered_df_percentage.columns
    matrix = np.zeros((len(taxons), len(samples_share_range)))
    
    for i, col in enumerate(taxons):
        for j, share in enumerate(samples_share_range):
            share_exceeding = (filtered_df_percentage[col] > share).mean()
            matrix[i, j] = share_exceeding
    
    return matrix, taxons

def plot_heatmap(matrix, taxons, hiv_status):
    samples_share_range = np.arange(0.1, 1.1, 0.1)

    plt.figure(figsize=(12, 8))
    heatmap = sns.heatmap(matrix, cmap='coolwarm', xticklabels=[int(share * 100) for share in samples_share_range], yticklabels=taxons, 
                          square=True, annot=True, fmt=".3f", linewidths=0.5, linecolor='white')
    plt.xlabel('Microorganisms percentage')
    plt.ylabel('Taxa')
    plt.title(f'Core microbiome for {hiv_status}')
    
    cbar = heatmap.collections[0].colorbar
    cbar.set_label('Samples exceeding share percentage')

    for label in heatmap.yaxis.get_ticklabels():
        label.set_fontstyle('italic')
    
    plt.show()

def main(counts_file, metadata_file, status, percentage_threshold):
    df_percentage = convert_to_percentage(counts_file, metadata_file, status)
    filtered_df_percentage = filter_taxa(df_percentage, percentage_threshold)
    
    matrix, taxons = create_share_matrix(filtered_df_percentage)
    
    hiv_status = 'HIV positive' if status == 'positive' else 'HIV negative'
    plot_heatmap(matrix, taxons, hiv_status)

if __name__ == "__main__":
    
    counts_file = sys.argv[1]
    metadata_file = sys.argv[2]
    status = sys.argv[3]
    percentage_threshold = float(sys.argv[4])
    
    main(counts_file, metadata_file, status, percentage_threshold)
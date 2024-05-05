import sys
import pandas as pd


def filter_species(input_file, output_file):
    # Load the data from the input file
    data = pd.read_csv(input_file)

    # Filter out columns (species) where all values are zero
    filtered_data = data.loc[:, (data != 0).any(axis=0)]

    # Save the filtered data to the output file
    filtered_data.to_csv(output_file, index=False)
    print(f"Filtered data saved to {output_file}")


def main():
    if len(sys.argv) != 3:
        print("Usage: %run filter_counts.py {input} {output}")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    filter_species(input_file, output_file)


if __name__ == "__main__":
    main()

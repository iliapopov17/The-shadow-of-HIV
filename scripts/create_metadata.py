import os
import csv


def process_folder(folder_path, hiv_status):
    # List all files in the directory
    files = os.listdir(folder_path)
    # Filter and process only .txt files
    return [
        (file.replace(".txt", ""), hiv_status)
        for file in files
        if file.endswith(".txt")
    ]


def write_metadata(hiv_folder, ctrl_folder, output_file):
    # Process each folder
    hiv_data = process_folder(hiv_folder, "positive")
    ctrl_data = process_folder(ctrl_folder, "negative")

    # Combine data
    combined_data = hiv_data + ctrl_data

    # Write to CSV
    with open(output_file, "w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["sample_id", "HIV_status"])  # Write header
        for item in combined_data:
            writer.writerow(item)

    print(f"Metadata written to {output_file}")


if __name__ == "__main__":
    import sys

    if len(sys.argv) != 4:
        print(
            "Usage: python script.py <path_to_HIV_folder> <path_to_CTRL_folder> <output_file>"
        )
        sys.exit(1)

    hiv_folder_path = sys.argv[1]
    ctrl_folder_path = sys.argv[2]
    output_file_path = sys.argv[3]
    write_metadata(hiv_folder_path, ctrl_folder_path, output_file_path)

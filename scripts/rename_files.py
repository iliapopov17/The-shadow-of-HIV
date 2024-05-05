import os


def rename_files(directory):
    # List all files in the directory
    files = os.listdir(directory)
    for file in files:
        # Check if the file is a .txt file and contains '_kraken_report'
        if file.endswith(".txt") and "_kraken_report" in file:
            # Create the new file name
            new_file_name = file.replace("_kraken_report", "")
            # Full path for the old and new files
            old_file_path = os.path.join(directory, file)
            new_file_path = os.path.join(directory, new_file_name)
            # Rename the file
            os.rename(old_file_path, new_file_path)


if __name__ == "__main__":
    import sys

    if len(sys.argv) != 2:
        print("Usage: python script.py <path_to_folder>")
        sys.exit(1)

    folder_path = sys.argv[1]
    rename_files(folder_path)

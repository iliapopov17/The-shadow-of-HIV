import os
import sys
import pandas as pd


def generate_metadata(hiv_dir, ctrl_dir, bgi_dir, output_file):
    directories = {"CTRL": ctrl_dir, "HIV": hiv_dir, "BGI": bgi_dir}
    data = []

    for group, dir_path in directories.items():
        if os.path.exists(dir_path):
            files = os.listdir(dir_path)
            for file in files:
                sample_id = file.split(".")[
                    0
                ]  # Assuming file name format is like sample_id.extension
                hiv_status = "negative" if group in ["CTRL", "BGI"] else "positive"
                platform = "BGI" if group == "BGI" else "IonTorrent"

                data.append(
                    {
                        "sample_id": sample_id,
                        "HIV_status": hiv_status,
                        "Platform": platform,
                    }
                )

    df = pd.DataFrame(data)
    df.to_csv(output_file, index=False)
    print(f"Metadata file created successfully at {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print(
            "Usage: %run create_metadata.py <HIV_dir> <CTRL_dir> <BGI_dir> <output_file>"
        )
        sys.exit(1)

    hiv_dir, ctrl_dir, bgi_dir, output_file = (
        sys.argv[1],
        sys.argv[2],
        sys.argv[3],
        sys.argv[4],
    )
    generate_metadata(hiv_dir, ctrl_dir, bgi_dir, output_file)

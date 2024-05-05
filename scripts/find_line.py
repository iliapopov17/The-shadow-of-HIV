import sys

def find_and_display_lines(filename, keyword):
    try:
        # Read all lines from the file
        with open(filename, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        
        # Search for the keyword and process the lines
        for i, line in enumerate(lines):
            if keyword.lower() in line.lower():
                # Get the line number of the keyword
                line_number = i + 1
                print(f"Found keyword in line {line_number}")
                
                # Calculate index for the first line to display
                start = max(0, i - 5)
                end = min(len(lines), i + 6)  # i+1 for the next 5 lines, exclusive, hence +6
                
                # Print 5 lines before the keyword
                for j in range(start, i):
                    print(f"{j + 1}: {lines[j].strip()}")

                # Print the line with the keyword
                print(f"{line_number}: {line.strip()}")  # Current line
                
                # Print 5 lines after the keyword
                for j in range(i + 1, end):
                    print(f"{j + 1}: {lines[j].strip()}")
                
                break
        else:
            print("Keyword not found in the file.")
    
    except FileNotFoundError:
        print("The file does not exist.")
    except Exception as e:
        print(f"An error occurred: {e}")

def main():
    if len(sys.argv) != 3:
        print("Usage: python script.py filename 'keyword'")
        sys.exit(1)
    
    filename = sys.argv[1]
    keyword = sys.argv[2]
    find_and_display_lines(filename, keyword)

if __name__ == "__main__":
    main()

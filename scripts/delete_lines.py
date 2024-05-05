import sys

def delete_lines(filename, line_numbers):
    try:
        # Convert line numbers from string to a set of integers
        line_numbers_to_delete = set(map(int, line_numbers.split(',')))
        
        # Read all lines from the file
        with open(filename, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        
        # Write back only those lines that are not in the deletion set
        with open(filename, 'w', encoding='utf-8') as file:
            for index, line in enumerate(lines, start=1):
                if index not in line_numbers_to_delete:
                    file.write(line)
        
        print(f"Lines {line_numbers} have been deleted from {filename}.")
    
    except FileNotFoundError:
        print("The file does not exist.")
    except ValueError:
        print("Invalid line number format. Please provide integers separated by commas.")
    except Exception as e:
        print(f"An error occurred: {e}")

def main():
    if len(sys.argv) != 3:
        print("Usage: python script.py filename 'line_numbers'")
        return
    
    filename = sys.argv[1]
    line_numbers = sys.argv[2]
    delete_lines(filename, line_numbers)

if __name__ == "__main__":
    main()

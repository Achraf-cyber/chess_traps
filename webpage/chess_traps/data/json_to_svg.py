import json
import csv

def convert_json_to_csv(input_json, output_csv):
    try:
        with open(input_json, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if not data:
            print("No data found in JSON.")
            return

        # Use the keys from the first object as CSV headers
        headers = data[0].keys()

        with open(output_csv, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=headers)
            writer.writeheader()
            writer.writerows(data)
            
        print(f"Successfully converted {input_json} to {output_csv}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    convert_json_to_csv('master_traps.json', 'master_traps.csv')
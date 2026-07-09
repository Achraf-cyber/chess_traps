import re
import json
import csv

def pgn_to_json_csv(input_file, output_json, output_csv):
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split the file into individual games
    # Games in PGN are separated by double newlines or end of file
    raw_games = re.split(r'\n\s*\n(?=\[)', content)
    
    unique_traps = []
    seen_moves = set()

    for raw_game in raw_games:
        if not raw_game.strip():
            continue

        # 1. Extract Tags using Regex
        tags = dict(re.findall(r'\[(\w+)\s+"(.*?)"\]', raw_game))
        
        # 2. Extract Move Text (everything after the last bracket)
        move_part = re.split(r'\]\s*\n', raw_game)[-1].strip()
        # Remove the result code at the end (1-0, 0-1, 1/2-1/2, *)
        move_part = re.sub(r'(1-0|0-1|1/2-1/2|\*)$', '', move_part).strip()
        
        commented_moves = move_part.replace('\n', ' ')
        
        # 3. Create Clean Moves
        # Remove variations in parentheses: ( ... )
        clean = re.sub(r'\s*\([^)]*\)', '', move_part)
        # Remove annotations: $4, $2, etc.
        clean = re.sub(r'\$\d+', '', clean)
        # Remove symbols: !, ?, !!, ??
        clean = re.sub(r'[!?]+', '', clean)
        # Normalize whitespace and remove line breaks
        clean = re.sub(r'\s+', ' ', clean).strip()
        
        # 4. Generate metadata string
        white = tags.get('White', 'Unknown')
        black = tags.get('Black', 'Unknown')
        event = tags.get('Event', '?')
        date = tags.get('Date', '????').split('.')[0] # Get just the year
        metadata_str = f"{white} - {black}, {event} {date}"

        # 5. Determine Opening Name
        # PGNs often lack 'Opening' tag but have 'ECO'. 
        # We use ECO if Opening is missing.
        opening_name = tags.get('Opening', f"Opening ({tags.get('ECO', 'Unknown')})")
        
        # Deduplication check
        if clean not in seen_moves:
            trap_obj = {
                "opening": opening_name,
                "trap_name": opening_name, # Placeholder as PGN doesn't store 'Trap Name'
                "clean_moves": clean,
                "commented_moves": commented_moves,
                "metadata": metadata_str
            }
            unique_traps.append(trap_obj)
            seen_moves.add(clean)

    # Export to JSON
    with open(output_json, 'w', encoding='utf-8') as f:
        json.dump(unique_traps, f, indent=4)

    # Export to CSV
    if unique_traps:
        keys = unique_traps[0].keys()
        with open(output_csv, 'w', newline='', encoding='utf-8') as f:
            dict_writer = csv.DictWriter(f, fieldnames=keys)
            dict_writer.writeheader()
            dict_writer.writerows(unique_traps)

    print(f"Success! Processed {len(unique_traps)} unique traps.")
    print(f"Files created: {output_json}, {output_csv}")

# Run the script
if __name__ == "__main__":
    # Change the filename here to match your exact file name
    pgn_to_json_csv('g700_minis - Copie.pgn.json', 'traps_converted.json', 'traps_converted.csv')
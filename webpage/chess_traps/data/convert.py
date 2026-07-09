import json
import re

def normalize_moves(moves):
    """Collapses whitespace for strict string comparison."""
    if not moves: return ""
    # Remove PGN variations (anything in parentheses)
    clean = re.sub(r'\s*\([^)]*\)', '', str(moves))
    # Remove PGN annotations and symbols
    clean = re.sub(r'\$\d+|[!?]+', '', clean)
    # Collapse multiple spaces and newlines
    return re.sub(r'\s+', ' ', clean).strip()

def parse_pseudo_json_pgn(file_path):
    """Parses a PGN file into the standard trap schema."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    games = []
    # Split PGN into individual game blocks
    raw_blocks = re.split(r'\n\s*\n(?=\[)', content)
    for block in raw_blocks:
        if not block.strip(): continue
        tags = dict(re.findall(r'\[(\w+)\s+"(.*?)"\]', block))
        move_part = re.split(r'\]\s*\n', block)[-1].strip()
        # Remove result (1-0, etc)
        move_part = re.sub(r'(1-0|0-1|1/2-1/2|\*)$', '', move_part).strip()
        
        # Build clean moves for the schema
        clean = normalize_moves(move_part)

        games.append({
            "opening": tags.get('Opening', tags.get('ECO', 'Unknown')),
            "trap_name": tags.get('Opening', 'Unknown'),
            "clean_moves": clean,
            "commented_moves": move_part.replace('\n', ' '),
            "metadata": f"{tags.get('White')} - {tags.get('Black')}, {tags.get('Date')}"
        })
    return games

def load_nested_json(file_path):
    """Loads [[{},{}]] and flattens it."""
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return [item for sublist in data for item in sublist]

# 1. Load both sources
list1 = load_nested_json('g700.json')
list2 = parse_pseudo_json_pgn('g700_minis - Copie.pgn.json')

# 2. Extract normalized move sets for comparison
set1 = {normalize_moves(g['clean_moves']) for g in list1}
set2 = {normalize_moves(g['clean_moves']) for g in list2}

# 3. Subset and Duplicate Analysis
common_count = len(set1.intersection(set2))
print(f"--- Comparison Report ---")
print(f"Unique games in Source 1: {len(set1)}")
print(f"Unique games in Source 2: {len(set2)}")
print(f"Common games (duplicates): {common_count}")

if set1.issubset(set2) and set2.issubset(set1):
    print("Result: Both files are identical in content.")
elif set1.issubset(set2):
    print("Result: Source 1 is ENTIRELY contained within Source 2.")
elif set2.issubset(set1):
    print("Result: Source 2 is ENTIRELY contained within Source 1.")
else:
    print("Result: Partial overlap found.")

# 4. Global Deduplication (Keep first encountered)
combined_list = list1 + list2
final_data = []
seen_normalized = set()

for entry in combined_list:
    norm = normalize_moves(entry.get('clean_moves', ''))
    if norm and norm not in seen_normalized:
        final_data.append(entry)
        seen_normalized.add(norm)

# 5. Export to Flat JSON
with open('master_traps.json', 'w', encoding='utf-8') as f:
    json.dump(final_data, f, indent=4)

print(f"\nSaved {len(final_data)} unique traps to master_traps.json")
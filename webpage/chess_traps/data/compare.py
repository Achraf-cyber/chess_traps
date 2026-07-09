import json
import re

def normalize_moves(moves):
    """Collapses all whitespace/newlines into single spaces for comparison."""
    if not moves:
        return ""
    return re.sub(r'\s+', ' ', str(moves)).strip()

def load_and_extract_moves(file_path):
    """
    Detects if the file is nested [[obj,...]] or flat [obj,...] 
    and returns a set of normalized clean_moves.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error loading {file_path}: {e}")
        return set()

    moves_set = set()
    
    # Check if the data is a nested list of lists
    if len(data) > 0 and isinstance(data[0], list):
        # Nested format
        for sublist in data:
            for item in sublist:
                m = normalize_moves(item.get('clean_moves', ''))
                if m: moves_set.add(m)
    else:
        # Flat format
        for item in data:
            m = normalize_moves(item.get('clean_moves', ''))
            if m: moves_set.add(m)
            
    return moves_set

def compare_chess_files(file1_path, file2_path):
    # Load unique moves from both files
    set1 = load_and_extract_moves(file1_path)
    set2 = load_and_extract_moves(file2_path)

    # 1. Intersection (Common games)
    common = set1.intersection(set2)
    common_count = len(common)

    # 2. Subset Checks
    is_1_in_2 = set1.issubset(set2)
    is_2_in_1 = set2.issubset(set1)

    # Output Results
    print(f"--- Comparison Report ---")
    print(f"File 1 ({file1_path}): {len(set1)} unique games found.")
    print(f"File 2 ({file2_path}): {len(set2)} unique games found.")
    print(f"-" * 30)
    print(f"Number of common games: {common_count}")
    
    if common_count == 0:
        print("Result: No overlap found between these files.")
    else:
        # Check if one is a complete subset of the other
        if is_1_in_2 and is_2_in_1:
            print("Result: Both files are identical (contain exactly the same games).")
        elif is_1_in_2:
            print(f"Result: File 1 is ENTIRELY contained within File 2.")
        elif is_2_in_1:
            print(f"Result: File 2 is ENTIRELY contained within File 1.")
        else:
            overlap_pct = (common_count / min(len(set1), len(set2))) * 100
            print(f"Result: Files overlap partially ({overlap_pct:.2f}% of the smaller file is shared).")

if __name__ == "__main__":
    # FILE 1: Your original nested g700.json
    # FILE 2: The converted JSON from the PGN script
    compare_chess_files('flattened_traps.json', 'traps_converted.json')
import json
import sqlite3
import os

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    json_path = os.path.join(script_dir, '..', 'assets', 'chess', 'g700.json')
    db_path = os.path.join(script_dir, '..', 'assets', 'chess', 'traps.db')
    
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS chess_traps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        opening TEXT,
        trap_name TEXT,
        clean_moves TEXT,
        commented_moves TEXT,
        metadata TEXT
    )
    ''')
    
    cursor.execute('DELETE FROM chess_traps')
    
    count = 0
    for section in data:
        if isinstance(section, list):
            for trap in section:
                cursor.execute('''
                INSERT INTO chess_traps (opening, trap_name, clean_moves, commented_moves, metadata)
                VALUES (?, ?, ?, ?, ?)
                ''', (
                    trap.get('opening', ''),
                    trap.get('trap_name', ''),
                    trap.get('clean_moves', ''),
                    trap.get('commented_moves', ''),
                    trap.get('metadata', '')
                ))
                count += 1
                
    conn.commit()
    conn.close()
    print(f"Successfully inserted {count} traps from {json_path} into {db_path}")

if __name__ == '__main__':
    main()

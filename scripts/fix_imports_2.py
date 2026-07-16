import glob
import os

replacements = [
    ('features/home/view/', 'presentation/screens/home/'),
    ('features/favorites/view/', 'presentation/screens/favorites/'),
    ('features/profile/view/', 'presentation/screens/profile/'),
    ('features/search_by_moves/view/', 'presentation/screens/search_by_moves/'),
    ('features/traps/view/', 'presentation/screens/traps/'),
    ('features/play/view/', 'presentation/screens/play/'),
    ('features/play/data/', 'data/play/'),
    ('features/traps/data/', 'data/traps/'),
    ('features/traps/providers/', 'presentation/state/traps/'),
    ('features/play/providers/', 'presentation/state/play/'),
    ('features/favorites/providers/', 'presentation/state/favorites/'),
    ('widgets/', 'presentation/widgets/'),
]

for file in glob.glob('lib/**/*.dart', recursive=True) + glob.glob('scripts/**/*.dart', recursive=True):
    with open(file, 'r', encoding='utf-8') as f:
        c = f.read()
    orig = c
    for old, new in replacements:
        c = c.replace(f"import '{old}", f"import '{new}")
        c = c.replace(f"import \"{old}", f"import \"{new}")
        c = c.replace(f"package:chess_traps/{old}", f"package:chess_traps/{new}")
    
    if orig != c:
        with open(file, 'w', encoding='utf-8') as f:
            f.write(c)

print('Fixed imports.')

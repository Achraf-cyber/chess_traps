
import json

def get_keys(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return set(data.keys())

en_keys = get_keys('lib/l10n/intl_en.arb')
ar_keys = get_keys('lib/l10n/intl_ar.arb')
es_keys = get_keys('lib/l10n/intl_es.arb')

print(f"EN Keys: {len(en_keys)}")
print(f"AR Keys: {len(ar_keys)}")
print(f"ES Keys: {len(es_keys)}")

missing_ar = en_keys - ar_keys
missing_es = en_keys - es_keys

if missing_ar:
    print(f"Missing in AR: {missing_ar}")
if missing_es:
    print(f"Missing in ES: {missing_es}")

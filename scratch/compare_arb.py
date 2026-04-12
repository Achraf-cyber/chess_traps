
import json

def compare_arb(base_file, target_file):
    with open(base_file, 'r', encoding='utf-8') as f:
        base_data = json.load(f)
    with open(target_file, 'r', encoding='utf-8') as f:
        target_data = json.load(f)
    
    base_keys = set(base_data.keys())
    target_keys = set(target_data.keys())
    
    missing = base_keys - target_keys
    extra = target_keys - base_keys
    
    print(f"Comparing {base_file} and {target_file}")
    print(f"Missing keys in {target_file}: {missing}")
    print(f"Extra keys in {target_file}: {extra}")

compare_arb('lib/l10n/intl_en.arb', 'lib/l10n/intl_ar.arb')
compare_arb('lib/l10n/intl_en.arb', 'lib/l10n/intl_es.arb')

#!/usr/bin/env python3
"""
Find duplicate definitions and their references in the codebase.
"""
import json
import re
from pathlib import Path
from collections import defaultdict, Counter

def extract_class_definitions(dart_file):
    """Extract class/interface definitions from a Dart file."""
    definitions = []
    try:
        with open(dart_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()

        # Find class definitions
        class_pattern = r'(?:class|abstract class|interface)\s+(\w+)'
        for match in re.finditer(class_pattern, content):
            class_name = match.group(1)
            definitions.append({
                'type': 'class',
                'name': class_name,
                'file': str(dart_file),
                'line': content[:match.start()].count('\n') + 1
            })

        # Find enum definitions
        enum_pattern = r'enum\s+(\w+)'
        for match in re.finditer(enum_pattern, content):
            enum_name = match.group(1)
            definitions.append({
                'type': 'enum',
                'name': enum_name,
                'file': str(dart_file),
                'line': content[:match.start()].count('\n') + 1
            })

    except Exception as e:
        print(f"Error reading {dart_file}: {e}")

    return definitions

def find_references(root_dir, definitions):
    """Find references to the defined symbols."""
    references = defaultdict(list)

    for dart_file in Path(root_dir).rglob('*.dart'):
        try:
            with open(dart_file, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()

            for line_num, line in enumerate(lines, 1):
                for def_info in definitions:
                    symbol = def_info['name']
                    if symbol in line and not line.strip().startswith('//'):
                        # Check if it's a definition (skip self-references)
                        if str(dart_file) == def_info['file'] and f'class {symbol}' in line:
                            continue
                        if str(dart_file) == def_info['file'] and f'enum {symbol}' in line:
                            continue

                        references[symbol].append({
                            'file': str(dart_file),
                            'line': line_num,
                            'context': line.strip()[:100]
                        })

        except Exception as e:
            print(f"Error reading {dart_file}: {e}")

    return references

def analyze_duplicates(root_dir):
    """Analyze duplicate definitions in the codebase."""
    all_definitions = []

    # Collect all definitions
    for dart_file in Path(root_dir).rglob('*.dart'):
        if 'packages/' in str(dart_file):  # Skip packages for now
            continue
        all_definitions.extend(extract_class_definitions(dart_file))

    # Group by name
    name_groups = defaultdict(list)
    for def_info in all_definitions:
        name_groups[def_info['name']].append(def_info)

    # Find duplicates (same name, different files)
    duplicates = {}
    for name, defs in name_groups.items():
        if len(defs) > 1:
            duplicates[name] = {
                'count': len(defs),
                'definitions': defs,
                'references': []
            }

    # Find references for duplicates
    if duplicates:
        references = find_references(root_dir, sum([d['definitions'] for d in duplicates.values()], []))
        for name in duplicates:
            duplicates[name]['references'] = references.get(name, [])

    return duplicates

def main():
    import sys

    if len(sys.argv) < 4:
        print("Usage: python find_duplicates_and_refs.py --root <root_dir> --out <output_file>")
        sys.exit(1)

    root_dir = None
    output_file = None

    i = 1
    while i < len(sys.argv):
        if sys.argv[i] == '--root' and i + 1 < len(sys.argv):
            root_dir = sys.argv[i + 1]
            i += 2
        elif sys.argv[i] == '--out' and i + 1 < len(sys.argv):
            output_file = sys.argv[i + 1]
            i += 2
        else:
            i += 1

    if not root_dir or not output_file:
        print("Missing root directory or output file")
        sys.exit(1)

    duplicates = analyze_duplicates(root_dir)

    result = {
        'total_duplicates': len(duplicates),
        'duplicates': duplicates,
        'analysis_note': 'Only checked for duplicate class/enum names within app/lib (excluding packages)'
    }

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

    if duplicates:
        print(f"Found {len(duplicates)} duplicate symbol definitions:")
        for name, info in duplicates.items():
            print(f"  {name}: {info['count']} definitions")
    else:
        print("No duplicate definitions found.")

if __name__ == '__main__':
    main()
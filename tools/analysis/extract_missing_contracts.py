#!/usr/bin/env python3
"""
Extract missing contracts from analyzer output and generate plans.
"""
import json
import re
from pathlib import Path
from collections import defaultdict

def parse_analyzer_errors(analyzer_file):
    """Parse analyzer errors to find missing symbols."""
    missing_symbols = []

    if not Path(analyzer_file).exists():
        return missing_symbols

    with open(analyzer_file, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            if '|' in line:
                parts = line.strip().split('|')
                if len(parts) >= 7:
                    severity = parts[0]
                    error_type = parts[1]
                    sub_type = parts[2]
                    file_path = parts[3]
                    message = '|'.join(parts[6:]) if len(parts) > 6 else ""

                    # Look for undefined symbols
                    if sub_type in ['UNDEFINED_IDENTIFIER', 'UNDEFINED_CLASS', 'UNDEFINED_FUNCTION']:
                        # Extract symbol name from message
                        symbol_match = re.search(r'Undefined name \'([^\']+)\'', message)
                        if symbol_match:
                            symbol = symbol_match.group(1)
                        else:
                            # Try other patterns
                            symbol_match = re.search(r'The function \'([^\']+)\' isn\'t defined', message)
                            if symbol_match:
                                symbol = symbol_match.group(1)
                            else:
                                symbol_match = re.search(r'Undefined class \'([^\']+)\'', message)
                                if symbol_match:
                                    symbol = symbol_match.group(1)

                        if symbol_match:
                            missing_symbols.append({
                                'symbol': symbol,
                                'error_type': sub_type,
                                'file': file_path,
                                'message': message,
                                'context': 'undefined_symbol'
                            })

                    # Extract URI issues
                    elif sub_type == 'URI_DOES_NOT_EXIST':
                        uri_match = re.search(r'Target of URI doesn\'t exist: \'([^\']+)\'', message)
                        if uri_match:
                            uri = uri_match.group(1)
                            missing_symbols.append({
                                'symbol': uri,
                                'error_type': sub_type,
                                'file': file_path,
                                'message': message,
                                'context': 'missing_uri'
                            })

    return missing_symbols

def categorize_by_feature(symbols):
    """Categorize missing symbols by feature area."""
    feature_patterns = {
        'payments': ['payment', 'stripe', 'card', 'transaction'],
        'mobility': ['location', 'geolocator', 'map', 'permission', 'background'],
        'notifications': ['notification', 'firebase', 'token', 'subscribe'],
        'auth': ['auth', 'login', 'session', 'user'],
        'device_security': ['device', 'security', 'biometric', 'jailbreak'],
        'telemetry': ['analytics', 'tracking', 'observability'],
        'files': ['file', 'upload', 'download'],
        'rbac': ['role', 'permission', 'access'],
        'config': ['config', 'settings'],
        'consent': ['consent', 'privacy', 'gdpr']
    }

    categorized = defaultdict(list)

    for symbol in symbols:
        symbol_name = symbol['symbol'].lower()
        matched = False

        for feature, patterns in feature_patterns.items():
            if any(pattern in symbol_name for pattern in patterns):
                categorized[feature].append(symbol)
                matched = True
                break

        if not matched:
            categorized['other'].append(symbol)

    return dict(categorized)

def generate_rewire_plan(symbols, canonical_map):
    """Generate import rewiring plan."""
    rewires = []

    if 'shim_exports' not in canonical_map:
        return rewires

    shim_exports = canonical_map['shim_exports']

    for symbol in symbols:
        if symbol['context'] == 'undefined_symbol':
            symbol_name = symbol['symbol']

            # Look for potential matches in shim exports
            for shim_name, exports in shim_exports.items():
                for export in exports:
                    if symbol_name in export['source_file'] or symbol_name in export['export_path']:
                        rewires.append({
                            'symbol': symbol_name,
                            'current_import': None,  # Would need more analysis
                            'target_import': export['package_import'],
                            'rationale': f'Symbol should be imported from {shim_name} shim',
                            'priority': 'high',
                            'file': symbol['file']
                        })
                        break

    return rewires

def generate_skeletons(missing_by_feature):
    """Generate skeleton contracts for missing symbols."""
    skeletons = []

    for feature, symbols in missing_by_feature.items():
        if feature == 'other':
            continue

        # Group symbols by type hints from context
        service_symbols = [s for s in symbols if 'service' in s['symbol'].lower()]
        contract_symbols = [s for s in symbols if 'contract' in s['symbol'].lower() or 'interface' in s['symbol'].lower()]

        if service_symbols or contract_symbols:
            skeleton = {
                'feature': feature,
                'package': f'{feature}_shims',
                'contracts': [],
                'services': [],
                'stubs_needed': True
            }

            for symbol in contract_symbols:
                skeleton['contracts'].append({
                    'name': symbol['symbol'],
                    'type': 'interface',
                    'minimal_definition': f'abstract class {symbol["symbol"]} {{\n  // TODO: Define contract methods\n}}'
                })

            for symbol in service_symbols:
                skeleton['services'].append({
                    'name': symbol['symbol'],
                    'type': 'service',
                    'minimal_definition': f'class {symbol["symbol"]} implements {symbol["symbol"].replace("Service", "Contract")} {{\n  // TODO: Implement service methods\n}}'
                })

            skeletons.append(skeleton)

    return skeletons

def main():
    import sys

    if len(sys.argv) < 4:
        print("Usage: python extract_missing_contracts.py --analyzer <analyzer_file> [--gen-rewire-plan] [--canonical <canonical_file>] [--out-map <map_file>] [--out-skel <skel_file>] [--out-rewire <rewire_file>]")
        sys.exit(1)

    analyzer_file = None
    canonical_file = None
    out_map = None
    out_skel = None
    out_rewire = None
    gen_rewire = False

    i = 1
    while i < len(sys.argv):
        if sys.argv[i] == '--analyzer' and i + 1 < len(sys.argv):
            analyzer_file = sys.argv[i + 1]
            i += 2
        elif sys.argv[i] == '--canonical' and i + 1 < len(sys.argv):
            canonical_file = sys.argv[i + 1]
            i += 2
        elif sys.argv[i] == '--out-map' and i + 1 < len(sys.argv):
            out_map = sys.argv[i + 1]
            i += 2
        elif sys.argv[i] == '--out-skel' and i + 1 < len(sys.argv):
            out_skel = sys.argv[i + 1]
            i += 2
        elif sys.argv[i] == '--out-rewire' and i + 1 < len(sys.argv):
            out_rewire = sys.argv[i + 1]
            i += 2
        elif sys.argv[i] == '--gen-rewire-plan':
            gen_rewire = True
            i += 1
        else:
            i += 1

    if not analyzer_file:
        print("Missing analyzer file")
        sys.exit(1)

    # Parse analyzer errors
    missing_symbols = parse_analyzer_errors(analyzer_file)
    categorized = categorize_by_feature(missing_symbols)

    # Generate outputs
    if out_map:
        result = {
            'total_missing_symbols': len(missing_symbols),
            'categorized_by_feature': categorized,
            'sample_missing': missing_symbols[:20]
        }
        with open(out_map, 'w', encoding='utf-8') as f:
            json.dump(result, f, indent=2, ensure_ascii=False)

    if out_skel:
        skeletons = generate_skeletons(categorized)
        with open(out_skel, 'w', encoding='utf-8') as f:
            json.dump(skeletons, f, indent=2, ensure_ascii=False)

    if gen_rewire and out_rewire and canonical_file and Path(canonical_file).exists():
        with open(canonical_file, 'r', encoding='utf-8') as f:
            canonical_map = json.load(f)

        rewires = generate_rewire_plan(missing_symbols, canonical_map)
        with open(out_rewire, 'w', encoding='utf-8') as f:
            json.dump({
                'total_rewires_needed': len(rewires),
                'rewire_plan': rewires,
                'priority_order': ['high', 'medium', 'low']
            }, f, indent=2, ensure_ascii=False)

    print(f"Extracted {len(missing_symbols)} missing symbols across {len(categorized)} feature categories.")

if __name__ == '__main__':
    main()
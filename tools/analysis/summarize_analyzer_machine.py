#!/usr/bin/env python3
"""
Summarize analyzer machine output into structured JSON report.
"""
import json
import sys
from collections import Counter, defaultdict
from pathlib import Path

def parse_analyzer_line(line):
    """Parse a single line from analyzer machine output."""
    try:
        parts = line.strip().split('|')
        if len(parts) < 4:
            return None

        severity = parts[0]
        error_type = parts[1]
        file_path = parts[2]
        line_num = parts[3]
        message = '|'.join(parts[4:]) if len(parts) > 4 else ""

        return {
            'severity': severity,
            'type': error_type,
            'file': file_path,
            'line': int(line_num) if line_num.isdigit() else 0,
            'message': message
        }
    except:
        return None

def main():
    if len(sys.argv) < 4:
        print("Usage: python summarize_analyzer_machine.py --in <input_file> --out <output_file>")
        sys.exit(1)

    input_file = None
    output_file = None

    i = 1
    while i < len(sys.argv):
        if sys.argv[i] == '--in' and i + 1 < len(sys.argv):
            input_file = sys.argv[i + 1]
            i += 2
        elif sys.argv[i] == '--out' and i + 1 < len(sys.argv):
            output_file = sys.argv[i + 1]
            i += 2
        else:
            i += 1

    if not input_file or not output_file:
        print("Missing input or output file")
        sys.exit(1)

    # Read analyzer output
    errors = []
    if Path(input_file).exists():
        with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                if line.strip():
                    parsed = parse_analyzer_line(line)
                    if parsed:
                        errors.append(parsed)

    # Analyze errors
    error_types = Counter(e['type'] for e in errors)
    severity_count = Counter(e['severity'] for e in errors)

    # Group by directory/feature
    dir_errors = defaultdict(list)
    for error in errors:
        file_path = error['file']
        if '/lib/' in file_path:
            parts = file_path.split('/lib/')
            if len(parts) > 1:
                dir_part = parts[1].split('/')[0] if '/' in parts[1] else 'root'
                dir_errors[dir_part].append(error)

    # Top 10 error types
    top_errors = [
        {'type': error_type, 'count': count, 'examples': []}
        for error_type, count in error_types.most_common(10)
    ]

    # Add examples for top errors
    for error_info in top_errors:
        examples = [e for e in errors if e['type'] == error_info['type']][:3]
        error_info['examples'] = [
            {
                'file': e['file'],
                'line': e['line'],
                'message': e['message'][:100] + '...' if len(e['message']) > 100 else e['message']
            }
            for e in examples
        ]

    # Directory distribution
    dir_summary = {}
    for dir_name, dir_errs in dir_errors.items():
        dir_summary[dir_name] = {
            'total_errors': len(dir_errs),
            'error_types': dict(Counter(e['type'] for e in dir_errs))
        }

    # Output JSON
    result = {
        'total_errors': len(errors),
        'severity_distribution': dict(severity_count),
        'top_10_errors': top_errors,
        'directory_distribution': dir_summary,
        'sample_errors': errors[:10]  # First 10 for reference
    }

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

    print(f"Analysis complete. Found {len(errors)} errors.")

if __name__ == '__main__':
    main()
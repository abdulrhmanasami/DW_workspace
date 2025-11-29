#!/usr/bin/env python3
"""
Extract build errors from Flutter build output and generate structured JSON report.
"""

import json
import re
from collections import defaultdict

def parse_build_errors(build_output):
    """Parse Flutter build output to extract structured error information."""

    errors = []
    current_error = None

    lines = build_output.split('\n')

    for line in lines:
        # Look for error lines that match the pattern: file:line:col: Error: message
        error_match = re.match(r'([^:]+):(\d+):(\d+):\s*Error:\s*(.+)', line)
        if error_match:
            if current_error:
                errors.append(current_error)

            file_path, line_num, col_num, message = error_match.groups()
            current_error = {
                'file': file_path,
                'line': int(line_num),
                'column': int(col_num),
                'message': message.strip(),
                'package': extract_package_from_path(file_path),
                'category': categorize_error(message)
            }
        elif current_error and line.strip():
            # Continuation of error message
            current_error['message'] += ' ' + line.strip()
        elif current_error and not line.strip():
            # End of error block
            errors.append(current_error)
            current_error = None

    if current_error:
        errors.append(current_error)

    return errors

def extract_package_from_path(file_path):
    """Extract package name from file path."""
    if file_path.startswith('lib/'):
        return 'app'
    elif file_path.startswith('packages/'):
        # Extract package name from packages/package_name/...
        parts = file_path.split('/')
        if len(parts) > 1:
            return parts[1]
    return 'unknown'

def categorize_error(message):
    """Categorize error by type."""
    if 'undefined' in message.lower() or 'not defined' in message.lower():
        return 'undefined_symbol'
    elif 'type' in message.lower() and 'not found' in message.lower():
        return 'missing_type'
    elif 'exported from both' in message.lower():
        return 'duplicate_export'
    elif 'can\'t be assigned' in message.lower():
        return 'type_mismatch'
    elif 'non-nullable' in message.lower():
        return 'null_safety'
    else:
        return 'other'

def generate_error_report(build_output):
    """Generate comprehensive error report."""

    errors = parse_build_errors(build_output)

    # Group by package
    by_package = defaultdict(list)
    for error in errors:
        by_package[error['package']].append(error)

    # Group by category
    by_category = defaultdict(list)
    for error in errors:
        by_category[error['category']].append(error)

    # Summary stats
    summary = {
        'total_errors': len(errors),
        'packages_affected': len(by_package),
        'categories': dict(by_category.keys()),
        'top_packages': sorted(by_package.keys(), key=lambda x: len(by_package[x]), reverse=True)[:5]
    }

    return {
        'summary': summary,
        'errors_by_package': dict(by_package),
        'errors_by_category': dict(by_category),
        'sample_errors': errors[:10]  # First 10 errors as samples
    }

if __name__ == "__main__":
    try:
        with open("B-central/reports/CENT_BUILD02_android_build.tail.txt", "r", encoding="utf-8") as f:
            build_output = f.read()

        report = generate_error_report(build_output)

        with open("B-central/reports/CENT_BUILD02_build_errors.json", "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)

        print(f"✅ Generated build error report: {report['summary']['total_errors']} errors found")

    except Exception as e:
        print(f"❌ Error processing build output: {e}")
        # Create minimal report
        minimal_report = {
            'summary': {'total_errors': 0, 'error': str(e)},
            'errors_by_package': {},
            'errors_by_category': {},
            'sample_errors': []
        }

        with open("B-central/reports/CENT_BUILD02_build_errors.json", "w", encoding="utf-8") as f:
            json.dump(minimal_report, f, indent=2, ensure_ascii=False)

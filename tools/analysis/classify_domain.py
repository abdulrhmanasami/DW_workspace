#!/usr/bin/env python3
"""
Classify analyzer errors by domain (commerce/mobility) based on ownership matrix.
"""
import json
import fnmatch
from pathlib import Path

def load_ownership_matrix(matrix_file):
    """Load ownership matrix from JSON file."""
    with open(matrix_file, 'r', encoding='utf-8') as f:
        return json.load(f)

def classify_file_domain(file_path, ownership_matrix):
    """Classify a file into a domain based on ownership matrix."""
    domains = ownership_matrix.get('domains', {})

    for domain_name, domain_config in domains.items():
        globs = domain_config.get('globs', [])
        for glob_pattern in globs:
            # Convert glob to pattern that matches from lib/ onwards
            if fnmatch.fnmatch(file_path, glob_pattern):
                return domain_name

    return ownership_matrix.get('fallbackDomain', 'uncategorized')

def main():
    # Load the temporary analyzer report
    temp_report_file = 'tools/reports/workspace_analyzer_truth_temp.json'
    matrix_file = 'tools/reports/ownership_matrix.json'
    output_file = 'tools/reports/workspace_analyzer_truth.json'

    # Check if temp report exists
    if not Path(temp_report_file).exists():
        print(f"Temp report not found: {temp_report_file}")
        # Create empty report
        report = {
            "total_errors": 0,
            "issues": [],
            "domain_summary": {
                "commerce": {"count": 0, "files": []},
                "mobility": {"count": 0, "files": []},
                "uncategorized": {"count": 0, "files": []}
            },
            "ownership_matrix_version": "v1.0"
        }
    else:
        with open(temp_report_file, 'r', encoding='utf-8') as f:
            temp_data = json.load(f)

        # Load ownership matrix
        if Path(matrix_file).exists():
            ownership_matrix = load_ownership_matrix(matrix_file)
        else:
            ownership_matrix = {"domains": {}, "fallbackDomain": "uncategorized"}

        # Classify all errors
        issues = []
        domain_files = {
            "commerce": set(),
            "mobility": set(),
            "uncategorized": set()
        }

        for error in temp_data.get('sample_errors', []):
            domain = classify_file_domain(error['file'], ownership_matrix)
            issue = {
                "file": error['file'],
                "line": error['line'],
                "code": error['type'],
                "message": error['message'],
                "domain": domain,
                "severity": error['severity']
            }
            issues.append(issue)
            domain_files[domain].add(error['file'])

        # Create domain summary
        domain_summary = {}
        for domain, files in domain_files.items():
            domain_summary[domain] = {
                "count": len([i for i in issues if i['domain'] == domain]),
                "files": sorted(list(files))
            }

        report = {
            "total_errors": temp_data.get('total_errors', 0),
            "issues": issues,
            "domain_summary": domain_summary,
            "ownership_matrix_version": "v1.0"
        }

    # Write the final report
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)

    print(f"Domain classification complete. Created {output_file}")

if __name__ == '__main__':
    main()

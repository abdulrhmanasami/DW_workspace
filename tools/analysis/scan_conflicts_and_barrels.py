#!/usr/bin/env python3
"""
Scan Conflicts and Barrels Script for Delivery Ways Project
Scans for import conflicts and validates barrel exports
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Set, Any

def find_dart_files(base_path: str) -> List[str]:
    """Find all Dart files in the project"""
    dart_files = []
    for root, dirs, files in os.walk(base_path):
        # Skip certain directories
        dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ['.dart_tool', 'build']]
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    return dart_files

def extract_exports(content: str) -> List[str]:
    """Extract export statements from a file"""
    export_pattern = r"export\s+['\"]([^'\"]+)['\"]"
    return re.findall(export_pattern, content)

def extract_imports(content: str) -> List[str]:
    """Extract import statements from a file"""
    import_pattern = r"import\s+['\"]([^'\"]+)['\"]"
    return re.findall(import_pattern, content)

def find_barrel_files(base_path: str) -> List[str]:
    """Find barrel files (files that only export other files)"""
    dart_files = find_dart_files(base_path)
    barrel_files = []

    for file_path in dart_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Check if file only contains exports and comments
            lines = content.split('\n')
            has_code = False

            for line in lines:
                line = line.strip()
                if line.startswith('//') or line.startswith('///') or not line:
                    continue
                if not (line.startswith('export') or line.startswith('library') or line.startswith('part')):
                    has_code = True
                    break

            if not has_code and extract_exports(content):
                barrel_files.append(file_path)

        except Exception as e:
            print(f"Error reading {file_path}: {e}")

    return barrel_files

def validate_barrels(base_path: str) -> Dict[str, Any]:
    """Validate barrel file exports"""
    issues = []

    barrel_files = find_barrel_files(base_path)

    for barrel_file in barrel_files:
        try:
            with open(barrel_file, 'r', encoding='utf-8') as f:
                content = f.read()

            exports = extract_exports(content)

            # Check if exported files exist
            for export in exports:
                if export.startswith('package:'):
                    # Package export - can't validate easily
                    continue

                # Convert to file path
                if export.startswith('./'):
                    export_path = os.path.join(os.path.dirname(barrel_file), export[2:])
                elif export.startswith('../'):
                    export_path = os.path.join(os.path.dirname(barrel_file), export)
                else:
                    export_path = os.path.join(os.path.dirname(barrel_file), export)

                # Add .dart extension if not present
                if not export_path.endswith('.dart'):
                    export_path += '.dart'

                if not os.path.exists(export_path):
                    issues.append(f"Barrel {barrel_file} exports non-existent file: {export}")

        except Exception as e:
            issues.append(f"Error validating barrel {barrel_file}: {e}")

    return {
        "barrel_files": barrel_files,
        "total_barrels": len(barrel_files),
        "issues": issues,
        "issues_count": len(issues)
    }

def scan_import_conflicts(base_path: str) -> Dict[str, Any]:
    """Scan for potential import conflicts"""
    conflicts = []
    import_usage = {}

    dart_files = find_dart_files(base_path)

    for file_path in dart_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            imports = extract_imports(content)

            for import_stmt in imports:
                if import_stmt not in import_usage:
                    import_usage[import_stmt] = []
                import_usage[import_stmt].append(file_path)

        except Exception as e:
            conflicts.append(f"Error reading {file_path}: {e}")

    # Find potential conflicts (same import used with different prefixes)
    conflict_patterns = {}
    for import_stmt, files in import_usage.items():
        if len(files) > 1:
            # Check for different import prefixes
            prefixes = set()
            for file in files:
                with open(file, 'r', encoding='utf-8') as f:
                    file_content = f.read()
                    # Find the as clause for this import
                    import_lines = [line for line in file_content.split('\n') if f"import '{import_stmt}'" in line]
                    for line in import_lines:
                        as_match = re.search(r"import\s+['\"][^'\"]+['\"]\s+as\s+(\w+)", line)
                        if as_match:
                            prefixes.add(as_match.group(1))

            if len(prefixes) > 1:
                conflicts.append(f"Import '{import_stmt}' used with different prefixes: {prefixes} in files: {files}")

    return {
        "total_imports": len(import_usage),
        "unique_imports": len(set(import_usage.keys())),
        "conflicts": conflicts,
        "conflicts_count": len(conflicts)
    }

def main():
    """Main function"""
    import argparse
    parser = argparse.ArgumentParser(description='Scan conflicts and barrels for Delivery Ways project')
    parser.add_argument('--path', default='.', help='Base path to scan')
    parser.add_argument('--out', required=True, help='Output file path')

    args = parser.parse_args()

    base_path = args.path if os.path.isabs(args.path) else os.path.join("/Users/abdulrahman/Documents/GitHub/Delivery Ways/workspace_pruned/app", args.path)

    print("🔍 Scanning barrels and conflicts...")

    barrels_result = validate_barrels(base_path)
    conflicts_result = scan_import_conflicts(base_path)

    result = {
        "scan_timestamp": "2025-11-04T02:15:00Z",
        "base_path": base_path,
        "barrels": barrels_result,
        "conflicts": conflicts_result,
        "overall_status": "PASS" if barrels_result["issues_count"] == 0 and conflicts_result["conflicts_count"] == 0 else "ISSUES_FOUND"
    }

    with open(args.out, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

    print(f"✅ Scan complete. Results saved to: {args.out}")
    print(f"   Barrels: {barrels_result['total_barrels']} files, {barrels_result['issues_count']} issues")
    print(f"   Conflicts: {conflicts_result['conflicts_count']} issues")

if __name__ == "__main__":
    main()

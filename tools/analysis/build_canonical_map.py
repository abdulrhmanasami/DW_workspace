#!/usr/bin/env python3
"""
Canonical Map Builder for Delivery Ways Project
Generates canonical map of files and their SHAs
"""

import os
import json
import subprocess
from pathlib import Path
from typing import Dict, Any

def get_git_sha(file_path: str) -> str:
    """Get SHA for a file"""
    try:
        result = subprocess.run(
            ['git', 'hash-object', file_path],
            capture_output=True, text=True, check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return "unknown"

def build_canonical_map(base_path: str, include_features: bool = False) -> Dict[str, Any]:
    """Build canonical map of all files"""
    canonical_map = {
        "metadata": {
            "base_path": base_path,
            "generated_at": subprocess.run(['date', '+%Y-%m-%d %H:%M:%S'], capture_output=True, text=True).stdout.strip(),
            "head_commit": subprocess.run(['git', 'rev-parse', 'HEAD'], capture_output=True, text=True).stdout.strip(),
            "branch": subprocess.run(['git', 'branch', '--show-current'], capture_output=True, text=True).stdout.strip()
        },
        "files": {}
    }

    # Find all relevant files
    file_extensions = ['.dart', '.yaml', '.json', '.md', '.sh', '.py', '.txt']
    for root, dirs, files in os.walk(base_path):
        # Skip certain directories
        dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ['.dart_tool', 'build', 'ios/Pods']]

        for file in files:
            file_path = os.path.join(root, file)
            if any(file.endswith(ext) for ext in file_extensions):
                relative_path = os.path.relpath(file_path, base_path)
                canonical_map["files"][relative_path] = {
                    "sha": get_git_sha(file_path),
                    "size": os.path.getsize(file_path),
                    "modified": os.path.getmtime(file_path)
                }

    if include_features:
        # Add features analysis (simplified)
        canonical_map["features"] = {
            "screens_count": len([f for f in canonical_map["files"].keys() if "screens/" in f and f.endswith('.dart')]),
            "services_count": len([f for f in canonical_map["files"].keys() if "services/" in f and f.endswith('.dart')]),
            "widgets_count": len([f for f in canonical_map["files"].keys() if "widgets/" in f and f.endswith('.dart')]),
            "packages_count": len([d for d in os.listdir(os.path.join(base_path, "packages")) if os.path.isdir(os.path.join(base_path, "packages", d))]) if os.path.exists(os.path.join(base_path, "packages")) else 0
        }

    return canonical_map

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Build canonical map for Delivery Ways project')
    parser.add_argument('--out', required=True, help='Output file path')
    parser.add_argument('--features', action='store_true', help='Include features analysis')

    args = parser.parse_args()

    base_path = "/Users/abdulrahman/Documents/GitHub/Delivery Ways/workspace_pruned/app"
    canonical_map = build_canonical_map(base_path, args.features)

    with open(args.out, 'w', encoding='utf-8') as f:
        json.dump(canonical_map, f, indent=2, ensure_ascii=False)

    print(f"Canonical map generated: {args.out}")

if __name__ == "__main__":
    main()

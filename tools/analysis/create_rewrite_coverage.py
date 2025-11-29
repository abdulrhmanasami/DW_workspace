#!/usr/bin/env python3
"""
Create rewrite coverage report comparing actual SDK usage with rewrite plan.
"""
import json
from pathlib import Path

def load_rewrite_plan(plan_file):
    """Load rewrite imports plan."""
    if not Path(plan_file).exists():
        return []

    with open(plan_file, 'r', encoding='utf-8') as f:
        return json.load(f)

def load_raw_sdk_refs(refs_file):
    """Load raw SDK references found in codebase."""
    refs = []
    if Path(refs_file).exists():
        with open(refs_file, 'r', encoding='utf-8') as f:
            for line in f:
                if line.strip():
                    refs.append(line.strip())
    return refs

def analyze_coverage(rewrite_plan, raw_refs):
    """Analyze coverage of rewrite plan vs actual usage."""
    # Extract package patterns from rewrite plan
    plan_patterns = set()
    for rule in rewrite_plan:
        if rule.get('from', '').startswith('package:'):
            # Extract package name (remove package: prefix and trailing /)
            package = rule['from'].replace('package:', '').rstrip('/')
            plan_patterns.add(package)

    # Extract packages from raw refs
    found_packages = set()
    for ref in raw_refs:
        # refs are in format: file:line:package:import_statement
        if 'package:' in ref:
            parts = ref.split('package:')
            if len(parts) > 1:
                package_part = parts[1].split('/')[0]
                found_packages.add(package_part)

    # Analyze coverage
    covered = []
    missing_rules = []
    should_be_banned = []

    for found_pkg in found_packages:
        covered_in_plan = False
        for plan_pkg in plan_patterns:
            if found_pkg.startswith(plan_pkg.replace('*', '')):
                covered_in_plan = True
                break

        if covered_in_plan:
            covered.append(found_pkg)
        else:
            # Check if it should be banned
            banned_patterns = [
                "geolocator", "location", "google_maps_flutter", "mapbox_gl",
                "here_sdk", "stripe_", "flutter_stripe", "payments_stripe_impl", "payments_adapter_stripe"
            ]
            is_banned = any(found_pkg.startswith(bp.replace('_', '')) or bp.replace('_', '') in found_pkg for bp in banned_patterns)
            if is_banned:
                should_be_banned.append(found_pkg)
            else:
                missing_rules.append(found_pkg)

    return {
        "covered": covered,
        "missing_rule": missing_rules,
        "should_be_banned": should_be_banned,
        "total_found_packages": len(found_packages),
        "total_plan_rules": len(plan_patterns)
    }

def main():
    plan_file = 'tools/reports/rewrite_imports_plan.json'
    refs_file = 'tools/reports/raw_sdk_refs.txt'
    output_file = 'tools/reports/rewrite_coverage_report.json'

    # Load data
    rewrite_plan = load_rewrite_plan(plan_file)
    raw_refs = load_raw_sdk_refs(refs_file)

    # Analyze coverage
    coverage = analyze_coverage(rewrite_plan, raw_refs)

    # Add summary
    coverage["summary"] = {
        "total_sdk_packages_found": coverage["total_found_packages"],
        "covered_by_plan": len(coverage["covered"]),
        "need_new_rules": len(coverage["missing_rule"]),
        "violating_bans": len(coverage["should_be_banned"]),
        "coverage_percentage": (len(coverage["covered"]) / max(1, coverage["total_found_packages"])) * 100 if coverage["total_found_packages"] > 0 else 100.0,
        "zero_gaps_critical": len(coverage["should_be_banned"]) == 0 and len(coverage["missing_rule"]) == 0
    }

    # Write report
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(coverage, f, indent=2, ensure_ascii=False)

    print(f"Rewrite coverage report created: {output_file}")
    print(f"Summary: {coverage['summary']}")

if __name__ == '__main__':
    main()

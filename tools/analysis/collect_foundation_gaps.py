#!/usr/bin/env python3
"""
Collect foundation wiring gaps and create implementation plan.
"""
import json
from pathlib import Path
from collections import defaultdict

def scan_app_structure(app_root):
    """Scan app structure for wiring needs."""
    wiring_gaps = {
        'missing_service_registrations': [],
        'missing_contract_implementations': [],
        'missing_shim_initializations': [],
        'circular_dependency_risks': []
    }

    # Scan for service locator patterns
    service_locator_patterns = ['GetIt', 'Provider', 'Riverpod', 'BlocProvider']

    for dart_file in Path(app_root).rglob('*.dart'):
        try:
            with open(dart_file, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()

            for pattern in service_locator_patterns:
                if pattern in content:
                    wiring_gaps['missing_service_registrations'].append({
                        'file': str(dart_file),
                        'pattern': pattern,
                        'needs_registration': True
                    })

        except Exception as e:
            print(f"Error reading {dart_file}: {e}")

    return wiring_gaps

def analyze_shim_dependencies(root_dir):
    """Analyze shim dependencies and wiring needs."""
    shim_packages = []
    packages_dir = Path(root_dir) / 'packages'

    if packages_dir.exists():
        for package_dir in packages_dir.iterdir():
            if package_dir.is_dir() and package_dir.name.endswith('_shims'):
                shim_packages.append(package_dir.name)

    wiring_plan = {
        'shim_packages': shim_packages,
        'wiring_steps': [
            {
                'step': 'Initialize core shims',
                'packages': ['core_shims', 'foundation_shims'],
                'priority': 'high'
            },
            {
                'step': 'Setup device security',
                'packages': ['device_security_shims'],
                'priority': 'high'
            },
            {
                'step': 'Configure mobility services',
                'packages': ['mobility_shims', 'maps_shims'],
                'priority': 'medium'
            },
            {
                'step': 'Setup payment systems',
                'packages': ['payments_shims'],
                'priority': 'medium'
            },
            {
                'step': 'Initialize notifications',
                'packages': ['notifications_shims'],
                'priority': 'low'
            }
        ],
        'implementation_notes': [
            'Ensure shims are initialized before app startup',
            'Use dependency injection for service registration',
            'Avoid circular dependencies between shims',
            'Test shim integrations in isolation'
        ]
    }

    return wiring_plan

def main():
    import sys

    if len(sys.argv) < 4:
        print("Usage: python collect_foundation_gaps.py --app-root <app_root> --out <output_file>")
        sys.exit(1)

    app_root = None
    output_file = None

    i = 1
    while i < len(sys.argv):
        if sys.argv[i] == '--app-root' and i + 1 < len(sys.argv):
            app_root = sys.argv[i + 1]
            i += 2
        elif sys.argv[i] == '--out' and i + 1 < len(sys.argv):
            output_file = sys.argv[i + 1]
            i += 2
        else:
            i += 1

    if not app_root or not output_file:
        print("Missing app root or output file")
        sys.exit(1)

    root_dir = Path(app_root).parent

    # Collect wiring gaps
    wiring_gaps = scan_app_structure(app_root)
    wiring_plan = analyze_shim_dependencies(root_dir)

    result = {
        'foundation_wiring_plan': wiring_plan,
        'identified_gaps': wiring_gaps,
        'summary': {
            'total_shim_packages': len(wiring_plan['shim_packages']),
            'total_wiring_steps': len(wiring_plan['wiring_steps']),
            'total_gaps': sum(len(gaps) for gaps in wiring_gaps.values())
        }
    }

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

    print(f"Foundation wiring plan created with {len(wiring_plan['shim_packages'])} shim packages and {len(wiring_plan['wiring_steps'])} wiring steps.")

if __name__ == '__main__':
    main()
#!/usr/bin/env python3

import json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
APP = ROOT / "app" / "lib"

# Canonical import mappings
CANONICAL_MAP = {
    # Payments
    r"package:payments/src/.*": "package:payments/payments.dart",
    r"package:payments/contracts\.dart": "package:payments/payments.dart",
    r"package:payments/models\.dart": "package:payments/payments.dart",
    r"package:payments/providers\.dart": "package:payments/payments.dart",

    # Mobility
    r"package:mobility_shims/src/.*": "package:mobility_shims/mobility.dart",
    r"package:mobility_shims/location/models\.dart": "package:mobility_shims/mobility.dart",
    r"package:mobility_shims/location/location_source\.dart": "package:mobility_shims/mobility.dart",
    r"package:mobility_shims/providers/location_providers\.dart": "package:mobility_shims/mobility.dart",

    # Maps
    r"package:maps_shims/src/.*": "package:maps_shims/maps.dart",
    r"package:maps_shims/src/models\.dart": "package:maps_shims/maps.dart",
    r"package:maps_shims/src/map_controller\.dart": "package:maps_shims/maps.dart",
    r"package:maps_shims/src/map_providers\.dart": "package:maps_shims/maps.dart",
    r"package:maps_adapter_google/.*": "package:maps_shims/maps.dart",

    # Design System
    r"package:design_system_components/.*": "package:design_system_shims/design_system_shims.dart",
}

def main():
    rewrite_plan = {
        "metadata": {
            "description": "Canonical imports rewrite plan for app/lib/**",
            "generated_at": "2025-11-12",
            "version": "1.0"
        },
        "rewrites": {}
    }

    for dart_file in APP.rglob("*.dart"):
        relative_path = dart_file.relative_to(ROOT)
        content = dart_file.read_text(encoding="utf-8", errors="ignore")

        file_rewrites = {}
        for line_num, line in enumerate(content.splitlines(), 1):
            # Find import statements
            import_match = re.match(r'^\s*import\s+["\']([^"\']+)["\']\s*;', line)
            if import_match:
                import_uri = import_match.group(1)

                # Check if this import needs rewriting
                for pattern, canonical in CANONICAL_MAP.items():
                    if re.match(pattern, import_uri):
                        if import_uri != canonical:
                            file_rewrites[str(line_num)] = {
                                "from": import_uri,
                                "to": canonical,
                                "line": line.strip()
                            }
                        break

        if file_rewrites:
            rewrite_plan["rewrites"][str(relative_path)] = file_rewrites

    # Save the plan
    output_file = ROOT / "tools" / "reports" / "rewrite_imports_plan.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(rewrite_plan, f, indent=2, ensure_ascii=False)

    print(f"✅ Rewrite imports plan generated: {output_file}")
    print(f"📊 Files requiring rewrites: {len(rewrite_plan['rewrites'])}")

if __name__ == "__main__":
    main()

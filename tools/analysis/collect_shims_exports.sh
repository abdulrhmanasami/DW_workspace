#!/bin/bash
set -euo pipefail

echo "🔍 Collecting exports from all *_shims packages"

# Define shims packages
SHIMS_PACKAGES=(
    "packages/foundation_shims/lib/foundation_shims.dart"
    "packages/design_system_shims/lib/design_system_shims.dart"
    "packages/accounts_shims/lib/accounts.dart"
    "packages/mobility_shims/lib/mobility_shims.dart"
    "packages/maps_shims/lib/maps_shims.dart"
    "packages/payments_shims/lib/payments_shims.dart"
)

echo "=== SHIMS PACKAGES EXPORTS MAP ==="
echo ""

for package in "${SHIMS_PACKAGES[@]}"; do
    if [[ -f "$package" ]]; then
        echo "📦 $(basename "$package"):"
        echo "   Path: $package"
        echo "   Exports:"
        grep -E "^export " "$package" | sed 's/^/     /' || echo "     (no exports found)"
        echo ""
    else
        echo "📦 $(basename "$package"): NOT FOUND"
        echo ""
    fi
done

echo "=== SUMMARY ==="
echo "Total shims packages checked: ${#SHIMS_PACKAGES[@]}"
echo "Found packages: $(find packages -name "*_shims.dart" -o -name "accounts.dart" | wc -l)"

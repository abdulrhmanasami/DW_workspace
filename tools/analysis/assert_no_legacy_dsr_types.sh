#!/bin/bash
set -euo pipefail

echo "🔍 Checking for legacy/misplaced DSR types in app/lib/**"

# Check for DSR types that should only be in accounts_shims
LEGACY_DSR_TYPES=(
    "DsrStatus"
    "DsrOperation"
    "DsrController"
    "DsrFactory"
    "DataSubjectRightsService"
)

echo "Searching for misplaced DSR types..."
echo ""

found_legacy=false

for type in "${LEGACY_DSR_TYPES[@]}"; do
    # Search in app/lib but exclude accounts_shims
    results=$(find lib -name "*.dart" -not -path "*/accounts_shims/*" -exec grep -l "$type" {} \; 2>/dev/null || true)

    if [[ -n "$results" ]]; then
        echo "❌ LEGACY DSR TYPE FOUND: $type"
        echo "   Should only be defined in accounts_shims"
        echo "   Found in:"
        echo "$results" | sed 's/^/     /'
        echo ""
        found_legacy=true
    fi
done

# Check for direct imports from accounts_shims/src/
echo "Checking for direct imports from accounts_shims/src/**..."
direct_imports=$(grep -r "accounts_shims/src/" lib/ --include="*.dart" | grep -v "accounts_shims/lib/accounts.dart" || true)

if [[ -n "$direct_imports" ]]; then
    echo "❌ DIRECT ACCOUNTS IMPORTS FOUND:"
    echo "   Must import from 'package:accounts_shims/accounts.dart' only"
    echo "$direct_imports" | sed 's/^/     /'
    echo ""
    found_legacy=true
fi

if [[ "$found_legacy" == "true" ]]; then
    echo "❌ LEGACY DSR TYPES OR DIRECT IMPORTS DETECTED"
    echo "Fix required before proceeding."
    exit 1
else
    echo "✅ NO LEGACY DSR TYPES FOUND"
    echo "All DSR types properly centralized in accounts_shims."
fi

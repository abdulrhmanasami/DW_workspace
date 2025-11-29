#!/bin/bash
set -euo pipefail

echo "🔍 Analyzing export collisions across shims packages"

# Define shims packages to check
SHIMS_PACKAGES=(
    "packages/foundation_shims/lib/foundation_shims.dart"
    "packages/design_system_shims/lib/design_system_shims.dart"
    "packages/accounts_shims/lib/accounts.dart"
)

echo "=== EXPORT COLLISIONS ANALYSIS ==="
echo ""

# Check for known collisions based on error patterns from previous build
echo "Checking for known collision patterns from build errors..."

# Check if foundation_shims exports feature flags
if grep -q "providers/feature_flags.dart" packages/foundation_shims/lib/foundation_shims.dart; then
    echo "✅ foundation_shims exports feature_flags.dart"
else
    echo "❌ foundation_shims does NOT export feature_flags.dart"
fi

# Check if design_system_shims exports anything that might conflict
if grep -q "feature_flags\|navigation\|remote_config" packages/design_system_shims/lib/design_system_shims.dart; then
    echo "❌ design_system_shims exports conflicting symbols (feature_flags/navigation/remote_config)"
else
    echo "✅ design_system_shims does not export conflicting symbols"
fi

# Check accounts_shims for DSR types
if grep -q "dsr_contracts.dart" packages/accounts_shims/lib/accounts.dart; then
    echo "✅ accounts_shims exports dsr_contracts.dart"
else
    echo "❌ accounts_shims does NOT export dsr_contracts.dart"
fi

echo ""
echo "=== COLLISION STATUS ==="

# Based on previous build errors, we know there are collisions
# Look for "exported from both" errors in recent reports
if [ -f "B-central/reports/CENT_BUILD02_build_errors.json" ]; then
    if grep -q "exported from both" B-central/reports/CENT_BUILD02_build_errors.json; then
        echo "❌ COLLISIONS DETECTED: 'exported from both' errors found in build report"
        echo "   Common collisions:"
        echo "   - trackingEnabledProvider (foundation_shims vs design_system_shims)"
        echo "   - DsrStatus (accounts_shims contracts vs models)"
    else
        echo "✅ NO COLLISIONS DETECTED in build errors"
    fi
else
    echo "⚠️  Build error report not found, cannot check for collisions"
fi

echo ""
echo "=== RESOLUTION REQUIRED ==="
echo "Apply these fixes:"
echo "1. Remove feature flag exports from design_system_shims"
echo "2. Ensure DSR types only from accounts_shims"
echo "3. Add AppThemeData to design_system_shims"
echo "4. Remove any duplicate providers"
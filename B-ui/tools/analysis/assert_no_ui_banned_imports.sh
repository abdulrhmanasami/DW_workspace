#!/bin/bash

echo "🔍 Checking for banned imports in UI scope (lib/ui/** and specified screens)"

# Check for package:*_shims/src/** imports
echo "Checking for package:*_shims/src/** imports..."
if grep -r "package:.*_shims/src/" lib/ui/** lib/screens/legal/** lib/screens/settings/dsr_export_screen.dart lib/screens/settings/dsr_erasure_screen.dart --include="*.dart" > /dev/null 2>&1; then
    echo "❌ Found banned imports: package:*_shims/src/**"
    exit 1
fi

# Check for direct SDK imports (only showLicensePage allowed in licenses_browser_screen.dart)
echo "Checking for direct SDK imports..."
WHITELIST_FILE="lib/screens/legal/licenses_browser_screen.dart"
if grep -r "package:flutter/material.dart" lib/ui/** lib/screens/legal/** lib/screens/settings/dsr_export_screen.dart lib/screens/settings/dsr_erasure_screen.dart --include="*.dart" | grep -v "export 'package:flutter/material.dart'" | while read -r line; do
    # Check if the file is in whitelist and contains showLicensePage
    file=$(echo "$line" | cut -d: -f1)
    if [ "$file" != "$WHITELIST_FILE" ] || ! echo "$line" | grep -q "show showLicensePage;"; then
        echo "❌ Found banned direct SDK import in $file: $line"
        echo "Only '$WHITELIST_FILE' is allowed to import 'package:flutter/material.dart' with 'show showLicensePage;'"
        exit 1
    fi
done; then
    : # Continue if no issues
else
    echo "✅ Direct SDK imports check passed"
fi

# Check for direct implementation package imports
echo "Checking for direct implementation package imports..."
if grep -r "package:design_system_components/" lib/ui/** lib/screens/legal/** lib/screens/settings/dsr_export_screen.dart lib/screens/settings/dsr_erasure_screen.dart --include="*.dart" > /dev/null 2>&1; then
    echo "❌ Found banned imports: package:design_system_components/"
    exit 1
fi

echo "✅ No banned imports found in UI scope"

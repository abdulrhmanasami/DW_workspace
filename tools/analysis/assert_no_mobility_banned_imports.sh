#!/usr/bin/env bash

set -euo pipefail

# Script to check for banned imports in mobility scope
# Requires: ripgrep (rg)

echo "Checking for banned mobility imports in app/lib/**..."

# Check for mobility src imports (must use barrel import only)
if rg -n "package:mobility_shims/src/" app/lib --type dart >/dev/null 2>&1; then
    echo "❌ Found mobility src imports in app/lib/** (use package:mobility_shims/mobility.dart only):"
    rg -n "package:mobility_shims/src/" app/lib --type dart
    exit 1
else
    echo "✅ No mobility src imports in app/lib/**"
fi

# Check for direct location SDK imports
if rg -n "package:(geolocator|location|workmanager)/" app/lib --type dart >/dev/null 2>&1; then
    echo "❌ Found direct location/background SDK imports in app/lib/**:"
    rg -n "package:(geolocator|location|workmanager)/" app/lib --type dart
    exit 1
else
    echo "✅ No direct location/background SDK imports in app/lib/**"
fi

# Check for direct dart:io imports (networking/file operations)
if rg -n "dart:io" app/lib --type dart >/dev/null 2>&1; then
    echo "❌ Found direct dart:io imports in app/lib/**:"
    rg -n "dart:io" app/lib --type dart
    exit 1
else
    echo "✅ No direct dart:io imports in app/lib/**"
fi

echo "✅ All mobility import checks passed!"

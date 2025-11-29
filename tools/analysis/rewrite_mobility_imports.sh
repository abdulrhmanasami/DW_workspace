#!/usr/bin/env bash

set -euo pipefail

# Script to rewrite mobility imports and names for compatibility
# Requires: ripgrep (rg), GNU sed (gsed on macOS)

echo "Starting mobility imports rewrite..."

# Function to replace import paths
replace_path() {
    local from="$1"
    local to="$2"

    echo "Replacing import path: $from -> $to"

    # Find files containing the import
    rg -l "$from" --glob '!**/.dart_tool/**' --glob '!**/build/**' --type dart | while read -r file; do
        echo "  Updating: $file"
        sed -i '' "s|$from|$to|g" "$file"
    done
}

# Function to replace type/class names (whole words only)
replace_name() {
    local from="$1"
    local to="$2"

    echo "Replacing name: $from -> $to"

    # Find files containing the name as a whole word
    rg -l "\\b$from\\b" --glob '!**/.dart_tool/**' --glob '!**/build/**' --type dart | while read -r file; do
        echo "  Updating: $file"
        sed -i '' "s/\\b$from\\b/$to/g" "$file"
    done
}

# Common mobility import path replacements
replace_path 'package:mobility_shims/location_point.dart' 'package:mobility_shims/mobility.dart'
replace_path 'package:mobility_shims/location/models.dart' 'package:mobility_shims/mobility.dart'
replace_path 'package:mobility_shims/location/location_source.dart' 'package:mobility_shims/mobility.dart'
replace_path 'package:mobility_shims/providers/location_providers.dart' 'package:mobility_shims/mobility.dart'
replace_path 'package:mobility_shims/src/location_contracts.dart' 'package:mobility_shims/mobility.dart'
replace_path 'package:mobility_shims/src/background_contracts.dart' 'package:mobility_shims/mobility.dart'

# Type name compatibility (LocationPoint remains as alias)
# replace_name 'LocationPermissionStatus' 'LocationPermission'  # Keep as alias

echo "Mobility imports rewrite completed!"

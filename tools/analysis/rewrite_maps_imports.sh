#!/usr/bin/env bash
set -euo pipefail

# Maps imports rewrite script for U-01
# Converts old imports to unified maps.dart barrel

echo "🔄 Rewriting maps imports to unified barrel..."

# Function to replace import paths
replace_path() {
  local from="$1"
  local to="$2"

  # Find files containing the old import
  find . -name "*.dart" -type f \
    -not -path "./.dart_tool/*" \
    -not -path "./build/*" \
    -not -path "./packages/maps_adapter_google/*" \
    -exec grep -l "$from" {} \;

  # Replace the imports in those files
  if [ -n "$(find . -name "*.dart" -type f \
    -not -path "./.dart_tool/*" \
    -not -path "./build/*" \
    -not -path "./packages/maps_adapter_google/*" \
    -exec grep -l "$from" {} \;)" ]; then

    find . -name "*.dart" -type f \
      -not -path "./.dart_tool/*" \
      -not -path "./build/*" \
      -not -path "./packages/maps_adapter_google/*" \
      -exec grep -l "$from" {} \; \
      | xargs sed -i '' "s|$from|$to|g"
  fi
}

# Function to replace type names
replace_name() {
  local from="$1"
  local to="$2"

  # Find files containing the old type name
  find . -name "*.dart" -type f \
    -not -path "./.dart_tool/*" \
    -not -path "./build/*" \
    -not -path "./packages/maps_adapter_google/*" \
    -exec grep -l "\\b$from\\b" {} \;

  # Replace the type names in those files
  if [ -n "$(find . -name "*.dart" -type f \
    -not -path "./.dart_tool/*" \
    -not -path "./build/*" \
    -not -path "./packages/maps_adapter_google/*" \
    -exec grep -l "\\b$from\\b" {} \;)" ]; then

    find . -name "*.dart" -type f \
      -not -path "./.dart_tool/*" \
      -not -path "./build/*" \
      -not -path "./packages/maps_adapter_google/*" \
      -exec grep -l "\\b$from\\b" {} \; \
      | xargs sed -i '' "s|\\b$from\\b|$to|g"
  fi
}

# Import path replacements
echo "📦 Converting import paths to unified barrel..."
replace_path 'package:maps_shims/models.dart' 'package:maps_shims/maps.dart'
replace_path 'package:maps_shims/maps_shims.dart' 'package:maps_shims/maps.dart'
replace_path 'package:maps_shims/controller.dart' 'package:maps_shims/maps.dart'
replace_path 'package:maps_shims/providers.dart' 'package:maps_shims/maps.dart'
replace_path 'package:maps_shims/src/models.dart' 'package:maps_shims/maps.dart'
replace_path 'package:maps_shims/src/controller.dart' 'package:maps_shims/maps.dart'
replace_path 'package:maps_shims/src/providers.dart' 'package:maps_shims/maps.dart'

# Type name replacements (for backward compatibility)
echo "🏷️  Converting legacy type names..."
replace_name 'GoogleLatLng' 'LatLng'
replace_name 'MapLatLng' 'LatLng'
replace_name 'MapControllerInterface' 'MapController'

echo "✅ Maps imports rewrite completed!"
echo "📋 Files affected:"
find . -name "*.dart" -type f \
  -not -path "./.dart_tool/*" \
  -not -path "./build/*" \
  -exec grep -l "package:maps_shims" {} \; | wc -l | xargs echo "   - Files with maps_shims imports:"

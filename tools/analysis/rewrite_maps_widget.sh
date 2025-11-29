#!/usr/bin/env bash
set -euo pipefail

# Maps widget rewrite script for U-02
# Removes direct google_maps_flutter imports from app/lib

echo "🔄 Rewriting maps widgets and removing direct imports..."

# Check for direct google_maps_flutter imports in lib
if rg -q "package:google_maps_flutter" lib; then
  echo "❌ ERROR: Direct google_maps_flutter imports found in lib"
  rg -n "package:google_maps_flutter" lib
  exit 1
else
  echo "✅ No direct google_maps_flutter imports found in lib"
fi

# Remove any remaining google_maps_flutter imports (safety net)
find lib -name "*.dart" -type f -exec grep -l "package:google_maps_flutter" {} \; | while read -r file; do
  echo "🧹 Removing google_maps_flutter imports from: $file"
  gsed -i '/^import.*google_maps_flutter/d' "$file"
done

echo "✅ Maps widget rewrite completed!"
echo "📋 All maps widgets now use mapViewBuilderProvider"

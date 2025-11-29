#!/bin/bash
# Rewrite foundation imports script - CENT-FIX-SYMBOL-COLLISIONS

echo "🔄 Starting foundation imports rewrite..."

# Find and replace any non-canonical foundation imports
find lib -name "*.dart" -type f -exec grep -l "foundation_shims" {} \; | while read -r file; do
    echo "Processing: $file"
    
    # Replace any direct imports from providers/ or src/ with canonical barrel
    sed -i '' 's|package:foundation_shims/providers/|package:foundation_shims/foundation_shims.dart|g' "$file"
    sed -i '' 's|package:foundation_shims/src/|package:foundation_shims/foundation_shims.dart|g' "$file"
    
    # Add 'as fnd' alias if not present
    if grep -q "foundation_shims/foundation_shims.dart" "$file" && ! grep -q "foundation_shims/foundation_shims.dart.*as fnd" "$file"; then
        sed -i '' 's|package:foundation_shims/foundation_shims.dart|package:foundation_shims/foundation_shims.dart as fnd|g' "$file"
    fi
done

echo "✅ Foundation imports rewrite complete"

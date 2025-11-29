#!/bin/bash
# Rewrite accounts imports script - CENT-FIX-SYMBOL-COLLISIONS

echo "🔄 Starting accounts imports rewrite..."

# Find and replace any non-canonical accounts imports
find lib -name "*.dart" -type f -exec grep -l "accounts_shims" {} \; | while read -r file; do
    echo "Processing: $file"
    
    # Replace any direct imports from src/ with canonical barrel
    sed -i '' 's|package:accounts_shims/src/|package:accounts_shims/accounts.dart|g' "$file"
    
    # Replace any imports from accounts_providers.dart with canonical
    sed -i '' 's|package:accounts_shims/accounts_providers.dart|package:accounts_shims/accounts.dart|g' "$file"
    
    # Add 'as acc' alias if not present
    if grep -q "accounts_shims/accounts.dart" "$file" && ! grep -q "accounts_shims/accounts.dart.*as acc" "$file"; then
        sed -i '' 's|package:accounts_shims/accounts.dart|package:accounts_shims/accounts.dart as acc|g' "$file"
    fi
done

echo "✅ Accounts imports rewrite complete"

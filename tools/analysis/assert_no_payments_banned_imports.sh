#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Checking for banned payments imports in app/lib/**"

# Check for direct payments/src imports (specific to payments)
echo "Checking for package:payments/src/.* imports..."
if rg -l "package:payments/src/" --glob "lib/**/*.dart" --type dart >/dev/null 2>&1; then
  echo "❌ ERROR: Found direct payments/src imports in app/lib:"
  rg -l "package:payments/src/" --glob "lib/**/*.dart" --type dart
  exit 1
fi

# Check for direct Stripe SDK imports
echo "Checking for direct Stripe SDK imports..."
if rg -l "package:stripe_|package:flutter_stripe|package:stripe_platform_interface" --glob "lib/**/*.dart" --type dart >/dev/null 2>&1; then
  echo "❌ ERROR: Found direct Stripe SDK imports in app/lib:"
  rg -l "package:stripe_|package:flutter_stripe|package:stripe_platform_interface" --glob "lib/**/*.dart" --type dart
  exit 1
fi

# Check for payments implementation packages leaking into app/lib
echo "Checking for payments implementation package imports..."
if rg -l "package:payments_(adapter_stripe|stripe_impl|stub_impl)/" --glob "lib/**/*.dart" --type dart >/dev/null 2>&1; then
  echo "❌ ERROR: Found payments implementation imports in app/lib:"
  rg -l "package:payments_(adapter_stripe|stripe_impl|stub_impl)/" --glob "lib/**/*.dart" --type dart
  exit 1
fi

echo "✅ No banned payments imports found in app/lib/**"
exit 0

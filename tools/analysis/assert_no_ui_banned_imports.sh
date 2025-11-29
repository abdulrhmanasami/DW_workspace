#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Checking for banned imports in UI scope (lib/ui/** and specified screens)"

# Check for direct src/** imports (banned: package:*_shims/src/**)
echo "Checking for package:*_shims/src/** imports..."
if rg -l "package:(design_system|foundation|mobility|maps|payments|accounts|database|network|realtime|observability|device_security)_shims/src/" --glob "lib/ui/**/*.dart" --glob "lib/screens/legal/**/*.dart" --glob "lib/screens/settings/dsr_*.dart" --type dart >/dev/null 2>&1; then
  echo "❌ ERROR: Found direct *_shims/src imports in UI scope:"
  rg -l "package:(design_system|foundation|mobility|maps|payments|accounts|database|network|realtime|observability|device_security)_shims/src/" --glob "lib/ui/**/*.dart" --glob "lib/screens/legal/**/*.dart" --glob "lib/screens/settings/dsr_*.dart" --type dart
  exit 1
fi

# Check for direct SDK imports (Stripe/Geolocator/Google Maps/HTTP/Flutter HTTP)
echo "Checking for direct SDK imports..."
if rg -l "package:(stripe_|flutter_stripe|stripe_platform_interface|geolocator|google_maps_flutter|http|flutter_http)" --glob "lib/ui/**/*.dart" --glob "lib/screens/legal/**/*.dart" --glob "lib/screens/settings/dsr_*.dart" --type dart >/dev/null 2>&1; then
  echo "❌ ERROR: Found direct SDK imports in UI scope:"
  rg -l "package:(stripe_|flutter_stripe|stripe_platform_interface|geolocator|google_maps_flutter|http|flutter_http)" --glob "lib/ui/**/*.dart" --glob "lib/screens/legal/**/*.dart" --glob "lib/screens/settings/dsr_*.dart" --type dart
  exit 1
fi

# Check for direct implementation package imports
echo "Checking for direct implementation package imports..."
if rg -l "package:(payments_adapter_stripe|payments_stripe_impl|mobility_adapter_geolocator|maps_adapter_google|auth_supabase_impl|database_sqflite_impl)/" --glob "lib/ui/**/*.dart" --glob "lib/screens/legal/**/*.dart" --glob "lib/screens/settings/dsr_*.dart" --type dart >/dev/null 2>&1; then
  echo "❌ ERROR: Found direct implementation imports in UI scope:"
  rg -l "package:(payments_adapter_stripe|payments_stripe_impl|mobility_adapter_geolocator|maps_adapter_google|auth_supabase_impl|database_sqflite_impl)/" --glob "lib/ui/**/*.dart" --glob "lib/screens/legal/**/*.dart" --glob "lib/screens/settings/dsr_*.dart" --type dart
  exit 1
fi

echo "✅ No banned imports found in UI scope"
exit 0

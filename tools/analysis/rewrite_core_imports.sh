#!/usr/bin/env bash

set -euo pipefail

# ملاحظات:
# - يعتمد على ripgrep (rg) و gnu-sed (gsed). على macOS: brew install ripgrep gnu-sed

replace_path() {
  local from="$1" to="$2"
  rg -l "$from" --type dart --glob '!**/.dart_tool/**' --glob '!**/build/**' \
    | xargs -I{} gsed -i "s|$from|$to|g" {}
}

# mobility → عبر البرميل
replace_path 'package:mobility_shims/location/models.dart' 'package:mobility_shims/mobility.dart'
replace_path 'package:mobility_shims/location/location_source.dart' 'package:mobility_shims/mobility.dart'
replace_path 'package:mobility_shims/providers/location_providers.dart' 'package:mobility_shims/mobility.dart'

# maps → عبر البرميل
replace_path 'package:maps_shims/src/models.dart' 'package:maps_shims/maps.dart'
replace_path 'package:maps_shims/src/map_controller.dart' 'package:maps_shims/maps.dart'
replace_path 'package:maps_shims/src/map_providers.dart' 'package:maps_shims/maps.dart'
replace_path 'package:maps_adapter_google/.*' 'package:maps_shims/maps.dart'

# payments → عبر البرميل
replace_path 'package:payments/models.dart' 'package:payments/payments.dart'
replace_path 'package:payments/contracts.dart' 'package:payments/payments.dart'
replace_path 'package:payments/providers.dart' 'package:payments/payments.dart'

# foundation → عبر البرميل
replace_path 'lib/config/remote_config_service.dart' 'package:foundation_shims/foundation_shims.dart'

echo "✅ rewrite_core_imports: DONE"

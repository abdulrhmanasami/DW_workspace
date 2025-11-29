#!/usr/bin/env bash

set -euo pipefail

# ملاحظات:
# - يعتمد على ripgrep (rg) و gnu-sed (gsed). على macOS: brew install ripgrep gnu-sed
# - يحول الاستيرادات القديمة للـdesign system إلى الـshims الجديدة

replace_path() {
  local from="$1" to="$2"
  rg -l "$from" --type dart --glob '!**/.dart_tool/**' --glob '!**/build/**' \
    | xargs -I{} sed -i '' "s|$from|$to|g" {}
}

# design_system_components → design_system_shims
replace_path 'package:design_system_components/.*' 'package:design_system_shims/design_system_shims.dart'
# design_system_shims/src → barrel
replace_path 'package:design_system_shims/src/.*' 'package:design_system_shims/design_system_shims.dart'
# design_system_foundation/src → barrel
replace_path 'package:design_system_foundation/src/.*' 'package:design_system_foundation/design_system_foundation.dart'

echo "✅ rewrite_design_system_imports: DONE"

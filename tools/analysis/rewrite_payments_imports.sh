#!/usr/bin/env bash
set -euo pipefail

replace_path() {
  local from="$1" to="$2"
  rg -l "$from" --type dart --glob '!**/.dart_tool/**' --glob '!**/build/**' \
    | xargs -I{} gsed -i "s|$from|$to|g" {}
}

replace_name() {
  local from="$1" to="$2"
  rg -l "\\b$from\\b" --type dart --glob '!**/.dart_tool/**' --glob '!**/build/**' \
    | xargs -I{} gsed -i "s|\\b$from\\b|$to|g" {}
}

# كل الاستيرادات تمر عبر البرميل
replace_path 'package:payments/models.dart' 'package:payments/payments.dart'
replace_path 'package:payments/contracts.dart' 'package:payments/payments.dart'
replace_path 'package:payments/providers.dart' 'package:payments/payments.dart'

# لو وُجدت أسماء قديمة:
replace_name 'PaymentGatewayInterface' 'PaymentGateway'

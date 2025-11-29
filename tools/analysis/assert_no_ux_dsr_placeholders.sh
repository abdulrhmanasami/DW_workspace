#!/usr/bin/env bash

set -euo pipefail

# Check for temporary DSR placeholders in UX screens
echo "Checking for UX/DSR placeholders..."

if rg -n "(Temporary type definitions|enum DsrOperation|enum DsrStatus|// TODO: import 'package:accounts_shims/accounts.dart';)" \
   lib/screens/settings/dsr_export_screen.dart \
   lib/screens/settings/dsr_erasure_screen.dart; then
  echo "❌ UX/DSR placeholders found"
  exit 1
else
  echo "OK: no UX/DSR placeholders"
fi

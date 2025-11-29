#!/usr/bin/env bash

set -euo pipefail

# استدعاء تشغيل المحاكي (إن لم يكن قيد التشغيل)
if ! adb get-state >/dev/null 2>&1; then
  bash tools/android/start_emulator_headless.sh
fi

# تمرير أسرار البيئة عبر dart-define لضمان وصول flutter_stripe داخل impl
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/payments_e2e_test.dart \
  -d emulator-5554 \
  --dart-define=STRIPE_PUBLISHABLE_KEY="${STRIPE_PUBLISHABLE_KEY:-}" \
  --dart-define=STRIPE_MERCHANT_COUNTRY="${STRIPE_MERCHANT_COUNTRY:-}" \
  --dart-define=STRIPE_MERCHANT_NAME="${STRIPE_MERCHANT_NAME:-}" \
  --dart-define=STRIPE_ENV="${STRIPE_ENV:-test}" \
  | tee tools/reports/C02_payments_e2e_test.txt

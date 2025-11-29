/// UI Routes Glue - Centralized route definitions for UI layer
/// Created by: UI-PHASE-01
/// Purpose: Single source of truth for UI routes with feature flag integration
/// Last updated: 2025-11-16

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;

import '../../screens/legal/about_legal_screen.dart';
import '../../screens/legal/licenses_browser_screen.dart';
import '../../screens/legal/privacy_markdown_screen.dart';
import '../../screens/legal/terms_markdown_screen.dart';
import '../../screens/settings/dsr_export_screen.dart';
import '../../screens/settings/dsr_erasure_screen.dart';

/// Provider for UI routes that respects feature flags
final uiRoutesProvider = Provider<Map<String, WidgetBuilder>>((ref) {
  final trackingEnabled = ref.watch(fnd.trackingEnabledProvider);

  return {
    // Legal routes - always available
    '/settings/about': (context) => const AboutLegalScreen(),
    '/settings/licenses': (context) => const LicensesBrowserScreen(),
    '/settings/legal/privacy': (context) => const PrivacyMarkdownScreen(),
    '/settings/legal/terms': (context) => const TermsMarkdownScreen(),

    // DSR routes - feature gated by tracking
    if (trackingEnabled) ...{
      '/settings/dsr/export': (context) => const DsrExportScreen(),
      '/settings/dsr/erasure': (context) => const DsrErasureScreen(),
    },
  };
});

/// Build UI routes function for easy integration with main.dart
Map<String, WidgetBuilder> buildUiRoutes(WidgetRef ref) {
  return ref.read(uiRoutesProvider);
}

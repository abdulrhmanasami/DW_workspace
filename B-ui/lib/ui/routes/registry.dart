// lib/ui/routes/registry.dart

import 'package:flutter/widgets.dart';

// شاشات القانونيات
import 'package:b_ui/screens/legal/about_legal_screen.dart';
import 'package:b_ui/screens/legal/licenses_browser_screen.dart';
import 'package:b_ui/screens/legal/privacy_markdown_screen.dart';
import 'package:b_ui/screens/legal/terms_markdown_screen.dart';

// شاشات DSR
import 'package:b_ui/screens/settings/dsr_export_screen.dart';
import 'package:b_ui/screens/settings/dsr_erasure_screen.dart';

/// مواصفة خفيفة لمسار واجهة المستخدم (ميتا فقط).
class UiRoute {
  final String route;
  final WidgetBuilder builder;

  /// مفتاح ميزة اختياري للاستدلال فقط (لا يتم تطبيق gating هنا).
  final String? featureGateKey;

  const UiRoute({
    required this.route,
    required this.builder,
    this.featureGateKey,
  });
}

/// قائمة مواصفات المسارات (ميتا للاستهلاك من B-central إن لزم).
const List<UiRoute> uiRouteSpecs = [
  UiRoute(route: '/settings/about', builder: _aboutBuilder),
  UiRoute(route: '/settings/licenses', builder: _licensesBuilder),
  UiRoute(route: '/settings/legal/privacy', builder: _privacyBuilder),
  UiRoute(route: '/settings/legal/terms', builder: _termsBuilder),
  UiRoute(
    route: '/settings/dsr/export',
    builder: _dsrExportBuilder,
    featureGateKey: 'trackingEnabled',
  ),
  UiRoute(
    route: '/settings/dsr/erase',
    builder: _dsrEraseBuilder,
    featureGateKey: 'trackingEnabled',
  ),
];

/// خريطة المسارات النهائيّة للاستهلاك المباشر من B-central.
Map<String, WidgetBuilder> uiRoutes() {
  final map = <String, WidgetBuilder>{};
  for (final spec in uiRouteSpecs) {
    map[spec.route] = spec.builder;
  }
  return map;
}

// ==== Builders (Widgets-only) ====

Widget _aboutBuilder(BuildContext c) => const AboutLegalScreen();
Widget _licensesBuilder(BuildContext c) => const LicensesBrowserScreen();
Widget _privacyBuilder(BuildContext c) => const PrivacyMarkdownScreen();
Widget _termsBuilder(BuildContext c) => const TermsMarkdownScreen();
Widget _dsrExportBuilder(BuildContext c) => const DsrExportScreen();
Widget _dsrEraseBuilder(BuildContext c) => const DsrErasureScreen();

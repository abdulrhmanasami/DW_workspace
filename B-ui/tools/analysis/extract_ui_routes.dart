#!/usr/bin/env dart

// Extract UI routes from uiRouteSpecs for reporting
import 'dart:io';
import 'dart:convert';

void main() {
  final registryFile = File('lib/ui/routes/registry.dart');
  final content = registryFile.readAsStringSync();

  // Extract route specs using regex - match UiRoute constructor calls
  final routePattern = RegExp(
    r"UiRoute\(route:\s*'([^']+)',\s*builder:\s*[^\s,]+(?:,\s*featureGateKey:\s*'([^']+)')?\s*\)",
  );
  final matches = routePattern.allMatches(content);

  final routes = <Map<String, dynamic>>[];

  for (final match in matches) {
    final route = match.group(1)!;
    final featureGateKey = match.group(2);

    // Determine file path based on route
    String screen = '';
    String file = '';
    bool featureGated = featureGateKey != null;

    if (route == '/settings/about') {
      screen = 'AboutLegalScreen';
      file = 'lib/screens/legal/about_legal_screen.dart';
    } else if (route == '/settings/licenses') {
      screen = 'LicensesBrowserScreen';
      file = 'lib/screens/legal/licenses_browser_screen.dart';
    } else if (route == '/settings/legal/privacy') {
      screen = 'PrivacyMarkdownScreen';
      file = 'lib/screens/legal/privacy_markdown_screen.dart';
    } else if (route == '/settings/legal/terms') {
      screen = 'TermsMarkdownScreen';
      file = 'lib/screens/legal/terms_markdown_screen.dart';
    } else if (route == '/settings/dsr/export') {
      screen = 'DsrExportScreen';
      file = 'lib/screens/settings/dsr_export_screen.dart';
    } else if (route == '/settings/dsr/erase') {
      screen = 'DsrErasureScreen';
      file = 'lib/screens/settings/dsr_erasure_screen.dart';
    }

    routes.add({
      'route': route,
      'screen': screen,
      'file': file,
      'feature_gated': featureGated,
      if (featureGated) 'gate_condition': featureGateKey,
    });
  }

  // Group by category
  final legalRoutes = routes
      .where(
        (r) =>
            r['route'].startsWith('/settings/') &&
            !r['route'].contains('/dsr/'),
      )
      .toList();
  final dsrRoutes = routes.where((r) => r['route'].contains('/dsr/')).toList();

  final report = {
    'ui_routes': {'legal': legalRoutes, 'dsr': dsrRoutes},
    'ui_components': [
      {
        'component': 'LoadingView',
        'file': 'lib/ui/components/loading_view.dart',
        'description': 'Standard loading interface with Design System tokens',
      },
      {
        'component': 'ErrorView',
        'file': 'lib/ui/components/error_view.dart',
        'description': 'Consistent error display across UI layer',
      },
      {
        'component': 'EmptyState',
        'file': 'lib/ui/components/empty_state.dart',
        'description': 'Standard empty state display across UI layer',
      },
    ],
    'barrel': {
      'file': 'lib/ui/ui.dart',
      'exports': [
        'design_system_shims (barrel)',
        'foundation_shims as fnd (barrel)',
        'flutter/widgets.dart (selective)',
        'flutter_riverpod.dart (selective)',
        'Local UI components',
        'Route registry (UiRoute, uiRouteSpecs, uiRoutes)',
      ],
    },
  };

  print(jsonEncode(report));
}

/// DwTestApp - Test harness for Delivery Ways widget tests
/// Created by: Track D - Ticket #236 (D-4)
/// Purpose: Standardized test app setup for identity/auth testing

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_shims/auth_shims.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/state/identity/identity_controller.dart';

/// Test app wrapper for Delivery Ways screens with identity testing support
class DwTestApp extends StatelessWidget {
  /// Create a test app with optional provider overrides
  const DwTestApp({
    super.key,
    required this.home,
    this.overrides = const [],
    this.locale = const Locale('en'),
  });

  /// The home widget to display
  final Widget home;

  /// Additional provider overrides for testing
  final List<Override> overrides;

  /// Locale for the test app
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: home,
        // Add basic routes that might be needed for navigation tests
        routes: {
          '/auth/otp': (context) => const Scaffold(body: Center(child: Text('OTP Screen'))),
        },
        onGenerateRoute: (settings) {
          // Handle routes with arguments
          if (settings.name == '/auth/otp' && settings.arguments is String) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(child: Text('OTP Screen with phone: ${settings.arguments}')),
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  /// Create a test app with identity shim override for testing
  factory DwTestApp.withIdentityShim({
    required Widget home,
    required IdentityShim fakeIdentityShim,
    List<Override> additionalOverrides = const [],
    Locale locale = const Locale('en'),
  }) {
    return DwTestApp(
      home: home,
      locale: locale,
      overrides: [
        identityShimProvider.overrideWithValue(fakeIdentityShim),
        ...additionalOverrides,
      ],
    );
  }
}

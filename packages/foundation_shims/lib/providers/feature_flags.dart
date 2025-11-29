import 'package:flutter_riverpod/flutter_riverpod.dart';

/// جميع هذه المزوّدات Compile-ready بستّ قيم قابلة للتهيئة عبر dart-define.
/// لاحقًا يمكن حقن RemoteConfig دون كسر العقود.

const _defFalse = bool.fromEnvironment('MAINTENANCE_MODE', defaultValue: false);
const _gpayDef = bool.fromEnvironment(
  'STRIPE_GPAY_ENABLED',
  defaultValue: false,
);
const _trackDef = bool.fromEnvironment('TRACKING_ENABLED', defaultValue: false);
const _mapsKey = String.fromEnvironment('MAPS_PROVIDER', defaultValue: 'none');
const _payEnv = String.fromEnvironment('PAYMENTS_ENV', defaultValue: 'test');
const _uiTheme = String.fromEnvironment('UI_THEME', defaultValue: 'light');

/// dart-define: MAINTENANCE_MODE (bool, default: false)
/// Controls whether the app shows maintenance mode banner
final maintenanceModeEnabledProvider = Provider<bool>((_) => _defFalse);

/// dart-define: STRIPE_GPAY_ENABLED (bool, default: false)
/// Enables/disables Google Pay integration via Stripe
final stripeGpayEnabledProvider = Provider<bool>((_) => _gpayDef);

/// dart-define: TRACKING_ENABLED (bool, default: false)
/// Enables/disables user tracking and analytics
final trackingEnabledProvider = Provider<bool>((_) => _trackDef);

/// dart-define: MAPS_PROVIDER (String, default: 'none')
/// Maps provider key ('google', 'mapbox', 'none' for stub)
final mapsProviderKeyProvider = Provider<String>((_) => _mapsKey);

/// dart-define: PAYMENTS_ENV (String, default: 'test')
/// Payment environment ('test', 'production')
final paymentsEnvProvider = Provider<String>((_) => _payEnv);

/// dart-define: UI_THEME (String, default: 'light')
/// UI theme preference
final uiThemeProvider = Provider<String>((_) => _uiTheme);

/// dart-define: MAINTENANCE_MESSAGE (String, default: '')
/// Maintenance mode message to display
final maintenanceMessageProvider = Provider<String>(
  (_) => String.fromEnvironment('MAINTENANCE_MESSAGE', defaultValue: ''),
);

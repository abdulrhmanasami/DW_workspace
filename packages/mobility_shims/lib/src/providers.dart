// Mobility Providers - Riverpod Configuration
// Created by: Cursor B-mobility
// Purpose: Riverpod providers for mobility operations with consent/kill-switch enforcement
// Last updated: 2025-11-13

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart';
import 'contracts.dart';
import 'impl/stub_impl.dart';

/// Provider for mobility configuration from RemoteConfig
final mobilityConfigProvider = Provider<bool>((ref) {
  return false;
});

/// Provider for background location consent (from U-06 privacy consent screen)
final consentBackgroundLocationProvider = Provider<bool>((ref) {
  // TODO: Read from actual consent state (U-06 implementation)
  // For now, default to false for safety
  return false;
});

/// Provider for location provider - must be overridden with concrete implementation
final locationProvider = Provider<LocationProvider>((ref) {
  final trackingEnabled = ref.watch(mobilityConfigProvider);
  final consentGranted = ref.watch(consentBackgroundLocationProvider);

  if (!trackingEnabled) {
    throw TrackingDisabledException('Tracking is disabled via kill-switch');
  }

  if (!consentGranted) {
    throw ConsentDeniedException('Background location consent not granted');
  }

  throw UnimplementedError(
    'LocationProvider must be provided by adapter when enabled',
  );
});

/// Provider for background tracker - must be overridden with concrete implementation
final backgroundTrackerProvider = Provider<BackgroundTracker>((ref) {
  final trackingEnabled = ref.watch(mobilityConfigProvider);
  final consentGranted = ref.watch(consentBackgroundLocationProvider);

  if (!trackingEnabled) {
    throw TrackingDisabledException('Tracking is disabled via kill-switch');
  }

  if (!consentGranted) {
    throw ConsentDeniedException('Background location consent not granted');
  }

  throw UnimplementedError(
    'BackgroundTracker must be provided by adapter when enabled',
  );
});

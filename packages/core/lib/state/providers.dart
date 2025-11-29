/// Core state providers for Riverpod
/// This file provides basic providers that screens depend on
library;

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:state_notifier/state_notifier.dart";

/// Simple notifier to satisfy Riverpod generics constraints
class _DynNotifier extends StateNotifier<dynamic> {
  _DynNotifier() : super(null);
}

/// Provider for app configuration
final configProvider = Provider<dynamic>((final ref) {
  // TODO: Implement actual config provider
  return null;
});

/// Provider for user authentication state
final authStateProvider = StateNotifierProvider<_DynNotifier, dynamic>(
  (final ref) => _DynNotifier(),
);

/// Provider for app navigation state
final navigationProvider = StateNotifierProvider<_DynNotifier, dynamic>(
  (final ref) => _DynNotifier(),
);

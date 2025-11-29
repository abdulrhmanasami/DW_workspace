/// Component: Map Providers
/// Created by: Cursor B-ux
/// Purpose: Riverpod providers for map services
/// Last updated: 2025-11-11

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'legacy/aliases.dart' show MapController;

/// Provider for map controller - must be overridden with concrete implementation
final mapControllerProvider = Provider<MapController>(
  (_) => throw UnimplementedError('Bind map adapter in app layer'),
);

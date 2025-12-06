/// Component: Map Providers
/// Created by: Cursor B-ux
/// Purpose: Simple provider hooks for map services (no DI framework required)
/// Last updated: 2025-11-11

import 'legacy/aliases.dart' show MapController;

/// Factory for map controller - override in app layer.
MapController Function() mapControllerProvider =
    () => throw UnimplementedError('Bind map adapter in app layer');

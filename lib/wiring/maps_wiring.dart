library maps_wiring;

/// Legacy wiring barrel kept for backward compatibility.
///
/// New code should import `package:maps_shims/maps.dart` directly and use the
/// overrides defined in `maps_binding.dart`. This library simply re-exports the
/// canonical shim surface and keeps a no-op `initializeMapsAdapter` hook for
/// older entry points.
export 'package:maps_shims/maps.dart';

/// Legacy initialization hook – adapters are now installed via Provider
/// overrides, so nothing needs to happen here.
void initializeMapsAdapter() {}

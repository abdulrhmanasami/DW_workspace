/// Component: Maps Binding
/// Created by: Cursor B-mobility
/// Purpose: Dynamic maps provider binding based on RemoteConfig
/// Last updated: 2025-11-24

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;
import 'package:maps_adapter_google/maps_adapter_google.dart' as maps_google;
import 'package:maps_shims/maps.dart';

import '../state/infra/feature_flags.dart';

/// Dynamic maps provider overrides based on RemoteConfig
final mapsOverrides = <Override>[
  mapViewBuilderProvider.overrideWith((ref) {
    final mapsEnabled = ref.watch(mapsEnabledProvider);
    final mapsProvider = ref.watch(fnd.mapsProviderKeyProvider);

    if (!mapsEnabled) {
      return _disabledMapViewBuilder;
    }

    if (mapsProvider == fnd.MapsProviderValues.google) {
      return ref.watch(maps_google.googleMapViewBuilderProvider);
    }

    return _disabledMapViewBuilder;
  }),
];

MapViewBuilder get _disabledMapViewBuilder => (params) =>
    const _MapsUnavailablePlaceholder();

class _MapsUnavailablePlaceholder extends StatelessWidget {
  const _MapsUnavailablePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
        child: Center(
          child: Text(
            'Maps unavailable',
            style: TextStyle(color: Color(0xFF616161)),
          ),
        ),
      ),
    );
  }
}

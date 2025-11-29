import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:observability_shims/observability_shims.dart';
import 'package:design_system_stub_impl/providers.dart';
import 'package:foundation_shims/foundation_shims.dart';
import '../../wiring/maps_binding.dart';
import '../../wiring/consent_binding.dart';
import 'network_providers.dart';

final appOverrides = <Override>[
  databaseMigrationManagerProvider.overrideWithValue(
    NoopDatabaseMigrationManager(),
  ),
  ...materialDesignOverrides,
  ...materialNoticeOverrides,
  ...mapsOverrides,
  ...consentOverrides,
  remoteConfigHttpClientProvider.overrideWith(
    (ref) => ref.watch(secureHttpClientProvider),
  ),
  // Initialize RemoteConfig fetch on app startup
  fetchRemoteConfigProvider,
];

/// Component: Kill Switch Overrides
/// Created by: Cursor B-central
/// Purpose: Centralized provider overrides for feature kill-switches and safe-mode
/// Last updated: 2025-11-12

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;
import 'package:maps_shims/maps.dart';
import 'package:mobility_shims/mobility.dart' as mob;
import 'package:payments/payments.dart' as pay;
import 'package:payments/providers.dart'
    as pay_internals
    show ensurePaymentGateway;

import '../../wiring/payments_wiring.dart' as payments_wiring;
import 'feature_flags.dart'; // For locally defined providers
import 'payments_providers.dart';

/// Kill Switch Overrides - Centralized feature control
/// These overrides switch implementations to NoOp/Stubs when features are disabled
final killSwitchOverrides = <Override>[
  ..._paymentsOverrides,

  // Maps kill-switch
  mapViewBuilderProvider.overrideWith((ref) {
    final mapsEnabled = ref.watch(mapsEnabledProvider);
    if (!mapsEnabled) {
      // Return placeholder implementation when maps are disabled
      return _mapsDisabledBuilder;
    }
    throw UnimplementedError(
      'MapViewBuilder must be provided by adapter when enabled',
    );
  }),

  // New mobility shims kill-switches (primary enforcement)
  mob.locationProvider.overrideWith((ref) {
    final trackingEnabled = ref.watch(fnd.trackingEnabledProvider);
    if (!trackingEnabled) {
      return const _KillSwitchLocationProvider();
    }
    throw UnimplementedError(
      'LocationProvider must be provided by binding when enabled',
    );
  }),

  mob.backgroundTrackerProvider.overrideWith((ref) {
    final trackingEnabled = ref.watch(trackingEnabledProvider);
    if (!trackingEnabled) {
      return const _KillSwitchBackgroundTracker();
    }
    throw UnimplementedError(
      'BackgroundTracker must be provided by binding when enabled',
    );
  }),
];

final _paymentsOverrides = <Override>[
  pay.paymentGatewayProvider.overrideWith((ref) {
    final paymentsEnabled = ref.watch(paymentsEnabledProvider);
    if (!paymentsEnabled) {
      return const _KillSwitchPaymentsGateway();
    }
    return pay_internals.ensurePaymentGateway() as pay.PaymentsGateway;
  }),
  pay.paymentsSheetProvider.overrideWith((ref) {
    final paymentsEnabled = ref.watch(paymentsEnabledProvider);
    if (!paymentsEnabled) {
      return const _KillSwitchPaymentsSheet();
    }
    return pay.ensurePaymentSheet();
  }),
  payments_wiring.paymentsGatewayProvider.overrideWith((ref) async {
    final paymentsEnabled = ref.watch(paymentsEnabledProvider);
    if (!paymentsEnabled) {
      return const _KillSwitchPaymentsGateway();
    }
    final runtimeConfig = ref.watch(paymentsRuntimeConfigProvider);
    final cfg = runtimeConfig.config;
    if (cfg == null) {
      return const _KillSwitchPaymentsGateway();
    }
    await pay.getPaymentService(cfg: cfg);
    return pay_internals.ensurePaymentGateway() as pay.PaymentsGateway;
  }),
  payments_wiring.paymentsSheetProvider.overrideWith((ref) async {
    final paymentsEnabled = ref.watch(paymentsEnabledProvider);
    if (!paymentsEnabled) {
      return const _KillSwitchPaymentsSheet();
    }
    final runtimeConfig = ref.watch(paymentsRuntimeConfigProvider);
    final cfg = runtimeConfig.config;
    if (cfg == null) {
      return const _KillSwitchPaymentsSheet();
    }
    await pay.getPaymentService(cfg: cfg);
    return pay.ensurePaymentSheet();
  }),
];

MapViewBuilder get _mapsDisabledBuilder =>
    (params) => const _MapsDisabledPlaceholder();

class _MapsDisabledPlaceholder extends StatelessWidget {
  const _MapsDisabledPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
        child: Center(
          child: Text(
            'Maps disabled',
            style: TextStyle(color: Color(0xFF616161)),
          ),
        ),
      ),
    );
  }
}

class _KillSwitchLocationProvider implements mob.LocationProvider {
  const _KillSwitchLocationProvider();

  @override
  Stream<mob.LocationPoint> watch() => const Stream<mob.LocationPoint>.empty();

  @override
  Future<mob.LocationPoint> getCurrent() async {
    throw mob.TrackingDisabledException('Tracking disabled via kill switch');
  }

  @override
  Future<mob.PermissionStatus> requestPermission() async =>
      mob.PermissionStatus.restricted;

  @override
  Future<bool> serviceEnabled() async => false;
}

class _KillSwitchBackgroundTracker implements mob.BackgroundTracker {
  const _KillSwitchBackgroundTracker();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Stream<mob.TrackingStatus> status() =>
      Stream<mob.TrackingStatus>.value(mob.TrackingStatus.stopped);
}

class _KillSwitchPaymentsGateway implements pay.PaymentsGateway {
  const _KillSwitchPaymentsGateway();

  static StateError _disabledError() =>
      StateError('Payments disabled by kill switch');

  Future<T> _disabledFuture<T>() => Future.error(_disabledError());

  @override
  Future<pay.PaymentIntent> createIntent(
    pay.Amount amount,
    pay.Currency currency,
  ) => _disabledFuture<pay.PaymentIntent>();

  @override
  Future<pay.PaymentResult> confirmIntent(
    String clientSecret, {
    pay.PaymentMethod? method,
  }) => _disabledFuture<pay.PaymentResult>();

  @override
  Future<pay.SetupResult> setupPaymentMethod({
    required pay.SetupRequest request,
  }) => _disabledFuture<pay.SetupResult>();

  @override
  Future<List<pay.SavedPaymentMethod>> listMethods({
    required String customerId,
  }) async => const [];

  @override
  Future<void> detachPaymentMethod({
    required String customerId,
    required String paymentMethodId,
  }) async {}

  @override
  void dispose() {}
}

class _KillSwitchPaymentsSheet implements pay.PaymentsSheet {
  const _KillSwitchPaymentsSheet();

  @override
  Future<pay.PaymentResult> present({required String clientSecret}) =>
      Future.error(_KillSwitchPaymentsGateway._disabledError());
}

/// Home Hub Active Parcel Card Tests - Track C Ticket #70, #71, #74
/// Purpose: Test Active Parcel Card display, visibility, navigation, and layout
/// Created by: Track C - Ticket #70
/// Updated by: Track C - Ticket #71 (Layout tests for Active Order State)
/// Updated by: Track C - Ticket #74 (Unified navigation to ParcelShipmentDetailsScreen)
/// Last updated: 2025-11-29

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_orders_state.dart';
// Track C - Ticket #74: Import for navigation test
import 'package:delivery_ways_clean/screens/parcels/parcel_shipment_details_screen.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  /// Creates a test widget with necessary L10n and routing setup.
  Widget createTestApp({
    required Widget home,
    Map<String, WidgetBuilder>? routes,
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
          Locale('de'),
        ],
        locale: locale,
        home: home,
        routes: routes ?? {},
      ),
    );
  }

  /// Creates a stub Parcel with given parameters.
  Parcel createStubParcel({
    required String id,
    required ParcelStatus status,
    String dropoffLabel = 'Riyadh - King Fahd Road',
    DateTime? createdAt,
  }) {
    return Parcel(
      id: id,
      createdAt: createdAt ?? DateTime.now(),
      pickupAddress: const ParcelAddress(label: 'Test Pickup Address'),
      dropoffAddress: ParcelAddress(label: dropoffLabel),
      details: const ParcelDetails(
        size: ParcelSize.medium,
        weightKg: 2.5,
      ),
      status: status,
    );
  }

  /// Creates a test widget that simulates Home Hub with Active Parcel Card.
  Widget createHomeWithActiveParcelCard({
    required List<Parcel> parcels,
    Locale locale = const Locale('en'),
    bool navigateToParcelsActive = false,
  }) {
    return ProviderScope(
      overrides: [
        parcelOrdersProvider.overrideWith(
          (ref) {
            final controller = ParcelOrdersController(
              repository: _StubParcelsRepository(),
            );
            // Manually populate state
            for (final p in parcels) {
              controller.state = ParcelOrdersState(
                activeParcel: p,
                parcels: parcels,
              );
            }
            return controller;
          },
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
          Locale('de'),
        ],
        locale: locale,
        home: _TestActiveParcelCardWidget(parcels: parcels),
        routes: {
          RoutePaths.parcelsActiveShipment: (context) => Scaffold(
                appBar: AppBar(title: const Text('Parcels Active')),
                body: const Center(child: Text('Parcels Active')),
              ),
        },
      ),
    );
  }

  group('Home Hub Active Parcel Card Tests', () {
    testWidgets('Card is visible when there is an active (non-terminal) parcel',
        (WidgetTester tester) async {
      final activeParcel = createStubParcel(
        id: 'parcel-001',
        status: ParcelStatus.inTransit,
        dropoffLabel: 'Riyadh - King Fahd Road',
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: [activeParcel]),
      );
      await tester.pumpAndSettle();

      // Verify card is visible
      expect(find.text('In transit'), findsOneWidget);
      expect(
        find.textContaining('To Riyadh - King Fahd Road'),
        findsOneWidget,
      );
      expect(find.text('View shipment'), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    });

    testWidgets('Card is NOT visible when no parcels exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: []),
      );
      await tester.pumpAndSettle();

      // Verify card is NOT visible
      expect(find.text('View shipment'), findsNothing);
      expect(find.byIcon(Icons.local_shipping_outlined), findsNothing);
    });

    testWidgets('Card is NOT visible when all parcels are terminal (delivered)',
        (WidgetTester tester) async {
      final deliveredParcel = createStubParcel(
        id: 'parcel-delivered',
        status: ParcelStatus.delivered,
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: [deliveredParcel]),
      );
      await tester.pumpAndSettle();

      // Verify card is NOT visible (delivered is terminal)
      expect(find.text('View shipment'), findsNothing);
    });

    testWidgets('Card is NOT visible when all parcels are cancelled',
        (WidgetTester tester) async {
      final cancelledParcel = createStubParcel(
        id: 'parcel-cancelled',
        status: ParcelStatus.cancelled,
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: [cancelledParcel]),
      );
      await tester.pumpAndSettle();

      // Verify card is NOT visible (cancelled is terminal)
      expect(find.text('View shipment'), findsNothing);
    });

    testWidgets('Card is NOT visible when all parcels have failed status',
        (WidgetTester tester) async {
      final failedParcel = createStubParcel(
        id: 'parcel-failed',
        status: ParcelStatus.failed,
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: [failedParcel]),
      );
      await tester.pumpAndSettle();

      // Verify card is NOT visible (failed is terminal)
      expect(find.text('View shipment'), findsNothing);
    });

    // Track C - Ticket #74: Updated to test navigation to ParcelShipmentDetailsScreen
    testWidgets('Tapping card navigates to ParcelShipmentDetailsScreen',
        (WidgetTester tester) async {
      final activeParcel = createStubParcel(
        id: 'parcel-001',
        status: ParcelStatus.scheduled,
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: [activeParcel]),
      );
      await tester.pumpAndSettle();

      // Tap the card
      await tester.tap(find.text('View shipment'));
      await tester.pumpAndSettle();

      // Track C - Ticket #74: Verify navigation to ParcelShipmentDetailsScreen
      expect(find.byType(ParcelShipmentDetailsScreen), findsOneWidget);
      // Verify AppBar shows "Active shipment" title
      expect(find.text('Active shipment'), findsOneWidget);
    });

    testWidgets('Card shows different status labels correctly',
        (WidgetTester tester) async {
      // Test scheduled status
      final scheduledParcel = createStubParcel(
        id: 'parcel-scheduled',
        status: ParcelStatus.scheduled,
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: [scheduledParcel]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pickup scheduled'), findsOneWidget);
    });

    testWidgets('Card shows pickedUp status label',
        (WidgetTester tester) async {
      final pickedUpParcel = createStubParcel(
        id: 'parcel-pickedup',
        status: ParcelStatus.pickedUp,
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: [pickedUpParcel]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Picked up'), findsOneWidget);
    });

    testWidgets('L10n AR: Card shows correct Arabic translations',
        (WidgetTester tester) async {
      final activeParcel = createStubParcel(
        id: 'parcel-ar',
        status: ParcelStatus.inTransit,
        dropoffLabel: 'الرياض',
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(
          parcels: [activeParcel],
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Arabic texts
      expect(find.text('قيد النقل'), findsOneWidget);
      expect(find.text('عرض الشحنة'), findsOneWidget);
      expect(find.textContaining('إلى الرياض'), findsOneWidget);
    });

    testWidgets('L10n DE: Card shows correct German translations',
        (WidgetTester tester) async {
      final activeParcel = createStubParcel(
        id: 'parcel-de',
        status: ParcelStatus.inTransit,
        dropoffLabel: 'Berlin',
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(
          parcels: [activeParcel],
          locale: const Locale('de'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify German texts
      expect(find.text('Unterwegs'), findsOneWidget);
      expect(find.text('Sendung ansehen'), findsOneWidget);
      expect(find.textContaining('Nach Berlin'), findsOneWidget);
    });

    testWidgets('Most recent active parcel is selected when multiple exist',
        (WidgetTester tester) async {
      final olderParcel = createStubParcel(
        id: 'parcel-old',
        status: ParcelStatus.scheduled,
        dropoffLabel: 'Old Destination',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      );

      final newerParcel = createStubParcel(
        id: 'parcel-new',
        status: ParcelStatus.inTransit,
        dropoffLabel: 'New Destination',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: [olderParcel, newerParcel]),
      );
      await tester.pumpAndSettle();

      // Should show the newer parcel (in transit)
      expect(find.text('In transit'), findsOneWidget);
      expect(find.textContaining('To New Destination'), findsOneWidget);
    });

    testWidgets('RoutePaths.parcelsActiveShipment has correct path value',
        (WidgetTester tester) async {
      expect(RoutePaths.parcelsActiveShipment, equals('/parcels/active'));
    });
  });

  // ===================================================================
  // Track C - Ticket #71: Layout and Design System Alignment Tests
  // ===================================================================
  group('Home Hub Layout Tests (Ticket #71)', () {
    testWidgets('Active parcel card appears with shipping icon',
        (WidgetTester tester) async {
      final activeParcel = createStubParcel(
        id: 'layout-test-001',
        status: ParcelStatus.inTransit,
        dropoffLabel: 'Test Location',
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: [activeParcel]),
      );
      await tester.pumpAndSettle();

      // Verify shipping icon is present
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    });

    testWidgets('Card displays View shipment CTA',
        (WidgetTester tester) async {
      final activeParcel = createStubParcel(
        id: 'cta-test-001',
        status: ParcelStatus.pickupPending,
        dropoffLabel: 'Destination',
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: [activeParcel]),
      );
      await tester.pumpAndSettle();

      // Verify CTA is visible (now using DWButton.tertiary)
      expect(find.text('View shipment'), findsOneWidget);
    });

    testWidgets('No card shown when parcels list is empty (no active order)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: []),
      );
      await tester.pumpAndSettle();

      // Verify no shipping icon (card not rendered)
      expect(find.byIcon(Icons.local_shipping_outlined), findsNothing);
      // Services text should still appear in empty state
      expect(find.text('No active parcel'), findsOneWidget);
    });

    testWidgets('L10n EN: Status preparing shown for draft parcel',
        (WidgetTester tester) async {
      final draftParcel = createStubParcel(
        id: 'draft-test',
        status: ParcelStatus.draft,
        dropoffLabel: 'Draft Destination',
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: [draftParcel]),
      );
      await tester.pumpAndSettle();

      // Draft status maps to "Preparing your shipment..." label
      expect(find.text('Preparing your shipment...'), findsOneWidget);
    });

    testWidgets('L10n EN: Status waiting for pickup shown for pickupPending',
        (WidgetTester tester) async {
      final pendingParcel = createStubParcel(
        id: 'pending-test',
        status: ParcelStatus.pickupPending,
        dropoffLabel: 'Pending Destination',
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: [pendingParcel]),
      );
      await tester.pumpAndSettle();

      // pickupPending status maps to "Waiting for pickup" label
      expect(find.text('Waiting for pickup'), findsOneWidget);
    });

    testWidgets('Destination label is shown with To prefix',
        (WidgetTester tester) async {
      const destinationName = 'King Abdullah Financial District';
      final activeParcel = createStubParcel(
        id: 'destination-test',
        status: ParcelStatus.inTransit,
        dropoffLabel: destinationName,
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: [activeParcel]),
      );
      await tester.pumpAndSettle();

      // Verify destination appears with "To" prefix from L10n
      expect(find.textContaining('To $destinationName'), findsOneWidget);
    });

    testWidgets('Empty destination label does not show subtitle',
        (WidgetTester tester) async {
      final activeParcel = createStubParcel(
        id: 'empty-dest-test',
        status: ParcelStatus.scheduled,
        dropoffLabel: '', // Empty destination
      );

      await tester.pumpWidget(
        createHomeWithActiveParcelCard(parcels: [activeParcel]),
      );
      await tester.pumpAndSettle();

      // Status should show
      expect(find.text('Pickup scheduled'), findsOneWidget);
      // But "To" text should not appear (no destination)
      expect(find.textContaining('To '), findsNothing);
    });
  });
}

/// Stub ParcelsRepository for testing.
class _StubParcelsRepository implements ParcelsRepository {
  final List<Parcel> _parcels = [];

  @override
  Future<Parcel> createShipment(ParcelCreateRequest request) async {
    final parcel = Parcel(
      id: 'stub-parcel-${DateTime.now().microsecondsSinceEpoch}',
      createdAt: DateTime.now(),
      pickupAddress: ParcelAddress(label: request.senderAddress),
      dropoffAddress: ParcelAddress(label: request.receiverAddress),
      details: ParcelDetails(
        size: request.size,
        weightKg: double.tryParse(request.weightText) ?? 1.0,
      ),
      status: ParcelStatus.scheduled,
    );
    _parcels.add(parcel);
    return parcel;
  }

  @override
  Future<List<Parcel>> listParcels() async {
    return List.unmodifiable(_parcels);
  }

  @override
  Future<Parcel?> getParcelById(String id) async {
    try {
      return _parcels.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Test widget that mimics Home Hub Active Parcel Card behavior.
/// Track C - Ticket #74: Updated to navigate to ParcelShipmentDetailsScreen
class _TestActiveParcelCardWidget extends ConsumerWidget {
  const _TestActiveParcelCardWidget({required this.parcels});

  final List<Parcel> parcels;

  bool _isTerminal(ParcelStatus status) =>
      status == ParcelStatus.delivered ||
      status == ParcelStatus.cancelled ||
      status == ParcelStatus.failed;

  Parcel? _selectActiveParcel(ParcelOrdersState state) {
    final active = state.parcels
        .where((p) => !_isTerminal(p.status))
        .toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return active.first;
  }

  String _mapStatusToLabel(AppLocalizations l10n, ParcelStatus status) {
    switch (status) {
      case ParcelStatus.draft:
      case ParcelStatus.quoting:
        return l10n.homeActiveParcelStatusPreparing;
      case ParcelStatus.scheduled:
        return l10n.homeActiveParcelStatusScheduled;
      case ParcelStatus.pickupPending:
        return l10n.homeActiveParcelStatusPickupPending;
      case ParcelStatus.pickedUp:
        return l10n.homeActiveParcelStatusPickedUp;
      case ParcelStatus.inTransit:
        return l10n.homeActiveParcelStatusInTransit;
      case ParcelStatus.delivered:
        return l10n.homeActiveParcelStatusDelivered;
      case ParcelStatus.cancelled:
        return l10n.homeActiveParcelStatusCancelled;
      case ParcelStatus.failed:
        return l10n.homeActiveParcelStatusFailed;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcelOrdersState = ref.watch(parcelOrdersProvider);
    final activeParcel = _selectActiveParcel(parcelOrdersState);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (activeParcel == null) {
      return const Scaffold(
        body: Center(child: Text('No active parcel')),
      );
    }

    final statusLabel = _mapStatusToLabel(l10n, activeParcel.status);
    final destinationLabel = activeParcel.dropoffAddress.label;

    // Track C - Ticket #74: Navigate directly to ParcelShipmentDetailsScreen
    void navigateToDetails() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ParcelShipmentDetailsScreen(parcel: activeParcel),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Card(
          child: InkWell(
            onTap: navigateToDetails,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_shipping_outlined,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          statusLabel,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (destinationLabel.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            l10n.homeActiveParcelSubtitleToDestination(
                              destinationLabel,
                            ),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.homeActiveParcelViewShipmentCta,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


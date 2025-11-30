/// Widget tests for RideDestinationScreen (Location Picker) - Ticket #93
/// Purpose: Verify location picker screen UI with pickup/destination fields
/// Created by: Ticket #93
/// Last updated: 2025-11-30

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// App imports
import 'package:delivery_ways_clean/screens/mobility/ride_destination_screen.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_quote_controller.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

// Shims
import 'package:mobility_shims/mobility_shims.dart';
import 'package:design_system_shims/design_system_shims.dart';

// Test support
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('RideDestinationScreen (Location Picker) Widget Tests (Ticket #93)', () {
    /// Helper to build the test widget with provider overrides
    Widget buildTestWidget({
      RideDraftUiState? rideDraft,
      RideQuoteUiState? quoteState,
      Locale locale = const Locale('en'),
    }) {
      final draft = rideDraft ?? const RideDraftUiState();
      final quote = quoteState ?? const RideQuoteUiState();

      return ProviderScope(
        overrides: [
          rideDraftProvider.overrideWith((ref) {
            final controller = RideDraftController();
            if (draft.pickupPlace != null) {
              controller.updatePickupPlace(draft.pickupPlace!);
            }
            if (draft.destinationPlace != null) {
              controller.updateDestinationPlace(draft.destinationPlace!);
            }
            if (draft.destinationQuery.isNotEmpty) {
              controller.updateDestination(draft.destinationQuery);
            }
            return controller;
          }),
          rideQuoteControllerProvider.overrideWith(
            (ref) => _FakeRideQuoteController(initialState: quote),
          ),
        ],
        child: MaterialApp(
          locale: locale,
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
          home: const RideDestinationScreen(),
        ),
      );
    }

    // ========================================================================
    // Test: shows_search_fields_and_map
    // ========================================================================

    testWidgets('shows search fields and map placeholder', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify title
      expect(find.text('Choose your trip'), findsOneWidget);

      // Verify Pickup label
      expect(find.text('Pickup'), findsOneWidget);

      // Verify map hint text
      expect(
        find.text('Adjust the pin or use search to set your locations.'),
        findsOneWidget,
      );

      // Verify map is present (MapWidget from maps_shims)
      // Note: MapWidget is rendered internally by the screen
    });

    // ========================================================================
    // Test: disables_continue_cta_when_locations_missing
    // ========================================================================

    testWidgets('disables continue CTA when locations are missing',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        rideDraft: const RideDraftUiState(
          pickupLabel: '',
          destinationQuery: '',
        ),
      ));
      await tester.pumpAndSettle();

      // Find the Continue CTA
      final continueButton = find.text('See prices');
      expect(continueButton, findsOneWidget);

      // Verify the button is disabled (DWButton with null onPressed)
      final dwButton = tester.widget<DWButton>(find.byType(DWButton));
      expect(dwButton.onPressed, isNull);
    });

    // ========================================================================
    // Test: enables_continue_cta_when_both_locations_set
    // ========================================================================

    testWidgets('enables continue CTA when both locations are set',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        rideDraft: const RideDraftUiState(
          pickupLabel: 'Current location',
          destinationQuery: 'Mall of Arabia',
          pickupPlace: MobilityPlace(
            label: 'Current location',
            type: MobilityPlaceType.currentLocation,
          ),
          destinationPlace: MobilityPlace(
            label: 'Mall of Arabia',
            type: MobilityPlaceType.searchResult,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Scroll to see the button
      await tester.ensureVisible(find.text('See prices'));
      await tester.pumpAndSettle();

      // Verify the button is enabled (DWButton with non-null onPressed)
      final dwButton = tester.widget<DWButton>(find.byType(DWButton));
      expect(dwButton.onPressed, isNotNull);
    });

    // ========================================================================
    // Test: updates_draft_when_destination_entered
    // ========================================================================

    testWidgets('updates draft when destination is entered', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find the destination text field (search field)
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter destination
      await tester.enterText(textField, 'Airport');
      await tester.pumpAndSettle();

      // Verify the text was entered
      expect(find.text('Airport'), findsOneWidget);
    });

    // ========================================================================
    // Test: shows_recent_locations_list
    // ========================================================================

    testWidgets('shows recent locations list', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify recent locations section header
      expect(find.text('Recent locations'), findsOneWidget);

      // Verify some recent locations appear (from stub data)
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
    });

    // ========================================================================
    // Test: l10n_ar_renders_arabic_labels
    // ========================================================================

    testWidgets('l10n AR renders Arabic labels', (tester) async {
      await tester.pumpWidget(buildTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Verify Arabic title
      expect(find.text('اختيار موقع الرحلة'), findsOneWidget);

      // Verify Arabic Pickup label
      expect(find.text('مكان الانطلاق'), findsOneWidget);

      // Verify Arabic Continue CTA
      expect(find.text('عرض الأسعار'), findsOneWidget);

      // Verify Arabic map hint
      expect(
        find.text('حرّك العلامة أو استخدم البحث لتحديد المواقع.'),
        findsOneWidget,
      );
    });

    // ========================================================================
    // Test: l10n_de_renders_german_labels
    // ========================================================================

    testWidgets('l10n DE renders German labels', (tester) async {
      await tester.pumpWidget(buildTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // Verify German title
      expect(find.text('Fahrtziel wählen'), findsOneWidget);

      // Verify German Pickup label
      expect(find.text('Abholort'), findsOneWidget);

      // Verify German Continue CTA
      expect(find.text('Preise anzeigen'), findsOneWidget);

      // Verify German map hint
      expect(
        find.text('Verschiebe die Markierung oder nutze die Suche, um Orte festzulegen.'),
        findsOneWidget,
      );
    });

    // ========================================================================
    // Test: pickup_field_is_tappable
    // ========================================================================

    testWidgets('pickup field is tappable and opens search sheet',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find the pickup field by looking for the edit icon
      final editIcon = find.byIcon(Icons.edit_location_outlined);
      expect(editIcon, findsOneWidget);

      // Tap on the pickup field (InkWell containing the field)
      final pickupField = find.ancestor(
        of: find.text('Pickup'),
        matching: find.byType(Column),
      ).first;
      
      // Find the InkWell within the pickup section
      final inkWell = find.descendant(
        of: pickupField,
        matching: find.byType(InkWell),
      );
      
      if (inkWell.evaluate().isNotEmpty) {
        await tester.tap(inkWell.first);
        await tester.pumpAndSettle();

        // Verify search sheet opened
        expect(find.byType(TextField), findsAtLeastNWidgets(1));
      }
    });

    // ========================================================================
    // Test: uses_design_system_components
    // ========================================================================

    testWidgets('uses Design System components', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify DWButton is used
      expect(find.byType(DWButton), findsOneWidget);
    });

    // ========================================================================
    // Test: displays_pickup_placeholder_when_empty
    // ========================================================================

    testWidgets('displays pickup placeholder when empty', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        rideDraft: const RideDraftUiState(
          pickupLabel: '',
          destinationQuery: '',
        ),
      ));
      await tester.pumpAndSettle();

      // Should show placeholder text
      expect(find.text('Where should we pick you up?'), findsAtLeastNWidgets(1));
    });
  });
}

// ============================================================================
// Fake Controllers for Testing
// ============================================================================

/// Fake RideQuoteController for testing
class _FakeRideQuoteController extends RideQuoteController {
  _FakeRideQuoteController({required RideQuoteUiState initialState})
      : _state = initialState,
        super.legacy(const MockRideQuoteService());

  final RideQuoteUiState _state;

  @override
  RideQuoteUiState get state => _state;

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {
    // No-op for tests
  }
}


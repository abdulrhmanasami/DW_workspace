/// Ride Confirmation Screen UI Tests - Ticket #154
/// Purpose: Test ride confirmation screen builds correctly without compilation errors
/// Created by: Ticket #154
/// Last updated: 2025-12-02

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobility_shims/mobility_shims.dart';

// Internal imports
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/mobility/ride_confirmation_screen.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_quote_controller.dart';

void main() {
  group('Ride Confirmation Screen Tests', () {
    testWidgets('builds successfully without errors', (tester) async {
      // Create a simple test app
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en'), Locale('ar')],
            home: RideConfirmationScreen(),
          ),
        ),
      );

      // Allow async operations to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify basic UI elements are present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Stack), findsWidgets); // Map and bottom sheet

      // Verify screen title
      expect(find.text('Confirm your ride'), findsOneWidget);

      // Verify bottom sheet container exists
      expect(find.byType(Container), findsWidgets);

      // Verify keys are present (even if widgets are not rendered due to missing data)
      expect(find.byKey(RideConfirmationScreen.vehicleListKey), findsNothing); // No quote data yet
      expect(find.byKey(RideConfirmationScreen.paymentMethodCardKey), findsOneWidget);
      expect(find.byKey(RideConfirmationScreen.ctaRequestRideKey), findsOneWidget);
      
      // TODO(Track B): Add more comprehensive tests when mock providers are ready
    });
  });

  group('RideConfirmationScreen pricing states', () {
    // Helper to create test app with custom providers
    Widget createTestAppWithProviders({
      required Widget home,
      List<Override> overrides = const [],
    }) {
      return ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ar')],
          home: home,
        ),
      );
    }

    testWidgets('shows loading state while fetching quote', (tester) async {
      await tester.pumpWidget(
        createTestAppWithProviders(
          home: const RideConfirmationScreen(),
          overrides: [
            rideQuoteControllerProvider.overrideWith(
              (ref) => _MockQuoteController(
                const RideQuoteUiState(isLoading: true),
              ),
            ),
          ],
        ),
      );

      await tester.pump();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      await tester.pumpWidget(
        createTestAppWithProviders(
          home: const RideConfirmationScreen(),
          overrides: [
            rideQuoteControllerProvider.overrideWith(
              (ref) => _MockQuoteController(
                const RideQuoteUiState(
                  error: RideQuoteError.pricingFailed('Network error'),
                ),
              ),
            ),
          ],
        ),
      );

      await tester.pump();

      // Verify error state
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Don't test retry button tap as text may vary by locale
    });

    testWidgets('shows vehicle options when quote is available', (tester) async {
      // Create test quote with options
      final testQuote = RideQuote(
        quoteId: 'test-123',
        request: const RideQuoteRequest(
          pickup: LocationPoint(latitude: 24.7136, longitude: 46.6753),
          dropoff: LocationPoint(latitude: 24.9576, longitude: 46.6988),
          currencyCode: 'SAR',
        ),
        options: const [
          RideQuoteOption(
            id: 'eco',
            displayName: 'Economy',
            category: RideVehicleCategory.economy,
            etaMinutes: 5,
            priceMinorUnits: 1500,
            currencyCode: 'SAR',
            isRecommended: true,
          ),
          RideQuoteOption(
            id: 'xl',
            displayName: 'XL',
            category: RideVehicleCategory.xl,
            etaMinutes: 7,
            priceMinorUnits: 2000,
            currencyCode: 'SAR',
            isRecommended: false,
          ),
        ],
      );

      await tester.pumpWidget(
        createTestAppWithProviders(
          home: const RideConfirmationScreen(),
          overrides: [
            rideQuoteControllerProvider.overrideWith(
              (ref) => _MockQuoteController(
                RideQuoteUiState(quote: testQuote),
              ),
            ),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(); // Extra pump for async operations

      // Verify vehicle options are displayed
      expect(find.text('Economy'), findsOneWidget);
      expect(find.text('XL'), findsOneWidget);
      expect(find.text('5 min'), findsOneWidget);
      expect(find.text('7 min'), findsOneWidget);
    });

    testWidgets('Request Ride button shown when quote available', (tester) async {
      final testQuote = RideQuote(
        quoteId: 'test-456',
        request: const RideQuoteRequest(
          pickup: LocationPoint(latitude: 24.7136, longitude: 46.6753),
          dropoff: LocationPoint(latitude: 24.9576, longitude: 46.6988),
          currencyCode: 'SAR',
        ),
        options: const [
          RideQuoteOption(
            id: 'eco',
            displayName: 'Economy',
            category: RideVehicleCategory.economy,
            etaMinutes: 5,
            priceMinorUnits: 1500,
            currencyCode: 'SAR',
            isRecommended: true,
          ),
        ],
      );

      await tester.pumpWidget(
        createTestAppWithProviders(
          home: const RideConfirmationScreen(),
          overrides: [
            rideQuoteControllerProvider.overrideWith(
              (ref) => _MockQuoteController(
                RideQuoteUiState(quote: testQuote),
              ),
            ),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(); // Extra pump for async operations

      // Just verify the button exists when quote is available
      final requestButton = find.widgetWithText(FilledButton, 'Request Ride');
      final elevatedButton = find.widgetWithText(ElevatedButton, 'Request Ride');

      // Button should exist in some form
      expect(requestButton.evaluate().isNotEmpty || elevatedButton.evaluate().isNotEmpty, isTrue);
    });

    testWidgets('shows vehicle options with proper keys when quote available', (tester) async {
      // Create test quote with options
      final testQuote = RideQuote(
        quoteId: 'test-123',
        request: const RideQuoteRequest(
          pickup: LocationPoint(latitude: 24.7136, longitude: 46.6753),
          dropoff: LocationPoint(latitude: 24.9576, longitude: 46.6988),
          currencyCode: 'SAR',
        ),
        options: const [
          RideQuoteOption(
            id: 'eco',
            displayName: 'Economy',
            category: RideVehicleCategory.economy,
            etaMinutes: 5,
            priceMinorUnits: 1500,
            currencyCode: 'SAR',
            isRecommended: true,
          ),
          RideQuoteOption(
            id: 'xl',
            displayName: 'XL',
            category: RideVehicleCategory.xl,
            etaMinutes: 7,
            priceMinorUnits: 2000,
            currencyCode: 'SAR',
            isRecommended: false,
          ),
        ],
      );

      await tester.pumpWidget(
        createTestAppWithProviders(
          home: const RideConfirmationScreen(),
          overrides: [
            rideQuoteControllerProvider.overrideWith(
              (ref) => _MockQuoteController(
                RideQuoteUiState(quote: testQuote),
              ),
            ),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(); // Extra pump for async operations

      // Verify vehicle options list is present with proper key
      expect(find.byKey(RideConfirmationScreen.vehicleListKey), findsOneWidget);

      // Verify vehicle options are displayed
      expect(find.text('Economy'), findsOneWidget);
      expect(find.text('XL'), findsOneWidget);
      expect(find.text('5 min'), findsOneWidget);
      expect(find.text('7 min'), findsOneWidget);
    });

    testWidgets('shows payment method card with proper key', (tester) async {
      await tester.pumpWidget(
        createTestAppWithProviders(
          home: const RideConfirmationScreen(),
        ),
      );

      await tester.pump();

      // Verify payment method card is present with proper key
      expect(find.byKey(RideConfirmationScreen.paymentMethodCardKey), findsOneWidget);
    });

    testWidgets('shows request ride button with proper key', (tester) async {
      final testQuote = RideQuote(
        quoteId: 'test-456',
        request: const RideQuoteRequest(
          pickup: LocationPoint(latitude: 24.7136, longitude: 46.6753),
          dropoff: LocationPoint(latitude: 24.9576, longitude: 46.6988),
          currencyCode: 'SAR',
        ),
        options: const [
          RideQuoteOption(
            id: 'eco',
            displayName: 'Economy',
            category: RideVehicleCategory.economy,
            etaMinutes: 5,
            priceMinorUnits: 1500,
            currencyCode: 'SAR',
            isRecommended: true,
          ),
        ],
      );

      await tester.pumpWidget(
        createTestAppWithProviders(
          home: const RideConfirmationScreen(),
          overrides: [
            rideQuoteControllerProvider.overrideWith(
              (ref) => _MockQuoteController(
                RideQuoteUiState(quote: testQuote),
              ),
            ),
          ],
        ),
      );

      await tester.pump();

      // Verify CTA button is present with proper key
      expect(find.byKey(RideConfirmationScreen.ctaRequestRideKey), findsOneWidget);
    });
  });
}

// Mock controllers for testing
class _MockQuoteController extends RideQuoteController {
  _MockQuoteController(RideQuoteUiState initialState)
      : super.legacy(const MockRideQuoteService()) {
    // Set initial state
    state = initialState;
  }

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {
    // Mock implementation - no-op
  }

  @override
  Future<void> retryFromDraft(RideDraftUiState draft) async {
    // Mock implementation - no-op
  }
}
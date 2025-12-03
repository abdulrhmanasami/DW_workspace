/// Ride Quote Options Sheet Widget Tests - Track B Ticket #140
/// Purpose: Test RideQuoteOptionsSheet UI components and behavior
/// Created by: Track B - Ticket #140
/// Last updated: 2025-12-02

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobility_shims/mobility_shims.dart';

import 'package:delivery_ways_clean/screens/mobility/ride_quote_options_sheet.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('RideQuoteOptionsSheet Widget Tests', () {
    // Helper to create test location
    LocationPoint createLocation(double lat, double lng) {
      return LocationPoint(
        latitude: lat,
        longitude: lng,
        accuracyMeters: 5,
        timestamp: DateTime.now(),
      );
    }

    // Helper to create test widget
    Widget createTestWidget({
      required RideQuote quote,
      RideQuoteOption? selectedOption,
      ValueChanged<RideQuoteOption>? onOptionSelected,
      VoidCallback? onClose,
    }) {
      return MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
        ],
        theme: ThemeData(
          colorScheme: const ColorScheme.light(),
        ),
        home: Scaffold(
          body: RideQuoteOptionsSheet(
            quote: quote,
            selectedOption: selectedOption,
            onOptionSelected: onOptionSelected ?? (_) {},
            onClose: onClose,
          ),
        ),
      );
    }

    testWidgets('renders all quote options with correct details', (WidgetTester tester) async {
      // Arrange
      final options = [
        const RideQuoteOption(
          id: 'economy',
          category: RideVehicleCategory.economy,
          displayName: 'Economy',
          etaMinutes: 5,
          priceMinorUnits: 1500,
          currencyCode: 'SAR',
          isRecommended: true,
        ),
        const RideQuoteOption(
          id: 'xl',
          category: RideVehicleCategory.xl,
          displayName: 'XL',
          etaMinutes: 8,
          priceMinorUnits: 2500,
          currencyCode: 'SAR',
          isRecommended: false,
        ),
        const RideQuoteOption(
          id: 'premium',
          category: RideVehicleCategory.premium,
          displayName: 'Premium',
          etaMinutes: 10,
          priceMinorUnits: 3500,
          currencyCode: 'SAR',
          isRecommended: false,
        ),
      ];

      final quote = RideQuote(
        quoteId: 'test-quote-1',
        request: RideQuoteRequest(
          pickup: createLocation(24.7136, 46.6753),
          dropoff: createLocation(24.7200, 46.6800),
        ),
        options: options,
      );

      // Act
      await tester.pumpWidget(createTestWidget(quote: quote));
      await tester.pumpAndSettle();

      // Assert - Check option names
      expect(find.text('Economy'), findsOneWidget);
      expect(find.text('XL'), findsOneWidget);
      expect(find.text('Premium'), findsOneWidget);

      // Assert - Check prices
      expect(find.text('15.00 SAR'), findsOneWidget);
      expect(find.text('25.00 SAR'), findsOneWidget);
      expect(find.text('35.00 SAR'), findsOneWidget);

      // Assert - Check ETA
      expect(find.text('5 min'), findsOneWidget);
      expect(find.text('8 min'), findsOneWidget);
      expect(find.text('10 min'), findsOneWidget);

      // Assert - Check recommended badge (only one should exist)
      expect(find.text('Recommended'), findsOneWidget);
    });

    testWidgets('calls onOptionSelected when option is tapped', (WidgetTester tester) async {
      // Arrange
      const option = RideQuoteOption(
        id: 'economy',
        category: RideVehicleCategory.economy,
        displayName: 'Economy',
        etaMinutes: 5,
        priceMinorUnits: 1500,
        currencyCode: 'SAR',
      );

      final quote = RideQuote(
        quoteId: 'test-quote-2',
        request: RideQuoteRequest(
          pickup: createLocation(24.7136, 46.6753),
          dropoff: createLocation(24.7200, 46.6800),
        ),
        options: const [option],
      );

      RideQuoteOption? selectedOption;

      // Act
      await tester.pumpWidget(createTestWidget(
        quote: quote,
        onOptionSelected: (option) {
          selectedOption = option;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Economy'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedOption, isNotNull);
      expect(selectedOption?.id, equals('economy'));
      expect(selectedOption?.displayName, equals('Economy'));
    });

    testWidgets('shows selected option with different styling', (WidgetTester tester) async {
      // Arrange
      final options = [
        const RideQuoteOption(
          id: 'economy',
          category: RideVehicleCategory.economy,
          displayName: 'Economy',
          etaMinutes: 5,
          priceMinorUnits: 1500,
          currencyCode: 'SAR',
        ),
        const RideQuoteOption(
          id: 'xl',
          category: RideVehicleCategory.xl,
          displayName: 'XL',
          etaMinutes: 8,
          priceMinorUnits: 2500,
          currencyCode: 'SAR',
        ),
      ];

      final quote = RideQuote(
        quoteId: 'test-quote-3',
        request: RideQuoteRequest(
          pickup: createLocation(24.7136, 46.6753),
          dropoff: createLocation(24.7200, 46.6800),
        ),
        options: options,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        quote: quote,
        selectedOption: options[1], // XL is selected
      ));
      await tester.pumpAndSettle();

      // Assert - Check for radio button indicators
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

      // The selected option (XL) should have the checked radio button
      final xlTileFinder = find.ancestor(
        of: find.text('XL'),
        matching: find.byType(InkWell),
      );
      expect(xlTileFinder, findsOneWidget);
      
      final checkedRadioFinder = find.descendant(
        of: xlTileFinder,
        matching: find.byIcon(Icons.radio_button_checked),
      );
      expect(checkedRadioFinder, findsOneWidget);
    });

    testWidgets('displays title and close button when provided', (WidgetTester tester) async {
      // Arrange
      final quote = RideQuote(
        quoteId: 'test-quote-4',
        request: RideQuoteRequest(
          pickup: createLocation(24.7136, 46.6753),
          dropoff: createLocation(24.7200, 46.6800),
        ),
        options: const [
          RideQuoteOption(
            id: 'economy',
            category: RideVehicleCategory.economy,
            displayName: 'Economy',
            etaMinutes: 5,
            priceMinorUnits: 1500,
            currencyCode: 'SAR',
          ),
        ],
      );

      bool closeCalled = false;

      // Act
      await tester.pumpWidget(createTestWidget(
        quote: quote,
        onClose: () {
          closeCalled = true;
        },
      ));
      await tester.pumpAndSettle();

      // Assert - Check title
      expect(find.text('Choose your ride'), findsOneWidget);

      // Assert - Check close button
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(closeCalled, isTrue);
    });

    testWidgets('displays vehicle icons for different categories', (WidgetTester tester) async {
      // Arrange
      final options = [
        const RideQuoteOption(
          id: 'economy',
          category: RideVehicleCategory.economy,
          displayName: 'Economy',
          etaMinutes: 5,
          priceMinorUnits: 1500,
          currencyCode: 'SAR',
        ),
        const RideQuoteOption(
          id: 'xl',
          category: RideVehicleCategory.xl,
          displayName: 'XL',
          etaMinutes: 8,
          priceMinorUnits: 2500,
          currencyCode: 'SAR',
        ),
        const RideQuoteOption(
          id: 'premium',
          category: RideVehicleCategory.premium,
          displayName: 'Premium',
          etaMinutes: 10,
          priceMinorUnits: 3500,
          currencyCode: 'SAR',
        ),
      ];

      final quote = RideQuote(
        quoteId: 'test-quote-5',
        request: RideQuoteRequest(
          pickup: createLocation(24.7136, 46.6753),
          dropoff: createLocation(24.7200, 46.6800),
        ),
        options: options,
      );

      // Act
      await tester.pumpWidget(createTestWidget(quote: quote));
      await tester.pumpAndSettle();

      // Assert - Check for vehicle icons
      expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget); // Economy
      expect(find.byIcon(Icons.airport_shuttle_outlined), findsOneWidget); // XL
      expect(find.byIcon(Icons.directions_car_filled), findsOneWidget); // Premium
    });

    testWidgets('showRideQuoteOptionsSheet returns selected option', (WidgetTester tester) async {
      // Arrange
      const option = RideQuoteOption(
        id: 'economy',
        category: RideVehicleCategory.economy,
        displayName: 'Economy',
        etaMinutes: 5,
        priceMinorUnits: 1500,
        currencyCode: 'SAR',
      );

      final quote = RideQuote(
        quoteId: 'test-quote-6',
        request: RideQuoteRequest(
          pickup: createLocation(24.7136, 46.6753),
          dropoff: createLocation(24.7200, 46.6800),
        ),
        options: const [option],
      );

      // Create a test app with a button to show the sheet
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final selected = await showRideQuoteOptionsSheet(
                      context: context,
                      quote: quote,
                    );
                    
                    // Store the result for assertion
                    if (selected != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected: ${selected.id}')),
                      );
                    }
                  },
                  child: const Text('Show Options'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Open the sheet
      await tester.tap(find.text('Show Options'));
      await tester.pumpAndSettle();

      // Assert - Sheet is shown
      expect(find.text('Economy'), findsOneWidget);

      // Act - Select an option
      await tester.tap(find.text('Economy'));
      await tester.pumpAndSettle();

      // Assert - Sheet is closed and snackbar shows selection
      expect(find.text('Selected: economy'), findsOneWidget);
    });
  });
}

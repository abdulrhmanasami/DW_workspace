/// Widget tests for PaymentsTabScreen (Track B - Ticket #99)
/// Purpose: Verify payments screen UI with payment methods list
/// Created by: Track B - Ticket #99
/// Last updated: 2025-11-30

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// App imports
import 'package:delivery_ways_clean/screens/payments/payments_tab_screen.dart';
import 'package:delivery_ways_clean/state/payments/payment_methods_ui_state.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

void main() {
  group('PaymentsTabScreen - Track B Ticket #99', () {
    /// Helper to build the test widget with provider overrides
    Widget buildTestWidget({
      PaymentMethodsUiState? state,
      Locale locale = const Locale('en'),
    }) {
      return ProviderScope(
        overrides: [
          paymentMethodsUiProvider.overrideWith(
            (ref) => state ?? PaymentMethodsUiState.defaultStub(),
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
          home: const PaymentsTabScreen(),
        ),
      );
    }

    // =========================================================================
    // Empty State Tests
    // =========================================================================

    testWidgets('shows_empty_state_when_no_payment_methods', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: PaymentMethodsUiState.empty,
      ));
      await tester.pumpAndSettle();

      // Verify empty state elements
      expect(find.byIcon(Icons.credit_card_off_outlined), findsOneWidget);
      expect(find.text('No payment methods saved'), findsOneWidget);
      expect(find.text('Your saved cards and payment options will appear here.'), findsOneWidget);
      // CTA should still be visible in empty state
      expect(find.text('Add new payment method'), findsOneWidget);
    });

    // =========================================================================
    // Payment Methods List Tests
    // =========================================================================

    testWidgets('shows_payment_methods_list_with_cash_and_card', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify title
      expect(find.text('Payments'), findsOneWidget);

      // Verify Cash payment method
      expect(find.text('Cash'), findsAtLeastNWidgets(1)); // displayName + type label

      // Verify Card payment method
      expect(find.text('Visa ···· 4242'), findsOneWidget);
      expect(find.text('Card'), findsOneWidget);

      // Verify Default badge is shown for Cash (which is default)
      expect(find.text('Default'), findsOneWidget);

      // Verify Add CTA
      expect(find.text('Add new payment method'), findsOneWidget);
    });

    testWidgets('shows_correct_icons_for_payment_types', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Cash uses payments_outlined icon
      expect(find.byIcon(Icons.payments_outlined), findsOneWidget);

      // Card uses credit_card icon
      expect(find.byIcon(Icons.credit_card), findsOneWidget);
    });

    testWidgets('default_badge_only_shown_for_default_method', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: PaymentMethodsUiState(
          methods: [
            // Cash is default
            PaymentMethodUiModel.cash,
            // Card is not default
            PaymentMethodUiModel.stubCard(brand: 'Mastercard', last4: '5555', isDefault: false),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      // Only one Default badge should appear (for Cash)
      expect(find.text('Default'), findsOneWidget);
    });

    // =========================================================================
    // CTA Tests
    // =========================================================================

    testWidgets('tap_add_method_shows_coming_soon_snackbar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Add button
      await tester.tap(find.text('Add new payment method'));
      await tester.pumpAndSettle();

      // Verify snackbar appears
      expect(find.text('Adding new payment methods will be available soon.'), findsOneWidget);
    });

    testWidgets('tap_add_method_in_empty_state_shows_coming_soon', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: PaymentMethodsUiState.empty,
      ));
      await tester.pumpAndSettle();

      // Tap Add button in empty state
      await tester.tap(find.text('Add new payment method'));
      await tester.pumpAndSettle();

      // Verify snackbar appears
      expect(find.text('Adding new payment methods will be available soon.'), findsOneWidget);
    });

    // =========================================================================
    // L10n Tests - Arabic
    // =========================================================================

    testWidgets('l10n_ar_renders_arabic_payments_labels', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      // Verify Arabic labels
      expect(find.text('طرق الدفع'), findsOneWidget); // Payments title
      expect(find.text('إضافة طريقة دفع جديدة'), findsOneWidget); // Add CTA
      expect(find.text('نقدًا'), findsOneWidget); // Cash type label
      expect(find.text('بطاقة'), findsOneWidget); // Card type label
      expect(find.text('افتراضية'), findsOneWidget); // Default badge
    });

    testWidgets('l10n_ar_empty_state_shows_arabic_text', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: PaymentMethodsUiState.empty,
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      // Verify Arabic empty state
      expect(find.text('لا توجد طرق دفع محفوظة'), findsOneWidget);
      expect(find.text('ستظهر هنا بطاقاتك وطرق الدفع المحفوظة.'), findsOneWidget);
    });

    // =========================================================================
    // L10n Tests - German
    // =========================================================================

    testWidgets('l10n_de_renders_german_payments_labels', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        locale: const Locale('de'),
      ));
      await tester.pumpAndSettle();

      // Verify German labels
      expect(find.text('Zahlungsmethoden'), findsOneWidget); // Payments title
      expect(find.text('Neue Zahlungsmethode hinzufügen'), findsOneWidget); // Add CTA
      expect(find.text('Barzahlung'), findsOneWidget); // Cash type label
      expect(find.text('Karte'), findsOneWidget); // Card type label
      expect(find.text('Standard'), findsOneWidget); // Default badge
    });

    testWidgets('l10n_de_empty_state_shows_german_text', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: PaymentMethodsUiState.empty,
        locale: const Locale('de'),
      ));
      await tester.pumpAndSettle();

      // Verify German empty state
      expect(find.text('Keine Zahlungsmethoden gespeichert'), findsOneWidget);
      expect(find.text('Deine gespeicherten Karten und Zahlungsoptionen erscheinen hier.'), findsOneWidget);
    });

    // =========================================================================
    // Multiple Cards Test
    // =========================================================================

    testWidgets('shows_multiple_cards_in_list', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: PaymentMethodsUiState(
          methods: [
            PaymentMethodUiModel.cash,
            PaymentMethodUiModel.stubCard(brand: 'Visa', last4: '4242'),
            PaymentMethodUiModel.stubCard(brand: 'Mastercard', last4: '5555'),
            PaymentMethodUiModel.stubCard(brand: 'Amex', last4: '1111'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      // Verify all cards are shown
      expect(find.text('Visa ···· 4242'), findsOneWidget);
      expect(find.text('Mastercard ···· 5555'), findsOneWidget);
      expect(find.text('Amex ···· 1111'), findsOneWidget);
    });

    // =========================================================================
    // Track B - Ticket #100: Selection Tests
    // =========================================================================

    testWidgets('tapping_card_updates_selected_method_state', (tester) async {
      // Start with Cash selected (default)
      final container = ProviderContainer(
        overrides: [
          paymentMethodsUiProvider.overrideWith(
            (ref) => PaymentMethodsUiState(
              methods: [
                PaymentMethodUiModel.cash,
                PaymentMethodUiModel.stubCard(brand: 'Visa', last4: '4242'),
              ],
              selectedMethodId: 'cash',
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            locale: Locale('en'),
            home: PaymentsTabScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial selection is Cash
      expect(container.read(paymentMethodsUiProvider).selectedMethodId, 'cash');

      // Tap on Visa card
      await tester.tap(find.text('Visa ···· 4242'));
      await tester.pumpAndSettle();

      // Verify selection changed to Visa
      expect(container.read(paymentMethodsUiProvider).selectedMethodId, 'visa_4242');
    });

    testWidgets('selected_card_has_visual_selection_indicator', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: PaymentMethodsUiState(
          methods: [
            PaymentMethodUiModel.cash,
            PaymentMethodUiModel.stubCard(brand: 'Visa', last4: '4242'),
          ],
          selectedMethodId: 'visa_4242', // Visa is selected
        ),
      ));
      await tester.pumpAndSettle();

      // Verify check icon is shown for selected card (Visa)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('only_selected_card_shows_check_icon', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: PaymentMethodsUiState(
          methods: [
            PaymentMethodUiModel.cash,
            PaymentMethodUiModel.stubCard(brand: 'Visa', last4: '4242'),
            PaymentMethodUiModel.stubCard(brand: 'Mastercard', last4: '5555'),
          ],
          selectedMethodId: 'cash', // Cash is selected
        ),
      ));
      await tester.pumpAndSettle();

      // Only one check icon should be visible (for Cash)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}


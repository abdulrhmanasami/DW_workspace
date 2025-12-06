import 'package:auth_shims/auth_shims.dart';
import 'package:delivery_ways_clean/app_shell/app_shell.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/orders/orders_history_screen.dart';
import 'package:delivery_ways_clean/screens/profile/profile_tab_screen.dart';
import 'package:delivery_ways_clean/state/identity/identity_controller.dart';
import 'package:delivery_ways_clean/state/identity/identity_state.dart';
import 'package:delivery_ways_clean/widgets/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_shims/providers/onboarding_prefs_providers.dart';

class _FakeIdentityController extends StateNotifier<IdentityControllerState> {
  _FakeIdentityController(super.state);
}

void main() {
  testWidgets('navigation smoke: authed user sees app shell and can switch tabs',
      (tester) async {
    final authedState = IdentityControllerState(
      session: IdentitySession(
        status: AuthStatus.authenticated,
        user: IdentityUser(userId: 'u1'),
        tokens: const AuthTokens(accessToken: 'token'),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Force onboarding as completed
          onboardingStatusProvider.overrideWith(
            (_) async => OnboardingStatus.completed,
          ),
          // Provide authenticated identity state
          identityControllerProvider.overrideWith(
            (_) => _FakeIdentityController(authedState),
          ),
        ],
        child: MaterialApp(
          home: const AuthGate(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // AppShell should be visible
    expect(find.byType(AppShell), findsOneWidget);

    // Switch to Orders tab
    await tester.tap(find.textContaining('Orders'));
    await tester.pumpAndSettle();
    expect(find.byType(OrdersHistoryScreen), findsOneWidget);

    // Switch to Profile tab
    await tester.tap(find.textContaining('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileTabScreen), findsOneWidget);
  });
}


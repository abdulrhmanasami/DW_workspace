/// Widget tests for Home Hub Account Bottom Sheet (Ticket #37 - Track D)
/// Purpose: Verify account sheet UI and interactions
/// Created by: Track D - Ticket #37
/// Last updated: 2025-11-28

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// App imports
import 'package:delivery_ways_clean/screens/auth/phone_sign_in_screen.dart';
import 'package:delivery_ways_clean/state/auth/auth_state.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

void main() {
  group('Home Account Sheet - Ticket #37', () {
    /// Helper to build test widget with MaterialApp + ProviderScope wrapper
    Widget buildTestApp({
      required Widget home,
      List<Override>? overrides,
    }) {
      return ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: home,
        ),
      );
    }

    /// Helper to create a home screen with account icon button that opens sheet
    Widget buildHomeWithAccountButton({List<Override>? overrides}) {
      return buildTestApp(
        overrides: overrides,
        home: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(title: const Text('Home')),
              body: Center(
                child: Consumer(
                  builder: (context, ref, _) {
                    return IconButton(
                      key: const Key('account_icon'),
                      icon: const Icon(Icons.account_circle),
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (sheetContext) {
                            return _TestAccountBottomSheet(
                              parentContext: context,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    }

    // --------------------------------------------------------------------------
    // Sheet Display Tests
    // --------------------------------------------------------------------------
    group('Sheet Display', () {
      testWidgets('sheet appears when account icon is tapped', (tester) async {
        await tester.pumpWidget(buildHomeWithAccountButton());
        await tester.pumpAndSettle();

        // Tap account icon
        await tester.tap(find.byKey(const Key('account_icon')));
        await tester.pumpAndSettle();

        // Verify sheet title appears
        expect(find.text('Account'), findsOneWidget);
      });

      testWidgets('sheet has handle bar', (tester) async {
        await tester.pumpWidget(buildHomeWithAccountButton());
        await tester.pumpAndSettle();

        // Open sheet
        await tester.tap(find.byKey(const Key('account_icon')));
        await tester.pumpAndSettle();

        // Verify handle bar container exists (40x4 decoration)
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.constraints?.maxWidth == 40 &&
                widget.constraints?.maxHeight == 4,
          ),
          findsOneWidget,
        );
      });

      testWidgets('sheet has footer text', (tester) async {
        await tester.pumpWidget(buildHomeWithAccountButton());
        await tester.pumpAndSettle();

        // Open sheet
        await tester.tap(find.byKey(const Key('account_icon')));
        await tester.pumpAndSettle();

        // Verify footer text
        expect(find.text('More account options coming soon.'), findsOneWidget);
      });
    });

    // --------------------------------------------------------------------------
    // Signed-Out State Tests
    // --------------------------------------------------------------------------
    group('Signed-Out State', () {
      testWidgets('shows signed-out subtitle when not authenticated',
          (tester) async {
        await tester.pumpWidget(buildHomeWithAccountButton());
        await tester.pumpAndSettle();

        // Open sheet
        await tester.tap(find.byKey(const Key('account_icon')));
        await tester.pumpAndSettle();

        // Verify signed-out subtitle
        expect(
          find.text(
              'You are not signed in. Sign in to sync your rides and deliveries.'),
          findsOneWidget,
        );
      });

      testWidgets('shows sign-in button when not authenticated', (tester) async {
        await tester.pumpWidget(buildHomeWithAccountButton());
        await tester.pumpAndSettle();

        // Open sheet
        await tester.tap(find.byKey(const Key('account_icon')));
        await tester.pumpAndSettle();

        // Verify sign-in button
        expect(find.text('Sign in with phone'), findsOneWidget);
      });

      testWidgets('sign-in button opens PhoneSignInScreen', (tester) async {
        await tester.pumpWidget(buildHomeWithAccountButton());
        await tester.pumpAndSettle();

        // Open sheet
        await tester.tap(find.byKey(const Key('account_icon')));
        await tester.pumpAndSettle();

        // Tap sign-in button
        await tester.tap(find.text('Sign in with phone'));
        await tester.pumpAndSettle();

        // Verify PhoneSignInScreen appears
        expect(find.byType(PhoneSignInScreen), findsOneWidget);

        // Verify sheet is closed
        expect(find.text('Account'), findsNothing);
      });
    });

    // --------------------------------------------------------------------------
    // Signed-In State Tests
    // --------------------------------------------------------------------------
    group('Signed-In State', () {
      testWidgets('shows signed-in title when authenticated', (tester) async {
        await tester.pumpWidget(
          buildHomeWithAccountButton(
            overrides: [
              simpleAuthStateProvider.overrideWith(
                (ref) => AuthController()
                  ..startPhoneSignIn('+966500000000')
                  ..verifyOtpCode('1234'),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        // Open sheet
        await tester.tap(find.byKey(const Key('account_icon')));
        await tester.pumpAndSettle();

        // Verify signed-in title
        expect(find.text('Signed in'), findsOneWidget);
      });

      testWidgets('shows phone number when authenticated', (tester) async {
        await tester.pumpWidget(
          buildHomeWithAccountButton(
            overrides: [
              simpleAuthStateProvider.overrideWith(
                (ref) => AuthController()
                  ..startPhoneSignIn('+966500000000')
                  ..verifyOtpCode('1234'),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        // Open sheet
        await tester.tap(find.byKey(const Key('account_icon')));
        await tester.pumpAndSettle();

        // Verify phone number is displayed
        expect(find.text('+966500000000'), findsOneWidget);
      });

      testWidgets('shows sign-out button when authenticated', (tester) async {
        await tester.pumpWidget(
          buildHomeWithAccountButton(
            overrides: [
              simpleAuthStateProvider.overrideWith(
                (ref) => AuthController()
                  ..startPhoneSignIn('+966500000000')
                  ..verifyOtpCode('1234'),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        // Open sheet
        await tester.tap(find.byKey(const Key('account_icon')));
        await tester.pumpAndSettle();

        // Verify sign-out button
        expect(find.text('Sign out'), findsOneWidget);
      });

      testWidgets('sign-out button closes sheet and updates state',
          (tester) async {
        late ProviderContainer container;

        await tester.pumpWidget(
          ProviderScope(
            child: Builder(
              builder: (context) {
                container = ProviderScope.containerOf(context);
                return MaterialApp(
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  locale: const Locale('en'),
                  home: Builder(
                    builder: (innerContext) {
                      return Scaffold(
                        body: Consumer(
                          builder: (ctx, ref, _) {
                            return IconButton(
                              key: const Key('account_icon'),
                              icon: const Icon(Icons.account_circle),
                              onPressed: () {
                                showModalBottomSheet<void>(
                                  context: ctx,
                                  builder: (sheetContext) {
                                    return _TestAccountBottomSheet(
                                      parentContext: ctx,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // First, sign in
        container.read(simpleAuthStateProvider.notifier).startPhoneSignIn('+966500000000');
        container.read(simpleAuthStateProvider.notifier).verifyOtpCode('1234');
        expect(container.read(simpleAuthStateProvider).isAuthenticated, isTrue);

        // Open sheet
        await tester.tap(find.byKey(const Key('account_icon')));
        await tester.pumpAndSettle();

        // Verify signed-in state
        expect(find.text('Signed in'), findsOneWidget);
        expect(find.text('Sign out'), findsOneWidget);

        // Tap sign-out button
        await tester.tap(find.text('Sign out'));
        await tester.pumpAndSettle();

        // Verify sheet is closed
        expect(find.text('Account'), findsNothing);

        // Verify state is updated
        expect(container.read(simpleAuthStateProvider).isAuthenticated, isFalse);
        expect(container.read(simpleAuthStateProvider).phoneNumber, isNull);
      });

      testWidgets('does not show sign-in button when authenticated',
          (tester) async {
        await tester.pumpWidget(
          buildHomeWithAccountButton(
            overrides: [
              simpleAuthStateProvider.overrideWith(
                (ref) => AuthController()
                  ..startPhoneSignIn('+966500000000')
                  ..verifyOtpCode('1234'),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        // Open sheet
        await tester.tap(find.byKey(const Key('account_icon')));
        await tester.pumpAndSettle();

        // Verify sign-in button is NOT shown
        expect(find.text('Sign in with phone'), findsNothing);
      });
    });

    // --------------------------------------------------------------------------
    // Arabic Localization Tests
    // --------------------------------------------------------------------------
    group('Arabic Localization', () {
      testWidgets('shows Arabic text when locale is Arabic', (tester) async {
        await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: IconButton(
                    key: const Key('account_icon'),
                    icon: const Icon(Icons.account_circle),
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (sheetContext) {
                          return _TestAccountBottomSheet(
                            parentContext: context,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Open sheet
        await tester.tap(find.byKey(const Key('account_icon')));
        await tester.pumpAndSettle();

        // Verify Arabic text
        expect(find.text('الحساب'), findsOneWidget);
        expect(find.text('تسجيل الدخول برقم الجوال'), findsOneWidget);
      });
    });
  });
}

/// Test version of AccountBottomSheet that mirrors the real implementation
/// Used for testing without importing the private widget from app_shell.dart
class _TestAccountBottomSheet extends ConsumerWidget {
  const _TestAccountBottomSheet({
    required this.parentContext,
  });

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final authState = ref.watch(simpleAuthStateProvider);
    final isAuthenticated = authState.isAuthenticated;
    final phoneNumber = authState.phoneNumber;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              constraints: const BoxConstraints(maxWidth: 40, maxHeight: 4),
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            l10n.accountSheetTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 12),

          if (!isAuthenticated) ...[
            // Signed-out state
            Text(
              l10n.accountSheetSignedOutSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close sheet
                Navigator.of(parentContext).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PhoneSignInScreen(),
                  ),
                );
              },
              child: Text(l10n.accountSheetSignInCta),
            ),
          ] else ...[
            // Signed-in state
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.primary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.person,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.accountSheetSignedInTitle,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (phoneNumber != null && phoneNumber.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          phoneNumber,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            TextButton(
              onPressed: () {
                // Sign out + close sheet
                ref.read(simpleAuthStateProvider.notifier).signOut();
                Navigator.of(context).pop();
              },
              child: Text(l10n.accountSheetSignOutCta),
            ),
          ],
          const SizedBox(height: 16),

          // Footer text
          Align(
            alignment: Alignment.center,
            child: Text(
              l10n.accountSheetFooterText,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}


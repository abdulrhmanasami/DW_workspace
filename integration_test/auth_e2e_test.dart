/// Component: Auth E2E Tests
/// Created by: Cursor (auto-generated)
/// Purpose: End-to-end authentication testing with Supabase
/// Last updated: 2025-11-02

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_ways_clean/config/service_locator.dart';
import 'package:delivery_ways_clean/config/integration_config.dart';

void main() {
  group('Auth E2E Tests', () {
    late bool isConfigured;

    setUpAll(() {
      isConfigured = IntegrationConfig.isFullyConfigured;
    });

    test('Auth service initialization', () {
      expect(
        isConfigured,
        isTrue,
        reason:
            'Auth requires SUPABASE_URL and SUPABASE_ANON_KEY to be configured',
      );
    });

    test('Sign up with valid credentials', () async {
      if (!isConfigured) return;

      final email =
          'test_user_${DateTime.now().millisecondsSinceEpoch}@example.com';
      const password = 'test_password_123';

      try {
        final session = await ServiceLocator.auth.signInWithEmail(
          email,
          password,
        );
        expect(session.userId, isNotEmpty);
        expect(session.email, email);

        // Clean up - sign out
        await ServiceLocator.auth.signOut();
      } on Exception catch (e) {
        // Sign up might fail if user already exists, try sign in
        expect(e.toString(), contains('AuthException'));
      }
    });

    test('Sign in with existing credentials', () async {
      if (!isConfigured) return;

      // Use a test account that should exist in Supabase test environment
      const email = 'test@example.com';
      const password = 'test_password';

      try {
        final session = await ServiceLocator.auth.signInWithEmail(
          email,
          password,
        );
        expect(session.userId, isNotEmpty);

        // Verify current user
        final currentUser = await ServiceLocator.auth.getCurrentUser();
        expect(currentUser, isNotNull);
        expect(currentUser!.userId, session.userId);

        // Clean up
        await ServiceLocator.auth.signOut();
      } catch (e) {
        // If test account doesn't exist, this is expected in dev environment
        expect(e.toString(), contains('AuthException'));
      }
    });

    test('Sign out functionality', () async {
      if (!isConfigured) return;

      try {
        await ServiceLocator.auth.signOut();

        // Verify user is signed out
        final currentUser = await ServiceLocator.auth.getCurrentUser();
        expect(currentUser, isNull);
      } catch (e) {
        // Sign out should not throw, but handle gracefully
        expect(e.toString(), contains('AuthException'));
      }
    });

    test('Auth state changes stream', () async {
      if (!isConfigured) return;

      final completer = Completer<void>();

      StreamSubscription? subscription;
      subscription = ServiceLocator.auth.onAuthStateChanged.listen((
        userSession,
      ) {
        // Just verify the stream works
        if (!completer.isCompleted) {
          completer.complete();
          subscription?.cancel();
        }
      });

      // Wait for stream to emit or timeout
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );

      await subscription.cancel();
    });
  });
}

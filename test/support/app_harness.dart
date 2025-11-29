/// UX Test Harness - Unified Testing Support
/// Created by: Cursor B-ux
/// Purpose: Standardized harness for UX widget and integration tests
/// Last updated: 2025-11-26

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system_stub_impl/providers.dart';
import 'package:design_system_stub_impl/notice_host.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;

/// Ensure test binding is initialized
void ensureTestBinding() {
  TestWidgetsFlutterBinding.ensureInitialized();
}

/// Fake DSR Service for testing
class FakeDsrService {
  final _ctrl = StreamController<Map<String, dynamic>>.broadcast();
  
  /// Counter for generating unique request IDs
  int _requestCounter = 0;
  
  /// Current request ID for test assertions
  int get requestId => _requestCounter;

  Stream<Map<String, dynamic>> watchStatus(String requestId, String type) =>
      _ctrl.stream;

  Future<Map<String, dynamic>> requestExport({
    required bool includePaymentsHistory,
  }) async {
    _requestCounter++;
    return {
      'id': 'fake_export_$_requestCounter',
      'status': 'pending',
      'type': 'export',
    };
  }

  Future<Map<String, dynamic>> requestErasure() async {
    _requestCounter++;
    return {
      'id': 'fake_erasure_$_requestCounter',
      'status': 'confirmRequired',
      'type': 'erasure',
    };
  }

  Future<void> confirmErasure(String id) async {}

  Future<void> cancelRequest(String id, String type) async {}

  // Helper for emitting events in tests
  void emit(Map<String, dynamic> event) => _ctrl.add(event);

  void dispose() => _ctrl.close();
}

/// Capturing Notice Presenter for tests
class CapturingNoticePresenter {
  AppNotice? lastNotice;
  bool wasCalled = false;

  void show(AppNotice notice) {
    lastNotice = notice;
    wasCalled = true;
  }

  void reset() {
    lastNotice = null;
    wasCalled = false;
  }
}

/// Global instances for tests
final fakeDsrService = FakeDsrService();
final capturingNoticePresenter = CapturingNoticePresenter();

/// Mock implementation for capturing notices
class MockNoticePresenter {
  AppNotice? lastNotice;
  bool wasCalled = false;

  void show(AppNotice notice) {
    lastNotice = notice;
    wasCalled = true;
  }

  void reset() {
    lastNotice = null;
    wasCalled = false;
  }
}

/// Mock implementation for navigation tracking
class MockNavigatorObserver extends NavigatorObserver {
  List<String> pushedRoutes = [];
  List<String> poppedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      pushedRoutes.add(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      poppedRoutes.add(route.settings.name!);
    }
  }

  void reset() {
    pushedRoutes.clear();
    poppedRoutes.clear();
  }
}

/// Test harness utilities
class AppTestHarness {
  static final mockNoticePresenter = MockNoticePresenter();
  static final mockNavigatorObserver = MockNavigatorObserver();

  /// Creates a test app with proper provider setup and NoticeHost
  static Widget makeTestApp({
    required Widget home,
    List<Override> overrides = const [],
  }) {
    ensureTestBinding();

    final defaultRoutes = <String, WidgetBuilder>{
      '/settings/privacy-data': (context) =>
          const Scaffold(body: Text('Privacy Data')),
      '/settings/dsr/export': (context) =>
          const Scaffold(body: Text('DSR Export')),
      '/settings/dsr/erasure': (context) =>
          const Scaffold(body: Text('DSR Erasure')),
      '/payment': (context) => const Scaffold(body: Text('Payment')),
      '/maps': (context) => const Scaffold(body: Text('Maps')),
    };

    final navigatorKey = GlobalKey<NavigatorState>();
    
    return ProviderScope(
      overrides: [
        // Material design overrides
        ...materialDesignOverrides,
        ...materialNoticeOverrides,

        // Core app overrides for testing
        fnd.navigatorKeyProvider.overrideWithValue(navigatorKey),
        appNoticePresenterProvider.overrideWithValue(
          capturingNoticePresenter.show,
        ),

        // DSR service override
        // dsrServiceProvider.overrideWithValue(fakeDsrService),

        // Feature flags - enabled by default for testing
        // dsrNotificationsEnabledProvider.overrideWithValue(const AsyncData(true)),

        // Add test-specific overrides
        ...overrides,
      ],
      child: NoticeHost(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [mockNavigatorObserver],
          home: home,
          routes: defaultRoutes,
          // Add localizations for Material widgets in tests
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US')],
        ),
      ),
    );
  }

  /// Safe pump and settle with extended timeout for async operations
  static Future<void> pumpAndSettleSafe(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Reset all mocks between tests
  static void reset() {
    mockNoticePresenter.reset();
    mockNavigatorObserver.reset();
  }
}

/// Custom matchers for UX testing
extension UxTestMatchers on WidgetTester {
  /// Find a notice by its message content
  Finder findSnackNotice(String message) {
    return find.text(message);
  }

  /// Expect that a route was pushed
  void expectRoutePushed(String routeName) {
    expect(
      AppTestHarness.mockNavigatorObserver.pushedRoutes.contains(routeName),
      isTrue,
      reason:
          'Expected route $routeName to be pushed, but pushed routes were: ${AppTestHarness.mockNavigatorObserver.pushedRoutes}',
    );
  }

  /// Expect that no route was pushed
  void expectNoRoutePushed() {
    expect(
      AppTestHarness.mockNavigatorObserver.pushedRoutes,
      isEmpty,
      reason:
          'Expected no routes to be pushed, but found: ${AppTestHarness.mockNavigatorObserver.pushedRoutes}',
    );
  }

  /// Expect a notice was shown
  void expectNoticeShown({
    String? message,
    AppNoticeType? type,
    bool? hasAction,
  }) {
    expect(
      AppTestHarness.mockNoticePresenter.wasCalled,
      isTrue,
      reason: 'Expected a notice to be shown',
    );

    if (message != null) {
      expect(
        AppTestHarness.mockNoticePresenter.lastNotice?.message,
        equals(message),
      );
    }
    if (type != null) {
      expect(AppTestHarness.mockNoticePresenter.lastNotice?.type, equals(type));
    }
    if (hasAction != null) {
      final hasActionActual =
          AppTestHarness.mockNoticePresenter.lastNotice?.action != null;
      expect(hasActionActual, equals(hasAction));
    }
  }

  /// Expect no notice was shown
  void expectNoNoticeShown() {
    expect(
      AppTestHarness.mockNoticePresenter.wasCalled,
      isFalse,
      reason: 'Expected no notice to be shown',
    );
  }
}

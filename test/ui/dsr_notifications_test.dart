import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system_stub_impl/providers.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;
import 'package:dsr_ux_adapter/dsr_ux_adapter.dart' as dsr;
import 'package:delivery_ways_clean/state/accounts/dsr_notifications.dart';

void main() {
  late StreamController<dsr.DsrRequestSummary> exportStreamController;
  late StreamController<dsr.DsrRequestSummary> erasureStreamController;

  setUp(() {
    exportStreamController = StreamController<dsr.DsrRequestSummary>.broadcast();
    erasureStreamController = StreamController<dsr.DsrRequestSummary>.broadcast();
  });

  tearDown(() {
    exportStreamController.close();
    erasureStreamController.close();
  });

  group('DSR Notifications Widget Tests', () {
    testWidgets('Export Ready: shows success notice with action button', (
      WidgetTester tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      late DsrNotificationCenter notificationCenter;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fnd.navigatorKeyProvider.overrideWithValue(navigatorKey),
            ...materialNoticeOverrides,
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: scaffoldMessengerKey,
            home: Builder(
              builder: (context) {
                // Create notification center with proper context
                final mockController = _MockDsrController(
                  exportStream: exportStreamController.stream,
                  erasureStream: erasureStreamController.stream,
                );
                final mockNavigationService = _MockNavigationService(navigatorKey);

                notificationCenter = DsrNotificationCenter(
                  mockController,
                  (notice) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(notice.message),
                        action: notice.action != null
                            ? SnackBarAction(
                                label: notice.action!.label,
                                onPressed: notice.action!.onPressed,
                              )
                            : null,
                      ),
                    );
                  },
                  mockNavigationService,
                );

                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        ),
      );

      // Start monitoring export request
      notificationCenter.monitorRequest(
        'test-export-123',
        dsr.DsrRequestType.export,
      );

      // Simulate ready status
      final readySummary = dsr.DsrRequestSummary(
        id: const dsr.DsrRequestId('test-export-123'),
        type: dsr.DsrRequestType.export,
        status: dsr.DsrStatus.ready,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      exportStreamController.add(readySummary);
      await tester.pumpAndSettle();

      // Verify notice appears
      expect(find.text('ملف التصدير جاهز للتنزيل'), findsOneWidget);

      // Verify action button exists
      expect(find.text('عرض'), findsOneWidget);
    });

    testWidgets('Erasure Confirm: shows warning notice with action button', (
      WidgetTester tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      late DsrNotificationCenter notificationCenter;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fnd.navigatorKeyProvider.overrideWithValue(navigatorKey),
            ...materialNoticeOverrides,
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: scaffoldMessengerKey,
            home: Builder(
              builder: (context) {
                final mockController = _MockDsrController(
                  exportStream: exportStreamController.stream,
                  erasureStream: erasureStreamController.stream,
                );
                final mockNavigationService = _MockNavigationService(navigatorKey);

                notificationCenter = DsrNotificationCenter(
                  mockController,
                  (notice) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(notice.message),
                        action: notice.action != null
                            ? SnackBarAction(
                                label: notice.action!.label,
                                onPressed: notice.action!.onPressed,
                              )
                            : null,
                      ),
                    );
                  },
                  mockNavigationService,
                );

                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        ),
      );

      // Start monitoring erasure request
      notificationCenter.monitorRequest(
        'test-erasure-456',
        dsr.DsrRequestType.erasure,
      );

      // Simulate confirm-required status
      final confirmSummary = dsr.DsrRequestSummary(
        id: const dsr.DsrRequestId('test-erasure-456'),
        type: dsr.DsrRequestType.erasure,
        status: dsr.DsrStatus.ready, // ready = confirm-required for erasure
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      erasureStreamController.add(confirmSummary);
      await tester.pumpAndSettle();

      // Verify notice appears
      expect(find.text('يلزم تأكيد حذف الحساب'), findsOneWidget);

      // Verify action button exists
      expect(find.text('تأكيد الآن'), findsOneWidget);
    });

    testWidgets('Dedup: prevents duplicate notifications within 60 seconds', (
      WidgetTester tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      late DsrNotificationCenter notificationCenter;
      int noticeCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fnd.navigatorKeyProvider.overrideWithValue(navigatorKey),
            ...materialNoticeOverrides,
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: scaffoldMessengerKey,
            home: Builder(
              builder: (context) {
                final mockController = _MockDsrController(
                  exportStream: exportStreamController.stream,
                  erasureStream: erasureStreamController.stream,
                );
                final mockNavigationService = _MockNavigationService(navigatorKey);

                notificationCenter = DsrNotificationCenter(
                  mockController,
                  (notice) {
                    noticeCount++;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(notice.message),
                        action: notice.action != null
                            ? SnackBarAction(
                                label: notice.action!.label,
                                onPressed: notice.action!.onPressed,
                              )
                            : null,
                      ),
                    );
                  },
                  mockNavigationService,
                );

                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        ),
      );

      // Start monitoring export request
      notificationCenter.monitorRequest(
        'test-export-dedup',
        dsr.DsrRequestType.export,
      );

      // Simulate ready status twice quickly
      final readySummary = dsr.DsrRequestSummary(
        id: const dsr.DsrRequestId('test-export-dedup'),
        type: dsr.DsrRequestType.export,
        status: dsr.DsrStatus.ready,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // First notification
      exportStreamController.add(readySummary);
      await tester.pumpAndSettle();

      // Second notification (should be deduped)
      exportStreamController.add(readySummary);
      await tester.pumpAndSettle();

      // Should only have shown one notice due to deduplication
      expect(noticeCount, equals(1));
    });

    testWidgets('Navigation: action buttons navigate to correct routes', (
      WidgetTester tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      late DsrNotificationCenter notificationCenter;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fnd.navigatorKeyProvider.overrideWithValue(navigatorKey),
            ...materialNoticeOverrides,
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: scaffoldMessengerKey,
            home: Builder(
              builder: (context) {
                final mockController = _MockDsrController(
                  exportStream: exportStreamController.stream,
                  erasureStream: erasureStreamController.stream,
                );
                final mockNavigationService = _MockNavigationService(navigatorKey);

                notificationCenter = DsrNotificationCenter(
                  mockController,
                  (notice) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(notice.message),
                        action: notice.action != null
                            ? SnackBarAction(
                                label: notice.action!.label,
                                onPressed: notice.action!.onPressed,
                              )
                            : null,
                      ),
                    );
                  },
                  mockNavigationService,
                );

                return const Scaffold(body: SizedBox());
              },
            ),
            routes: {
              '/settings/dsr/export': (context) =>
                  const Scaffold(body: Text('Export Screen')),
              '/settings/dsr/erasure': (context) =>
                  const Scaffold(body: Text('Erasure Screen')),
            },
          ),
        ),
      );

      // Start monitoring export request
      notificationCenter.monitorRequest(
        'test-nav-export',
        dsr.DsrRequestType.export,
      );

      // Simulate ready status
      final readySummary = dsr.DsrRequestSummary(
        id: const dsr.DsrRequestId('test-nav-export'),
        type: dsr.DsrRequestType.export,
        status: dsr.DsrStatus.ready,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      exportStreamController.add(readySummary);
      await tester.pumpAndSettle();

      // Tap the action button
      await tester.tap(find.text('عرض'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.text('Export Screen'), findsOneWidget);
    });
  });
}

/// Mock DsrController for testing
class _MockDsrController implements dsr.DsrController {
  final Stream<dsr.DsrRequestSummary> exportStream;
  final Stream<dsr.DsrRequestSummary> erasureStream;

  _MockDsrController({
    required this.exportStream,
    required this.erasureStream,
  });

  @override
  Stream<dsr.DsrRequestSummary> watchStatus(
    String requestId,
    dsr.DsrRequestType type,
  ) {
    switch (type) {
      case dsr.DsrRequestType.export:
        return exportStream;
      case dsr.DsrRequestType.erasure:
        return erasureStream;
    }
  }

  @override
  Future<void> requestErasure({
    required dsr.DsrStatusCallback onStatusUpdate,
  }) async {}

  @override
  Future<void> confirmErasure({
    required dsr.DsrRequestId id,
    required dsr.DsrStatusCallback onStatusUpdate,
  }) async {}

  @override
  Future<void> cancelErasure({
    required dsr.DsrRequestId id,
    required dsr.DsrStatusCallback onStatusUpdate,
  }) async {}

  @override
  Future<void> refreshStatus(
    String requestId,
    dsr.DsrRequestType type,
    dsr.DsrStatusCallback onStatusUpdate,
  ) async {}

  @override
  void dispose() {}
}

/// Mock NavigationService for testing
class _MockNavigationService implements fnd.NavigationService {
  @override
  final GlobalKey<NavigatorState> key;

  _MockNavigationService(this.key);

  @override
  NavigatorState? get nav => key.currentState;

  @override
  Future<T?> push<T>(Route<T> route) => nav?.push(route) ?? Future.value(null);

  @override
  void pop<T extends Object?>([T? result]) => nav?.pop(result);
}

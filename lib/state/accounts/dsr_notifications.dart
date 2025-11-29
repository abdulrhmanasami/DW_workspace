import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart' as ds;
import 'package:foundation_shims/foundation_shims.dart' as fnd;
import 'package:dsr_ux_adapter/dsr_ux_adapter.dart' as dsr;

import 'dsr_controller.dart';

/// DSR Notification Center - manages in-app notifications for DSR status changes
class DsrNotificationCenter {
  final dsr.DsrController _dsrController;
  final ds.AppNoticePresenter _noticePresenter;
  final fnd.NavigationService _navigationService;
  final Map<String, DateTime> _deliveredNotifications = {}; // Key -> timestamp for TTL
  final Map<String, StreamSubscription<dsr.DsrRequestSummary>> _activeSubscriptions = {};
  static const Duration _dedupTtl = Duration(seconds: 60);

  DsrNotificationCenter(
    this._dsrController,
    this._noticePresenter,
    this._navigationService,
  );

  /// Start monitoring a DSR request for notifications
  void monitorRequest(String requestId, dsr.DsrRequestType type) {
    final key = '${type.name}_$requestId';

    // Skip if already monitoring
    if (_activeSubscriptions.containsKey(key)) return;

    final subscription = _dsrController.watchStatus(requestId, type).listen(
      (summary) {
        _handleStatusUpdate(summary);
      },
      onError: (error) {
        // ignore: avoid_print
        print('DSR notification stream error for $key: $error');
      },
    );

    _activeSubscriptions[key] = subscription;
  }

  /// Stop monitoring a DSR request
  void stopMonitoring(String requestId, dsr.DsrRequestType type) {
    final key = '${type.name}_$requestId';
    final subscription = _activeSubscriptions.remove(key);
    subscription?.cancel();
  }

  /// Handle status updates and send notifications for critical events
  void _handleStatusUpdate(dsr.DsrRequestSummary summary) {
    final notificationKey = '${summary.id.value}::${summary.status.name}';

    // Check TTL-based deduplication
    final now = DateTime.now();
    final lastShown = _deliveredNotifications[notificationKey];
    if (lastShown != null && now.difference(lastShown) < _dedupTtl) {
      return; // Still within TTL, skip notification
    }

    ds.AppNotice? notice;
    switch (summary.type) {
      case dsr.DsrRequestType.export:
        notice = _createExportNotice(summary);
        break;
      case dsr.DsrRequestType.erasure:
        notice = _createErasureNotice(summary);
        break;
    }

    if (notice != null) {
      _noticePresenter(notice);
      _deliveredNotifications[notificationKey] = now;
      _cleanupExpiredEntries(now);
    }
  }

  /// Clean up expired deduplication entries
  void _cleanupExpiredEntries(DateTime now) {
    final expiredKeys = <String>[];
    _deliveredNotifications.forEach((key, timestamp) {
      if (now.difference(timestamp) >= _dedupTtl) {
        expiredKeys.add(key);
      }
    });
    expiredKeys.forEach(_deliveredNotifications.remove);
  }

  /// Create notice for export status changes
  ds.AppNotice? _createExportNotice(dsr.DsrRequestSummary summary) {
    switch (summary.status) {
      case dsr.DsrStatus.ready:
        return ds.AppNotice.success(
          message: 'ملف التصدير جاهز للتنزيل',
          action: ds.AppNoticeAction('عرض', () => _navigateTo('/settings/dsr/export')),
        );
      case dsr.DsrStatus.failed:
        return ds.AppNotice.error(
          message: 'فشل في إعداد ملف التصدير',
          action: ds.AppNoticeAction(
            'إعادة المحاولة',
            () => _navigateTo('/settings/dsr/export'),
          ),
        );
      default:
        return null; // Only notify on critical status changes
    }
  }

  /// Create notice for erasure status changes
  ds.AppNotice? _createErasureNotice(dsr.DsrRequestSummary summary) {
    switch (summary.status) {
      case dsr.DsrStatus.ready:
        return ds.AppNotice.warning(
          message: 'يلزم تأكيد حذف الحساب',
          action: ds.AppNoticeAction(
            'تأكيد الآن',
            () => _navigateTo('/settings/dsr/erasure'),
          ),
        );
      case dsr.DsrStatus.completed:
        return ds.AppNotice.success(
          message: 'تم حذف حسابك بنجاح',
          action: ds.AppNoticeAction('موافق', () => _navigateTo('/settings/privacy-data')),
        );
      case dsr.DsrStatus.failed:
        return ds.AppNotice.error(
          message: 'فشل في حذف الحساب',
          action: ds.AppNoticeAction(
            'إعادة المحاولة',
            () => _navigateTo('/settings/dsr/erasure'),
          ),
        );
      case dsr.DsrStatus.canceled:
        return ds.AppNotice.info(
          message: 'تم إلغاء طلب حذف الحساب',
          action: ds.AppNoticeAction('موافق', () {}),
        );
      default:
        return null; // Only notify on critical status changes
    }
  }

  Future<void> _navigateTo(String route) async {
    await _navigationService.nav?.pushNamed(route);
  }

  /// Clean up all subscriptions
  void dispose() {
    for (final subscription in _activeSubscriptions.values) {
      subscription.cancel();
    }
    _activeSubscriptions.clear();
    _deliveredNotifications.clear();
  }
}

/// Provider for DSR notification center
final dsrNotificationCenterProvider =
    Provider.autoDispose<DsrNotificationCenter>((ref) {
  final dsrController = ref.watch(dsrControllerProvider);
  final noticePresenter = ref.watch(ds.appNoticePresenterProvider);
  final navigationService = ref.watch(fnd.navigationServiceProvider);

  final center = DsrNotificationCenter(
    dsrController,
    noticePresenter,
    navigationService,
  );

  ref.onDispose(center.dispose);
  return center;
});

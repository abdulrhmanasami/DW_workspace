import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsr_ux_adapter/dsr_ux_adapter.dart' as dsr;

import 'dsr_controller.dart';

/// Foreground watcher for DSR requests - updates status for active requests
class DsrForegroundWatcher {
  final dsr.DsrController _dsrController;
  Timer? _statusCheckTimer;
  final Set<String> _activeRequests = {};

  DsrForegroundWatcher(this._dsrController);

  /// Start monitoring active DSR requests
  void startMonitoring() {
    _stopMonitoring(); // Clean up any existing timer

    _statusCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkActiveRequests(),
    );
  }

  /// Stop monitoring
  void stopMonitoring() {
    _stopMonitoring();
  }

  /// Add a request to monitor
  void monitorRequest(String requestId, dsr.DsrRequestType type) {
    _activeRequests.add('${type.name}_$requestId');
    // Start monitoring if not already running
    if (_statusCheckTimer == null) {
      startMonitoring();
    }
  }

  /// Remove a request from monitoring
  void stopMonitoringRequest(String requestId, dsr.DsrRequestType type) {
    _activeRequests.remove('${type.name}_$requestId');
    // Stop timer if no more requests to monitor
    if (_activeRequests.isEmpty) {
      _stopMonitoring();
    }
  }

  /// Check status of all active requests
  Future<void> _checkActiveRequests() async {
    if (_activeRequests.isEmpty) {
      _stopMonitoring();
      return;
    }

    for (final requestKey in _activeRequests.toList()) {
      final parts = requestKey.split('_');
      if (parts.length != 2) continue;

      final typeStr = parts[0];
      final requestId = parts[1];

      final type = typeStr == 'export'
          ? dsr.DsrRequestType.export
          : dsr.DsrRequestType.erasure;

      try {
        // Get current status - this will update the UI through the controller
        await _dsrController.refreshStatus(requestId, type, (summary) {
          // Remove from monitoring if terminal state
          if (summary.isTerminal) {
            _activeRequests.remove(requestKey);
          }
        });
      } catch (e) {
        // Remove failed requests from monitoring
        _activeRequests.remove(requestKey);
        // Log locally until observability plumbing is available
        // ignore: avoid_print
        print('Failed to check status for $requestKey: $e');
      }
    }

    // Stop timer if no more active requests
    if (_activeRequests.isEmpty) {
      _stopMonitoring();
    }
  }

  void _stopMonitoring() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
  }

  /// Clean up resources
  void dispose() {
    _stopMonitoring();
    _activeRequests.clear();
  }
}

/// Provider for DSR foreground watcher
final dsrForegroundWatcherProvider = Provider.autoDispose<DsrForegroundWatcher>(
  (ref) {
    final dsrController = ref.watch(dsrControllerProvider);
    final watcher = DsrForegroundWatcher(dsrController);

    // Check kill switch and stop monitoring if disabled
    final notificationsEnabled = ref.watch(dsr.dsrNotificationsEnabledProvider);
    notificationsEnabled.whenData((enabled) {
      if (!enabled) {
        watcher.stopMonitoring();
      }
    });

    // Auto-dispose cleanup
    ref.onDispose(() {
      watcher.dispose();
    });

    return watcher;
  },
);

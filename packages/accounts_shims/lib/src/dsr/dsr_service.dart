/// DSR (Data Subject Rights) service implementation
/// Created by: Cursor B-central
/// Purpose: Implementation of DSR contracts with polling and error handling
/// Last updated: 2025-11-12

import 'dart:async';
import 'package:foundation_shims/foundation_shims.dart';

import '../accounts_endpoints.dart';
import 'dsr_client.dart';
import 'dsr_contracts.dart';
import 'dsr_models.dart';
import 'dsr_audit.dart';

/// Implementation of DataSubjectRightsService
class DsrServiceImpl implements DataSubjectRightsService {
  final DsrClient client;
  final Duration pollingInterval;
  final DsrAuditSink auditSink;
  final String userId;

  // Active polling streams to manage cleanup
  final Map<DsrRequestId, StreamController<DsrRequestSummary>> _activeStreams =
      {};

  DsrServiceImpl({
    required this.client,
    required this.auditSink,
    required this.userId,
    this.pollingInterval = const Duration(seconds: 2),
  });

  /// Emit an audit event for a DSR operation
  Future<void> _emitAuditEvent(
    DsrRequestId reqId,
    DsrRequestType type,
    DsrStatus status,
    DsrAuditAction action, {
    Map<String, String> meta = const {},
  }) async {
    final event = DsrAuditEvent(
      ts: DateTime.now(),
      userIdHash: DsrAuditUtils.userHash(userId),
      reqId: reqId,
      type: type,
      status: status,
      action: action,
      meta: meta,
    );

    await auditSink.write(event);
  }

  @override
  Future<DsrRequestSummary> requestExport({
    bool includePaymentsHistory = false,
  }) async {
    // Check if export is enabled via RemoteConfig
    if (!await _isFeatureEnabled(DsrRequestType.export)) {
      throw FeatureDisabledException(
        'Data export feature is currently disabled',
      );
    }

    final request = DsrCreateRequest(
      type: DsrRequestType.export,
      includePaymentsHistory: includePaymentsHistory,
    );

    final summary = await client.createRequest(request);

    // Audit the creation
    await _emitAuditEvent(
      summary.id,
      summary.type,
      summary.status,
      DsrAuditAction.create,
      meta: {
        'include_payments_history': includePaymentsHistory.toString(),
        'feature_flags': 'export:1',
      },
    );

    return summary;
  }

  @override
  Future<DsrRequestSummary> requestErasure() async {
    // Check if erasure is enabled via RemoteConfig
    if (!await _isFeatureEnabled(DsrRequestType.erasure)) {
      throw FeatureDisabledException(
        'Account erasure feature is currently disabled',
      );
    }

    final request = DsrCreateRequest(type: DsrRequestType.erasure);
    final summary = await client.createRequest(request);

    // Audit the creation
    await _emitAuditEvent(
      summary.id,
      summary.type,
      summary.status,
      DsrAuditAction.create,
      meta: {'feature_flags': 'erasure:1'},
    );

    return summary;
  }

  @override
  Future<DsrRequestSummary> getRequestStatus(DsrRequestId id) async {
    final summary = await client.getRequestStatus(id);

    // Audit the status check
    await _emitAuditEvent(
      summary.id,
      summary.type,
      summary.status,
      DsrAuditAction.statusPoll,
    );

    return summary;
  }

  @override
  Future<void> cancelRequest(DsrRequestId id) async {
    // Get current status before cancellation for audit
    DsrRequestSummary? currentStatus;
    try {
      currentStatus = await client.getRequestStatus(id);
    } catch (_) {
      // If we can't get status, continue with cancellation
    }

    await client.cancelRequest(id);
    // Stop any active polling for this request
    _cleanupStream(id);

    // Audit the cancellation (use pending as fallback if we couldn't get status)
    if (currentStatus != null) {
      await _emitAuditEvent(
        id,
        currentStatus.type,
        DsrStatus.canceled,
        DsrAuditAction.cancel,
      );
    }
  }

  @override
  Future<void> confirmErasure(DsrRequestId id) async {
    // Get current status before confirmation for audit
    DsrRequestSummary? currentStatus;
    try {
      currentStatus = await client.getRequestStatus(id);
    } catch (_) {
      // If we can't get status, continue with confirmation
    }

    await client.confirmErasure(id);

    // Audit the confirmation
    if (currentStatus != null) {
      await _emitAuditEvent(
        id,
        currentStatus.type,
        currentStatus.status,
        DsrAuditAction.confirm,
      );
    }
  }

  @override
  Stream<DsrRequestSummary> watchStatus(DsrRequestId id) {
    // Create a new stream controller for this request
    final controller = StreamController<DsrRequestSummary>.broadcast();
    _activeStreams[id] = controller;

    // Start polling in background
    _startPolling(id, controller);

    return controller.stream;
  }

  /// Start polling for request status updates
  void _startPolling(
    DsrRequestId id,
    StreamController<DsrRequestSummary> controller,
  ) {
    Timer? timer;
    DsrRequestSummary? lastStatus;

    // Initial fetch
    _pollOnce(id, controller)
        .then((status) {
          lastStatus = status;

          // Set up periodic polling if request is not terminal
          if (!status.isTerminal) {
            timer = Timer.periodic(pollingInterval, (_) async {
              try {
                final currentStatus = await _pollOnce(id, controller);

                // Check if status changed
                if (currentStatus.status != lastStatus?.status ||
                    currentStatus.updatedAt != lastStatus?.updatedAt) {
                  lastStatus = currentStatus;

                  // Stop polling if terminal state reached
                  if (currentStatus.isTerminal) {
                    timer?.cancel();
                    _cleanupStream(id);
                  }
                }
              } catch (e) {
                // On error, emit current status if available, or close stream
                if (lastStatus != null) {
                  controller.addError(e);
                } else {
                  controller.addError(e);
                  _cleanupStream(id);
                }
              }
            });
          } else {
            // Terminal state reached immediately
            _cleanupStream(id);
          }
        })
        .catchError((error) {
          controller.addError(error);
          _cleanupStream(id);
        });

    // Clean up timer when stream is cancelled
    controller.onCancel = () {
      timer?.cancel();
      _cleanupStream(id);
    };
  }

  /// Poll once and emit to stream
  Future<DsrRequestSummary> _pollOnce(
    DsrRequestId id,
    StreamController<DsrRequestSummary> controller,
  ) async {
    final status = await client.getRequestStatus(id);
    controller.add(status);
    return status;
  }

  /// Clean up stream resources
  void _cleanupStream(DsrRequestId id) {
    final controller = _activeStreams.remove(id);
    if (controller != null && !controller.isClosed) {
      controller.close();
    }
  }

  /// Check if a DSR feature is enabled via RemoteConfig
  Future<bool> _isFeatureEnabled(DsrRequestType type) async {
    // TODO: Integrate with foundation_shims RemoteConfig
    // For now, assume features are enabled
    // This should check:
    // - dsr_export_enabled for export requests
    // - dsr_erasure_enabled for erasure requests

    // Placeholder implementation - replace with actual RemoteConfig check
    return true;
  }

  /// Clean up all active streams (call on dispose)
  void dispose() {
    for (final controller in _activeStreams.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _activeStreams.clear();
  }
}

/// Factory for creating DSR services
class DsrServiceFactoryImpl implements DsrServiceFactory {
  final AccountsEndpoints endpoints;
  final ConfigManager configManager;
  final DsrAuditSink auditSink;
  final String userId;

  DsrServiceFactoryImpl({
    required this.endpoints,
    required this.configManager,
    required this.auditSink,
    required this.userId,
  });

  @override
  DataSubjectRightsService createService() {
    final client = DsrClient(
      endpoints: endpoints,
      configManager: configManager,
    );

    return DsrServiceImpl(client: client, auditSink: auditSink, userId: userId);
  }

  @override
  Future<bool> isDsrEnabled(DsrRequestType type) async {
    // TODO: Check RemoteConfig flags
    // dsr_export_enabled for export
    // dsr_erasure_enabled for erasure
    return true; // Placeholder
  }
}

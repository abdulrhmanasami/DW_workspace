/// Component: dsr_state.dart
/// Created by: GPT-5.1 Codex (B-ux)
/// Purpose: Riverpod state + controllers for DSR UX flows
/// Last updated: 2025-11-24

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dsr_models.dart';

/// Immutable UI state for the export screen.
class DsrExportState {
  final AsyncValue<DsrRequestSummary?> request;
  final bool includePaymentsHistory;

  const DsrExportState({
    this.request = const AsyncValue.data(null),
    this.includePaymentsHistory = false,
  });

  bool get hasActiveRequest =>
      request.value != null && !(request.value?.isTerminal ?? true);

  DsrExportState copyWith({
    AsyncValue<DsrRequestSummary?>? request,
    bool? includePaymentsHistory,
  }) {
    return DsrExportState(
      request: request ?? this.request,
      includePaymentsHistory:
          includePaymentsHistory ?? this.includePaymentsHistory,
    );
  }
}

/// Immutable UI state for the erasure screen.
class DsrErasureState {
  final AsyncValue<DsrRequestSummary?> request;
  final bool showConfirmation;

  const DsrErasureState({
    this.request = const AsyncValue.data(null),
    this.showConfirmation = false,
  });

  DsrErasureState copyWith({
    AsyncValue<DsrRequestSummary?>? request,
    bool? showConfirmation,
  }) {
    return DsrErasureState(
      request: request ?? this.request,
      showConfirmation: showConfirmation ?? this.showConfirmation,
    );
  }
}

/// State notifier for export operations.
class DsrExportNotifier extends StateNotifier<DsrExportState> {
  DsrExportNotifier() : super(const DsrExportState());

  void setIncludePaymentsHistory(bool value) {
    state = state.copyWith(includePaymentsHistory: value);
  }

  void setRequest(AsyncValue<DsrRequestSummary?> request) {
    state = state.copyWith(request: request);
  }

  void reset() {
    state = const DsrExportState();
  }
}

/// State notifier for erasure operations.
class DsrErasureNotifier extends StateNotifier<DsrErasureState> {
  DsrErasureNotifier() : super(const DsrErasureState());

  void setRequest(AsyncValue<DsrRequestSummary?> request) {
    state = state.copyWith(request: request);
  }

  void setShowConfirmation(bool show) {
    state = state.copyWith(showConfirmation: show);
  }

  void reset() {
    state = const DsrErasureState();
  }
}

class InMemoryDsrStore {
  final Map<String, DsrRequestSummary> _requests = {};
  final Map<String, StreamController<DsrRequestSummary>> _streams = {};

  DsrRequestSummary save(DsrRequestSummary summary) {
    final key = _key(summary.type, summary.id.value);
    _requests[key] = summary;
    final controller = _streams[key];
    if (controller != null && !controller.isClosed) {
      controller.add(summary);
    }
    return summary;
  }

  DsrRequestSummary? read(DsrRequestType type, String id) {
    return _requests[_key(type, id)];
  }

  DsrRequestSummary updateStatus({
    required DsrRequestId id,
    required DsrRequestType type,
    required DsrStatus status,
    DsrExportLink? exportLink,
  }) {
    final existing = read(type, id.value) ??
        DsrRequestSummary.initial(id: id, type: type);
    final updated = existing.copyWith(
      status: status,
      updatedAt: DateTime.now(),
      exportLink: exportLink ?? existing.exportLink,
    );
    return save(updated);
  }

  Stream<DsrRequestSummary> watch(DsrRequestType type, String id) {
    final key = _key(type, id);
    final controller =
        _streams.putIfAbsent(key, () => StreamController.broadcast());
    final snapshot = _requests[key];
    if (snapshot != null) {
      Future.microtask(() => controller.add(snapshot));
    }
    return controller.stream;
  }

  void dispose() {
    for (final controller in _streams.values) {
      controller.close();
    }
    _streams.clear();
    _requests.clear();
  }

  String _key(DsrRequestType type, String id) => '${type.name}_$id';
}

class DsrRequestController {
  final InMemoryDsrStore _store;
  final DsrExportNotifier _exportNotifier;
  bool _disposed = false;

  DsrRequestController(this._store, this._exportNotifier);

  Future<void> submit(DsrRequest request) async {
    if (_disposed) return;

    _exportNotifier.setRequest(const AsyncValue.loading());

    final summary = DsrRequestSummary.initial(
      id: DsrRequestId(request.id),
      type: request.action,
      payload: request.payload,
    ).copyWith(
      status: DsrStatus.inProgress,
      updatedAt: DateTime.now(),
    );

    _store.save(summary);
    _exportNotifier.setRequest(AsyncValue.data(summary));

    await Future.delayed(const Duration(milliseconds: 450));
    if (_disposed) return;

    final readySummary = summary.copyWith(
      status: DsrStatus.ready,
      updatedAt: DateTime.now(),
      exportLink: DsrExportLink(
        url: Uri.parse(
          'https://downloads.deliveryways.local/${summary.id.value}.zip',
        ),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
    );

    _store.save(readySummary);
    _exportNotifier.setRequest(AsyncValue.data(readySummary));

    await Future.delayed(const Duration(milliseconds: 300));
    if (_disposed) return;

    final completedSummary = readySummary.copyWith(
      status: DsrStatus.completed,
      updatedAt: DateTime.now(),
    );
    _store.save(completedSummary);
    _exportNotifier.setRequest(AsyncValue.data(completedSummary));
  }

  void dispose() {
    _disposed = true;
  }
}

class DsrController {
  final InMemoryDsrStore _store;
  bool _disposed = false;

  DsrController(this._store);

  Future<void> requestErasure({required DsrStatusCallback onStatusUpdate}) async {
    if (_disposed) return;
    final id = DsrRequestId(DateTime.now().millisecondsSinceEpoch.toString());
    var summary = DsrRequestSummary.initial(
      id: id,
      type: DsrRequestType.erasure,
    ).copyWith(
      status: DsrStatus.inProgress,
      updatedAt: DateTime.now(),
    );

    summary = _store.save(summary);
    onStatusUpdate(summary);

    await Future.delayed(const Duration(milliseconds: 600));
    if (_disposed) return;

    final ready = _store.updateStatus(
      id: id,
      type: DsrRequestType.erasure,
      status: DsrStatus.ready,
    );
    onStatusUpdate(ready);
  }

  Future<void> confirmErasure({
    required DsrRequestId id,
    required DsrStatusCallback onStatusUpdate,
  }) async {
    if (_disposed) return;
    final completed = _store.updateStatus(
      id: id,
      type: DsrRequestType.erasure,
      status: DsrStatus.completed,
    );
    onStatusUpdate(completed);
  }

  Future<void> cancelErasure({
    required DsrRequestId id,
    required DsrStatusCallback onStatusUpdate,
  }) async {
    if (_disposed) return;
    final canceled = _store.updateStatus(
      id: id,
      type: DsrRequestType.erasure,
      status: DsrStatus.canceled,
    );
    onStatusUpdate(canceled);
  }

  Future<void> refreshStatus(
    String requestId,
    DsrRequestType type,
    DsrStatusCallback onStatusUpdate,
  ) async {
    if (_disposed) return;
    final summary =
        _store.read(type, requestId) ??
        DsrRequestSummary.initial(
          id: DsrRequestId(requestId),
          type: type,
        );
    onStatusUpdate(summary);
  }

  Stream<DsrRequestSummary> watchStatus(
    String requestId,
    DsrRequestType type,
  ) {
    return _store.watch(type, requestId);
  }

  void dispose() {
    _disposed = true;
  }
}

final _dsrStoreProvider = Provider<InMemoryDsrStore>((ref) {
  final store = InMemoryDsrStore();
  ref.onDispose(store.dispose);
  return store;
});

final dsrExportStateProvider =
    StateNotifierProvider<DsrExportNotifier, DsrExportState>(
  (ref) => DsrExportNotifier(),
);

final dsrErasureStateProvider =
    StateNotifierProvider<DsrErasureNotifier, DsrErasureState>(
  (ref) => DsrErasureNotifier(),
);

final dsrRequestControllerProvider = Provider<DsrRequestController>((ref) {
  final store = ref.watch(_dsrStoreProvider);
  final notifier = ref.watch(dsrExportStateProvider.notifier);
  final controller = DsrRequestController(store, notifier);
  ref.onDispose(controller.dispose);
  return controller;
});

final dsrControllerProvider = Provider<DsrController>((ref) {
  final store = ref.watch(_dsrStoreProvider);
  final controller = DsrController(store);
  ref.onDispose(controller.dispose);
  return controller;
});

final dsrExportEnabledProvider = FutureProvider<bool>((_) async => true);
final dsrErasureEnabledProvider = FutureProvider<bool>((_) async => true);
final dsrNotificationsEnabledProvider = FutureProvider<bool>((_) async => true);

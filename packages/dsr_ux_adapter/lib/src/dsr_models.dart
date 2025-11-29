/// Component: dsr_models.dart
/// Created by: GPT-5.1 Codex (B-ux)
/// Purpose: Canonical DSR domain models for UX layer consumption
/// Last updated: 2025-11-24

typedef DsrAction = DsrRequestType;

/// Supported DSR request categories.
enum DsrRequestType { export, erasure }

/// Finite set of DSR lifecycle statuses exposed to the UI.
enum DsrStatus { pending, inProgress, ready, completed, failed, canceled }

/// Strongly typed request identifier.
class DsrRequestId {
  final String value;

  const DsrRequestId(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DsrRequestId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  String toString() => 'DsrRequestId($value)';
}

/// Secure export link metadata.
class DsrExportLink {
  final Uri url;
  final DateTime expiresAt;

  const DsrExportLink({required this.url, required this.expiresAt});

  /// Returns `true` when the link has not expired yet.
  bool get isValid => DateTime.now().isBefore(expiresAt);

  /// Remaining duration before the link expires.
  Duration get timeUntilExpiration => expiresAt.difference(DateTime.now());
}

/// Immutable snapshot of a DSR request.
class DsrRequestSummary {
  final DsrRequestId id;
  final DsrRequestType type;
  final DsrStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? payload;
  final DsrExportLink? exportLink;

  const DsrRequestSummary({
    required this.id,
    required this.type,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.payload,
    this.exportLink,
  });

  /// Convenience factory for initializing a summary in pending state.
  factory DsrRequestSummary.initial({
    required DsrRequestId id,
    required DsrRequestType type,
    DateTime? timestamp,
    Map<String, dynamic>? payload,
  }) {
    final now = timestamp ?? DateTime.now();
    return DsrRequestSummary(
      id: id,
      type: type,
      status: DsrStatus.pending,
      createdAt: now,
      updatedAt: now,
      payload: payload,
    );
  }

  /// Returns `true` if the request reached a terminal state.
  bool get isTerminal =>
      status == DsrStatus.completed ||
      status == DsrStatus.failed ||
      status == DsrStatus.canceled;

  /// Returns `true` if export artifacts are ready for download.
  bool get isExportReady => status == DsrStatus.ready && exportLink != null;

  /// Creates a modified copy while keeping existing fields intact.
  DsrRequestSummary copyWith({
    DsrStatus? status,
    DateTime? updatedAt,
    Map<String, dynamic>? payload,
    DsrExportLink? exportLink,
  }) {
    return DsrRequestSummary(
      id: id,
      type: type,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      payload: payload ?? this.payload,
      exportLink: exportLink ?? this.exportLink,
    );
  }
}

/// DSR request payload captured from the UI.
class DsrRequest {
  final String id;
  final DsrAction action;
  final DateTime createdAt;
  final Map<String, dynamic>? payload;

  const DsrRequest({
    required this.id,
    required this.action,
    required this.createdAt,
    this.payload,
  });
}

/// Callback used by controllers to notify about status changes.
typedef DsrStatusCallback = void Function(DsrRequestSummary summary);

/// DSR (Data Subject Rights) contracts - SINGLE SOURCE OF TRUTH
/// Created by: Cursor B-central - CENT-DSR+FND-PROVIDERS-CLEANUP
/// Purpose: All DSR types consolidated in one canonical location
/// Last updated: 2025-11-17

/// DSR operation types
enum DsrOperation { export, erase }

/// Type of DSR request
enum DsrRequestType {
  /// Data export request (access to personal data)
  export,

  /// Account erasure request (right to be forgotten)
  erasure,
}

/// DSR status enumeration
enum DsrStatus {
  /// Request submitted and pending processing
  pending,

  /// Request is being processed
  running,

  /// Request completed successfully
  completed,

  /// Request failed due to error
  failed,

  /// Data is ready for export/download (legacy compatibility)
  ready,

  /// Request was canceled by user (legacy compatibility)
  canceled,
}

/// Unique identifier for DSR requests
class DsrRequestId {
  final String value;

  const DsrRequestId(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DsrRequestId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'DsrRequestId($value)';
}

/// Export link with expiration for secure data access
class DsrExportLink {
  final Uri url;
  final DateTime expiresAt;

  const DsrExportLink({required this.url, required this.expiresAt});

  /// Check if the link is still valid (not expired)
  bool get isValid => DateTime.now().isBefore(expiresAt);

  /// Get remaining time before expiration
  Duration get timeUntilExpiration => expiresAt.difference(DateTime.now());

  @override
  String toString() => 'DsrExportLink(url: $url, expires: $expiresAt)';
}

/// Request to create a new DSR operation
class DsrCreateRequest {
  final DsrRequestType type;

  /// For export requests: whether to include payment history
  final bool includePaymentsHistory;

  const DsrCreateRequest({
    required this.type,
    this.includePaymentsHistory = false,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'include_payments_history': includePaymentsHistory,
  };
}

/// Summary of a DSR request with current status
class DsrRequestSummary {
  final DsrRequestId id;
  final DsrRequestType type;
  final DsrStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DsrExportLink? exportLink;

  const DsrRequestSummary({
    required this.id,
    required this.type,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.exportLink,
  });

  /// Check if the request is in a terminal state
  bool get isTerminal =>
      status == DsrStatus.completed ||
      status == DsrStatus.failed ||
      status == DsrStatus.canceled;

  /// Check if the export is ready for download
  bool get isExportReady => status == DsrStatus.ready && exportLink != null;

  factory DsrRequestSummary.fromJson(Map<String, dynamic> json) {
    return DsrRequestSummary(
      id: DsrRequestId(json['id'] as String),
      type: DsrRequestType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DsrRequestType.export,
      ),
      status: DsrStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DsrStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      exportLink: json['export_link'] != null
          ? DsrExportLink(
              url: Uri.parse(json['export_link']['url'] as String),
              expiresAt: DateTime.parse(
                json['export_link']['expires_at'] as String,
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id.value,
    'type': type.name,
    'status': status.name,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'export_link': exportLink != null
        ? {
            'url': exportLink!.url.toString(),
            'expires_at': exportLink!.expiresAt.toIso8601String(),
          }
        : null,
  };

  @override
  String toString() {
    return 'DsrRequestSummary(id: ${id.value}, type: $type, status: $status, '
        'created: $createdAt, updated: $updatedAt, hasExport: ${exportLink != null})';
  }
}

/// DSR request data model
class DsrRequest {
  const DsrRequest({
    required this.id,
    required this.op,
    required this.createdAt,
    required this.status,
    this.errorMessage,
  });

  final String id;
  final DsrOperation op;
  final DateTime createdAt;
  final DsrStatus status;
  final String? errorMessage;
}

/// Abstract factory for creating DSR controllers
abstract class DsrFactory {
  DsrController create();
}

/// Abstract DSR controller interface
abstract class DsrController {
  Stream<DsrStatus> get status;
  Future<void> start(DsrOperation op);
  Future<void> cancel();
}

/// Exception thrown when DSR feature is disabled
class FeatureDisabledException implements Exception {
  final String message;

  const FeatureDisabledException(this.message);

  @override
  String toString() => 'FeatureDisabledException: $message';
}

/// Exception for DSR request conflicts (e.g., duplicate requests)
class DsrConflictException implements Exception {
  final String message;
  final DsrRequestId? existingRequestId;

  const DsrConflictException(this.message, [this.existingRequestId]);

  @override
  String toString() =>
      'DsrConflictException: $message${existingRequestId != null ? ' (existing: ${existingRequestId!.value})' : ''}';
}

/// Exception for DSR validation errors
class DsrValidationException implements Exception {
  final String message;

  const DsrValidationException(this.message);

  @override
  String toString() => 'DsrValidationException: $message';
}

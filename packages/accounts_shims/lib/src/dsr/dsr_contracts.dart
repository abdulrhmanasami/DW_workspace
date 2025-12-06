import 'package:dsr_ux_adapter/src/dsr_models.dart' as ux;

/// Type aliases that point to the canonical DSR models in dsr_ux_adapter.
typedef DsrRequestType = ux.DsrRequestType;
typedef DsrStatus = ux.DsrStatus;
typedef DsrRequestId = ux.DsrRequestId;
typedef DsrExportLink = ux.DsrExportLink;
typedef DsrRequestSummary = ux.DsrRequestSummary;

/// DSR operation types (mapped to request types for compatibility)
enum DsrOperation { export, erase }

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

/// DSR service interface (used by providers and implementations)
abstract class DataSubjectRightsService {
  Future<DsrRequestSummary> requestExport({bool includePaymentsHistory = false});

  Future<DsrRequestSummary> requestErasure();

  Future<DsrRequestSummary> getRequestStatus(DsrRequestId id);

  Future<void> cancelRequest(DsrRequestId id);

  Future<void> confirmErasure(DsrRequestId id);

  Stream<DsrRequestSummary> watchStatus(DsrRequestId id);
}

/// Helper to construct DSR summaries from backend JSON payloads.
DsrRequestSummary dsrRequestSummaryFromJson(Map<String, dynamic> json) {
  final typeStr = json['type'] as String? ?? 'export';
  final statusStr = json['status'] as String? ?? 'pending';

  final type = DsrRequestType.values.firstWhere(
    (e) => e.name == typeStr,
    orElse: () => DsrRequestType.export,
  );

  final status = DsrStatus.values.firstWhere(
    (e) => e.name == statusStr,
    orElse: () => DsrStatus.pending,
  );

  return DsrRequestSummary(
    id: DsrRequestId(json['id'] as String),
    type: type,
    status: status,
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
    payload: json['payload'] as Map<String, dynamic>?,
  );
}

/// Factory for constructing a DSR service with environment-dependent wiring.
abstract class DsrServiceFactory {
  DataSubjectRightsService createService();
}

/// Legacy factory/controller abstractions kept for compatibility with older wiring.
abstract class DsrFactory {
  DsrController create();
}

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

import 'package:json_annotation/json_annotation.dart';

part 'dsar_types.g.dart';

/// Supported DSAR request types.
enum DSARRequestType {
  access,
  portability,
  deletion,
  rectification,
}

/// Status values returned by the backend for an existing DSAR request.
enum DSARRequestStatus {
  pending,
  inProgress,
  fulfilled,
  rejected,
}

/// Attachment metadata returned for DSAR exports.
@JsonSerializable()
class DSARAttachment {
  DSARAttachment({
    required this.name,
    required this.url,
    required this.contentType,
    required this.expiresAt,
  });

  factory DSARAttachment.fromJson(Map<String, dynamic> json) =>
      _$DSARAttachmentFromJson(json);

  final String name;
  final Uri url;
  final String contentType;
  final DateTime expiresAt;

  Map<String, dynamic> toJson() => _$DSARAttachmentToJson(this);
}

/// Request payload that is submitted to the backend.
@JsonSerializable(explicitToJson: true)
class DSARRequest {
  DSARRequest({
    required this.requestId,
    required this.userId,
    required this.type,
    required this.createdAt,
    this.notes,
    this.payload,
  });

  factory DSARRequest.fromJson(Map<String, dynamic> json) =>
      _$DSARRequestFromJson(json);

  final String requestId;
  final String userId;
  final DSARRequestType type;
  final DateTime createdAt;
  final String? notes;
  final Map<String, dynamic>? payload;

  Map<String, dynamic> toJson() => _$DSARRequestToJson(this);
}

/// Response returned by the backend for DSAR operations.
@JsonSerializable(explicitToJson: true)
class DSARResponse {
  DSARResponse({
    required this.requestId,
    required this.status,
    required this.updatedAt,
    this.attachments = const [],
    this.message,
  });

  factory DSARResponse.fromJson(Map<String, dynamic> json) =>
      _$DSARResponseFromJson(json);

  final String requestId;
  final DSARRequestStatus status;
  final DateTime updatedAt;
  final List<DSARAttachment> attachments;
  final String? message;

  Map<String, dynamic> toJson() => _$DSARResponseToJson(this);
}

/// High-level category describing the type of personal data stored.
@JsonSerializable()
class DataCategory {
  DataCategory({
    required this.key,
    required this.title,
    required this.description,
    required this.containsPersonalData,
  });

  factory DataCategory.fromJson(Map<String, dynamic> json) =>
      _$DataCategoryFromJson(json);

  final String key;
  final String title;
  final String description;
  final bool containsPersonalData;

  Map<String, dynamic> toJson() => _$DataCategoryToJson(this);
}

/// Retention policy entry for a specific [DataCategory].
@JsonSerializable()
class DataRetentionPeriod {
  DataRetentionPeriod({
    required this.categoryKey,
    required this.retainedForDays,
  });

  factory DataRetentionPeriod.fromJson(Map<String, dynamic> json) =>
      _$DataRetentionPeriodFromJson(json);

  final String categoryKey;
  final int retainedForDays;

  Map<String, dynamic> toJson() => _$DataRetentionPeriodToJson(this);
}


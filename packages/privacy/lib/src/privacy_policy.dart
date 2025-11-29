import 'package:json_annotation/json_annotation.dart';

part 'privacy_policy.g.dart';

/// Metadata describing a privacy policy version hosted by the backend.
@JsonSerializable()
class PrivacyPolicy {
  PrivacyPolicy({
    required this.version,
    required this.publishedAt,
    required this.contentUrl,
    this.locale = 'en',
  });

  factory PrivacyPolicy.fromJson(Map<String, dynamic> json) =>
      _$PrivacyPolicyFromJson(json);

  final String version;
  final DateTime publishedAt;
  final Uri contentUrl;
  final String locale;

  Map<String, dynamic> toJson() => _$PrivacyPolicyToJson(this);
}


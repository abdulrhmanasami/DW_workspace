import 'package:privacy/src/privacy_policy.dart';

/// Types of consent that can be granted or denied by the user.
enum ConsentType {
  marketing,
  pushNotifications,
  telemetry,
}

/// Representation of a stored consent decision.
class ConsentRecord {
  ConsentRecord({
    required this.userId,
    required this.type,
    required this.granted,
    required this.updatedAt,
    this.policy,
  });

  final String userId;
  final ConsentType type;
  final bool granted;
  final DateTime updatedAt;
  final PrivacyPolicy? policy;
}


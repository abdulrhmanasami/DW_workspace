import '../privacy_policy.dart';

/// Associates a policy version with a locale for display purposes.
class LegalVersion {
  LegalVersion({
    required this.locale,
    required this.policy,
  });

  final String locale;
  final PrivacyPolicy policy;
}


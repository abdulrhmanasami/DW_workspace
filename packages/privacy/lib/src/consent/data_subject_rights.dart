import '../dsar/dsar_types.dart';

/// Represents a user-facing right (access, deletion, portability, etc.).
class DataSubjectRight {
  DataSubjectRight({
    required this.type,
    required this.title,
    required this.description,
  });

  final DSARRequestType type;
  final String title;
  final String description;
}

/// Catalog of the mandatory rights that must be exposed in PrivacyCenter UIs.
class DataSubjectRightsCatalog {
  DataSubjectRightsCatalog({
    List<DataSubjectRight>? rights,
  }) : rights = rights ?? _defaultRights;

  final List<DataSubjectRight> rights;

  static final List<DataSubjectRight> _defaultRights = [
    DataSubjectRight(
      type: DSARRequestType.access,
      title: 'Right of access',
      description: 'Users can request a full export of their personal data.',
    ),
    DataSubjectRight(
      type: DSARRequestType.deletion,
      title: 'Right to be forgotten',
      description: 'Users can request deletion or anonymization of data.',
    ),
    DataSubjectRight(
      type: DSARRequestType.portability,
      title: 'Right to portability',
      description: 'Users can obtain data in portable formats.',
    ),
  ];
}


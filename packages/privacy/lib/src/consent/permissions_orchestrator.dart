import 'consent_types.dart';

/// Simple orchestrator that can be wired into app state later.
class PermissionsOrchestrator {
  const PermissionsOrchestrator(this._records);

  final List<ConsentRecord> _records;

  bool hasGranted(ConsentType type) {
    final record = _records.firstWhere(
      (element) => element.type == type,
      orElse: () => ConsentRecord(
        userId: '',
        type: type,
        granted: false,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    return record.granted;
  }
}


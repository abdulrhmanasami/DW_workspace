import 'package:privacy/src/dsar/dsar_types.dart';
import 'package:test/test.dart';

void main() {
  group('DSARRequest', () {
    test('serializes to json', () {
      final request = DSARRequest(
        requestId: 'req_123',
        userId: 'user_42',
        type: DSARRequestType.access,
        createdAt: DateTime.utc(2025, 11, 21),
        notes: 'Export all data',
        payload: {'scope': 'all'},
      );

      final json = request.toJson();
      final restored = DSARRequest.fromJson(json);

      expect(restored.requestId, equals('req_123'));
      expect(restored.type, DSARRequestType.access);
      expect(restored.payload?['scope'], equals('all'));
    });
  });

  group('DSARResponse', () {
    test('includes attachments', () {
      final attachment = DSARAttachment(
        name: 'export.zip',
        url: Uri.parse('https://privacy.example/export.zip'),
        contentType: 'application/zip',
        expiresAt: DateTime.utc(2025, 11, 25),
      );

      final response = DSARResponse(
        requestId: 'req_123',
        status: DSARRequestStatus.fulfilled,
        updatedAt: DateTime.utc(2025, 11, 22),
        attachments: [attachment],
      );

      final json = response.toJson();
      final restored = DSARResponse.fromJson(json);

      expect(restored.attachments.single.name, equals('export.zip'));
      expect(restored.status, DSARRequestStatus.fulfilled);
    });
  });
}


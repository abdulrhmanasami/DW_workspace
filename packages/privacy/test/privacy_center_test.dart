import 'dart:async';
import 'dart:convert';

import 'package:network_shims/network_shims.dart';
import 'package:privacy/privacy.dart';
import 'package:test/test.dart';

class _FakeSecureHttpClient implements SecureHttpClient {
  _FakeSecureHttpClient(this._handler);

  final Future<StreamedResponse> Function(Request request) _handler;

  @override
  Future<StreamedResponse> send(Request request) => _handler(request);

  @override
  void close() {}
}

StreamedResponse _jsonResponse(int statusCode, Map<String, dynamic> body) {
  return StreamedResponse(
    stream: Stream.value(utf8.encode(jsonEncode(body))),
    statusCode: statusCode,
    headers: const {},
  );
}

void main() {
  group('PrivacyCenter', () {
    test('proxies consent checks to DSAR endpoint', () async {
      final client = _FakeSecureHttpClient((request) {
        expect(request.url.path, contains('/v1/privacy/consent'));
        expect(request.url.queryParameters['userId'], equals('user-001'));
        return Future.value(_jsonResponse(200, {'hasConsented': true}));
      });

      final config = PrivacyBackendConfig(
        baseUrl: Uri.parse('https://api.example.com'),
      );

      final center = createPrivacyCenter(
        client: client,
        config: config,
      );

      final result = await center.hasConsented('user-001');
      expect(result, isTrue);
    });

    test('issues deletion request via DataDeletionService', () async {
      final completer = Completer<Map<String, dynamic>>();
      final client = _FakeSecureHttpClient((request) async {
        final body = jsonDecode(request.body as String) as Map<String, dynamic>;
        completer.complete(body);
        return _jsonResponse(202, const {});
      });

      final config = PrivacyBackendConfig(
        baseUrl: Uri.parse('https://api.example.com'),
      );

      final center = createPrivacyCenter(
        client: client,
        config: config,
      );

      await center.deleteUserData('user-001', anonymize: true);
      final captured = await completer.future;
      expect(captured['userId'], equals('user-001'));
      expect(captured['anonymize'], isTrue);
    });
  });
}


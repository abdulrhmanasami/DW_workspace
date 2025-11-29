// Uplink Client Tests
// Created by: Cursor B-mobility
// Purpose: Test HTTP client with retry logic and error handling
// Last updated: 2025-11-14

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobility_uplink_impl/src/uplink_client.dart';
import 'package:mobility_uplink_impl/uplink_config.dart';

void main() {
  group('UplinkClient Tests', () {
    late UplinkConfig config;
    late MockClient mockClient;

    setUp(() {
      config = UplinkConfig(
        uplinkEnabled: true,
        flushInterval: const Duration(seconds: 10),
        batchSize: 50,
        maxQueue: 1000,
        endpoint: Uri.parse('https://api.example.com'),
        requestTimeout: const Duration(seconds: 15),
        maxRetries: 2,
      );

      mockClient = MockClient((request) async {
        if (request.url.path == '/success') {
          return http.Response('{"success": true}', 200);
        } else if (request.url.path == '/server-error') {
          return http.Response('Internal Server Error', 500);
        } else if (request.url.path == '/client-error') {
          return http.Response('Bad Request', 400);
        }
        return http.Response('Not Found', 404);
      });
    });

    test('successful request returns response', () async {
      final client = UplinkClient(config, httpClient: mockClient);
      final uri = config.endpoint!.resolve('/success');

      final response = await client.post(uri, {'test': 'data'});

      expect(response.statusCode, 200);
      expect(response.body, '{"success": true}');
    });

    test('server errors trigger retry', () async {
      int requestCount = 0;
      final retryClient = MockClient((request) async {
        requestCount++;
        if (request.url.path == '/server-error' && requestCount < 3) {
          return http.Response('Internal Server Error', 500);
        }
        return http.Response('{"success": true}', 200);
      });

      final client = UplinkClient(config, httpClient: retryClient);
      final uri = config.endpoint!.resolve('/server-error');

      final response = await client.post(uri, {'test': 'data'});

      expect(requestCount, 3); // Initial + 2 retries
      expect(response.statusCode, 200);
    });

    test('client errors do not trigger retry', () async {
      int requestCount = 0;
      final noRetryClient = MockClient((request) async {
        requestCount++;
        return http.Response('Bad Request', 400);
      });

      final client = UplinkClient(config, httpClient: noRetryClient);
      final uri = config.endpoint!.resolve('/client-error');

      expect(
        () => client.post(uri, {'test': 'data'}),
        throwsA(isA<UplinkHttpException>()),
      );

      expect(requestCount, 1); // Only initial request
    });

    test('max retries exceeded throws exception', () async {
      final alwaysFailClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final client = UplinkClient(config, httpClient: alwaysFailClient);
      final uri = config.endpoint!.resolve('/server-error');

      expect(
        () => client.post(uri, {'test': 'data'}),
        throwsA(isA<UplinkHttpException>()),
      );
    });

    test('timeout throws TimeoutException', () async {
      final slowClient = MockClient((request) async {
        await Future.delayed(
            const Duration(seconds: 20)); // Longer than timeout
        return http.Response('OK', 200);
      });

      final client = UplinkClient(config, httpClient: slowClient);
      final uri = config.endpoint!.resolve('/timeout');

      expect(
        () => client.post(uri, {'test': 'data'}),
        throwsA(isA<UplinkTimeoutException>()),
      );
    });
  });
}

/// HTTP client for accounts backend communication
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart';

import 'accounts_endpoints.dart';
import 'models.dart';

/// Provider for accounts client
final accountsClientProvider = Provider<AccountsClient>((ref) {
  final cfg = ConfigManager.instance;
  return AccountsClient(endpoints: AccountsEndpoints.fromConfig(cfg), cfg: cfg);
});

class AccountsClient {
  final AccountsEndpoints endpoints;
  final ConfigManager cfg;
  final Duration _timeout = const Duration(seconds: 15);

  AccountsClient({required this.endpoints, required this.cfg});

  /// Fetch current user profile
  Future<UserProfile> fetchMe() async {
    final tok = cfg.getString('auth_token');
    final resp = await http
        .get(endpoints.me, headers: _headers(tok))
        .timeout(_timeout);

    final map = _decodeOk(resp);
    return UserProfile.fromJson(map);
  }

  /// Ensure Stripe customer exists and return customer ID
  Future<String> ensureStripeCustomer() async {
    final tok = cfg.getString('auth_token');
    final resp = await http
        .post(endpoints.ensureStripeCustomer, headers: _headers(tok))
        .timeout(_timeout);

    final map = _decodeOk(resp);
    return map['stripe_customer_id'] as String;
  }

  /// Build headers with authorization if available
  Map<String, String> _headers(String? tok) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (tok != null && tok.isNotEmpty) 'Authorization': 'Bearer $tok',
  };

  /// Decode response and check for success
  Map<String, dynamic> _decodeOk(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('Accounts API ${r.statusCode}: ${r.body}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
}

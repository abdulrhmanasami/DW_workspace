/// Component: RBAC REST Client
/// Created by: Cursor (auto-generated)
/// Purpose: REST implementation of RBAC authorization client
/// Last updated: 2025-11-02

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:core/core.dart';
import 'package:network_shims/network_shims.dart';

/// REST implementation of RBACClient
class RbacRestClient implements RBACClient {
  final String baseUrl;
  final String? certPinsJson;
  late final SecureHttpClient _httpClient;

  RbacRestClient({
    required this.baseUrl,
    this.certPinsJson,
  }) {
    _initializeHttpClient();
  }

  void _initializeHttpClient() {
    // TODO: Initialize SecureHttpClient with certificate pinning
    // For now, we'll use regular HTTP client
    // _httpClient = SecureHttpClient();
  }

  @override
  Future<RBACDecision> authorize({
    required String action,
    required String resource,
    required String subjectId,
    Map<String, dynamic>? context,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/rbac/authorize');
      final body = {
        'action': action,
        'resource': resource,
        'subjectId': subjectId,
        if (context != null) 'context': context,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return RBACDecision(
          allowed: data['allowed'] as bool,
          reason: data['reason'] as String?,
        );
      } else {
        throw RBACException(
          'authorization_failed',
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw RBACException('authorization_error', e.toString());
    }
  }

  @override
  Future<bool> hasPermission({
    required String action,
    required String resource,
    required String subjectId,
  }) async {
    final decision = await authorize(
      action: action,
      resource: resource,
      subjectId: subjectId,
    );
    return decision.allowed;
  }

  @override
  Future<List<RBACPermission>> getSubjectPermissions(String subjectId) async {
    try {
      final url = Uri.parse('$baseUrl/rbac/permissions/$subjectId');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data.map((item) {
          final permission = item as Map<String, dynamic>;
          final resourceStr = permission['resource'] as String;
          final actionStr = permission['action'] as String;

          // Parse resource and action from strings
          final resource = RBACResource.values.firstWhere(
            (r) => r.name == resourceStr,
            orElse: () => RBACResource.userData, // fallback
          );

          final action = RBACAction.values.firstWhere(
            (a) => a.name == actionStr,
            orElse: () => RBACAction.read, // fallback
          );

          return RBACPermission(resource: resource, action: action);
        }).toList();
      } else {
        throw RBACException(
          'get_permissions_failed',
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw RBACException('get_permissions_error', e.toString());
    }
  }

  @override
  Future<UserRole?> getSubjectRole(String subjectId) async {
    try {
      final url = Uri.parse('$baseUrl/rbac/role/$subjectId');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final roleStr = data['role'] as String?;

        if (roleStr == null) return null;

        return UserRole.values.firstWhere(
          (role) => role.name == roleStr,
          orElse: () => UserRole.customer, // fallback
        );
      } else if (response.statusCode == 404) {
        return null; // Subject not found
      } else {
        throw RBACException(
          'get_role_failed',
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw RBACException('get_role_error', e.toString());
    }
  }
}

/// RBAC specific exceptions
class RBACException implements Exception {
  final String code;
  final String message;

  const RBACException(this.code, this.message);

  @override
  String toString() => 'RBACException($code): $message';
}

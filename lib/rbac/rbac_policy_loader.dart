import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class RbacPolicyLoader {
  static const _default = {
    "roles": {
      "guest": {"allow": []},
    },
    "screens": {},
  };

  Future<Map<String, dynamic>> load() async {
    try {
      final raw = await rootBundle.loadString('assets/rbac/policy.json');
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return _default;
    }
  }
}

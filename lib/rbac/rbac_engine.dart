import '../config/config_manager.dart';

class RbacEngine {
  final Map<String, dynamic> policy;
  final ConfigManager? _cfg;

  RbacEngine(this.policy, {ConfigManager? config}) : _cfg = config;

  String get currentRole => _cfg?.getString('user.role') ?? 'guest';

  bool canAccess(String screenId) {
    final roles =
        (policy['roles'] as Map?)?.cast<String, dynamic>() ?? const {};
    final screens =
        (policy['screens'] as Map?)?.cast<String, dynamic>() ?? const {};
    final role =
        (roles[currentRole] as Map?)?.cast<String, dynamic>() ??
        (roles['guest'] as Map?)?.cast<String, dynamic>() ??
        const {'allow': <String>[]};
    final allow = (role['allow'] as List?)?.cast<String>() ?? const <String>[];
    final minRole = (screens[screenId] as Map?)?['minRole'] as String?;
    if (minRole != null &&
        currentRole != 'admin' &&
        currentRole != minRole &&
        !allow.contains('*')) {
      return false;
    }
    return allow.contains('*') || allow.contains(screenId);
  }
}

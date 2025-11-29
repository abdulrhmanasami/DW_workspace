class RBACService {
  RBACService._();
  static final RBACService instance = RBACService._();

  bool shouldApplyRBAC(String? userId) => true;
  Map<String, dynamic> getStats() => <String, dynamic>{'users': 0, 'checks': 0};
}

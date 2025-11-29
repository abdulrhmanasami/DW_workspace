/// Endpoints configuration for accounts backend
import 'package:foundation_shims/foundation_shims.dart';

class AccountsEndpoints {
  final Uri me;
  final Uri ensureStripeCustomer;

  // DSR (Data Subject Rights) endpoints
  final Uri dsrCreate;
  final Uri Function(String) dsrStatus;
  final Uri Function(String) dsrCancel;
  final Uri Function(String) dsrConfirm;

  AccountsEndpoints._(
    this.me,
    this.ensureStripeCustomer,
    this.dsrCreate,
    this.dsrStatus,
    this.dsrCancel,
    this.dsrConfirm,
  );

  factory AccountsEndpoints.fromConfig(ConfigManager cfg) {
    final baseUrlStr = cfg.getString('accounts_backend_base_url');
    if (baseUrlStr == null || baseUrlStr.isEmpty) {
      throw StateError('ACCOUNTS_BACKEND_BASE_URL not configured');
    }

    final base = Uri.parse(baseUrlStr);
    return AccountsEndpoints._(
      base.resolve('/users/me'),
      base.resolve('/payments/ensure-stripe-customer'),
      base.resolve('/dsr/requests'),
      (id) => base.resolve('/dsr/requests/$id'),
      (id) => base.resolve('/dsr/requests/$id/cancel'),
      (id) => base.resolve('/dsr/requests/$id/confirm'),
    );
  }
}

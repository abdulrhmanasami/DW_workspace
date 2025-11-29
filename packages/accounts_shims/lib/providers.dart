/// Riverpod providers for DSR - LEGAL BARREL EXPORTS ONLY
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Import DSR contracts from the canonical location
import 'src/dsr/dsr_contracts.dart';

/// DSR factory provider - throws UnimplementedError to prevent incorrect wiring
final dsrFactoryProvider = Provider<DsrFactory>(
  (ref) => const _MissingDsrFactory(),
);

/// Missing DSR factory implementation - prevents incorrect wiring outside CI
class _MissingDsrFactory implements DsrFactory {
  const _MissingDsrFactory();

  @override
  DsrController create() {
    throw UnimplementedError(
      'DSR factory not wired. Import from accounts_shims/accounts.dart barrel only.',
    );
  }
}

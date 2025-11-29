/// NoOp implementation for accounts DSR operations
/// Created by: Cursor B-central - CENT-DSR-BOOTSTRAP Phase-01
/// Purpose: Safe stub implementation that does nothing
/// Last updated: 2025-11-16

import 'package:accounts_shims/accounts.dart';

/// NoOp DSR factory implementation
class NoOpDsrFactory implements DsrFactory {
  @override
  DsrController create() => const NoOpDsrController();
}

/// NoOp DSR controller implementation
class NoOpDsrController implements DsrController {
  const NoOpDsrController();

  @override
  Stream<DsrStatus> get status => const Stream<DsrStatus>.empty();

  @override
  Future<void> start(DsrOperation op) async {}

  @override
  Future<void> cancel() async {}
}

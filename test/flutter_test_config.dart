import 'dart:async';
import 'package:dsr_ux_adapter/dsr_ux_adapter.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  registerUxOverrides();
  await testMain();
}

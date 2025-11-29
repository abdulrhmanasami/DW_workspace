import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_stub_impl/providers.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Widget that provides notice presenter to downstream widgets
class DsrNoticeProvider extends ConsumerWidget {
  final Widget child;

  const DsrNoticeProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppNoticePresenter presenter = createMaterialNoticePresenter();

    return ProviderScope(
      overrides: [
        appNoticePresenterProvider.overrideWithValue(presenter),
      ],
      child: child,
    );
  }
}

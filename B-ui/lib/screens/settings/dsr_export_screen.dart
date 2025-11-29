// ignore_for_file: undefined_prefixed_name, non_type_as_type_argument, undefined_method
import '../../ui/ui.dart';
import 'package:accounts_shims/accounts.dart' as acc;

final dsrControllerProvider = Provider<acc.DsrController>((ref) {
  final factory = ref.watch(acc.dsrFactoryProvider);
  return factory.create();
});

final dsrStatusProvider = StreamProvider.autoDispose<acc.DsrStatus>((ref) {
  return ref.watch(dsrControllerProvider).status;
});

class DsrExportScreen extends ConsumerWidget {
  const DsrExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(dsrStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const DwText('Export Data', variant: DwTextVariant.body),
      ),
      body: AppCard.standard(
        child: statusAsync.when(
          loading: () => const LoadingView(),
          error: (error, stack) => const ErrorView(),
          data: (status) => Column(
            children: [
              DwText(
                'Data Export Status: ${status.name}',
                variant: DwTextVariant.body,
              ),
              SizedBox(height: DwSpacing().md),
              AppButton.primary(
                label: 'Start Export',
                onPressed: () => ref
                    .read(dsrControllerProvider)
                    .start(acc.DsrOperation.export),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class DsrErasureScreen extends ConsumerWidget {
  const DsrErasureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(dsrStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const DwText('Erase Data', variant: DwTextVariant.body),
      ),
      body: AppCard.standard(
        child: statusAsync.when(
          loading: () => const LoadingView(),
          error: (error, stack) => const ErrorView(),
          data: (status) => Column(
            children: [
              DwText(
                'Data Erasure Status: ${status.name}',
                variant: DwTextVariant.body,
              ),
              SizedBox(height: DwSpacing().md),
              AppButton.primary(
                label: 'Start Erasure',
                onPressed: () => ref
                    .read(dsrControllerProvider)
                    .start(acc.DsrOperation.erase),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

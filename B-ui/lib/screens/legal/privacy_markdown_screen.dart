import '../../ui/ui.dart';
import '../../ui/providers/legal_content_providers.dart';

class PrivacyMarkdownScreen extends ConsumerWidget {
  const PrivacyMarkdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacy = ref.watch(privacyMarkdownProvider);

    return Scaffold(
      appBar: AppBar(
        title: const DwText('Privacy Policy', variant: DwTextVariant.body),
      ),
      body: AppCard.standard(
        child: privacy.isEmpty
            ? const EmptyState()
            : SingleChildScrollView(child: SelectableText(privacy)),
      ),
    );
  }
}

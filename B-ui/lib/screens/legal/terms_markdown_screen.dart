import 'package:b_ui/ui/ui.dart';
import 'package:b_ui/ui/providers/legal_content_providers.dart';

class TermsMarkdownScreen extends ConsumerWidget {
  const TermsMarkdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final terms = ref.watch(termsMarkdownProvider);

    return Scaffold(
      appBar: AppBar(
        title: const DwText('Terms of Service', variant: DwTextVariant.body),
      ),
      body: AppCard.standard(
        child: terms.isEmpty
            ? const EmptyState()
            : SingleChildScrollView(child: SelectableText(terms)),
      ),
    );
  }
}

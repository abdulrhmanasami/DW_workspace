import 'package:b_ui/ui/ui.dart';

class AboutLegalScreen extends ConsumerWidget {
  const AboutLegalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const DwText('About', variant: DwTextVariant.body)),
      body: AppCard.standard(
        child: Column(
          children: [
            AppButton.primary(
              label: 'Licenses',
              onPressed: () {
                Navigator.of(context).pushNamed('/settings/licenses');
              },
            ),
            SizedBox(height: DwSpacing().md),
            AppButton.primary(
              label: 'Privacy Policy',
              onPressed: () {
                Navigator.of(context).pushNamed('/settings/legal/privacy');
              },
            ),
            SizedBox(height: DwSpacing().md),
            AppButton.primary(
              label: 'Terms of Service',
              onPressed: () {
                Navigator.of(context).pushNamed('/settings/legal/terms');
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart' show showLicensePage;
import 'package:b_ui/ui/ui.dart';

class LicensesBrowserScreen extends ConsumerWidget {
  const LicensesBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const DwText('Licenses', variant: DwTextVariant.body),
      ),
      body: AppCard.standard(
        child: Center(
          child: AppButton.primary(
            label: 'View Licenses',
            onPressed: () => showLicensePage(context: context),
          ),
        ),
      ),
    );
  }
}

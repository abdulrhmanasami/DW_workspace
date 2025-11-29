/// Licenses Browser Screen - Open source licenses viewer
/// Created by: UI-PHASE-01 (adapted from B-ux)
/// Purpose: Display open source licenses using Flutter's built-in license page
/// Last updated: 2025-11-16

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart' as ds;

class LicensesBrowserScreen extends ConsumerWidget {
  const LicensesBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ds.AppCard.standard(
      child: ds.AppButton.primary(
        label: 'عرض التراخيص المفتوحة المصدر',
        onPressed: () =>
            showLicensePage(context: context, applicationName: 'DeliveryWays'),
        expanded: true,
      ),
    );
  }
}

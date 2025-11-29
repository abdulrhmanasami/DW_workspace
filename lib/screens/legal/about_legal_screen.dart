/// About Legal Screen - Main legal information center
/// Created by: UI-PHASE-01 (adapted from B-ux)
/// Purpose: Display main legal information center with navigation to legal documents
/// Last updated: 2025-11-17

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart' as ds;

class AboutLegalScreen extends ConsumerWidget {
  const AboutLegalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
        return ds.AppCard.standard(
      child: Column(
        children: [
          ds.AppButton.primary(
            label: 'سياسة الخصوصية',
            onPressed: () => _navigateTo(context, '/settings/legal/privacy'),
            expanded: true,
          ),
          const SizedBox(height: 16),
          ds.AppButton.primary(
            label: 'شروط الاستخدام',
            onPressed: () => _navigateTo(context, '/settings/legal/terms'),
            expanded: true,
          ),
          const SizedBox(height: 16),
          ds.AppButton.primary(
            label: 'التراخيص المفتوحة المصدر',
            onPressed: () => _navigateTo(context, '/settings/licenses'),
            expanded: true,
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }
}

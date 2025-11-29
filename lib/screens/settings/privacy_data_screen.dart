import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart' as ds;
import 'package:dsr_ux_adapter/dsr_ux_adapter.dart' as dsr;

class PrivacyDataScreen extends ConsumerWidget {
  const PrivacyDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(ds.appThemeProvider);
    final exportEnabledAsync = ref.watch(dsr.dsrExportEnabledProvider);
    final erasureEnabledAsync = ref.watch(dsr.dsrErasureEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('البيانات والخصوصية')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إدارة بياناتك الشخصية', style: theme.typography.headline6),
            const SizedBox(height: 8),
            Text(
              'يمكنك طلب تصدير بياناتك أو حذف حسابك نهائياً',
              style: theme.typography.body2.copyWith(
                color: theme.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            exportEnabledAsync.when(
              data: (enabled) => _buildDataCard(
                theme,
                'تصدير بياناتي',
                'احصل على نسخة من جميع بياناتك الشخصية المخزنة في التطبيق',
                'ابدأ التصدير',
                enabled,
                () => Navigator.pushNamed(context, '/settings/dsr/export'),
              ),
              loading: () => _buildLoadingCard(theme, 'تصدير بياناتي'),
              error: (_, __) => _buildErrorCard(
                theme,
                'تصدير بياناتي',
                'تعذر التحقق من توفر هذه الميزة',
              ),
            ),
            const SizedBox(height: 16),
            erasureEnabledAsync.when(
              data: (enabled) => _buildDataCard(
                theme,
                'حذف حسابي',
                'احذف حسابك نهائياً وجميع البيانات المرتبطة به',
                'طلب حذف الحساب',
                enabled,
                () => Navigator.pushNamed(context, '/settings/dsr/erasure'),
              ),
              loading: () => _buildLoadingCard(theme, 'حذف حسابي'),
              error: (_, __) => _buildErrorCard(
                theme,
                'حذف حسابي',
                'تعذر التحقق من توفر هذه الميزة',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(
    ds.AppThemeData theme,
    String title,
    String description,
    String buttonText,
    bool enabled,
    VoidCallback onPressed,
  ) {
    return ds.AppCard.standard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: theme.typography.subtitle1)),
                if (!enabled)
                  Icon(Icons.block, color: theme.colors.error, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.typography.body2.copyWith(
                color: theme.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            ds.AppButton.primary(
              label: buttonText,
              expanded: true,
              onPressed: enabled ? onPressed : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(ds.AppThemeData theme, String title) {
    return ds.AppCard.standard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.typography.subtitle1),
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(
    ds.AppThemeData theme,
    String title,
    String errorMessage,
  ) {
    return ds.AppCard.standard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.typography.subtitle1),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: theme.typography.body2.copyWith(
                color: theme.colors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

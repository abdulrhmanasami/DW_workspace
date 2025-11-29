import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../../state/consent/consent_controller.dart';

class PrivacyConsentGate extends ConsumerStatefulWidget {
  final Widget child;

  const PrivacyConsentGate({super.key, required this.child});

  @override
  ConsumerState<PrivacyConsentGate> createState() => _PrivacyConsentGateState();
}

class _PrivacyConsentGateState extends ConsumerState<PrivacyConsentGate> {
  @override
  Widget build(BuildContext context) {
    final isUnknown = ref.watch(consentUnknownProvider);

    if (isUnknown) {
      return _buildConsentDialog();
    }

    return widget.child;
  }

  Widget _buildConsentDialog() {
    final controller = ref.read(consentControllerProvider.notifier);
    final theme = ref.watch(appThemeProvider);

    final denyAllButton = AppButton.primary(
      label: 'رفض الكل',
      onPressed: () async {
        await controller.denyAll();
      },
    );

    final acceptLimitedButton = AppButton.primary(
      label: 'السماح المحدود',
      onPressed: () async {
        await controller.acceptLimited();
      },
    );

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: theme.colors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الخصوصية أولاً', style: theme.typography.headline6),
                  const SizedBox(height: 16),
                  Text(
                    'نحن نحترم خصوصيتك. اختر كيف تريد مشاركة بياناتك معنا لتحسين تجربتك.',
                    style: theme.typography.body1,
                  ),
                  const SizedBox(height: 24),
                  _buildOptionCard(
                    theme,
                    'رفض الكل',
                    'لا مشاركة أي بيانات. قد تكون بعض الميزات محدودة.',
                    Icons.block,
                    theme.colors.error,
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    theme,
                    'السماح المحدود',
                    'مشاركة تحليلات الاستخدام فقط لتحسين التطبيق.',
                    Icons.analytics,
                    theme.colors.primary,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: denyAllButton),
                      const SizedBox(width: 12),
                      Expanded(child: acceptLimitedButton),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'يمكنك تغيير هذه الإعدادات في أي وقت من قائمة الإعدادات.',
                    style: theme.typography.caption.copyWith(
                      color: theme.colors.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    AppThemeData theme,
    String title,
    String description,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.typography.subtitle2),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.typography.caption.copyWith(
                    color: theme.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

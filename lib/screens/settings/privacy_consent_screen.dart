import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:delivery_ways_clean/state/consent/consent_controller.dart';

class PrivacyConsentScreen extends ConsumerStatefulWidget {
  const PrivacyConsentScreen({super.key});

  @override
  ConsumerState<PrivacyConsentScreen> createState() =>
      _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends ConsumerState<PrivacyConsentScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(consentControllerProvider);
    final controller = ref.read(consentControllerProvider.notifier);
    final appSwitch = ref.watch(appSwitchBuilderProvider);
    final theme = ref.watch(appThemeProvider);

    final analyticsSwitch = appSwitch.build(
      context,
      _ConcreteSwitchProps(
        value: state.analytics,
        onChanged: (value) => controller.setAnalytics(value),
        label: 'تحليلات الاستخدام',
      ),
    );

    final crashReportsSwitch = appSwitch.build(
      context,
      _ConcreteSwitchProps(
        value: state.crashReports,
        onChanged: (value) => controller.setCrashReports(value),
        label: 'تقارير الأعطال',
      ),
    );

    final backgroundLocationSwitch = appSwitch.build(
      context,
      _ConcreteSwitchProps(
        value: state.backgroundLocation,
        onChanged: (value) => controller.setBackgroundLocation(value),
        label: 'الموقع في الخلفية',
      ),
    );

    final saveButton = AppButton.primary(
      label: 'حفظ',
      expanded: true,
      onPressed: () async {
        await controller.applyAndPersist();
        if (mounted && state.error == null) {
          final noticePresenter = ref.read(appNoticePresenterProvider);
          noticePresenter(
            AppNotice.success(message: 'تم حفظ إعدادات الخصوصية'),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('الخصوصية والموافقة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تحكم في خصوصيتك', style: theme.typography.headline6),
            const SizedBox(height: 8),
            Text(
              'اختر ما تريد مشاركته معنا لتحسين تجربتك',
              style: theme.typography.body2.copyWith(
                color: theme.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Analytics Section
            _buildConsentSection(
              context,
              theme,
              'تحليلات الاستخدام',
              'يساعدنا في فهم كيفية استخدام التطبيق لتحسين الأداء والميزات',
              analyticsSwitch,
            ),

            const SizedBox(height: 16),

            // Crash Reports Section
            _buildConsentSection(
              context,
              theme,
              'تقارير الأعطال',
              'يرسل تقارير تلقائية عند حدوث أعطال لمساعدتنا في إصلاح المشاكل',
              crashReportsSwitch,
            ),

            const SizedBox(height: 16),

            // Background Location Section
            _buildConsentSection(
              context,
              theme,
              'الموقع في الخلفية',
              'يسمح بتتبع الموقع حتى عندما يكون التطبيق مغلقاً لتحسين خدمات التوصيل',
              backgroundLocationSwitch,
            ),

            const SizedBox(height: 24),
            saveButton,

            if (state.error != null) ...[
              const SizedBox(height: 16),
              Text(
                'خطأ: ${state.error}',
                style: theme.typography.caption.copyWith(
                  color: theme.colors.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConsentSection(
    BuildContext context,
    AppThemeData theme,
    String title,
    String description,
    Widget switchWidget,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.typography.subtitle1),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.typography.body2.copyWith(
              color: theme.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          switchWidget,
        ],
      ),
    );
  }
}

class _ConcreteSwitchProps implements AppSwitchProps {
  @override
  final bool value;
  @override
  final ValueChanged<bool> onChanged;
  @override
  final String? label;

  _ConcreteSwitchProps({
    required this.value,
    required this.onChanged,
    this.label,
  });
}

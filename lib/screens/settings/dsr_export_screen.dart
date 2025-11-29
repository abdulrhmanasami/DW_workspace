import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart' as ds;
import 'package:dsr_ux_adapter/dsr_ux_adapter.dart' as dsr;

class DsrExportScreen extends ConsumerStatefulWidget {
  const DsrExportScreen({super.key});

  @override
  ConsumerState<DsrExportScreen> createState() => _DsrExportScreenState();
}

class _DsrExportScreenState extends ConsumerState<DsrExportScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dsr.dsrExportStateProvider);
    final exportNotifier = ref.read(dsr.dsrExportStateProvider.notifier);
    final controller = ref.watch(dsr.dsrRequestControllerProvider);
    final appSwitch = ref.watch(ds.appSwitchBuilderProvider);
    final theme = ref.watch(ds.appThemeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تصدير البيانات')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تصدير بياناتك الشخصية', style: theme.typography.headline6),
            const SizedBox(height: 8),
            Text(
              'ستحصل على رابط آمن لتنزيل جميع بياناتك. الرابط صالح لمدة 7 أيام فقط.',
              style: theme.typography.body2.copyWith(
                color: theme.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ds.AppCard.standard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تضمين سجل المدفوعات',
                      style: theme.typography.subtitle2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'قد يحتوي سجل المدفوعات على معلومات حساسة. تأكد من مراجعة الملف بعناية.',
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    appSwitch.build(
                      context,
                      _ConcreteSwitchProps(
                        value: state.includePaymentsHistory,
                        onChanged: exportNotifier.setIncludePaymentsHistory,
                        label: 'تضمين سجل المدفوعات',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ds.AppButton.primary(
              label: 'ابدأ التصدير',
              expanded: true,
              onPressed: _canStartExport(state)
                  ? () => _startExport(controller, state.includePaymentsHistory)
                  : null,
            ),
            const SizedBox(height: 16),
            state.request.when(
              data: (summary) => summary != null
                  ? _buildStatusCard(theme, summary, controller)
                  : const SizedBox.shrink(),
              loading: () => _buildLoadingCard(theme),
              error: (error, _) => _buildErrorCard(theme, error.toString()),
            ),
          ],
        ),
      ),
    );
  }

  bool _canStartExport(dsr.DsrExportState state) {
    return state.request.value == null || state.request.value!.isTerminal;
  }

  Future<void> _startExport(
    dsr.DsrRequestController controller,
    bool includePaymentsHistory,
  ) async {
    final request = dsr.DsrRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      action: dsr.DsrAction.export,
      createdAt: DateTime.now(),
      payload: {
        'includePaymentsHistory': includePaymentsHistory,
      },
    );

    await controller.submit(request);
  }

  Widget _buildStatusCard(
    ds.AppThemeData theme,
    dsr.DsrRequestSummary summary,
    dsr.DsrRequestController controller,
  ) {
    final statusColor = _getStatusColor(theme, summary.status);
    final statusText = _getStatusText(summary.status);

    return ds.AppCard.standard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(summary.status),
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text('حالة الطلب', style: theme.typography.subtitle2),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              style: theme.typography.body2.copyWith(color: statusColor),
            ),
            const SizedBox(height: 8),
            Text(
              'تاريخ الطلب: ${_formatDateTime(summary.createdAt)}',
              style: theme.typography.caption,
            ),
            if (summary.isExportReady) ...[
              const SizedBox(height: 16),
              _buildExportLinkSection(theme, summary.exportLink!),
            ],
            if (summary.status == dsr.DsrStatus.inProgress) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'جارٍ تجهيز ملفك…',
                style: theme.typography.caption,
                textAlign: TextAlign.center,
              ),
            ],
            if (summary.status == dsr.DsrStatus.failed) ...[
              const SizedBox(height: 16),
              ds.AppButton.primary(
                label: 'إعادة المحاولة',
                expanded: true,
                onPressed: () => _startExport(
                  controller,
                  summary.payload?['includePaymentsHistory'] == true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExportLinkSection(
    ds.AppThemeData theme,
    dsr.DsrExportLink exportLink,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('رابط التنزيل', style: theme.typography.subtitle2),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colors.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exportLink.url.toString(),
                style: theme.typography.caption.copyWith(
                  fontFamily: 'monospace',
                  color: theme.colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ينتهي في: ${_formatDateTime(exportLink.expiresAt)}',
                style: theme.typography.caption.copyWith(
                  color: exportLink.isValid
                      ? theme.colors.success
                      : theme.colors.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ds.AppButton.primary(
          label: 'نسخ الرابط',
          expanded: true,
          onPressed: () => _copyToClipboard(exportLink.url.toString()),
        ),
      ],
    );
  }

  Widget _buildLoadingCard(ds.AppThemeData theme) {
    return ds.AppCard.standard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'جارٍ إرسال طلب التصدير…',
              style: theme.typography.body2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ds.AppThemeData theme, String error) {
    return ds.AppCard.standard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: theme.colors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'فشل في إرسال الطلب',
              style: theme.typography.subtitle2.copyWith(
                color: theme.colors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.typography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ds.AppThemeData theme, dsr.DsrStatus status) {
    switch (status) {
      case dsr.DsrStatus.pending:
        return theme.colors.warning;
      case dsr.DsrStatus.inProgress:
        return theme.colors.primary;
      case dsr.DsrStatus.ready:
        return theme.colors.success;
      case dsr.DsrStatus.completed:
        return theme.colors.success;
      case dsr.DsrStatus.failed:
        return theme.colors.error;
      case dsr.DsrStatus.canceled:
        return theme.colors.error;
    }
  }

  IconData _getStatusIcon(dsr.DsrStatus status) {
    switch (status) {
      case dsr.DsrStatus.pending:
        return Icons.schedule;
      case dsr.DsrStatus.inProgress:
        return Icons.sync;
      case dsr.DsrStatus.ready:
        return Icons.download_done;
      case dsr.DsrStatus.completed:
        return Icons.check_circle;
      case dsr.DsrStatus.failed:
        return Icons.error;
      case dsr.DsrStatus.canceled:
        return Icons.cancel;
    }
  }

  String _getStatusText(dsr.DsrStatus status) {
    switch (status) {
      case dsr.DsrStatus.pending:
        return 'في انتظار المراجعة';
      case dsr.DsrStatus.inProgress:
        return 'قيد المعالجة';
      case dsr.DsrStatus.ready:
        return 'جاهز للتنزيل';
      case dsr.DsrStatus.completed:
        return 'مكتمل';
      case dsr.DsrStatus.failed:
        return 'فشل في المعالجة';
      case dsr.DsrStatus.canceled:
        return 'ملغي';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      final noticePresenter = ref.read(ds.appNoticePresenterProvider);
      noticePresenter(ds.AppNotice.info(message: 'تم نسخ الرابط'));
    }
  }
}

class _ConcreteSwitchProps implements ds.AppSwitchProps {
  @override
  final bool value;
  @override
  final ValueChanged<bool> onChanged;
  @override
  final String? label;

  const _ConcreteSwitchProps({
    required this.value,
    required this.onChanged,
    this.label,
  });
}

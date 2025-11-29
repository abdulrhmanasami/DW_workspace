import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart' as ds;
import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:dsr_ux_adapter/dsr_ux_adapter.dart' as dsr;

class DsrErasureScreen extends ConsumerStatefulWidget {
  const DsrErasureScreen({super.key});

  @override
  ConsumerState<DsrErasureScreen> createState() => _DsrErasureScreenState();
}

class _DsrErasureScreenState extends ConsumerState<DsrErasureScreen> {
  final _spacing = DwSpacing();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dsr.dsrErasureStateProvider);
    final controller = ref.read(dsr.dsrControllerProvider);
    final erasureNotifier = ref.read(dsr.dsrErasureStateProvider.notifier);
    final theme = ref.watch(ds.appThemeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('حذف الحساب')),
      body: Padding(
        padding: EdgeInsets.all(_spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('حذف حسابك نهائياً', style: theme.typography.headline6),
            SizedBox(height: _spacing.sm),
            Text(
              'هذا الإجراء لا رجعة فيه. سيتم حذف جميع بياناتك وبيانات حسابك.',
              style: theme.typography.body2.copyWith(
                color: theme.colors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: _spacing.lg),
            _buildWarningCard(theme),
            SizedBox(height: _spacing.lg),
            ds.AppButton.primary(
              label: 'طلب حذف الحساب',
              expanded: true,
              onPressed: _canRequestErasure(state)
                  ? () => _requestErasure(controller, erasureNotifier)
                  : null,
            ),
            SizedBox(height: _spacing.md),
            state.request.when(
              data: (summary) => summary != null
                  ? _buildStatusCard(
                      theme,
                      summary,
                      controller,
                      erasureNotifier,
                      state.showConfirmation,
                    )
                  : const SizedBox.shrink(),
              loading: () => _buildLoadingCard(theme),
              error: (error, _) => _buildErrorCard(theme, error.toString()),
            ),
            const Spacer(),
            _buildLegalNotice(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard(ds.AppThemeData theme) {
    return ds.AppCard.standard(
      child: Padding(
        padding: EdgeInsets.all(_spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colors.error,
                  size: 24,
                ),
                SizedBox(height: _spacing.sm, width: _spacing.sm),
                Text(
                  'تحذير مهم',
                  style: theme.typography.subtitle2.copyWith(
                    color: theme.colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: _spacing.iconSm),
            ...[
              'سيتم حذف جميع بياناتك الشخصية نهائياً',
              'لن تتمكن من استرجاع حسابك أو بياناتك',
              'سيتم إلغاء جميع الطلبات والحجوزات النشطة',
              'سيتم حذف سجل المدفوعات والمعاملات',
              'قد يستغرق تنفيذ الطلب عدة أيام',
            ].map((point) => _buildWarningPoint(theme, point)),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningPoint(ds.AppThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: theme.typography.body2.copyWith(
              color: theme.colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: _spacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.typography.body2.copyWith(
                color: theme.colors.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalNotice(ds.AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colors.outline.withValues(alpha: 0.3)),
      ),
      child: Text(
        'حذف الحساب يخضع للائحة حماية البيانات العامة (GDPR). سنرسل لك تأكيداً قبل تنفيذ الحذف النهائي.',
        style: theme.typography.caption.copyWith(
          color: theme.colors.onSurface.withValues(alpha: 0.6),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  bool _canRequestErasure(dsr.DsrErasureState state) {
    return state.request.value == null || state.request.value!.isTerminal;
  }

  Future<void> _requestErasure(
    dsr.DsrController controller,
    dsr.DsrErasureNotifier notifier,
  ) async {
    try {
      await controller.requestErasure(
        onStatusUpdate: (summary) {
          notifier.setRequest(AsyncValue.data(summary));
          if (summary.status == dsr.DsrStatus.ready) {
            notifier.setShowConfirmation(true);
          }
        },
      );
    } catch (e, st) {
      notifier.setRequest(AsyncValue.error(e, st));
    }
  }

  Future<void> _confirmErasure(
    dsr.DsrRequestId id,
    dsr.DsrController controller,
    dsr.DsrErasureNotifier notifier,
  ) async {
    try {
      await controller.confirmErasure(
        id: id,
        onStatusUpdate: (summary) {
          notifier.setRequest(AsyncValue.data(summary));
          notifier.setShowConfirmation(false);
        },
      );
    } catch (e, st) {
      notifier.setRequest(AsyncValue.error(e, st));
    }
  }

  Future<void> _cancelErasure(
    dsr.DsrRequestId id,
    dsr.DsrController controller,
    dsr.DsrErasureNotifier notifier,
  ) async {
    try {
      await controller.cancelErasure(
        id: id,
        onStatusUpdate: (summary) {
          notifier.setRequest(AsyncValue.data(summary));
        },
      );
    } catch (e, st) {
      notifier.setRequest(AsyncValue.error(e, st));
    }
  }

  Widget _buildStatusCard(
    ds.AppThemeData theme,
    dsr.DsrRequestSummary summary,
    dsr.DsrController controller,
    dsr.DsrErasureNotifier notifier,
    bool showConfirmation,
  ) {
    final statusColor = _getStatusColor(theme, summary.status);
    final statusText = _getStatusText(summary.status);

    return ds.AppCard.standard(
      child: Padding(
        padding: EdgeInsets.all(_spacing.md),
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
                SizedBox(width: _spacing.sm),
                Text('حالة الطلب', style: theme.typography.subtitle2),
              ],
            ),
            SizedBox(height: _spacing.sm),
            Text(
              statusText,
              style: theme.typography.body2.copyWith(color: statusColor),
            ),
            SizedBox(height: _spacing.sm),
            Text(
              'تاريخ الطلب: ${_formatDateTime(summary.createdAt)}',
              style: theme.typography.caption,
            ),
            if (summary.status == dsr.DsrStatus.ready && showConfirmation) ...[
              SizedBox(height: _spacing.md),
              _buildConfirmationDialog(
                theme,
                summary.id,
                controller,
                notifier,
              ),
            ],
            if (summary.status == dsr.DsrStatus.inProgress) ...[
              SizedBox(height: _spacing.md),
              const LinearProgressIndicator(),
              SizedBox(height: _spacing.sm),
              Text(
                'جارٍ مراجعة طلبك…',
                style: theme.typography.caption,
                textAlign: TextAlign.center,
              ),
            ],
            if (summary.status == dsr.DsrStatus.failed) ...[
              SizedBox(height: _spacing.md),
              ds.AppButton.primary(
                label: 'إعادة المحاولة',
                expanded: true,
                onPressed: () => _requestErasure(controller, notifier),
              ),
            ],
            if (summary.status == dsr.DsrStatus.canceled) ...[
              SizedBox(height: _spacing.md),
              ds.AppButton.primary(
                label: 'طلب حذف جديد',
                expanded: true,
                onPressed: () => _requestErasure(controller, notifier),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationDialog(
    ds.AppThemeData theme,
    dsr.DsrRequestId id,
    dsr.DsrController controller,
    dsr.DsrErasureNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تأكيد الحذف النهائي',
            style: theme.typography.subtitle2.copyWith(
              color: theme.colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: _spacing.sm),
          Text(
            'هذا هو الخطوة الأخيرة. بعد التأكيد، سيتم حذف حسابك نهائياً خلال 30 يوماً ولن يمكن التراجع عن هذا القرار.',
            style: theme.typography.body2.copyWith(
              color: theme.colors.onSurface.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: _spacing.md),
          Row(
            children: [
              Expanded(
                child: ds.AppButton.primary(
                  label: 'إلغاء',
                  onPressed: () => _cancelErasure(id, controller, notifier),
                ),
              ),
              SizedBox(width: _spacing.iconSm),
              Expanded(
                child: ds.AppButton.primary(
                  label: 'تأكيد الحذف',
                  onPressed: () => _confirmErasure(id, controller, notifier),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(ds.AppThemeData theme) {
    return ds.AppCard.standard(
      child: Padding(
        padding: EdgeInsets.all(_spacing.md),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: _spacing.md),
            Text(
              'جارٍ إرسال طلب الحذف…',
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
        padding: EdgeInsets.all(_spacing.md),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: theme.colors.error, size: 48),
            SizedBox(height: _spacing.md),
            Text(
              'فشل في إرسال الطلب',
              style: theme.typography.subtitle2.copyWith(
                color: theme.colors.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _spacing.sm),
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
        return 'جاهز للتأكيد';
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
}

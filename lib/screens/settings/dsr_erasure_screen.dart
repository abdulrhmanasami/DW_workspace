import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart' as ds;
import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:dsr_ux_adapter/dsr_ux_adapter.dart' as dsr;

import '../../l10n/generated/app_localizations.dart';
import '../../widgets/app_shell.dart';

/// DSR Erasure Screen - Track D - Ticket #59
/// Allows users to request deletion of their account and personal data.
/// Updated to use L10n instead of hardcoded strings.
class DsrErasureScreen extends ConsumerStatefulWidget {
  const DsrErasureScreen({super.key});

  @override
  ConsumerState<DsrErasureScreen> createState() => _DsrErasureScreenState();
}

class _DsrErasureScreenState extends ConsumerState<DsrErasureScreen> {
  final _spacing = DwSpacing();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(dsr.dsrErasureStateProvider);
    final controller = ref.read(dsr.dsrControllerProvider);
    final erasureNotifier = ref.read(dsr.dsrErasureStateProvider.notifier);
    final theme = ref.watch(ds.appThemeProvider);

    return AppShell(
      title: l10n.dsrErasureTitle,
      showAppBar: true,
      showBottomNav: false,
      body: Padding(
        padding: EdgeInsets.all(_spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dsrErasureHeadline, style: theme.typography.headline6),
            SizedBox(height: _spacing.sm),
            Text(
              l10n.dsrErasureDescription,
              style: theme.typography.body2.copyWith(
                color: theme.colors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: _spacing.lg),
            _buildWarningCard(theme, l10n),
            SizedBox(height: _spacing.lg),
            ds.AppButton.primary(
              label: l10n.dsrErasureRequestButton,
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
                      l10n,
                    )
                  : const SizedBox.shrink(),
              loading: () => _buildLoadingCard(theme, l10n),
              error: (error, _) => _buildErrorCard(theme, l10n, error.toString()),
            ),
            const Spacer(),
            _buildLegalNotice(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard(ds.AppThemeData theme, AppLocalizations l10n) {
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
                  l10n.dsrErasureWarningTitle,
                  style: theme.typography.subtitle2.copyWith(
                    color: theme.colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: _spacing.iconSm),
            ...[
              l10n.dsrErasureWarningPoint1,
              l10n.dsrErasureWarningPoint2,
              l10n.dsrErasureWarningPoint3,
              l10n.dsrErasureWarningPoint4,
              l10n.dsrErasureWarningPoint5,
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

  Widget _buildLegalNotice(ds.AppThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colors.outline.withValues(alpha: 0.3)),
      ),
      child: Text(
        l10n.dsrErasureLegalNotice,
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
    AppLocalizations l10n,
  ) {
    final statusColor = _getStatusColor(theme, summary.status);
    final statusText = _getStatusText(summary.status, l10n);

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
                Text(l10n.dsrErasureRequestStatus, style: theme.typography.subtitle2),
              ],
            ),
            SizedBox(height: _spacing.sm),
            Text(
              statusText,
              style: theme.typography.body2.copyWith(color: statusColor),
            ),
            SizedBox(height: _spacing.sm),
            Text(
              l10n.dsrExportRequestDate(_formatDateTime(summary.createdAt)),
              style: theme.typography.caption,
            ),
            if (summary.status == dsr.DsrStatus.ready && showConfirmation) ...[
              SizedBox(height: _spacing.md),
              _buildConfirmationDialog(
                theme,
                summary.id,
                controller,
                notifier,
                l10n,
              ),
            ],
            if (summary.status == dsr.DsrStatus.inProgress) ...[
              SizedBox(height: _spacing.md),
              const LinearProgressIndicator(),
              SizedBox(height: _spacing.sm),
              Text(
                l10n.dsrErasureReviewingRequest,
                style: theme.typography.caption,
                textAlign: TextAlign.center,
              ),
            ],
            if (summary.status == dsr.DsrStatus.failed) ...[
              SizedBox(height: _spacing.md),
              ds.AppButton.primary(
                label: l10n.retry,
                expanded: true,
                onPressed: () => _requestErasure(controller, notifier),
              ),
            ],
            if (summary.status == dsr.DsrStatus.canceled) ...[
              SizedBox(height: _spacing.md),
              ds.AppButton.primary(
                label: l10n.dsrErasureNewRequest,
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
    AppLocalizations l10n,
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
            l10n.dsrErasureConfirmTitle,
            style: theme.typography.subtitle2.copyWith(
              color: theme.colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: _spacing.sm),
          Text(
            l10n.dsrErasureConfirmMessage,
            style: theme.typography.body2.copyWith(
              color: theme.colors.onSurface.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: _spacing.md),
          Row(
            children: [
              Expanded(
                child: ds.AppButton.primary(
                  label: l10n.cancel,
                  onPressed: () => _cancelErasure(id, controller, notifier),
                ),
              ),
              SizedBox(width: _spacing.iconSm),
              Expanded(
                child: ds.AppButton.primary(
                  label: l10n.dsrErasureConfirmButton,
                  onPressed: () => _confirmErasure(id, controller, notifier),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(ds.AppThemeData theme, AppLocalizations l10n) {
    return ds.AppCard.standard(
      child: Padding(
        padding: EdgeInsets.all(_spacing.md),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: _spacing.md),
            Text(
              l10n.dsrErasureSendingRequest,
              style: theme.typography.body2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ds.AppThemeData theme, AppLocalizations l10n, String error) {
    return ds.AppCard.standard(
      child: Padding(
        padding: EdgeInsets.all(_spacing.md),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: theme.colors.error, size: 48),
            SizedBox(height: _spacing.md),
            Text(
              l10n.dsrErasureRequestFailed,
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

  String _getStatusText(dsr.DsrStatus status, AppLocalizations l10n) {
    switch (status) {
      case dsr.DsrStatus.pending:
        return l10n.dsrErasureStatusPending;
      case dsr.DsrStatus.inProgress:
        return l10n.dsrErasureStatusInProgress;
      case dsr.DsrStatus.ready:
        return l10n.dsrErasureStatusReady;
      case dsr.DsrStatus.completed:
        return l10n.dsrErasureStatusCompleted;
      case dsr.DsrStatus.failed:
        return l10n.dsrErasureStatusFailed;
      case dsr.DsrStatus.canceled:
        return l10n.dsrErasureStatusCanceled;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

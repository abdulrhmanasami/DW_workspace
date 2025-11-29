import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:design_system_components/design_system_components.dart';
import 'package:design_system_foundation/design_system_foundation.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/ux/notifications_inbox_ux_providers.dart';

class SystemNotificationDetailScreen extends ConsumerWidget {
  const SystemNotificationDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final route = ModalRoute.of(context);
    final args = route?.settings.arguments as SystemNotificationDetailRouteArgs?;

    if (args == null || args.messageId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.notificationsSystemTitle),
        ),
        body: _SystemNotificationDetailError(message: l10n.notificationsInboxErrorGeneric),
      );
    }

    final detailAsync = ref.watch(systemNotificationDetailUxProvider(args.messageId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsSystemTitle),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          debugPrint('SystemNotificationDetailScreen error=$error stack=$stackTrace');
          return _SystemNotificationDetailError(message: l10n.notificationsInboxErrorGeneric);
        },
        data: (viewModel) => _SystemNotificationDetailView(viewModel: viewModel),
      ),
    );
  }
}

class _SystemNotificationDetailView extends StatelessWidget {
  const _SystemNotificationDetailView({required this.viewModel});

  final SystemNotificationDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = DwSpacing();
    final timestampLabel = _formatRelativeTimestamp(l10n, viewModel.timestamp);

    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(spacing.md, spacing.lg, spacing.md, spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DwText(
            viewModel.title,
            variant: DwTextVariant.title,
          ),
          SizedBox(height: spacing.xs),
          DwText(
            timestampLabel,
            variant: DwTextVariant.bodyMuted,
          ),
          SizedBox(height: spacing.md),
          DwCard(
            child: Padding(
              padding: EdgeInsetsDirectional.all(spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DwText(
                    viewModel.body,
                    variant: DwTextVariant.body,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemNotificationDetailError extends StatelessWidget {
  const _SystemNotificationDetailError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final spacing = DwSpacing();
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(spacing.lg),
        child: DwText(
          message,
          variant: DwTextVariant.body,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

String _formatRelativeTimestamp(AppLocalizations l10n, DateTime timestamp) {
  final now = DateTime.now();
  final diff = now.difference(timestamp);
  if (diff.inSeconds < 60) {
    return l10n.notificationsInboxTimeNow;
  }
  if (diff.inMinutes < 60) {
    return l10n.notificationsInboxTimeMinutes(diff.inMinutes);
  }
  if (diff.inHours < 24) {
    return l10n.notificationsInboxTimeHours(diff.inHours);
  }
  return l10n.notificationsInboxTimeDays(diff.inDays);
}


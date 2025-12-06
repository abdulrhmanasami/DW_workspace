import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:design_system_components/design_system_components.dart';
import 'package:design_system_foundation/design_system_foundation.dart';

import 'package:b_ui/l10n/generated/app_localizations.dart';
import 'package:b_ui/state/ux/notifications_inbox_ux_providers.dart';

class PromotionsNotificationsScreen extends ConsumerWidget {
  const PromotionsNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncPromotions = ref.watch(promotionsNotificationsUxProvider);
    final controllerState = ref.watch(notificationsInboxControllerProvider);
    final controller = ref.read(promotionsNotificationsUxControllerProvider);
    final emptyState = ref.watch(promotionsNotificationsEmptyStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsPromotionsTitle),
        actions: [
          PopupMenuButton<_PromotionsMenuAction>(
            tooltip: l10n.notificationsInboxMarkAllAsReadTooltip,
            onSelected: (action) =>
                _handlePromotionsMenuAction(context, controller, action, l10n),
            itemBuilder: (context) => [
              PopupMenuItem<_PromotionsMenuAction>(
                value: _PromotionsMenuAction.markAllAsRead,
                child: Text(l10n.notificationsInboxMarkAllAsReadTooltip),
              ),
              PopupMenuItem<_PromotionsMenuAction>(
                value: _PromotionsMenuAction.clearAll,
                child: Text(l10n.notificationsInboxClearAllTooltip),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (controllerState.isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: asyncPromotions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  _PromotionsError(error: error, stackTrace: stackTrace),
              data: (items) {
                if (emptyState.isEmpty) {
                  return const _PromotionsEmpty();
                }
                return _PromotionsList(items: items, controller: controller);
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum _PromotionsMenuAction { markAllAsRead, clearAll }

Future<void> _handlePromotionsMenuAction(
  BuildContext context,
  PromotionsNotificationsUxController controller,
  _PromotionsMenuAction action,
  AppLocalizations l10n,
) async {
  switch (action) {
    case _PromotionsMenuAction.markAllAsRead:
      try {
        await controller.markAllPromotionsAsRead();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.notificationsInboxMarkAsReadTooltip)),
        );
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.notificationsInboxErrorGeneric)),
        );
      }
      break;
    case _PromotionsMenuAction.clearAll:
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.notificationsInboxClearAllDialogTitle),
          content: Text(l10n.notificationsInboxClearAllDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.notificationsInboxClearAllConfirm),
            ),
          ],
        ),
      );
      if (confirmed == true && context.mounted) {
        try {
          await controller.clearAllPromotions();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.notificationsInboxClearAllConfirm)),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.notificationsInboxErrorGeneric)),
          );
        }
      }
      break;
  }
}

class _PromotionsList extends StatelessWidget {
  const _PromotionsList({
    required this.items,
    required this.controller,
  });

  final List<NotificationListItemViewModel> items;
  final PromotionsNotificationsUxController controller;

  @override
  Widget build(BuildContext context) {
    final spacing = DwSpacing();
    final l10n = AppLocalizations.of(context)!;

    return ListView.separated(
      padding: EdgeInsetsDirectional.fromSTEB(
        spacing.md,
        spacing.sm,
        spacing.md,
        spacing.lg,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: spacing.xs),
      itemBuilder: (context, index) {
        final item = items[index];
        final timestampLabel = _formatRelativeTimestamp(l10n, item.timestamp);

        return DwCard(
          child: InkWell(
            borderRadius: BorderRadius.circular(spacing.xs),
            onTap: () async {
              try {
                await controller.markPromotionAsRead(item.rawId);
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.notificationsInboxErrorGeneric)),
                );
              }
            },
            child: Padding(
              padding: EdgeInsetsDirectional.all(spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DwText(
                    item.title,
                    variant: item.isUnread ? DwTextVariant.title : DwTextVariant.body,
                  ),
                  SizedBox(height: spacing.xs),
                  DwText(
                    item.subtitle,
                    variant: DwTextVariant.bodyMuted,
                  ),
                  SizedBox(height: spacing.xs),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: DwText(
                      timestampLabel,
                      variant: DwTextVariant.label,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PromotionsError extends StatelessWidget {
  const _PromotionsError({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    debugPrint('PromotionsNotificationsScreen error=$error stack=$stackTrace');
    final l10n = AppLocalizations.of(context)!;
    final spacing = DwSpacing();

    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DwText(
              l10n.notificationsPromotionsErrorTitle,
              variant: DwTextVariant.title,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.sm),
            DwText(
              l10n.notificationsPromotionsErrorDescription,
              variant: DwTextVariant.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionsEmpty extends StatelessWidget {
  const _PromotionsEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = DwSpacing();

    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DwText(
              l10n.notificationsPromotionsEmptyTitle,
              variant: DwTextVariant.title,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.sm),
            DwText(
              l10n.notificationsPromotionsEmptyDescription,
              variant: DwTextVariant.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
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


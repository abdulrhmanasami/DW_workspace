import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:design_system_components/design_system_components.dart';
import 'package:design_system_foundation/design_system_foundation.dart';

import 'package:b_ui/l10n/generated/app_localizations.dart';
import 'package:b_ui/router/app_router.dart';
import 'package:b_ui/state/ux/notifications_inbox_ux_providers.dart';

class SystemNotificationsScreen extends ConsumerWidget {
  const SystemNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncSystem = ref.watch(systemNotificationsUxProvider);
    final controllerState = ref.watch(notificationsInboxControllerProvider);
    final controller = ref.read(systemNotificationsUxControllerProvider);
    final emptyState = ref.watch(systemNotificationsEmptyStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsSystemTitle),
        actions: [
          PopupMenuButton<_SystemMenuAction>(
            tooltip: l10n.notificationsInboxMarkAllAsReadTooltip,
            onSelected: (action) =>
                _handleSystemMenuAction(context, controller, action, l10n),
            itemBuilder: (context) => [
              PopupMenuItem<_SystemMenuAction>(
                value: _SystemMenuAction.markAllAsRead,
                child: Text(l10n.notificationsInboxMarkAllAsReadTooltip),
              ),
              PopupMenuItem<_SystemMenuAction>(
                value: _SystemMenuAction.clearAll,
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
            child: asyncSystem.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  _SystemError(error: error, stackTrace: stackTrace),
              data: (items) {
                if (emptyState.isEmpty) {
                  return const _SystemEmpty();
                }
                return _SystemList(items: items, controller: controller);
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum _SystemMenuAction { markAllAsRead, clearAll }

Future<void> _handleSystemMenuAction(
  BuildContext context,
  SystemNotificationsUxController controller,
  _SystemMenuAction action,
  AppLocalizations l10n,
) async {
  switch (action) {
    case _SystemMenuAction.markAllAsRead:
      try {
        await controller.markAllSystemMessagesAsRead();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.notificationsInboxMarkAsReadTooltip)),
        );
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.notificationsInboxErrorGeneric)),
        );
      }
      break;
    case _SystemMenuAction.clearAll:
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
          await controller.clearAllSystemMessages();
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

class _SystemList extends StatelessWidget {
  const _SystemList({
    required this.items,
    required this.controller,
  });

  final List<NotificationListItemViewModel> items;
  final SystemNotificationsUxController controller;

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
          child: ListTile(
            title: DwText(
              item.title,
              variant: item.isUnread ? DwTextVariant.title : DwTextVariant.body,
            ),
            subtitle: DwText(
              item.subtitle,
              variant: DwTextVariant.bodyMuted,
            ),
            trailing: DwText(
              timestampLabel,
              variant: DwTextVariant.label,
            ),
            onTap: () async {
              try {
                await controller.markSystemMessageAsRead(item.rawId);
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.notificationsInboxErrorGeneric)),
                );
                return;
              }

              if (!context.mounted) {
                return;
              }

              final messageId = _messageIdFor(item);
              if (messageId.isEmpty) {
                return;
              }

              await Navigator.of(context).pushNamed(
                RoutePaths.notificationsSystemDetail,
                arguments: SystemNotificationDetailRouteArgs(messageId: messageId),
              );
            },
          ),
        );
      },
    );
  }
}

String _messageIdFor(NotificationListItemViewModel item) {
  final action = item.action;
  if (action is NotificationActionOpenSystemMessage && action.messageId != null && action.messageId!.isNotEmpty) {
    return action.messageId!;
  }
  return item.id;
}

class _SystemError extends StatelessWidget {
  const _SystemError({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    debugPrint('SystemNotificationsScreen error=$error stack=$stackTrace');
    final l10n = AppLocalizations.of(context)!;
    final spacing = DwSpacing();

    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DwText(
              l10n.notificationsSystemErrorTitle,
              variant: DwTextVariant.title,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.sm),
            DwText(
              l10n.notificationsSystemErrorDescription,
              variant: DwTextVariant.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemEmpty extends StatelessWidget {
  const _SystemEmpty();

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
              l10n.notificationsSystemEmptyTitle,
              variant: DwTextVariant.title,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.sm),
            DwText(
              l10n.notificationsSystemEmptyDescription,
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


/// Notifications Inbox Screen
/// Renders production inbox UI backed by notifications UX providers.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:b_ui/l10n/generated/app_localizations.dart';
import 'package:b_ui/state/ux/notifications_inbox_ux_providers.dart';
import 'package:b_ui/screens/settings/notifications_settings_screen.dart';

class NotificationsInboxScreen extends ConsumerWidget {
  const NotificationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final inboxAsync = ref.watch(notificationsInboxUxProvider);
    final controllerState = ref.watch(notificationsInboxControllerProvider);
    final emptyState = ref.watch(notificationsInboxEmptyStateProvider);
    final controller = ref.read(notificationsInboxControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsInboxTitle),
        actions: [
          IconButton(
            tooltip: l10n.notificationsSettingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationsSettingsScreen(),
              ),
            ),
          ),
          PopupMenuButton<_InboxMenuAction>(
            tooltip: l10n.notificationsInboxMarkAllAsReadTooltip,
            onSelected: (action) async =>
                _handleMenuAction(context, controller, action, l10n),
            itemBuilder: (context) => [
              PopupMenuItem<_InboxMenuAction>(
                value: _InboxMenuAction.markAllAsRead,
                child: Text(l10n.notificationsInboxMarkAllAsReadTooltip),
              ),
              PopupMenuItem<_InboxMenuAction>(
                value: _InboxMenuAction.clearAll,
                child: Text(l10n.notificationsInboxClearAllTooltip),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (controllerState.isLoading)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: inboxAsync.when(
              loading: () => const _NotificationsInboxLoading(),
              error: (error, stackTrace) => _NotificationsInboxError(
                message: l10n.notificationsInboxErrorGeneric,
                onRetry: () => ref.refresh(notificationsInboxUxProvider),
              ),
              data: (items) {
                if (emptyState.isEmpty) {
                  return _NotificationsInboxEmpty(emptyState: emptyState);
                }
                return _NotificationsInboxList(
                  items: items,
                  controller: controller,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum _InboxMenuAction { markAllAsRead, clearAll }

Future<void> _handleMenuAction(
  BuildContext context,
  NotificationsInboxUxController controller,
  _InboxMenuAction action,
  AppLocalizations l10n,
) async {
  switch (action) {
    case _InboxMenuAction.markAllAsRead:
      await controller.markAllAsRead();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.notificationsInboxMarkAsReadTooltip)),
      );
      break;
    case _InboxMenuAction.clearAll:
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
        await controller.clearAll();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.notificationsInboxClearAllConfirm)),
        );
      }
      break;
  }
}

class _NotificationsInboxLoading extends StatelessWidget {
  const _NotificationsInboxLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _NotificationsInboxError extends StatelessWidget {
  const _NotificationsInboxError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 40),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context)!
                  .notificationsInboxRetryButtonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsInboxEmpty extends StatelessWidget {
  const _NotificationsInboxEmpty({required this.emptyState});

  final NotificationsEmptyStateViewModel emptyState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final NotificationAction? action = emptyState.primaryAction;
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.notificationsInboxEmptyTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.notificationsInboxEmptySubtitle,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: action == null
                  ? null
                  : () => _handleNotificationAction(context, action),
              child: Text(l10n.notificationsInboxEmptyCtaBackToHomeLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsInboxList extends StatelessWidget {
  const _NotificationsInboxList({
    required this.items,
    required this.controller,
  });

  final List<NotificationListItemViewModel> items;
  final NotificationsInboxUxController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 32),
      itemBuilder: (context, index) {
        final item = items[index];
        return _NotificationListTile(
          viewModel: item,
          controller: controller,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: items.length,
    );
  }
}

class _NotificationListTile extends StatelessWidget {
  const _NotificationListTile({
    required this.viewModel,
    required this.controller,
  });

  final NotificationListItemViewModel viewModel;
  final NotificationsInboxUxController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final timestamp = _formatRelativeTimestamp(l10n, viewModel.timestamp);

    return Semantics(
      label: viewModel.semanticsLabel,
      child: Card(
        elevation: viewModel.isUnread ? 2 : 0,
        color: viewModel.isUnread
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface,
        child: InkWell(
          onTap: () => _handleItemTap(context, l10n),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viewModel.isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsetsDirectional.only(end: 12, top: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: viewModel.isUnread
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        viewModel.subtitle,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timestamp,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleItemTap(
      BuildContext context, AppLocalizations l10n) async {
    try {
      await controller.markAsRead(viewModel);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.notificationsInboxErrorGeneric)),
      );
      return;
    }

    if (!context.mounted) return;
    _handleNotificationAction(context, viewModel.action);
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
}

void _handleNotificationAction(
    BuildContext context, NotificationAction action) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        AppLocalizations.of(context)!.notificationsInboxTappedGeneric,
      ),
    ),
  );
}

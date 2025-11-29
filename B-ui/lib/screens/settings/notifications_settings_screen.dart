/// Notifications Settings Screen
/// Created by: UX-NOTIF001 Implementation
/// Purpose: Production-ready notification preferences management
/// Last updated: 2025-11-19

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:design_system_components/design_system_components.dart';
import 'package:design_system_foundation/design_system_foundation.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/ux/notification_preferences_ux.dart';

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  static const routeName = '/settings/notifications';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(notificationPreferencesUxControllerProvider);
    final controller =
        ref.read(notificationPreferencesUxControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsSettingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: l10n.back,
        ),
      ),
      body: SafeArea(
        child: state.when(
          loading: () => const _NotificationsSettingsLoading(),
          error: (error, _) => _NotificationsSettingsError(
            message: l10n.notificationsSettingsErrorGeneric,
            onRetry: controller.refresh,
          ),
          data: (prefs) => _NotificationsSettingsContent(
            prefs: prefs,
            controller: controller,
          ),
        ),
      ),
    );
  }
}

class _NotificationsSettingsLoading extends StatelessWidget {
  const _NotificationsSettingsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _NotificationsSettingsError extends StatelessWidget {
  const _NotificationsSettingsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(_spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: _colors.error,
            ),
            SizedBox(height: _spacing.md),
            DwText(
              message,
              variant: DwTextVariant.body,
            ),
            SizedBox(height: _spacing.lg),
            DwButton(
              text: l10n.retry,
              onPressed: onRetry,
              variant: DwButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsSettingsContent extends StatelessWidget {
  const _NotificationsSettingsContent({
    required this.prefs,
    required this.controller,
  });

  final NotificationPreferencesViewModel prefs;
  final NotificationPreferencesUxController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(
        _spacing.md,
        _spacing.md,
        _spacing.md,
        _spacing.lg,
      ),
      children: [
        if (!prefs.marketingConsented) ...[
          DwCard(
            child: Padding(
              padding: EdgeInsetsDirectional.all(_spacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: _colors.warning,
                    size: 24,
                  ),
                  SizedBox(width: _spacing.sm),
                  Expanded(
                    child: DwText(
                      l10n.notificationsSettingsConsentRequired,
                      variant: DwTextVariant.body,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: _spacing.md),
        ],
        _NotificationToggleTile(
          title: l10n.notificationsSettingsOrderStatusTitle,
          subtitle: l10n.notificationsSettingsOrderStatusSubtitle,
          value: prefs.orderStatusUpdatesEnabled,
          onChanged: controller.updateOrderStatus,
        ),
        _NotificationToggleTile(
          title: l10n.notificationsSettingsPromotionsTitle,
          subtitle: l10n.notificationsSettingsPromotionsSubtitle,
          value: prefs.promotionsEnabled && prefs.canEditPromotions,
          onChanged:
              prefs.canEditPromotions ? controller.updatePromotions : null,
        ),
        _NotificationToggleTile(
          title: l10n.notificationsSettingsSystemTitle,
          subtitle: l10n.notificationsSettingsSystemSubtitle,
          value: prefs.systemAlertsEnabled,
          onChanged: controller.updateSystemAlerts,
        ),
        SizedBox(height: _spacing.md),
        _QuietHoursCard(
          prefs: prefs,
          controller: controller,
        ),
        SizedBox(height: _spacing.lg),
        const _OpenSystemSettingsButton(),
      ],
    );
  }
}

class _NotificationToggleTile extends StatelessWidget {
  const _NotificationToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DwCard(
      margin: EdgeInsetsDirectional.only(bottom: _spacing.sm),
      child: SwitchListTile.adaptive(
        contentPadding:
            EdgeInsetsDirectional.only(start: _spacing.sm, end: _spacing.sm),
        title: DwText(title, variant: DwTextVariant.body),
        subtitle: DwText(subtitle, variant: DwTextVariant.bodyMuted),
        value: value,
        onChanged: onChanged,
        activeTrackColor: _colors.primary,
      ),
    );
  }
}

class _OpenSystemSettingsButton extends StatelessWidget {
  const _OpenSystemSettingsButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DwButton(
      text: l10n.notificationsSettingsSystemSettingsButton,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notificationsSettingsSystemSettingsPlaceholder),
          ),
        );
      },
      variant: DwButtonVariant.secondary,
    );
  }
}

class _QuietHoursCard extends StatelessWidget {
  const _QuietHoursCard({
    required this.prefs,
    required this.controller,
  });

  final NotificationPreferencesViewModel prefs;
  final NotificationPreferencesUxController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasQuietHours = prefs.quietHoursLabel != null;
    final actionLabel = hasQuietHours
        ? l10n.notificationsQuietHoursEditActive
        : l10n.notificationsQuietHoursEdit;

    return DwCard(
      child: Padding(
        padding: EdgeInsetsDirectional.all(_spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DwText(l10n.notificationsQuietHoursTitle,
                variant: DwTextVariant.body),
            SizedBox(height: _spacing.xs),
            DwText(
              prefs.quietHoursLabel ??
                  (hasQuietHours
                      ? l10n.notificationsQuietHoursDescription
                      : l10n.notificationsQuietHoursInactive),
              variant: DwTextVariant.bodyMuted,
            ),
            SizedBox(height: _spacing.sm),
            Row(
              children: [
                DwButton(
                  text: actionLabel,
                  onPressed: () => _editQuietHours(context),
                  variant: DwButtonVariant.secondary,
                ),
                SizedBox(width: _spacing.sm),
                TextButton(
                  onPressed:
                      hasQuietHours ? () => _clearQuietHours(context) : null,
                  child: Text(l10n.notificationsQuietHoursDisable),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editQuietHours(BuildContext context) async {
    final initialStart = prefs.quietHoursStart ?? TimeOfDay.now();
    final start = await showTimePicker(
      context: context,
      initialTime: initialStart,
    );
    if (start == null) return;

    final fallbackEnd = prefs.quietHoursEnd ??
        start.replacing(
          hour: (start.hour + 1) % 24,
        );
    final end = await showTimePicker(
      context: context,
      initialTime: fallbackEnd,
    );
    if (end == null) return;

    await _saveQuietHours(context, start, end);
  }

  Future<void> _clearQuietHours(BuildContext context) {
    return _saveQuietHours(context, null, null);
  }

  Future<void> _saveQuietHours(
    BuildContext context,
    TimeOfDay? start,
    TimeOfDay? end,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await controller.updateQuietHours(start, end);
    } on QuietHoursValidationException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.notificationsQuietHoursInvalidRange)),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.notificationsQuietHoursSaveError)),
      );
    }
  }
}

// Design system instances (shared with other settings screens)
final DwColors _colors = DwColors();
final DwSpacing _spacing = DwSpacing();

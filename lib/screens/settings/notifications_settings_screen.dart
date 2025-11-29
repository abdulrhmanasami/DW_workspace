/// Notifications Settings Screen
/// Created by: UX-NOTIF001 Implementation (UX-005: Loading states + Sale-Only)
/// Purpose: Production-ready notification preferences management with enhanced UX
/// Last updated: 2025-11-25

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:design_system_shims/design_system_shims.dart' as ds;

import '../../state/ux/notification_preferences_ux.dart';
import '../../state/guidance/guidance_providers.dart';
import '../../widgets/in_app_hint_banner.dart';
import 'package:b_ui/ui_components.dart';

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  static const routeName = '/settings/notifications';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationPreferencesUxControllerProvider);
    final controller = ref.watch(
      notificationPreferencesUxControllerProvider.notifier,
    );
    final theme = ref.watch(ds.appThemeProvider);
    final spacing = theme.spacing;

    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات الإشعارات', style: theme.typography.headline6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'رجوع',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Notifications Importance Hint
            _NotificationsHintBanner(),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.all(spacing.md),
                child: state.when(
                  loading: () => const _NotificationsSettingsLoading(),
                  error: (e, _) => _NotificationsSettingsError(
                    theme: theme,
                    message: 'حدث خطأ في تحميل إعدادات الإشعارات',
                    onRetry: controller.refresh,
                  ),
                  data: (prefs) => _NotificationsSettingsContent(
                    theme: theme,
                    prefs: prefs,
                    onOrderStatusChanged: controller.updateOrderStatus,
                    onPromotionsChanged: controller.updatePromotions,
                    onSystemChanged: controller.updateSystemAlerts,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsSettingsLoading extends StatelessWidget {
  const _NotificationsSettingsLoading();

  @override
  Widget build(BuildContext context) {
    return const UiSkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info banner skeleton
          UiSkeletonCard(height: 60),
          SizedBox(height: 16),
          // Toggle tiles skeleton
          UiSkeletonCard(height: 72),
          SizedBox(height: 8),
          UiSkeletonCard(height: 72),
          SizedBox(height: 8),
          UiSkeletonCard(height: 72),
          SizedBox(height: 16),
          // Quiet hours skeleton
          UiSkeletonCard(height: 80),
          Spacer(),
          // Button skeleton
          UiSkeletonLine(height: 48, borderRadius: 8),
        ],
      ),
    );
  }
}

class _NotificationsSettingsError extends StatelessWidget {
  const _NotificationsSettingsError({
    required this.theme,
    required this.message,
    required this.onRetry,
  });

  final ds.AppThemeData theme;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final spacing = theme.spacing;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colors.error),
            SizedBox(height: spacing.md),
            Text(
              message,
              style: theme.typography.body2.copyWith(
                color: theme.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.lg),
            ds.AppButton.primary(label: 'إعادة المحاولة', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _NotificationsSettingsContent extends StatelessWidget {
  const _NotificationsSettingsContent({
    required this.theme,
    required this.prefs,
    required this.onOrderStatusChanged,
    required this.onPromotionsChanged,
    required this.onSystemChanged,
  });

  final ds.AppThemeData theme;
  final NotificationPreferencesViewModel prefs;
  final ValueChanged<bool> onOrderStatusChanged;
  final ValueChanged<bool> onPromotionsChanged;
  final ValueChanged<bool> onSystemChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!prefs.marketingConsented)
          ds.AppCard.standard(
            child: Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colors.warning, size: 24),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Text(
                      'يجب منح إذن الإشعارات لتفعيل هذه الإعدادات',
                      style: typography.body2.copyWith(color: colors.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!prefs.marketingConsented) SizedBox(height: spacing.md),
        _NotificationToggleTile(
          theme: theme,
          title: 'تحديثات الطلبات',
          subtitle: 'إشعارات عند تغيير حالة الطلب',
          value: prefs.orderStatusUpdatesEnabled,
          onChanged: onOrderStatusChanged,
        ),
        SizedBox(height: spacing.sm),
        _NotificationToggleTile(
          theme: theme,
          title: 'العروض والترويج',
          subtitle: 'إشعارات العروض والخصومات',
          value: prefs.promotionsEnabled && prefs.canEditPromotions,
          onChanged: prefs.canEditPromotions ? onPromotionsChanged : null,
        ),
        SizedBox(height: spacing.sm),
        _NotificationToggleTile(
          theme: theme,
          title: 'إشعارات النظام',
          subtitle: 'تحديثات وإشعارات مهمة من التطبيق',
          value: prefs.systemAlertsEnabled,
          onChanged: onSystemChanged,
        ),
        SizedBox(height: spacing.md),
        ds.AppCard.standard(
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ساعات الهدوء',
                  style: typography.subtitle1.copyWith(color: colors.onSurface),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  prefs.quietHoursLabel ?? 'لم يتم تفعيل وضع عدم الإزعاج',
                  style: typography.body2.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        const _OpenSystemSettingsButton(),
      ],
    );
  }
}

class _NotificationToggleTile extends StatelessWidget {
  const _NotificationToggleTile({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final ds.AppThemeData theme;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = theme.spacing;
    final colors = theme.colors;
    final typography = theme.typography;

    return ds.AppCard.standard(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        child: SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: typography.body2.copyWith(color: colors.onSurface),
          ),
          subtitle: Text(
            subtitle,
            style: typography.body2.copyWith(
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeTrackColor: colors.primary,
          activeThumbColor: colors.primary,
        ),
      ),
    );
  }
}

class _OpenSystemSettingsButton extends StatelessWidget {
  const _OpenSystemSettingsButton();

  @override
  Widget build(BuildContext context) {
    return ds.AppButton.primary(
      label: 'فتح إعدادات النظام',
      expanded: true,
      onPressed: () {
        // TODO: Implement opening system notification settings
        // For now, show a placeholder
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سيتم فتح إعدادات النظام قريباً')),
        );
      },
    );
  }
}

/// Notifications Hint Banner widget.
class _NotificationsHintBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintsAsync = ref.watch(notificationsHintsProvider);

    return hintsAsync.when(
      data: (hints) {
        if (hints.isEmpty) return const SizedBox.shrink();
        return InAppHintBanner(hint: hints.first);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

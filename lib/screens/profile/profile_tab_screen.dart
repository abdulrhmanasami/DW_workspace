import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/auth/passwordless_auth_controller.dart';
import '../../state/identity/identity_controller.dart';
import '../../ui/profile/profile_header_card.dart';
import '../../ui/profile/profile_menu_item.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_shell.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Profile Tab Screen
/// Displays user profile information and settings menu
/// Track A - Ticket #227: Profile / Settings Tab UI implementation
class ProfileTabScreen extends ConsumerWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(passwordlessAuthControllerProvider);

    // Track D-3: Use actual user data from PasswordlessAuthController
    final displayName = l10n.profileGuestName;
    final phoneNumber = authState.phoneE164 ?? l10n.profileGuestPhonePlaceholder;

    return AppShell(
      title: l10n.profileTitle,
      showAppBar: true,
      showBottomNav: false,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ProfileHeaderCard(
            displayName: displayName,
            phoneNumber: phoneNumber,
          ),
          const SizedBox(height: DWSpacing.sm),

          // Settings group
          _buildSectionHeader(context, l10n.profileSectionSettingsTitle),
          ProfileMenuItem(
            icon: Icons.person_outline,
            title: l10n.profileSettingsPersonalInfoTitle,
            subtitle: l10n.profileSettingsPersonalInfoSubtitle,
            onTap: () => _navigateToPersonalInfo(context),
          ),
          ProfileMenuItem(
            icon: Icons.directions_car_outlined,
            title: l10n.profileSettingsRidePrefsTitle,
            subtitle: l10n.profileSettingsRidePrefsSubtitle,
            onTap: () => _navigateToRidePreferences(context),
          ),
          ProfileMenuItem(
            icon: Icons.notifications_none,
            title: l10n.profileSettingsNotificationsTitle,
            subtitle: l10n.profileSettingsNotificationsSubtitle,
            onTap: () => _navigateToNotifications(context),
          ),
          ProfileMenuItem(
            icon: Icons.help_outline,
            title: l10n.profileSettingsHelpTitle,
            subtitle: l10n.profileSettingsHelpSubtitle,
            onTap: () => _navigateToHelpSupport(context),
          ),

          const SizedBox(height: DWSpacing.md),

          // DSR / Privacy group
          _buildSectionHeader(context, l10n.profileSectionPrivacyTitle),
          ProfileMenuItem(
            icon: Icons.download_outlined,
            title: l10n.profilePrivacyExportTitle,
            subtitle: l10n.profilePrivacyExportSubtitle,
            onTap: () => _navigateToDsrExport(context),
          ),
          ProfileMenuItem(
            icon: Icons.delete_forever_outlined,
            title: l10n.profilePrivacyErasureTitle,
            subtitle: l10n.profilePrivacyErasureSubtitle,
            onTap: () => _navigateToDsrErasure(context),
          ),

          const SizedBox(height: DWSpacing.md),

          // Logout button using AppButtonUnified
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DWSpacing.md),
            child: AppButtonUnified(
              label: l10n.profileLogoutTitle,
              onPressed: () => _handleLogout(context, ref),
              style: AppButtonStyle.secondary,
              leadingIcon: const Icon(Icons.logout),
            ),
          ),
          const SizedBox(height: DWSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DWSpacing.md,
        DWSpacing.sm,
        DWSpacing.md,
        DWSpacing.xs,
      ),
      child: Text(
        title,
        style: textTheme.labelLarge,
      ),
    );
  }

  void _navigateToPersonalInfo(BuildContext context) {
    Navigator.of(context).pushNamed(RoutePaths.settingsPersonalInfo);
  }

  void _navigateToRidePreferences(BuildContext context) {
    Navigator.of(context).pushNamed(RoutePaths.settingsRidePreferences);
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.of(context).pushNamed(RoutePaths.settingsNotifications);
  }

  void _navigateToHelpSupport(BuildContext context) {
    Navigator.of(context).pushNamed(RoutePaths.settingsHelpSupport);
  }

  void _navigateToDsrExport(BuildContext context) {
    Navigator.of(context).pushNamed(RoutePaths.dsrExport);
  }

  void _navigateToDsrErasure(BuildContext context) {
    Navigator.of(context).pushNamed(RoutePaths.dsrErasure);
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    // Track D-3: Use actual logout logic from IdentityController
    final identityController = ref.read(identityControllerProvider.notifier);
    identityController.signOut();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.profileLogoutSnack)),
    );
  }
}

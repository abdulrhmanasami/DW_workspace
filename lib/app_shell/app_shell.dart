/// Root App Shell for Delivery Ways Super-App
/// Created by: Track A - Ticket #2
/// Updated by: Track D - Ticket #5 (Profile tab implementation)
/// Updated by: Track B - Ticket #19 (Home Hub Active Ride Card)
/// Updated by: Track B - Ticket #20 (Ride → RideDestinationScreen)
/// Updated by: Ticket #32 (App Shell + Home Hub DWTheme consistency)
/// Updated by: Track D - Ticket #36 (Phone + OTP Auth flow)
/// Updated by: Track D - Ticket #37 (Account Bottom Sheet + Sign out)
/// Updated by: Track C - Ticket #51 (Orders Tab → OrdersHistoryScreen)
/// Purpose: Unified AppShell with Bottom Navigation (Home, Orders, Payments, Profile)
/// Last updated: 2025-11-29
///
/// This widget serves as the main entry point for authenticated users,
/// providing a consistent navigation structure across the app.
/// NOTE: Map integration & real data will be wired in Tracks B/C, this is a UI shell only.

import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_shims/mobility_shims.dart';
import 'package:design_system_shims/design_system_shims.dart'
    show DWButton, DWSpacing, DWRadius;

import '../config/feature_flags.dart';
import '../router/app_router.dart';
import '../screens/auth/phone_sign_in_screen.dart';
import '../screens/food/food_coming_soon_screen.dart';
import '../screens/orders/orders_history_screen.dart';
import '../state/auth/auth_state.dart';
import '../state/infra/auth_providers.dart';
import '../state/mobility/ride_trip_session.dart';
import '../state/mobility/ride_draft_state.dart';
import '../state/mobility/ride_quote_controller.dart';

/// Root App Shell for Delivery Ways Super-App
/// Tabs: Home, Orders, Payments, Profile
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const <Widget>[
          _HomeTab(), // Home Hub
          OrdersHistoryScreen(), // Orders history (Track C - Ticket #51)
          _PaymentsTabStub(), // Payments (stub for now)
          _ProfileTab(), // Profile & Settings (Track D - Ticket #5)
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        // Design System: 4 tabs as per spec (Home, Orders, Payments, Profile)
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.payment_outlined),
            selectedIcon: Icon(Icons.payment),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Home Hub tab – map-centric layout + service cards (Ride / Parcels / Food)
/// Updated by: Track B - Ticket #19 (Home Hub Active Ride Card)
/// NOTE: Map integration & real data will be wired in Tracks B/C, this is a UI shell only.
class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  /// Check if a phase is terminal (completed/cancelled/failed).
  bool _isTerminal(RideTripPhase phase) =>
      phase == RideTripPhase.completed ||
      phase == RideTripPhase.cancelled ||
      phase == RideTripPhase.failed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    // Watch ride state providers (Track B - Ticket #19)
    final tripSession = ref.watch(rideTripSessionProvider);
    final rideDraft = ref.watch(rideDraftProvider);
    final quoteState = ref.watch(rideQuoteControllerProvider);
    final quote = quoteState.quote;

    // Extract destination and selected option
    final destination = rideDraft.destinationQuery.trim();
    final selectedOptionId = rideDraft.selectedOptionId;

    final selectedOption = quote == null
        ? null
        : (selectedOptionId != null
            ? quote.optionById(selectedOptionId) ?? quote.recommendedOption
            : quote.recommendedOption);

    // Determine if there's an active (non-terminal) trip
    // Use local binding to avoid null assertion warnings
    final activeTripState = tripSession.activeTrip;
    final hasActiveTrip =
        activeTripState != null && !_isTerminal(activeTripState.phase);

    // Adjust map aspect ratio based on active trip
    final aspectRatio = hasActiveTrip ? (16 / 6) : (16 / 9);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Bar: location + profile icon
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: DWSpacing.md,
              vertical: DWSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current location',
                        style: textTheme.titleMedium,
                      ),
                      Text(
                        'Set your pickup point',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Track D - Ticket #37: Open Account Bottom Sheet
                    showModalBottomSheet<void>(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(DWRadius.lg),
                        ),
                      ),
                      builder: (sheetContext) {
                        return _AccountBottomSheet(
                          parentContext: context,
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.account_circle),
                ),
              ],
            ),
          ),

          // Map area (placeholder for now – real Map will come from maps_shims in Track B)
          // واضح أنه Placeholder حتى لا يُعتبر ميزة جاهزة.
          // Aspect ratio adjusts when active trip exists (Track B - Ticket #19)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DWSpacing.md),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(DWRadius.md),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: DWSpacing.xs),
                      Text(
                        'Map area (stub)',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'To be replaced with maps_shims integration',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: DWSpacing.md),

          // Service Cards: Ride / Parcels / Food
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: DWSpacing.md),
              child: ListView(
                children: [
                  // Active Ride Card (Track B - Ticket #19)
                  if (activeTripState != null && hasActiveTrip) ...[
                    _ActiveRideHomeCard(
                      phase: activeTripState.phase,
                      destinationLabel: destination.isEmpty
                          ? null
                          : l10n.rideActiveDestinationLabel(destination),
                      selectedOption: selectedOption,
                      onViewTrip: () {
                        Navigator.of(context).pushNamed(RoutePaths.rideActive);
                      },
                    ),
                    SizedBox(height: DWSpacing.md),
                  ],
                  Text(
                    'Services',
                    style: textTheme.headlineSmall,
                  ),
                  SizedBox(height: DWSpacing.xs),
                  _ServiceCard(
                    icon: Icons.directions_car,
                    title: 'Ride',
                    subtitle: 'Get a ride, instantly.',
                    onTap: () {
                      // Track B - Ticket #20: Navigate to RideDestinationScreen
                      Navigator.of(context).pushNamed(RoutePaths.rideDestination);
                    },
                  ),
                  SizedBox(height: DWSpacing.xs),
                  _ServiceCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Parcels',
                    subtitle: 'Send anything, anywhere.',
                    onTap: () {
                      // Track C - Ticket #40: Parcels Feature Flag gate
                      if (FeatureFlags.enableParcelsMvp) {
                        Navigator.of(context).pushNamed(RoutePaths.parcelsHome);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.parcelsComingSoonMessage,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: DWSpacing.xs),
                  _ServiceCard(
                    icon: Icons.fastfood_outlined,
                    title: 'Food',
                    subtitle: 'Your favorite food, delivered.',
                    onTap: () {
                      // Track C - Ticket #48: Food Feature Flag gate
                      if (!FeatureFlags.enableFoodMvp) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const FoodComingSoonScreen(),
                          ),
                        );
                        return;
                      }
                      // TODO: Wire to Food flow when enableFoodMvp == true.
                    },
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

/// Helper function to generate the headline based on trip phase and ETA.
/// Track B - Ticket #19
String _homeActiveRideHeadline({
  required AppLocalizations l10n,
  required RideTripPhase phase,
  required RideQuoteOption? selectedOption,
}) {
  final etaMinutes = selectedOption?.etaMinutes;

  switch (phase) {
    case RideTripPhase.findingDriver:
      return l10n.rideActiveHeadlineFindingDriver;
    case RideTripPhase.driverAccepted:
      if (etaMinutes != null) {
        return l10n.rideActiveHeadlineDriverEta(etaMinutes.toString());
      }
      return l10n.rideActiveHeadlineDriverOnTheWay;
    case RideTripPhase.driverArrived:
      return l10n.rideActiveHeadlineDriverArrived;
    case RideTripPhase.inProgress:
      return l10n.rideActiveHeadlineInProgress;
    case RideTripPhase.payment:
      return l10n.rideActiveHeadlinePayment;
    case RideTripPhase.completed:
      return l10n.rideActiveHeadlineCompleted;
    case RideTripPhase.cancelled:
      return l10n.rideActiveHeadlineCancelled;
    case RideTripPhase.failed:
      return l10n.rideActiveHeadlineFailed;
    case RideTripPhase.draft:
    case RideTripPhase.quoting:
    case RideTripPhase.requesting:
      return l10n.rideActiveHeadlinePreparing;
  }
}

/// Active Ride Card displayed on Home Hub when there's an active trip.
/// Track B - Ticket #19
/// Updated by: Ticket #32 (DWSpacing/DWRadius consistency)
class _ActiveRideHomeCard extends StatelessWidget {
  const _ActiveRideHomeCard({
    required this.phase,
    required this.destinationLabel,
    required this.selectedOption,
    required this.onViewTrip,
  });

  final RideTripPhase phase;
  final String? destinationLabel;
  final RideQuoteOption? selectedOption;
  final VoidCallback onViewTrip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final headline = _homeActiveRideHeadline(
      l10n: l10n,
      phase: phase,
      selectedOption: selectedOption,
    );

    return Card(
      // Uses CardTheme from DWTheme (radius: DWRadius.md, elevation: DWElevation.medium)
      child: Padding(
        padding: EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car_filled, color: colorScheme.primary),
                SizedBox(width: DWSpacing.sm),
                Expanded(
                  child: Text(
                    headline,
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (destinationLabel != null && destinationLabel!.isNotEmpty) ...[
              SizedBox(height: DWSpacing.xxs),
              Text(
                destinationLabel!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: DWSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: DWButton.tertiary(
                label: l10n.homeActiveRideViewTripCta,
                onPressed: onViewTrip,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Service Card widget for Home Hub
/// Uses Theme.of(context) for unified styling (Track A - Ticket #1)
/// Updated by: Ticket #32 (DWSpacing/DWRadius consistency)
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      // Uses CardTheme from DWTheme (radius: DWRadius.md, elevation: DWElevation.medium)
      child: InkWell(
        borderRadius: BorderRadius.circular(DWRadius.md),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(DWSpacing.md),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(DWSpacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DWRadius.md),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 28),
              ),
              SizedBox(width: DWSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: DWSpacing.xxs),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Payments Tab Stub
/// NOTE: Payment Methods to be implemented in Track C
class _PaymentsTabStub extends StatelessWidget {
  const _PaymentsTabStub();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: DWSpacing.md),
            Text(
              'Payments',
              style: textTheme.headlineSmall,
            ),
            SizedBox(height: DWSpacing.xs),
            Text(
              'Payment methods will be implemented in future tracks',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile Tab - Track D - Ticket #5
/// Full Profile/Settings implementation with DSR integration
/// Updated by: Ticket #32 (DWSpacing/DWRadius consistency)
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Get auth state for user info
    final authStateAsync = ref.watch(authStateProvider);

    String? phone;
    String? displayName;

    authStateAsync.whenData((state) {
      if (state.isAuthenticated && state.session != null) {
        phone = state.session!.user.phoneNumber;
        displayName = state.session!.user.displayName;
      }
    });

    final effectiveName = displayName?.trim().isNotEmpty == true
        ? displayName!
        : l10n.profileUserFallbackName;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Text(
              l10n.profileTitle,
              style: textTheme.headlineMedium,
            ),
            SizedBox(height: DWSpacing.md),

            // User Info Card
            Card(
              // Uses CardTheme from DWTheme (radius: DWRadius.md)
              child: Padding(
                padding: EdgeInsets.all(DWSpacing.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person,
                        color: colorScheme.primary,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: DWSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            effectiveName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: DWSpacing.xxs),
                          Text(
                            phone ?? '—',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: DWSpacing.lg),

            // Settings Section
            Text(
              l10n.profileSectionSettingsTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: DWSpacing.xs),

            _ProfileListTile(
              icon: Icons.person_outline,
              title: l10n.profileSettingsPersonalInfoTitle,
              subtitle: l10n.profileSettingsPersonalInfoSubtitle,
              enabled: false,
              onTap: null,
            ),
            _ProfileListTile(
              icon: Icons.settings_suggest_outlined,
              title: l10n.profileSettingsRidePrefsTitle,
              subtitle: l10n.profileSettingsRidePrefsSubtitle,
              enabled: false,
              onTap: null,
            ),
            _ProfileListTile(
              icon: Icons.notifications_outlined,
              title: l10n.profileSettingsNotificationsTitle,
              subtitle: l10n.profileSettingsNotificationsSubtitle,
              enabled: false,
              onTap: null,
            ),
            _ProfileListTile(
              icon: Icons.help_outline,
              title: l10n.profileSettingsHelpTitle,
              subtitle: l10n.profileSettingsHelpSubtitle,
              enabled: false,
              onTap: null,
            ),

            SizedBox(height: DWSpacing.lg),

            // Privacy & Data Section (DSR)
            Text(
              l10n.profileSectionPrivacyTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: DWSpacing.xs),

            _ProfileListTile(
              icon: Icons.download_outlined,
              title: l10n.profilePrivacyExportTitle,
              subtitle: l10n.profilePrivacyExportSubtitle,
              enabled: true,
              onTap: () => _openDsrExport(context),
            ),
            _ProfileListTile(
              icon: Icons.delete_forever_outlined,
              title: l10n.profilePrivacyErasureTitle,
              subtitle: l10n.profilePrivacyErasureSubtitle,
              enabled: true,
              onTap: () => _openDsrErasure(context),
            ),

            SizedBox(height: DWSpacing.lg),

            // Logout
            _ProfileListTile(
              icon: Icons.logout,
              title: l10n.profileLogoutTitle,
              subtitle: l10n.profileLogoutSubtitle,
              enabled: true,
              onTap: () => _logout(ref, context),
            ),
          ],
        ),
      ),
    );
  }

  void _openDsrExport(BuildContext context) {
    Navigator.of(context).pushNamed(RoutePaths.dsrExport);
  }

  void _openDsrErasure(BuildContext context) {
    Navigator.of(context).pushNamed(RoutePaths.dsrErasure);
  }

  Future<void> _logout(WidgetRef ref, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileLogoutDialogTitle),
        content: Text(l10n.profileLogoutDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.profileLogoutDialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.profileLogoutDialogConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final authService = ref.read(authServiceProvider);
        await authService.logout();
      } catch (e) {
        // Handle error silently - auth state will update automatically
        debugPrint('Logout error: $e');
      }
    }
  }
}

/// Helper widget for profile list tiles
/// Updated by: Ticket #32 (DWSpacing/DWRadius consistency)
class _ProfileListTile extends StatelessWidget {
  const _ProfileListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(vertical: DWSpacing.xxs),
      // Uses CardTheme from DWTheme (radius: DWRadius.md)
      child: ListTile(
        enabled: enabled,
        leading: Icon(
          icon,
          color: enabled ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: textTheme.bodyLarge?.copyWith(
            color: enabled ? null : colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: enabled ? colorScheme.onSurfaceVariant : colorScheme.outline,
        ),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}

/// Account Bottom Sheet for Home Hub
/// Created by: Track D - Ticket #37
/// Shows sign-in CTA when not authenticated, or user info + sign out when authenticated.
class _AccountBottomSheet extends ConsumerWidget {
  const _AccountBottomSheet({
    required this.parentContext,
  });

  /// Parent context for navigation outside the sheet
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final authState = ref.watch(simpleAuthStateProvider);
    final isAuthenticated = authState.isAuthenticated;
    final phoneNumber = authState.phoneNumber;

    return Padding(
      padding: const EdgeInsets.all(DWSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(DWRadius.circle),
              ),
            ),
          ),
          const SizedBox(height: DWSpacing.lg),

          // Title
          Text(
            l10n.accountSheetTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: DWSpacing.sm),

          if (!isAuthenticated) ...[
            // Signed-out state
            Text(
              l10n.accountSheetSignedOutSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DWSpacing.lg),

            DWButton.primary(
              label: l10n.accountSheetSignInCta,
              onPressed: () {
                Navigator.of(context).pop(); // Close sheet
                Navigator.of(parentContext).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PhoneSignInScreen(),
                  ),
                );
              },
            ),
          ] else ...[
            // Signed-in state
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.primary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.person,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: DWSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.accountSheetSignedInTitle,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (phoneNumber != null && phoneNumber.isNotEmpty) ...[
                        const SizedBox(height: DWSpacing.xxs),
                        Text(
                          phoneNumber,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DWSpacing.lg),

            DWButton.tertiary(
              label: l10n.accountSheetSignOutCta,
              onPressed: () {
                // Sign out + close sheet
                ref.read(simpleAuthStateProvider.notifier).signOut();
                Navigator.of(context).pop();
              },
            ),
          ],
          const SizedBox(height: DWSpacing.md),

          // Footer text
          Align(
            alignment: Alignment.center,
            child: Text(
              l10n.accountSheetFooterText,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: DWSpacing.sm),
        ],
      ),
    );
  }
}


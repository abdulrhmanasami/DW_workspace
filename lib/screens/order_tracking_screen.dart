// Component: Order Tracking Screen
// Created by: Cursor B-central (UX-005: Micro-interactions)
// Purpose: Order tracking screen with Sale-Only behavior and enhanced perceived performance
// Last updated: 2025-11-25

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/config_manager.dart';
import '../l10n/generated/app_localizations.dart';
import '../state/tracking/providers.dart';
import '../widgets/in_app_hint_banner.dart';
import 'package:b_ui/ui_components.dart';
import 'package:b_ux/guidance_ux.dart';

/// Order tracking screen with Sale-Only realtime tracking behavior
///
/// - When realtime tracking is available: Shows live tracking UI
/// - When unavailable: Shows clear message without any fake/demo data
class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    
    // Fail-closed: Check backend availability for realtime features
    if (!AppConfig.canUseBackendFeature()) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n?.trackingTitle ?? 'Order Tracking')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppConfig.backendPolicyMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    final trackingState = ref.watch(tripTrackingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.trackingTitle ?? 'Tracking'),
      ),
      body: _buildBody(context, ref, trackingState, l10n),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    TrackingState state,
    AppLocalizations? l10n,
  ) {
    // Use UiAnimatedStateTransition for smooth state changes
    return UiAnimatedStateTransition(
      child: _buildStateContent(context, ref, state, l10n),
    );
  }

  Widget _buildStateContent(
    BuildContext context,
    WidgetRef ref,
    TrackingState state,
    AppLocalizations? l10n,
  ) {
    // Loading state with skeleton
    if (state.isLoading) {
      return _buildLoadingState(context, l10n);
    }

    // Sale-Only: Show unavailable message when tracking is not available
    if (!state.isAvailable) {
      return _buildUnavailableState(context, l10n);
    }

    // Tracking available - show full UI
    return _buildTrackingUI(context, ref, state, l10n);
  }

  /// Build loading state with skeleton UI
  Widget _buildLoadingState(BuildContext context, AppLocalizations? l10n) {
    final theme = Theme.of(context);

    return Center(
      key: const ValueKey('loading'),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              l10n?.trackingCheckingAvailability ?? 'Checking tracking availability...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the unavailable state UI (Sale-Only behavior)
  /// No fake data or demo content - just a clear message with hint
  Widget _buildUnavailableState(BuildContext context, AppLocalizations? l10n) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tracking Unavailable Hint
            Consumer(
              builder: (context, ref, child) {
                // Show the tracking unavailable hint
                const hint = TrackingHints.unavailable;
                return const InAppHintBanner(hint: hint);
              },
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.location_off_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              l10n?.trackingRealtimeUnavailableTitle ??
                  'Live Tracking Unavailable',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.trackingRealtimeUnavailableBody ??
                  'Real-time tracking is currently unavailable. '
                      'Your order status will be updated automatically.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Order status card placeholder - will show static order info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n?.trackingOrderStatus ?? 'Order Status',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the full tracking UI when available
  Widget _buildTrackingUI(
    BuildContext context,
    WidgetRef ref,
    TrackingState state,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Trip info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.trackingLocationTitle ?? 'Location Tracking',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    icon: Icons.route,
                    label: 'Trip',
                    value: state.activeTripId ??
                        (l10n?.trackingNoActiveTrip ?? 'No active trip'),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    icon: Icons.location_on,
                    label: l10n?.trackingCurrentLocation ?? 'Current Location',
                    value: state.lastPoint != null
                        ? '${state.lastPoint!.latitude.toStringAsFixed(4)}, '
                            '${state.lastPoint!.longitude.toStringAsFixed(4)}'
                        : '-',
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Error message if any
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                state.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Control buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: state.canStartTracking
                      ? () => ref
                          .read(tripTrackingProvider.notifier)
                          .begin('trip_${DateTime.now().millisecondsSinceEpoch}')
                      : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Begin'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.hasActiveTrip
                      ? () => ref.read(tripTrackingProvider.notifier).end()
                      : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('End'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

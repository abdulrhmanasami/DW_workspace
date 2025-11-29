/// Preferences Screen - Onboarding Step 3
/// Created by: Ticket #33 - Track D Onboarding
/// Purpose: Collect user preferences (UI only, no persistence)
/// Last updated: 2025-11-28

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Vertical preferences for the app.
enum _ServiceVertical {
  rides,
  parcels,
  food,
}

/// Preferences screen - Final step of onboarding flow.
/// Allows users to set initial preferences (stored temporarily in local state).
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({
    super.key,
    this.onComplete,
  });

  /// Optional callback when onboarding is completed.
  final VoidCallback? onComplete;

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // Local state for preferences (not persisted in this ticket)
  _ServiceVertical _selectedVertical = _ServiceVertical.rides;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DWSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                l10n?.onboardingPreferencesTitle ?? 'Set your preferences',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DWSpacing.sm),
              
              // Subtitle
              Text(
                l10n?.onboardingPreferencesSubtitle ??
                    'You can change these later in Settings.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DWSpacing.xl),
              
              // Preference options
              Expanded(
                child: ListView(
                  children: [
                    // Service vertical selection
                    _PreferenceSection(
                      title: l10n?.onboardingPreferencesPrimaryServiceTitle ??
                          'What do you use most?',
                      child: Column(
                        children: [
                          _ServiceOption(
                            icon: Icons.directions_car_outlined,
                            title: l10n?.onboardingPreferencesServiceRides ?? 
                                'Rides',
                            subtitle: l10n?.onboardingPreferencesServiceRidesDesc ??
                                'Get picked up and dropped off',
                            isSelected: _selectedVertical == _ServiceVertical.rides,
                            onTap: () => setState(() {
                              _selectedVertical = _ServiceVertical.rides;
                            }),
                          ),
                          const SizedBox(height: DWSpacing.sm),
                          _ServiceOption(
                            icon: Icons.inventory_2_outlined,
                            title: l10n?.onboardingPreferencesServiceParcels ?? 
                                'Parcels',
                            subtitle: l10n?.onboardingPreferencesServiceParcelsDesc ??
                                'Send and receive packages',
                            isSelected: _selectedVertical == _ServiceVertical.parcels,
                            onTap: () => setState(() {
                              _selectedVertical = _ServiceVertical.parcels;
                            }),
                          ),
                          const SizedBox(height: DWSpacing.sm),
                          _ServiceOption(
                            icon: Icons.restaurant_outlined,
                            title: l10n?.onboardingPreferencesServiceFood ?? 
                                'Food',
                            subtitle: l10n?.onboardingPreferencesServiceFoodDesc ??
                                'Order from restaurants',
                            isSelected: _selectedVertical == _ServiceVertical.food,
                            onTap: () => setState(() {
                              _selectedVertical = _ServiceVertical.food;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Done button
              DWButton.primary(
                label: l10n?.onboardingPreferencesDoneCta ?? 
                    'Start using Delivery Ways',
                onPressed: () {
                  // Notify completion if callback provided
                  widget.onComplete?.call();
                  // Pop back to root (initial route)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: DWSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// A section container for preference groups.
class _PreferenceSection extends StatelessWidget {
  const _PreferenceSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DWSpacing.md),
        child,
      ],
    );
  }
}

/// A selectable service option tile.
class _ServiceOption extends StatelessWidget {
  const _ServiceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(DWSpacing.md),
        decoration: BoxDecoration(
          color: isSelected 
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(DWRadius.md),
          border: Border.all(
            color: isSelected ? colors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withValues(alpha: 0.15)
                    : colors.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DWRadius.sm),
              ),
              child: Icon(
                icon,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(width: DWSpacing.md),
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colors.primary : colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: DWSpacing.xxs),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}


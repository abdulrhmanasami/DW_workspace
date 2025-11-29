import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Placeholder screens for incomplete or feature-gated functionality
/// Created by: Cursor B-central
/// Purpose: Safe placeholders using only design_system_shims barrels
/// Last updated: 2025-11-16

/// Generic "Coming Soon" placeholder screen
class ComingSoonPlaceholder extends ConsumerWidget {
  const ComingSoonPlaceholder({super.key, this.title = 'Coming Soon'});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: AppCard.standard(
          child: Text('Coming soon', style: theme.typography.body1),
        ),
      ),
    );
  }
}

/// Feature-gated placeholder for tracking functionality
class TrackingDisabledPlaceholder extends ConsumerWidget {
  const TrackingDisabledPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking')),
      body: Center(
        child: AppCard.standard(
          child: Text(
            'Tracking is currently disabled',
            style: theme.typography.body1,
          ),
        ),
      ),
    );
  }
}

/// Feature-gated placeholder for maps functionality
class MapsDisabledPlaceholder extends ConsumerWidget {
  const MapsDisabledPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: Center(
        child: AppCard.standard(
          child: Text(
            'Maps are currently disabled',
            style: theme.typography.body1,
          ),
        ),
      ),
    );
  }
}

/// Feature-gated placeholder for DSR export functionality
class DsrExportDisabledPlaceholder extends ConsumerWidget {
  const DsrExportDisabledPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Export Data')),
      body: Center(
        child: AppCard.standard(
          child: Text(
            'Data export is currently disabled',
            style: theme.typography.body1,
          ),
        ),
      ),
    );
  }
}

/// Feature-gated placeholder for DSR erasure functionality
class DsrErasureDisabledPlaceholder extends ConsumerWidget {
  const DsrErasureDisabledPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Data')),
      body: Center(
        child: AppCard.standard(
          child: Text(
            'Data deletion is currently disabled',
            style: theme.typography.body1,
          ),
        ),
      ),
    );
  }
}

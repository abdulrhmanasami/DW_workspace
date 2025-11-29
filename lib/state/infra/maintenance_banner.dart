import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:foundation_shims/providers/remote_config_providers.dart'
    show rcString;

import 'feature_flags.dart';

final maintenanceMessageProvider = Provider<String?>((ref) {
  final raw = rcString(ref, 'maintenance_message', defaultValue: '').trim();
  if (raw.isEmpty) {
    return null;
  }
  return raw;
});

class MaintenanceBanner extends ConsumerWidget {
  final Widget child;

  const MaintenanceBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMaintenanceMode = ref.watch(maintenanceModeEnabledProvider);
    final banner = () {
      if (!isMaintenanceMode) {
        return null;
      }
      final rawMessage = ref.watch(maintenanceMessageProvider);
      final message = rawMessage?.trim();
      if (message == null || message.isEmpty) {
        return null;
      }
      return _buildMaintenanceBanner(ref, message);
    }();
    return Column(
      children: [
        if (banner != null) banner,
        Expanded(child: child),
      ],
    );
  }

  Widget _buildMaintenanceBanner(WidgetRef ref, String message) {
    final theme = ref.watch(appThemeProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      color: Colors.orange[100],
      child: AppCard.standard(
        padding: const EdgeInsets.all(16.0),
        backgroundColor: Colors.orange[50],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.orange[300]!, width: 1.0),
        child: Text(
          message,
          style: theme.typography.body1.copyWith(
            color: Colors.orange[900],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

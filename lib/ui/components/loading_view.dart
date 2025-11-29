import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Loading View - Basic loading interface using Design System tokens
/// Created by: UI-PHASE-01
/// Purpose: Standardized loading view for UI layer
/// Last updated: 2025-11-16

class LoadingView extends ConsumerWidget {
  final String? message;
  final double? size;

  const LoadingView({super.key, this.message, this.size = 48.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final spacing = theme.spacing;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
              strokeWidth: 3.0,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: spacing.md),
            Text(
              message!,
              style: theme.typography.body2.copyWith(
                color: theme.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

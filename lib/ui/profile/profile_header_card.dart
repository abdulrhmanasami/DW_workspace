import 'package:flutter/material.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Profile Header Card Component
/// Represents the user info card at the top of the Profile tab
/// Track A - Ticket #227: Profile / Settings Tab UI implementation
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.displayName,
    required this.phoneNumber,
  });

  final String displayName;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Semantics(
      header: true,
      label: '$displayName, $phoneNumber',
      child: Container(
        margin: const EdgeInsets.all(DWSpacing.md),
        padding: const EdgeInsets.all(DWSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(DWRadius.lg),
          boxShadow: kElevationToShadow[1],
        ),
        child: Row(
          children: [
            // Avatar circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.person,
                size: 28,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: DWSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: DWSpacing.xs),
                  Text(
                    phoneNumber,
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

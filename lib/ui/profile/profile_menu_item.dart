import 'package:flutter/material.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Profile Menu Item Component
/// Represents individual menu items in the profile settings list
/// Track A - Ticket #227: Profile / Settings Tab UI implementation
class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: subtitle == null ? title : '$title, $subtitle',
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: DWSpacing.sm,
            horizontal: DWSpacing.md,
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: DWSpacing.md,
            vertical: DWSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(DWRadius.md),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: DWSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.bodyMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: DWSpacing.xs),
                      Text(
                        subtitle!,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Payments Tab Screen (Screen 16)
/// Created by: Track B - Ticket #99
/// Updated by: Track B - Ticket #100 (Added selection support for Ride flow)
/// Purpose: Payment methods list screen for BottomNav Payments tab
/// Last updated: 2025-11-30
///
/// This screen shows the payment methods list as per Screen 16 in Hi-Fi Mockups:
/// - List of payment methods (Cash + Cards)
/// - Default badge for default payment method
/// - Selection support (tapping a card selects it)
/// - Empty state when no methods saved
/// - Add new payment method CTA (stub)
///
/// NOTE: This is MVP UI Stub. Backend integration in future ticket.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/payments/payment_methods_ui_state.dart';

/// Payments Tab Screen - Shows list of saved payment methods
/// Track B - Ticket #99
class PaymentsTabScreen extends ConsumerWidget {
  const PaymentsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(paymentMethodsUiProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paymentsTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: state.methods.isEmpty
            ? _PaymentsEmptyState(l10n: l10n)
            : _PaymentsMethodsList(
                methods: state.methods,
                l10n: l10n,
              ),
      ),
    );
  }
}

/// Empty state widget when no payment methods are saved
class _PaymentsEmptyState extends StatelessWidget {
  const _PaymentsEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DWSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              Icons.credit_card_off_outlined,
              size: 72,
              color: colorScheme.outline,
            ),
            SizedBox(height: DWSpacing.lg),

            // Title
            Text(
              l10n.paymentsEmptyTitle,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DWSpacing.sm),

            // Body
            Text(
              l10n.paymentsEmptyBody,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DWSpacing.xl),

            // Add CTA
            SizedBox(
              width: double.infinity,
              child: DWButton.secondary(
                label: l10n.paymentsAddMethodCta,
                onPressed: () => _showComingSoonSnackbar(context, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List of payment methods with Add CTA at bottom
/// Track B - Ticket #100: Now passes state for selection tracking
class _PaymentsMethodsList extends ConsumerWidget {
  const _PaymentsMethodsList({
    required this.methods,
    required this.l10n,
  });

  final List<PaymentMethodUiModel> methods;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentMethodsUiProvider);
    
    return Column(
      children: [
        // List of methods
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(DWSpacing.md),
            itemCount: methods.length,
            separatorBuilder: (_, __) => SizedBox(height: DWSpacing.sm),
            itemBuilder: (context, index) {
              final method = methods[index];
              final isSelected = method.id == state.selectedMethodId;
              return _PaymentMethodCard(
                method: method,
                l10n: l10n,
                isSelected: isSelected,
                onTap: () {
                  // Track B - Ticket #100: Update selected method
                  ref.read(paymentMethodsUiProvider.notifier).state =
                      state.copyWith(selectedMethodId: method.id);
                },
              );
            },
          ),
        ),

        // Add new method CTA
        Padding(
          padding: EdgeInsets.all(DWSpacing.md),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: DWButton.secondary(
                label: l10n.paymentsAddMethodCta,
                onPressed: () => _showComingSoonSnackbar(context, l10n),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Card widget for displaying a single payment method
/// Track B - Ticket #100: Added selection support with visual feedback
class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.l10n,
    this.isSelected = false,
    this.onTap,
  });

  final PaymentMethodUiModel method;
  final AppLocalizations l10n;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DWRadius.md),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DWRadius.md),
          // Track B - Ticket #100: Visual selection indicator
          side: isSelected
              ? BorderSide(color: colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: EdgeInsets.all(DWSpacing.md),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(DWRadius.sm),
                ),
                child: Icon(
                  _getMethodIcon(method.type),
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              SizedBox(width: DWSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display name
                    Text(
                      method.displayName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: DWSpacing.xxs),

                    // Type label
                    Text(
                      _getTypeLabel(method.type, l10n),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Default badge
              if (method.isDefault) ...[
                SizedBox(width: DWSpacing.sm),
                _DefaultBadge(label: l10n.paymentsDefaultBadge),
              ],

              // Track B - Ticket #100: Selection check icon
              if (isSelected) ...[
                SizedBox(width: DWSpacing.sm),
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMethodIcon(PaymentMethodUiType type) {
    switch (type) {
      case PaymentMethodUiType.cash:
        return Icons.payments_outlined;
      case PaymentMethodUiType.card:
        return Icons.credit_card;
    }
  }

  String _getTypeLabel(PaymentMethodUiType type, AppLocalizations l10n) {
    switch (type) {
      case PaymentMethodUiType.cash:
        return l10n.paymentsMethodTypeCash;
      case PaymentMethodUiType.card:
        return l10n.paymentsMethodTypeCard;
    }
  }
}

/// Default badge chip
class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DWSpacing.xs,
        vertical: DWSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DWRadius.sm),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Shows coming soon snackbar
void _showComingSoonSnackbar(BuildContext context, AppLocalizations l10n) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.paymentsAddMethodComingSoon),
      behavior: SnackBarBehavior.floating,
    ),
  );
}


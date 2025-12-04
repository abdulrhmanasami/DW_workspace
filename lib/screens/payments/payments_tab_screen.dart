/// Payments Screen (Screen 16)
/// Created by: Track B - Ticket #99
/// Updated by: Track B - Ticket #100 (Added selection support for Ride flow)
/// Updated by: Track A - Ticket #225 (Design System alignment + Payments shim integration)
/// Purpose: Payment methods list screen for BottomNav Payments tab
/// Last updated: 2025-12-04
///
/// This screen shows the payment methods list as per Screen 16 in Hi-Fi Mockups:
/// - List of payment methods from payments shim
/// - Default badge for default payment method
/// - Empty state using DWEmptyState
/// - Add new payment method CTA using DWButton.secondary
/// - Proper RTL/LTR support and accessibility
///
/// Track A - Ticket #225: Design System Integration
/// - Uses DWSpacing, DWRadius, DWButton.secondary
/// - Integrates with payments shim (SavedPaymentMethod)
/// - Uses DWEmptyState for empty state
/// - Card/Generic spec via PaymentMethodCard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments/payments.dart';
import 'package:design_system_shims/design_system_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/payments/payment_methods_controller.dart';
import '../../ui/common/empty_state.dart';
import '../../ui/payments/payment_method_card.dart';

/// Payments Screen - Shows list of saved payment methods from payments shim
/// Track A - Ticket #225: Design System aligned implementation
class PaymentsTabScreen extends ConsumerWidget {
  const PaymentsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final paymentMethodsState = ref.watch(paymentMethodsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.paymentsTitle,
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(DWSpacing.md),
          child: paymentMethodsState.methods.when(
            loading: () => const _PaymentsLoadingState(),
            error: (error, stackTrace) => _PaymentsErrorState(
              error: error.toString(),
              onRetry: () => ref.read(paymentMethodsControllerProvider.notifier).refresh(),
            ),
            data: (methods) => methods.isEmpty
                ? _PaymentsEmptyState(l10n: l10n)
                : _PaymentsMethodsList(
                    methods: methods,
                    l10n: l10n,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Empty state widget when no payment methods are saved
/// Track A - Ticket #225: Uses DWEmptyState following design system
class _PaymentsEmptyState extends StatelessWidget {
  const _PaymentsEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DWEmptyState(
      icon: Icons.account_balance_wallet,
      title: l10n.paymentsEmptyTitle,
      description: l10n.paymentsEmptyBody,
      primaryActionLabel: l10n.paymentsAddMethodCta,
      onPrimaryActionTap: () => _showComingSoonSnackbar(context, l10n),
    );
  }
}

/// List of payment methods with Add CTA at bottom
/// Track A - Ticket #225: Uses PaymentMethodCard + proper design tokens
class _PaymentsMethodsList extends StatelessWidget {
  const _PaymentsMethodsList({
    required this.methods,
    required this.l10n,
  });

  final List<SavedPaymentMethod> methods;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // List of methods
        Expanded(
          child: ListView.separated(
            itemCount: methods.length,
            separatorBuilder: (_, __) => SizedBox(height: DWSpacing.sm),
            itemBuilder: (context, index) {
              final method = methods[index];
              final mapping = _mapPaymentMethodToUi(method, l10n);
              return PaymentMethodCard(
                icon: mapping.icon,
                title: mapping.title,
                subtitle: mapping.subtitle,
                isDefault: mapping.isDefault,
                onTap: () {
                  // TODO: Future ticket - Navigate to payment method details
                },
              );
            },
          ),
        ),

        // Add new method CTA
        SizedBox(height: DWSpacing.md),
        SizedBox(
          width: double.infinity,
          child: DWButton.secondary(
            label: l10n.paymentsAddMethodCta,
            onPressed: () => _showComingSoonSnackbar(context, l10n),
          ),
        ),
      ],
    );
  }
}

/// UI mapping for PaymentMethodCard props
/// Track A - Ticket #225: Maps SavedPaymentMethod to PaymentMethodCard props
class _PaymentMethodUiMapping {
  const _PaymentMethodUiMapping({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDefault,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDefault;
}

/// Maps SavedPaymentMethod from payments shim to UI props for PaymentMethodCard
/// Track A - Ticket #225: Integration with payments shim without duplicating models
_PaymentMethodUiMapping _mapPaymentMethodToUi(SavedPaymentMethod method, AppLocalizations l10n) {
  return _PaymentMethodUiMapping(
    icon: _getMethodIcon(method.type),
    title: method.displayName,
    subtitle: _getMethodSubtitle(method, l10n),
    isDefault: method.isDefault,
  );
}

/// Gets appropriate icon for payment method type
IconData _getMethodIcon(PaymentMethodType type) {
  switch (type) {
    case PaymentMethodType.card:
      return Icons.credit_card;
    case PaymentMethodType.cash:
      return Icons.payments_outlined;
    case PaymentMethodType.applePay:
      return Icons.apple;
    case PaymentMethodType.googlePay:
      return Icons.account_balance_wallet;
    case PaymentMethodType.digitalWallet:
    case PaymentMethodType.bankTransfer:
    case PaymentMethodType.cashOnDelivery:
      return Icons.account_balance;
  }
}

/// Gets subtitle for payment method based on type
String _getMethodSubtitle(SavedPaymentMethod method, AppLocalizations l10n) {
  switch (method.type) {
    case PaymentMethodType.card:
      if (method.expMonth != null && method.expYear != null) {
        return l10n.paymentsCardExpiry(method.expMonth!, method.expYear!);
      }
      return l10n.paymentsMethodTypeCard;
    case PaymentMethodType.cash:
      return l10n.paymentsMethodTypeCash;
    case PaymentMethodType.applePay:
      return l10n.paymentsMethodTypeApplePay;
    case PaymentMethodType.googlePay:
      return l10n.paymentsMethodTypeGooglePay;
    case PaymentMethodType.digitalWallet:
      return l10n.paymentsMethodTypeDigitalWallet;
    case PaymentMethodType.bankTransfer:
      return l10n.paymentsMethodTypeBankTransfer;
    case PaymentMethodType.cashOnDelivery:
      return l10n.paymentsMethodTypeCashOnDelivery;
  }
}

/// Loading state for payment methods
/// Track A - Ticket #225: Proper loading state
class _PaymentsLoadingState extends StatelessWidget {
  const _PaymentsLoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: CircularProgressIndicator(
        color: colorScheme.primary,
      ),
    );
  }
}

/// Error state for payment methods
/// Track A - Ticket #225: Error state with retry capability
class _PaymentsErrorState extends StatelessWidget {
  const _PaymentsErrorState({
    required this.error,
    this.onRetry,
  });

  final String error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DWSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: colorScheme.error,
            ),
            SizedBox(height: DWSpacing.md),
            Text(
              'Unable to load payment methods',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DWSpacing.xs),
            Text(
              error,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: DWSpacing.lg),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Retry',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shows coming soon snackbar
/// Track A - Ticket #225: Placeholder for Add Payment Method functionality
void _showComingSoonSnackbar(BuildContext context, AppLocalizations l10n) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.paymentsAddMethodComingSoon),
      behavior: SnackBarBehavior.floating,
    ),
  );
}


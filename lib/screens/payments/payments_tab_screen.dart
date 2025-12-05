/// Payments Screen (Screen 16)
/// Created by: Track B - Ticket #99
/// Updated by: Track B - Ticket #100 (Added selection support for Ride flow)
/// Updated by: Track A - Ticket #225 (Design System alignment + Payments shim integration)
/// Updated by: Track E - Ticket E-1 (Use UI state provider for MVP)
/// Purpose: Payment methods list screen for BottomNav Payments tab
/// Last updated: 2025-12-05
///
/// This screen shows the payment methods list as per Screen 16 in Hi-Fi Mockups:
/// - List of payment methods from UI state (stub for MVP)
/// - Default badge for default payment method
/// - Selection indicator for currently selected method
/// - Empty state using DWEmptyState
/// - Add new payment method CTA using DWButton.secondary
/// - Proper RTL/LTR support and accessibility
///
/// Track A - Ticket #225: Design System Integration
/// - Uses DWSpacing, DWRadius, DWButton.secondary
/// - Card/Generic spec via PaymentMethodCard
///
/// Track E - Ticket E-1: MVP Payment Methods
/// - Uses paymentMethodsUiProvider (stub) instead of paymentMethodsControllerProvider
/// - Supports selection and default setting via UI state controller

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/payments/payment_methods_ui_state.dart';
import '../../ui/common/empty_state.dart';
import '../../ui/payments/payment_method_card.dart';

/// Payments Screen - Shows list of saved payment methods
/// Track E - Ticket E-1: Uses UI state provider for MVP
class PaymentsTabScreen extends ConsumerWidget {
  const PaymentsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final paymentMethodsState = ref.watch(paymentMethodsUiProvider);

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
          padding: const EdgeInsets.all(DWSpacing.md),
          child: paymentMethodsState.methods.isEmpty
              ? _PaymentsEmptyState(l10n: l10n)
              : _PaymentsMethodsList(
                  methods: paymentMethodsState.methods,
                  selectedMethodId: paymentMethodsState.selectedMethodId,
                  l10n: l10n,
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
      icon: Icons.credit_card_off_outlined,
      title: l10n.paymentsEmptyTitle,
      description: l10n.paymentsEmptyBody,
      primaryActionLabel: l10n.paymentsAddMethodCta,
      onPrimaryActionTap: () => _showComingSoonSnackbar(context, l10n),
    );
  }
}

/// List of payment methods with Add CTA at bottom
/// Track E - Ticket E-1: Updated to use PaymentMethodUiModel
class _PaymentsMethodsList extends ConsumerWidget {
  const _PaymentsMethodsList({
    required this.methods,
    required this.selectedMethodId,
    required this.l10n,
  });

  final List<PaymentMethodUiModel> methods;
  final String? selectedMethodId;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // List of methods
        Expanded(
          child: ListView.separated(
            itemCount: methods.length,
            separatorBuilder: (_, __) => const SizedBox(height: DWSpacing.sm),
            itemBuilder: (context, index) {
              final method = methods[index];
              final isSelected = method.id == selectedMethodId;
              return PaymentMethodCard(
                icon: _getMethodIcon(method.type),
                title: method.displayName,
                subtitle: _getMethodSubtitle(method, l10n),
                isDefault: method.isDefault,
                isSelected: isSelected,
                defaultLabel: l10n.paymentsDefaultBadge,
                onTap: () {
                  // Track E - Ticket E-1: Update selection via controller
                  // Bug Fix: Use controller directly instead of mutating StateProvider
                  ref.read(paymentMethodsUiControllerProvider.notifier)
                      .selectMethod(method.id);
                },
              );
            },
          ),
        ),

        // Add new method CTA
        const SizedBox(height: DWSpacing.md),
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

/// Gets appropriate icon for payment method UI type
/// Track E - Ticket E-1: Maps PaymentMethodUiType to icon
IconData _getMethodIcon(PaymentMethodUiType type) {
  switch (type) {
    case PaymentMethodUiType.card:
      return Icons.credit_card;
    case PaymentMethodUiType.cash:
      return Icons.payments_outlined;
    case PaymentMethodUiType.applePay:
      return Icons.apple;
    case PaymentMethodUiType.googlePay:
      return Icons.account_balance_wallet;
  }
}

/// Gets subtitle for payment method based on type
/// Track E - Ticket E-1: Maps PaymentMethodUiModel to subtitle
String _getMethodSubtitle(PaymentMethodUiModel method, AppLocalizations l10n) {
  switch (method.type) {
    case PaymentMethodUiType.card:
      return l10n.paymentsMethodTypeCard;
    case PaymentMethodUiType.cash:
      return l10n.paymentsMethodTypeCash;
    case PaymentMethodUiType.applePay:
      return l10n.paymentsMethodTypeApplePay;
    case PaymentMethodUiType.googlePay:
      return l10n.paymentsMethodTypeGooglePay;
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


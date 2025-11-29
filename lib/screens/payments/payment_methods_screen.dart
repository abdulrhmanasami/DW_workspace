// Component: Payment Methods Screen
// Created by: UX-005 Implementation
// Purpose: Payment methods management with loading states and skeleton UI
// Last updated: 2025-11-25

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:payments/payments.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/payments/payment_methods_controller.dart';
import '../../state/guidance/guidance_providers.dart';
import '../../widgets/in_app_hint_banner.dart';
import 'package:b_ui/ui_components.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentMethodsControllerProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    Widget buildList(List<SavedPaymentMethod> items) {
      if (items.isEmpty) {
        return UiEmptyState(
          icon: Icons.credit_card_off_outlined,
          title: l10n?.paymentMethodsEmptyTitle ?? 'No payment methods',
          subtitle: l10n?.paymentMethodsEmptySubtitle ?? 
              'Add a payment method to get started',
        );
      }

      return UiAnimatedStateTransition(
        child: Column(
          key: ValueKey('list_${items.length}'),
          children: items.map((method) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    _getCardIcon(method.brand),
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    '${method.brand.toUpperCase()} •••• ${method.last4}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: () => ref
                        .read(paymentMethodsControllerProvider.notifier)
                        .removeMethod(method.id),
                    tooltip: l10n?.cancel ?? 'Remove',
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    Widget buildAddButton() {
      return AppButton.primary(
        label: state.isAdding 
            ? (l10n?.loading ?? 'Saving...') 
            : (l10n?.paymentMethodsAddButton ?? 'Add payment method'),
        expanded: true,
        loading: state.isAdding,
        onPressed: state.isAdding
            ? null
            : () => ref
                  .read(paymentMethodsControllerProvider.notifier)
                  .addMethod(useGPayIfAvailable: true),
      );
    }

    Widget buildErrorNotice() {
      if (state.error == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final content = state.methods.when(
      data: (items) => UiAnimatedStateTransition(
        child: Column(
          key: const ValueKey('data'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: buildList(items)),
            buildAddButton(),
            buildErrorNotice(),
          ],
        ),
      ),
      loading: () => const _PaymentMethodsLoadingSkeleton(key: ValueKey('loading')),
      error: (error, _) => UiAnimatedStateTransition(
        child: UiErrorState(
          key: const ValueKey('error'),
          message: l10n?.paymentMethodsLoadError ?? 'Unable to load payment methods',
          onRetry: () => ref.read(paymentMethodsControllerProvider.notifier).refresh(),
          retryLabel: l10n?.retry ?? 'Retry',
          icon: Icons.error_outline,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.paymentMethodsTitle ?? 'Payment Methods')),
      body: Column(
        children: [
          // Payment Methods Hint Banner
          _PaymentMethodsHintBanner(),
          // Main content
          Expanded(child: Padding(padding: const EdgeInsets.all(16), child: content)),
        ],
      ),
    );
  }

  IconData _getCardIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
}

/// Skeleton loading state for payment methods list
class _PaymentMethodsLoadingSkeleton extends StatelessWidget {
  const _PaymentMethodsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return UiSkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: UiSkeletonCard(height: 72),
              ),
            ),
          ),
          const UiSkeletonLine(height: 48, borderRadius: 8),
        ],
      ),
    );
  }
}

/// Payment Methods Hint Banner widget.
class _PaymentMethodsHintBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintsAsync = ref.watch(paymentMethodsHintsProvider);

    return hintsAsync.when(
      data: (hints) {
        if (hints.isEmpty) return const SizedBox.shrink();
        return InAppHintBanner(hint: hints.first);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

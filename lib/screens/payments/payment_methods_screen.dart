// Component: Payment Methods Screen
// Created by: UX-005 Implementation
// Updated by: Track E - Ticket E-1 (Full CRUD with UI state controller)
// Purpose: Payment methods management with loading states and skeleton UI
// Last updated: 2025-12-05

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/state/payments/payment_methods_ui_state.dart';
import 'package:delivery_ways_clean/state/guidance/guidance_providers.dart';
import 'package:delivery_ways_clean/widgets/in_app_hint_banner.dart';
import 'package:b_ui/ui_components.dart';

/// Track E - Ticket E-1: Payment Methods Screen with full CRUD support
class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentMethodsUiControllerProvider);
    final controller = ref.read(paymentMethodsUiControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.paymentMethodsTitle ?? 'Payment Methods')),
      body: Column(
        children: [
          // Payment Methods Hint Banner
          _PaymentMethodsHintBanner(),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _PaymentMethodsContent(
                state: state,
                controller: controller,
                l10n: l10n,
                theme: theme,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Track E - Ticket E-1: Main content widget for payment methods
class _PaymentMethodsContent extends StatelessWidget {
  const _PaymentMethodsContent({
    required this.state,
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  final PaymentMethodsUiState state;
  final PaymentMethodsUiController controller;
  final AppLocalizations? l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.methods.isEmpty) {
      return const _PaymentMethodsLoadingSkeleton();
    }

    return UiAnimatedStateTransition(
      child: Column(
        key: ValueKey('content_${state.methods.length}'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildList(context)),
          _buildAddButton(context),
          _buildErrorNotice(),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (state.methods.isEmpty) {
      return UiEmptyState(
        icon: Icons.credit_card_off_outlined,
        title: l10n?.paymentMethodsEmptyTitle ?? 'No payment methods',
        subtitle: l10n?.paymentMethodsEmptySubtitle ?? 
            'Add a payment method to get started',
      );
    }

    return ListView.builder(
      itemCount: state.methods.length,
      itemBuilder: (context, index) {
        final method = state.methods[index];
        return _PaymentMethodCard(
          method: method,
          isSelected: method.id == state.selectedMethodId,
          onTap: () => controller.selectMethod(method.id),
          onSetDefault: () => controller.setAsDefault(method.id),
          onDelete: method.type == PaymentMethodUiType.cash
              ? null  // Can't delete cash
              : () => _confirmDelete(context, method),
          theme: theme,
          l10n: l10n,
        );
      },
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return AppButton.primary(
      label: state.isAdding 
          ? (l10n?.loading ?? 'Saving...') 
          : (l10n?.paymentMethodsAddButton ?? 'Add payment method'),
      expanded: true,
      loading: state.isAdding,
      onPressed: state.isAdding
          ? null
          : () => _showAddCardDialog(context),
    );
  }

  Widget _buildErrorNotice() {
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
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: controller.clearError,
              color: theme.colorScheme.onErrorContainer,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, PaymentMethodUiModel method) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.paymentMethodsRemoveTitle ?? 'Remove Card'),
        content: Text(
          l10n?.paymentMethodsRemoveMessage ?? 
              'Are you sure you want to remove ${method.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n?.paymentMethodsRemoveButton ?? 'Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.removeMethod(method.id);
    }
  }

  void _showAddCardDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddCardBottomSheet(
        controller: controller,
        l10n: l10n,
        theme: theme,
      ),
    );
  }
}

/// Track E - Ticket E-1: Individual payment method card with selection and actions
class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
    required this.onSetDefault,
    required this.onDelete,
    required this.theme,
    required this.l10n,
  });

  final PaymentMethodUiModel method;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback? onDelete;
  final ThemeData theme;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final isDefault = method.isDefault;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: theme.colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getMethodIcon(method.type, method.brand),
                    size: 24,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              method.displayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l10n?.paymentMethodsDefault ?? 'Default',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (method.type == PaymentMethodUiType.card && 
                          method.expMonth != null && 
                          method.expYear != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Expires ${method.expMonth!.toString().padLeft(2, '0')}/${method.expYear}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Actions
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'default':
                        onSetDefault();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (ctx) => [
                    if (!isDefault)
                      PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n?.paymentMethodsSetDefault ?? 'Set as default'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                            const SizedBox(width: 8),
                            Text(
                              l10n?.paymentMethodsRemoveButton ?? 'Remove',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getMethodIcon(PaymentMethodUiType type, String? brand) {
    switch (type) {
      case PaymentMethodUiType.cash:
        return Icons.payments_outlined;
      case PaymentMethodUiType.applePay:
        return Icons.apple;
      case PaymentMethodUiType.googlePay:
        return Icons.account_balance_wallet;
      case PaymentMethodUiType.card:
        return Icons.credit_card;
    }
  }
}

/// Track E - Ticket E-1: Bottom sheet for adding a new card
class _AddCardBottomSheet extends StatefulWidget {
  const _AddCardBottomSheet({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  final PaymentMethodsUiController controller;
  final AppLocalizations? l10n;
  final ThemeData theme;

  @override
  State<_AddCardBottomSheet> createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<_AddCardBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  bool _setAsDefault = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    widget.l10n?.paymentMethodsAddCard ?? 'Add Card',
                    style: widget.theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Card Number Field
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: widget.l10n?.paymentMethodsCardNumber ?? 'Card Number',
                  hintText: '4242 4242 4242 4242',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberInputFormatter(),
                ],
                validator: (value) {
                  final digits = value?.replaceAll(' ', '') ?? '';
                  if (digits.length < 13) {
                    return widget.l10n?.paymentMethodsInvalidCard ?? 
                        'Please enter a valid card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Expiry Field
              TextFormField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: widget.l10n?.paymentMethodsExpiry ?? 'Expiry Date',
                  hintText: 'MM/YY',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryDateInputFormatter(),
                ],
                validator: (value) {
                  final digits = value?.replaceAll('/', '') ?? '';
                  if (digits.length != 4) {
                    return widget.l10n?.paymentMethodsInvalidExpiry ?? 
                        'Please enter a valid expiry date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Set as Default Checkbox
              CheckboxListTile(
                value: _setAsDefault,
                onChanged: (value) => setState(() => _setAsDefault = value ?? false),
                title: Text(widget.l10n?.paymentMethodsSetDefault ?? 'Set as default'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              AppButton.primary(
                label: _isSubmitting
                    ? (widget.l10n?.loading ?? 'Saving...')
                    : (widget.l10n?.paymentMethodsAddButton ?? 'Add Card'),
                expanded: true,
                loading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submitCard,
              ),
              
              // Stub Note
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: widget.theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.l10n?.paymentMethodsStubNote ??
                            'This is a demo. No real payment will be processed.',
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          color: widget.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Parse card number for brand detection
    final cardDigits = _cardNumberController.text.replaceAll(' ', '');
    final last4 = cardDigits.substring(cardDigits.length - 4);
    final brand = _detectBrand(cardDigits);

    // Parse expiry
    final expiryParts = _expiryController.text.split('/');
    final expMonth = int.tryParse(expiryParts[0]);
    final expYear = int.tryParse(expiryParts[1]);

    final success = await widget.controller.addCard(
      brand: brand,
      last4: last4,
      expMonth: expMonth,
      expYear: expYear,
      setAsDefault: _setAsDefault,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.l10n?.paymentMethodsAddSuccess ?? 'Card added successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _detectBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5') || cardNumber.startsWith('2')) return 'Mastercard';
    if (cardNumber.startsWith('3')) return 'Amex';
    if (cardNumber.startsWith('6')) return 'Discover';
    return 'Card';
  }
}

/// Track E - Ticket E-1: Card number formatter (adds spaces every 4 digits)
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Track E - Ticket E-1: Expiry date formatter (MM/YY)
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Skeleton loading state for payment methods list
class _PaymentMethodsLoadingSkeleton extends StatelessWidget {
  const _PaymentMethodsLoadingSkeleton();

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

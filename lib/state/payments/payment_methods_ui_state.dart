/// Payment Methods UI State (Stub)
/// Created by: Track B - Ticket #99
/// Updated by: Track B - Ticket #100 (Added selectedMethodId for Ride flow integration)
/// Purpose: UI Stub model for payment methods display (Screen 16)
/// Last updated: 2025-11-30
///
/// This is a UI-level stub model for MVP. It will be replaced by
/// actual `SavedPaymentMethod` from `packages/payments` when backend is ready.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Payment method type enum for UI display
enum PaymentMethodUiType { cash, card }

/// UI Model for Payment Method display (MVP Stub)
/// 
/// Track B - Ticket #99: This is a UI-only stub model, not a domain model.
/// Use [SavedPaymentMethod] from payments package when backend is integrated.
@immutable
class PaymentMethodUiModel {
  const PaymentMethodUiModel({
    required this.id,
    required this.displayName,
    required this.type,
    required this.isDefault,
    this.brand,
    this.last4,
  });

  final String id;
  final String displayName;
  final PaymentMethodUiType type;
  final bool isDefault;
  final String? brand;
  final String? last4;

  /// Helper to create a Cash payment method
  static const PaymentMethodUiModel cash = PaymentMethodUiModel(
    id: 'cash',
    displayName: 'Cash',
    type: PaymentMethodUiType.cash,
    isDefault: true,
  );

  /// Helper to create a stub Card payment method
  static PaymentMethodUiModel stubCard({
    required String brand,
    required String last4,
    bool isDefault = false,
  }) => PaymentMethodUiModel(
    id: '${brand.toLowerCase()}_$last4',
    displayName: '$brand ···· $last4',
    type: PaymentMethodUiType.card,
    isDefault: isDefault,
    brand: brand,
    last4: last4,
  );
}

/// State for Payment Methods UI
/// Track B - Ticket #100: Added selectedMethodId for Ride flow integration
@immutable
class PaymentMethodsUiState {
  const PaymentMethodsUiState({
    this.methods = const [],
    this.selectedMethodId,
  });

  final List<PaymentMethodUiModel> methods;
  
  /// Track B - Ticket #100: Currently selected payment method ID
  final String? selectedMethodId;

  /// Track B - Ticket #100: Get the currently selected payment method
  /// Falls back to default method, then first method if no selection
  PaymentMethodUiModel? get selectedMethod {
    if (methods.isEmpty) return null;
    
    // First try to find the selected method
    if (selectedMethodId != null) {
      final selected = methods.where((m) => m.id == selectedMethodId);
      if (selected.isNotEmpty) return selected.first;
    }
    
    // Fall back to default method
    final defaultMethods = methods.where((m) => m.isDefault);
    if (defaultMethods.isNotEmpty) return defaultMethods.first;
    
    // Last resort: first method
    return methods.first;
  }

  /// Default stub state with Cash + sample Card
  /// Track B - Ticket #100: Default selection is the default method (Cash)
  static PaymentMethodsUiState defaultStub() {
    const methods = [
      PaymentMethodUiModel.cash,
    ];
    // Add card separately since stubCard is not const
    final allMethods = [
      PaymentMethodUiModel.cash,
      PaymentMethodUiModel.stubCard(brand: 'Visa', last4: '4242'),
    ];
    // Default selection is the default method (Cash)
    final defaultMethod = allMethods.firstWhere(
      (m) => m.isDefault,
      orElse: () => allMethods.first,
    );
    return PaymentMethodsUiState(
      methods: allMethods,
      selectedMethodId: defaultMethod.id,
    );
  }

  /// Empty state
  static const PaymentMethodsUiState empty = PaymentMethodsUiState();

  PaymentMethodsUiState copyWith({
    List<PaymentMethodUiModel>? methods,
    String? selectedMethodId,
  }) => PaymentMethodsUiState(
    methods: methods ?? this.methods,
    selectedMethodId: selectedMethodId ?? this.selectedMethodId,
  );
}

/// Provider for Payment Methods UI State
/// Track B - Ticket #99: Default stub data for MVP display
/// Track B - Ticket #100: Now includes selectedMethodId
final paymentMethodsUiProvider = StateProvider<PaymentMethodsUiState>((ref) {
  return PaymentMethodsUiState.defaultStub();
});


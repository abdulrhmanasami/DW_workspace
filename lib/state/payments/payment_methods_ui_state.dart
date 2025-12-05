/// Payment Methods UI State (Stub)
/// Created by: Track B - Ticket #99
/// Updated by: Track B - Ticket #100 (Added selectedMethodId for Ride flow integration)
/// Updated by: Track E - Ticket E-1 (Full CRUD controller for MVP)
/// Purpose: UI Stub model for payment methods display (Screen 16)
/// Last updated: 2025-12-05
///
/// This is a UI-level stub model for MVP. It will be replaced by
/// actual `SavedPaymentMethod` from `packages/payments` when backend is ready.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Payment method type enum for UI display
enum PaymentMethodUiType { cash, card, applePay, googlePay }

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
    this.expMonth,
    this.expYear,
  });

  final String id;
  final String displayName;
  final PaymentMethodUiType type;
  final bool isDefault;
  final String? brand;
  final String? last4;
  /// Track E - Ticket E-1: Expiry month for card display
  final int? expMonth;
  /// Track E - Ticket E-1: Expiry year for card display
  final int? expYear;

  /// Helper to create a Cash payment method
  static const PaymentMethodUiModel cash = PaymentMethodUiModel(
    id: 'cash',
    displayName: 'Cash',
    type: PaymentMethodUiType.cash,
    isDefault: true,
  );

  /// Helper to create Apple Pay method
  /// Track E - Ticket E-1: Added Apple Pay support
  static const PaymentMethodUiModel applePay = PaymentMethodUiModel(
    id: 'apple_pay',
    displayName: 'Apple Pay',
    type: PaymentMethodUiType.applePay,
    isDefault: false,
  );

  /// Helper to create Google Pay method
  /// Track E - Ticket E-1: Added Google Pay support
  static const PaymentMethodUiModel googlePay = PaymentMethodUiModel(
    id: 'google_pay',
    displayName: 'Google Pay',
    type: PaymentMethodUiType.googlePay,
    isDefault: false,
  );

  /// Helper to create a stub Card payment method
  static PaymentMethodUiModel stubCard({
    required String brand,
    required String last4,
    bool isDefault = false,
    int? expMonth,
    int? expYear,
  }) => PaymentMethodUiModel(
    id: '${brand.toLowerCase()}_$last4',
    displayName: '$brand ···· $last4',
    type: PaymentMethodUiType.card,
    isDefault: isDefault,
    brand: brand,
    last4: last4,
    expMonth: expMonth,
    expYear: expYear,
  );

  /// Track E - Ticket E-1: Create a copy with updated isDefault
  PaymentMethodUiModel copyWith({bool? isDefault}) => PaymentMethodUiModel(
    id: id,
    displayName: displayName,
    type: type,
    isDefault: isDefault ?? this.isDefault,
    brand: brand,
    last4: last4,
    expMonth: expMonth,
    expYear: expYear,
  );
}

/// State for Payment Methods UI
/// Track B - Ticket #100: Added selectedMethodId for Ride flow integration
/// Track E - Ticket E-1: Added isLoading and error for async operations
@immutable
class PaymentMethodsUiState {
  const PaymentMethodsUiState({
    this.methods = const [],
    this.selectedMethodId,
    this.isLoading = false,
    this.isAdding = false,
    this.error,
  });

  final List<PaymentMethodUiModel> methods;
  
  /// Track B - Ticket #100: Currently selected payment method ID
  final String? selectedMethodId;

  /// Track E - Ticket E-1: Whether the list is loading
  final bool isLoading;

  /// Track E - Ticket E-1: Whether a new method is being added
  final bool isAdding;

  /// Track E - Ticket E-1: Error message if any
  final String? error;

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

  /// Track E - Ticket E-1: Get the default payment method
  PaymentMethodUiModel? get defaultMethod {
    if (methods.isEmpty) return null;
    final defaultMethods = methods.where((m) => m.isDefault);
    return defaultMethods.isNotEmpty ? defaultMethods.first : methods.first;
  }

  /// Default stub state with Cash + sample Card
  /// Track B - Ticket #100: Default selection is the default method (Cash)
  static PaymentMethodsUiState defaultStub() {
    // Add card separately since stubCard is not const
    final allMethods = [
      PaymentMethodUiModel.cash,
      PaymentMethodUiModel.stubCard(
        brand: 'Visa',
        last4: '4242',
        expMonth: 12,
        expYear: 26,
      ),
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
    bool? isLoading,
    bool? isAdding,
    String? error,
    bool clearError = false,
  }) => PaymentMethodsUiState(
    methods: methods ?? this.methods,
    selectedMethodId: selectedMethodId ?? this.selectedMethodId,
    isLoading: isLoading ?? this.isLoading,
    isAdding: isAdding ?? this.isAdding,
    error: clearError ? null : (error ?? this.error),
  );
}

/// Track E - Ticket E-1: Controller for Payment Methods UI operations
/// Provides full CRUD operations for MVP stub implementation.
class PaymentMethodsUiController extends StateNotifier<PaymentMethodsUiState> {
  PaymentMethodsUiController() : super(PaymentMethodsUiState.defaultStub());

  /// Select a payment method by ID
  void selectMethod(String methodId) {
    final methodExists = state.methods.any((m) => m.id == methodId);
    if (methodExists) {
      state = state.copyWith(selectedMethodId: methodId, clearError: true);
    }
  }

  /// Set a payment method as the default
  /// This also selects the method as current selection
  void setAsDefault(String methodId) {
    final updatedMethods = state.methods.map((method) {
      if (method.id == methodId) {
        return method.copyWith(isDefault: true);
      } else if (method.isDefault) {
        return method.copyWith(isDefault: false);
      }
      return method;
    }).toList();

    state = state.copyWith(
      methods: updatedMethods,
      selectedMethodId: methodId,
      clearError: true,
    );
  }

  /// Add a new card payment method (stub)
  /// Returns true if successful
  Future<bool> addCard({
    required String brand,
    required String last4,
    int? expMonth,
    int? expYear,
    bool setAsDefault = false,
  }) async {
    state = state.copyWith(isAdding: true, clearError: true);

    try {
      // Simulate network delay for realistic UX
      await Future<void>.delayed(const Duration(milliseconds: 800));

      final newCard = PaymentMethodUiModel.stubCard(
        brand: brand,
        last4: last4,
        isDefault: setAsDefault,
        expMonth: expMonth,
        expYear: expYear,
      );

      // Check for duplicate
      final isDuplicate = state.methods.any((m) => m.id == newCard.id);
      if (isDuplicate) {
        state = state.copyWith(
          isAdding: false,
          error: 'This card is already saved',
        );
        return false;
      }

      List<PaymentMethodUiModel> updatedMethods;
      if (setAsDefault) {
        // Remove default from other methods
        updatedMethods = state.methods.map((m) {
          return m.isDefault ? m.copyWith(isDefault: false) : m;
        }).toList();
        updatedMethods.add(newCard);
      } else {
        updatedMethods = [...state.methods, newCard];
      }

      state = state.copyWith(
        methods: updatedMethods,
        selectedMethodId: setAsDefault ? newCard.id : state.selectedMethodId,
        isAdding: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isAdding: false,
        error: 'Failed to add card: $e',
      );
      return false;
    }
  }

  /// Remove a payment method by ID
  /// Cannot remove the last payment method or the currently selected one
  Future<bool> removeMethod(String methodId) async {
    // Cannot remove if it's the only method
    if (state.methods.length <= 1) {
      state = state.copyWith(
        error: 'Cannot remove the only payment method',
      );
      return false;
    }

    // Cannot remove Cash (system method)
    if (methodId == 'cash') {
      state = state.copyWith(
        error: 'Cash payment cannot be removed',
      );
      return false;
    }

    final methodToRemove = state.methods.firstWhere(
      (m) => m.id == methodId,
      orElse: () => PaymentMethodUiModel.cash,
    );

    if (methodToRemove.id != methodId) {
      state = state.copyWith(error: 'Payment method not found');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Simulate network delay
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final updatedMethods = state.methods.where((m) => m.id != methodId).toList();
      
      // If removed method was default, set first as default
      final wasDefault = methodToRemove.isDefault;
      if (wasDefault && updatedMethods.isNotEmpty) {
        updatedMethods[0] = updatedMethods[0].copyWith(isDefault: true);
      }

      // If removed method was selected, select the default/first
      String? newSelectedId = state.selectedMethodId;
      if (state.selectedMethodId == methodId) {
        final newDefault = updatedMethods.firstWhere(
          (m) => m.isDefault,
          orElse: () => updatedMethods.first,
        );
        newSelectedId = newDefault.id;
      }

      state = state.copyWith(
        methods: updatedMethods,
        selectedMethodId: newSelectedId,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to remove card: $e',
      );
      return false;
    }
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh the payment methods list (stub: just resets to default)
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    // In real implementation, this would fetch from backend
    // For stub, we keep current methods
    state = state.copyWith(isLoading: false);
  }
}

/// Track E - Ticket E-1: StateNotifier provider for Payment Methods UI
/// Replaces the simple StateProvider for full CRUD support.
final paymentMethodsUiControllerProvider = 
    StateNotifierProvider<PaymentMethodsUiController, PaymentMethodsUiState>((ref) {
  return PaymentMethodsUiController();
});

/// Provider for Payment Methods UI State
/// Track B - Ticket #99: Default stub data for MVP display
/// Track B - Ticket #100: Now includes selectedMethodId
/// Track E - Ticket E-1: StateProvider for backward compatibility with tests
/// Use paymentMethodsUiControllerProvider for full CRUD operations.
final paymentMethodsUiProvider = StateProvider<PaymentMethodsUiState>((ref) {
  // Listen to controller and sync state
  return ref.watch(paymentMethodsUiControllerProvider);
});


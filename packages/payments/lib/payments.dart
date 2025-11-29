/// Barrel: Payments - Unified Entry Point
/// Created by: Cursor (auto-generated)
/// Purpose: Main barrel export for unified payments package
/// Last updated: 2025-11-18 COM-INTEG-038 - Added critical blocker exports

library payments;

export 'models.dart';
export 'contracts.dart' show PaymentGateway, PaymentsGateway, PaymentsSheet;
export 'providers.dart'
    show
        paymentGatewayProvider,
        paymentsSheetProvider,
        getPaymentService,
        ensurePaymentService,
        ensurePaymentSheet;
export 'package:foundation_shims/payments_config.dart' show PaymentsConfig, loadPaymentsConfig;
export 'legacy/aliases.dart';
// Payment method abstractions
export 'src/payment_method.dart' show PaymentMethod, PaymentMethodType;
// Legacy exports for backward compatibility - avoiding conflicts
export 'src/payment_models.dart'
    show PaymentServiceType, PaymentMetadata, PaymentFailure;
export 'src/payment_service.dart' show PaymentService;
export 'src/payment_status.dart' show PaymentIntentStatus;

/// Component: Stripe Mappers
/// Created by: Cursor (auto-generated)
/// Purpose: Map Stripe states/errors to unified payment models
/// Last updated: 2025-11-11

import 'package:flutter_stripe/flutter_stripe.dart' as stripe_sdk;
import 'package:payments_shims/payments.dart';
import 'package:payments/src/payment_models.dart' as legacy;

/// Map Stripe payment status to unified PaymentStatus
PaymentStatus mapStripeStatus(String? stripeStatus) {
  switch (stripeStatus?.toLowerCase()) {
    case 'succeeded':
      return PaymentStatus.succeeded;
    case 'processing':
    case 'requires_payment_method':
    case 'requires_confirmation':
      return PaymentStatus.processing;
    case 'requires_action':
      return PaymentStatus.requiresAction;
    case 'canceled':
      return PaymentStatus.canceled;
    case 'failed':
    default:
      return PaymentStatus.failed;
  }
}

/// Map Stripe exception to unified legacy.PaymentFailure
legacy.PaymentFailure mapStripeException(dynamic error) {
  if (error is stripe_sdk.StripeException) {
    return legacy.PaymentFailure(
      code: (error.error.code as String?) ?? 'STRIPE_ERROR',
      message: error.error.message ?? 'Payment failed',
      details: {
        'type': error.error.type?.toString(),
        'declineCode': error.error.declineCode,
      },
    );
  }

  // Handle other payment-related exceptions
  if (error is legacy.PaymentFailure) {
    return error;
  }

  return legacy.PaymentFailure(
    code: 'UNKNOWN_ERROR',
    message: error?.toString() ?? 'Unknown payment error',
  );
}

/// Map backend HTTP errors to payment failures
legacy.PaymentFailure mapBackendError(dynamic error, {int? statusCode}) {
  if (error is legacy.PaymentFailure) {
    return error;
  }

  String code = 'BACKEND_ERROR';
  String message = 'Backend communication failed';

  if (statusCode != null) {
    switch (statusCode) {
      case 400:
        code = 'INVALID_REQUEST';
        message = 'Invalid payment request';
        break;
      case 401:
        code = 'AUTHENTICATION_FAILED';
        message = 'Authentication failed';
        break;
      case 402:
        code = 'PAYMENT_REQUIRED';
        message = 'Payment required';
        break;
      case 403:
        code = 'FORBIDDEN';
        message = 'Access forbidden';
        break;
      case 404:
        code = 'NOT_FOUND';
        message = 'Resource not found';
        break;
      case 408:
        code = 'TIMEOUT';
        message = 'Request timeout';
        break;
      case 429:
        code = 'RATE_LIMITED';
        message = 'Too many requests';
        break;
      case 500:
      case 502:
      case 503:
      case 504:
        code = 'SERVER_ERROR';
        message = 'Server error';
        break;
      default:
        code = 'HTTP_$statusCode';
        message = 'HTTP error: $statusCode';
    }
  }

  return legacy.PaymentFailure(
    code: code,
    message: message,
    details: {'original_error': error?.toString()},
  );
}

/// Map 3DS and payment sheet specific errors
legacy.PaymentFailure mapPaymentSheetError(dynamic error) {
  if (error is stripe_sdk.StripeException) {
    // Handle specific payment sheet errors
    final errorType = error.error.type?.toString();
    switch (errorType) {
      case 'canceled':
        return const legacy.PaymentFailure(
          code: 'USER_CANCELLED',
          message: 'Payment was cancelled by user',
        );
      case 'failed':
        return legacy.PaymentFailure(
          code: 'PAYMENT_FAILED',
          message: error.error.message ?? 'Payment failed',
        );
      case 'timeout':
        return const legacy.PaymentFailure(
          code: 'PAYMENT_TIMEOUT',
          message: 'Payment timed out',
        );
      default:
        return mapStripeException(error);
    }
  }

  return mapStripeException(error);
}

/// Create PaymentResult from Stripe payment intent status
PaymentResult createPaymentResultFromStripe(String? status, {String? message}) {
  return PaymentResult(
    status: mapStripeStatus(status),
    message: message,
  );
}

/// Component: Domain Exceptions
/// Created by: Cursor (auto-generated)
/// Purpose: Domain-specific exception classes
/// Last updated: 2025-11-03

/// Base domain exception
abstract class DomainException implements Exception {
  String get message;
  String? get code;
}

/// Validation exception
class ValidationException extends DomainException {
  @override
  final String message;
  @override
  final String? code;

  ValidationException(this.message, {this.code});
}

/// Network exception
class NetworkException extends DomainException {
  @override
  final String message;
  @override
  final String? code;

  NetworkException(this.message, {this.code});
}

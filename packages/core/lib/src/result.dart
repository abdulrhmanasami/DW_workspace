/// Component: Result Type
/// Created by: Cursor (auto-generated)
/// Purpose: Functional programming result type for operations
/// Last updated: 2025-11-03

/// Result type for operations that can succeed or fail
abstract class Result<T, E> {
  const Result._();

  /// Create a successful result
  factory Result.success(T value) = Success<T, E>;

  /// Create a failed result
  factory Result.failure(E error) = Failure<T, E>;

  /// Check if result is successful
  bool get isSuccess;

  /// Check if result failed
  bool get isFailure;

  /// Get the success value (throws if failed)
  T get value;

  /// Get the failure error (throws if successful)
  E get error;
}

/// Success result
class Success<T, E> extends Result<T, E> {
  final T _value;

  Success(this._value) : super._();

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  T get value => _value;

  @override
  E get error => throw StateError('Cannot access error on success result');
}

/// Failure result
class Failure<T, E> extends Result<T, E> {
  final E _error;

  Failure(this._error) : super._();

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  T get value => throw StateError('Cannot access value on failure result');

  @override
  E get error => _error;
}

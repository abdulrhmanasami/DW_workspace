/// Component: Use Case Pattern
/// Created by: Cursor (auto-generated)
/// Purpose: Clean Architecture use case abstractions
/// Last updated: 2025-11-03

/// Base use case interface
abstract class UseCase<T, P> {
  Future<T> call(P params);
}

/// Parameters for use cases that don't need parameters
class NoParams {
  const NoParams();
}

/// Use case parameters base class
abstract class UseCaseParams {
  const UseCaseParams();

  Map<String, dynamic> toJson();
}

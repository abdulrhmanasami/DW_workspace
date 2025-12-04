// packages/mobility_shims/lib/src/ride_exceptions.dart

class InvalidRideTransitionException implements Exception {
  final dynamic from;
  final dynamic to;

  InvalidRideTransitionException(this.from, this.to);

  @override
  String toString() =>
      'InvalidRideTransitionException: cannot transition from $from to $to';
}

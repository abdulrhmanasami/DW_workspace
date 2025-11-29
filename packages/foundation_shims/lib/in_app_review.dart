abstract class InAppReview {
  static InAppReview get instance => _NoopInAppReview();
  Future<bool> isAvailable();
  Future<void> requestReview();
}

class _NoopInAppReview implements InAppReview {
  @override
  Future<bool> isAvailable() async => false;
  @override
  Future<void> requestReview() async {}
}

/// In‑App Review facade (compile‑ready, no SDK logic)
library;

abstract class InAppReviewService {
  Future<bool> canRequest() async => true;
  Future<void> tryRequestOnce() async {}
  static InAppReviewService get I => _StubIAR();
}

class _StubIAR extends InAppReviewService {}

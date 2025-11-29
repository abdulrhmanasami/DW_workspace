/// A/B testing selector interface
abstract class ABSelector {
  bool isEnabled(final String experimentKey);
  String getVariant(final String experimentKey);
  void trackExposure(final String experimentKey, final String variant);
  String getInAppReviewVariant();
}

class ABSelectorStub implements ABSelector {
  static ABSelectorStub? _instance;

  static void initialize(final prefsService) {
    _instance = ABSelectorStub();
  }

  static ABSelectorStub get instance => _instance ?? ABSelectorStub();

  @override
  bool isEnabled(final String experimentKey) => false;

  @override
  String getVariant(final String experimentKey) => 'control';

  @override
  void trackExposure(final String experimentKey, final String variant) {
    // Stub implementation - no tracking
  }

  @override
  String getInAppReviewVariant() => 'default';
}

// Enum for In-App Review variants
enum InAppReviewVariant {
  A, // Added for compatibility
  defaultVariant,
  aggressive,
  conservative,
}

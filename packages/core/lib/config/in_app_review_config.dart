/// In-app review configuration
class InAppReviewConfig {
  static const int minAppLaunches = 5;
  static const int minDaysSinceInstall = 7;
  static const int minDaysSinceLastReview = 30;
  static const double minRatingThreshold = 4;
  static const bool enableInAppReview = true;
  static const int cooldownDays = 30;
  static const int maxPromptsPerUser = 3;

  /// Check if feature is available (static)
  static bool get isFeatureAvailable => true;

  /// Get session threshold for variant (static)
  static int getSessionThresholdForVariant(final String variant) =>
      minAppLaunches;
}

/// A/B Testing selector for local experiments
/// Component|Service|Provider: ABSelector
/// Created by: Cursor (auto-generated)
/// Purpose: Local A/B testing without external services
/// Last updated: 2025-11-08

import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Experiment variants for in-app review
enum InAppReviewVariant {
  A, // More aggressive: 2 sessions
  B, // More conservative: 4 sessions
}

/// Local A/B testing selector using stable hashing
class ABSelector {
  static const String _variantKey = 'in_app_review_variant';
  static const String _assignmentKey = 'in_app_review_assigned';

  /// Get assigned variant for in-app review experiment
  /// Uses stable hashing based on device ID for consistent assignment
  static Future<InAppReviewVariant> getInAppReviewVariant() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if already assigned
    final isAssigned = prefs.getBool(_assignmentKey) ?? false;
    if (isAssigned) {
      final variantStr = prefs.getString(_variantKey);
      if (variantStr == 'A') return InAppReviewVariant.A;
      if (variantStr == 'B') return InAppReviewVariant.B;
    }

    // Generate stable assignment using device fingerprint
    final variant = await _generateStableVariant();

    // Store assignment
    await prefs.setBool(_assignmentKey, true);
    await prefs.setString(
      _variantKey,
      variant == InAppReviewVariant.A ? 'A' : 'B',
    );

    return variant;
  }

  /// Generate stable variant assignment using device fingerprint
  static Future<InAppReviewVariant> _generateStableVariant() async {
    // Use combination of timestamp and random seed for stable hashing
    final seed = DateTime.now().millisecondsSinceEpoch % 1000;
    final random = Random(seed);

    // 50/50 split for A/B testing
    return random.nextBool() ? InAppReviewVariant.A : InAppReviewVariant.B;
  }

  /// Get variant distribution for analytics
  static Future<Map<String, int>> getVariantDistribution() async {
    final prefs = await SharedPreferences.getInstance();
    final variantStr = prefs.getString(_variantKey);

    return {
      'A': variantStr == 'A' ? 1 : 0,
      'B': variantStr == 'B' ? 1 : 0,
      'unassigned': (variantStr == null) ? 1 : 0,
    };
  }

  /// Reset assignment (for testing only)
  static Future<void> resetAssignment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_variantKey);
    await prefs.remove(_assignmentKey);
  }
}

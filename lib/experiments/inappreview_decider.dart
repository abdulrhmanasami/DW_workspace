/// Decision Engine for In-App Review Prompts
/// Component: InAppReviewDecider
/// Created by: Cursor (auto-generated)
/// Purpose: Safe decision-making for when to show review prompts with ANR protection
/// Last updated: 2025-11-03

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'dart:ui';
import 'package:foundation_shims/foundation_shims.dart' as fnd;
import 'package:delivery_ways_clean/config/in_app_review_config.dart';
import 'ab_selector.dart';
import 'prompt_scheduler.dart';

/// Decision engine for in-app review prompts with ANR protection
class InAppReviewDecider {
  static final InAppReview _inAppReview = InAppReview.instance;
  static fnd.Telemetry get _telemetry => fnd.Telemetry.instance;

  /// Evaluate and potentially trigger in-app review prompt
  ///
  /// This is the main entry point for review prompt decisions
  /// Uses PromptScheduler for non-blocking execution with guardrails
  static Future<void> evaluateReviewPrompt({
    required String userId,
    required String sessionId,
    required int sessionCount,
    bool isInBusyFlow = false,
  }) async {
    // Early exit if feature not available
    if (!InAppReviewConfig.isFeatureAvailable) {
      return;
    }

    try {
      // Get A/B variant for this user
      final variant = await ABSelector.getInAppReviewVariant();
      final variantName = variant == InAppReviewVariant.A ? 'A' : 'B';

      // Get session threshold for variant
      final threshold = InAppReviewConfig.getSessionThresholdForVariant(
        variantName,
      );

      // Check if user qualifies for prompt
      if (sessionCount < threshold) {
        // Send decision event using telemetry
        await _telemetry.logEvent('exp_decision.review_eligible_check', {
          'user_id': userId,
          'decision': 'not_eligible',
          'variant': variantName,
          'session_count': sessionCount,
          'threshold': threshold,
        });
        return;
      }

      // Check cooldown (additional safety)
      if (await PromptScheduler.isInCooldown()) {
        await _telemetry.logEvent('exp_decision.review_cooldown', {
          'user_id': userId,
          'decision': 'cooldown_active',
          'variant': variantName,
        });
        return;
      }

      // Schedule prompt with guardrails
      final scheduled = await PromptScheduler.schedulePrompt(
        promptAction: () =>
            _executeReviewPrompt(userId, sessionId, variantName),
        userId: userId,
        isInBusyFlow: isInBusyFlow,
      );

      final cooldownOk = !(await PromptScheduler.isInCooldown());
      if (scheduled) {
        await _telemetry.logEvent('review_prompt.scheduled', {
          'user_id': userId,
          'decision': 'scheduled',
          'variant': variantName,
          'session_count': sessionCount,
          'reason': 'session_threshold',
          'delay_ms': 2000,
          'cooldown_ok': cooldownOk,
          'jank_ratio_last120': PromptScheduler.getCurrentJankRatio(),
          'threshold': threshold,
        });
      }
    } catch (e) {
      // Silent failure - don't break app flow
      await _telemetry.error('InAppReviewDecider evaluation failed: $e');
      if (kDebugMode) {
        print('InAppReviewDecider: Evaluation failed: $e');
      }
    }
  }

  /// Execute the actual review prompt with timeout protection
  static Future<void> _executeReviewPrompt(
    String userId,
    String sessionId,
    String variant,
  ) async {
    try {
      // Check platform availability
      if (!await _inAppReview.isAvailable()) {
        await _telemetry.error(
          'Review prompt error: platform_unavailable',
          context: {'trigger': 'session_threshold'},
        );
        return;
      }

      // Request review
      await _inAppReview.requestReview();

      // Mark as shown for cooldown
      await PromptScheduler.markPromptShown();

      // Send success telemetry
      await _telemetry.logEvent('review_prompt.shown', {
        'variant': variant,
        'session_count': 0, // TODO: Pass actual session count
        'trigger': 'session_threshold',
      });
    } catch (e) {
      // Handle timeout or other errors
      await _telemetry.error(
        'Review prompt execution failed: $e',
        context: {'trigger': 'timeout'},
      );
      if (kDebugMode) {
        print('InAppReviewDecider: Prompt execution failed: $e');
      }
    }
  }

  /// Handle app lifecycle events for PromptScheduler
  static void onAppResume() {
    PromptScheduler.onAppResume();
  }

  /// Handle frame timing for jank detection
  static void onFrame(FrameTiming timing) {
    PromptScheduler.trackFrameTiming(timing);
  }

  /// Get current decision state for debugging
  static Future<Map<String, dynamic>> getDecisionState(String userId) async {
    final variant = await ABSelector.getInAppReviewVariant();
    final variantName = variant == InAppReviewVariant.A ? 'A' : 'B';
    final threshold = InAppReviewConfig.getSessionThresholdForVariant(
      variantName,
    );

    return {
      'variant': variantName,
      'threshold': threshold,
      'is_in_cooldown': await PromptScheduler.isInCooldown(),
      'current_jank_ratio': PromptScheduler.getCurrentJankRatio(),
      'feature_enabled': InAppReviewConfig.isFeatureAvailable,
    };
  }
}

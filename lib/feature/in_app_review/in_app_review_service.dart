/// In-App Review service with intelligent prompting
/// Component|Service|Provider: InAppReviewService
/// Created by: Cursor (auto-generated)
/// Purpose: Manage in-app review prompts with feature flags and A/B testing
/// Last updated: 2025-11-08

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;
import 'package:delivery_ways_clean/config/in_app_review_config.dart';
import 'package:delivery_ways_clean/experiments/ab_selector.dart';

/// Service for managing in-app review prompts
class InAppReviewService {
  static const String _lastPromptKey = 'in_app_review_last_prompt';
  static const String _promptCountKey = 'in_app_review_prompt_count';
  static const String _paymentTriggerKey = 'in_app_review_payment_trigger';
  static const String _day3TriggerKey = 'in_app_review_day3_trigger';

  final InAppReview _inAppReview = InAppReview.instance;
  final fnd.Telemetry _telemetry;

  InAppReviewService(this._telemetry);

  /// Check if review prompt should be shown and trigger if conditions met
  Future<void> maybePromptReview() async {
    if (!await _isFeatureAvailable()) {
      return;
    }

    if (!await _shouldShowPrompt()) {
      return;
    }

    await _showReviewPrompt();
  }

  /// Request in-app review with required BuildContext
  Future<void> requestReview({required BuildContext context}) async {
    if (!await _isFeatureAvailable()) {
      return;
    }

    if (!await _shouldShowPrompt()) {
      return;
    }

    await _showReviewPrompt();
  }

  /// Check if prompt should be shown for given route and launch count
  bool shouldPrompt(String route, {int launches = 0}) {
    // Simplified check - in real implementation would use async checks
    // For now, return false to avoid blocking during migration
    return false;
  }

  /// Check if in-app review feature is available
  Future<bool> _isFeatureAvailable() async {
    // Use static config for now - can be enhanced with remote config later
    return InAppReviewConfig.isFeatureAvailable;
  }

  /// Mark successful payment to potentially trigger review prompt
  Future<void> onPaymentSuccess() async {
    if (!await _isFeatureAvailable()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_paymentTriggerKey, true);

    // Check if we should show prompt immediately after payment
    if (await _shouldShowPrompt()) {
      await _showReviewPrompt(trigger: 'payment_success');
    }
  }

  /// Mark third day usage to potentially trigger review prompt
  Future<void> onThirdDayReached() async {
    if (!await _isFeatureAvailable()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_day3TriggerKey, true);

    // Check if we should show prompt on third day
    if (await _shouldShowPrompt()) {
      await _showReviewPrompt(trigger: 'third_day');
    }
  }

  /// Check if review prompt should be shown based on all conditions
  Future<bool> _shouldShowPrompt() async {
    final prefs = await SharedPreferences.getInstance();

    // Check cooldown period
    final lastPrompt = prefs.getInt(_lastPromptKey);
    if (lastPrompt != null) {
      final daysSinceLastPrompt = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(lastPrompt))
          .inDays;
      if (daysSinceLastPrompt < InAppReviewConfig.cooldownDays) {
        return false;
      }
    }

    // Check maximum prompts per user
    final promptCount = prefs.getInt(_promptCountKey) ?? 0;
    if (promptCount >= InAppReviewConfig.maxPromptsPerUser) {
      return false;
    }

    // Check if platform supports in-app reviews
    if (!await _inAppReview.isAvailable()) {
      return false;
    }

    // Get user's A/B test variant
    final variant = await ABSelector.getInAppReviewVariant();
    final sessionThreshold = InAppReviewConfig.getSessionThresholdForVariant(
      variant == InAppReviewVariant.A ? 'A' : 'B',
    );

    // Check session count (simplified - would need actual session tracking)
    final sessionCount = await _getSessionCount();
    if (sessionCount < sessionThreshold) {
      return false;
    }

    // Check special triggers
    final hasPaymentTrigger = prefs.getBool(_paymentTriggerKey) ?? false;
    final hasDay3Trigger = prefs.getBool(_day3TriggerKey) ?? false;

    // Show prompt if session threshold met OR special trigger activated
    return sessionCount >= sessionThreshold ||
        hasPaymentTrigger ||
        hasDay3Trigger;
  }

  /// Show the review prompt and handle result
  Future<void> _showReviewPrompt({String trigger = 'session_threshold'}) async {
    try {
      final variant = await ABSelector.getInAppReviewVariant();
      final sessionCount = await _getSessionCount();

      // Track prompt shown
      await _telemetry.logEvent('review_prompt.shown', {
        'variant': variant == InAppReviewVariant.A ? 'A' : 'B',
        'session_count': sessionCount,
        'trigger': trigger,
      });

      // Show the review prompt
      await _inAppReview.requestReview();

      // Note: requestReview() returns void, user response is not tracked
      // Track that the prompt was shown (response tracking would require native integration)
      await _telemetry.logEvent('review_response.shown', {
        'variant': variant == InAppReviewVariant.A ? 'A' : 'B',
        'session_count': sessionCount,
        'trigger': trigger,
        'result':
            'shown', // We can only track that it was shown, not the response
      });

      // Update prompt tracking
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastPromptKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt(
        _promptCountKey,
        (prefs.getInt(_promptCountKey) ?? 0) + 1,
      );

      // Reset triggers after showing prompt
      await prefs.setBool(_paymentTriggerKey, false);
      await prefs.setBool(_day3TriggerKey, false);
    } catch (e) {
      // Track error but don't crash
      await _telemetry.error(
        'review_prompt.error: ${e.toString()}',
        context: {'trigger': trigger},
      );
    }
  }

  /// Get current session count (simplified implementation)
  Future<int> _getSessionCount() async {
    // In a real implementation, this would integrate with session tracking
    // For now, use a simple counter stored in prefs
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('session_count') ?? 1;
  }

  /// Increment session count (call this on app launch)
  Future<void> incrementSessionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('session_count') ?? 0;
    await prefs.setInt('session_count', current + 1);
  }
}

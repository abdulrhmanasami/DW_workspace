/// Non-blocking PromptScheduler for In-App Review
/// Component: PromptScheduler
/// Created by: Cursor (auto-generated)
/// Purpose: Safe, non-blocking scheduling of review prompts with runtime guardrails
/// Last updated: 2025-11-03

import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;
import 'package:shared_preferences/shared_preferences.dart';

/// Non-blocking scheduler for in-app review prompts
/// Prevents ANR by deferring execution and applying runtime guardrails
class PromptScheduler {
  static const String _lastPromptKey = 'review_prompt_last_shown';
  static const String _cooldownStartKey = 'review_prompt_cooldown_start';
  static const Duration _cooldownPeriod = Duration(hours: 24);
  static const Duration _debounceWindow = Duration(seconds: 5);

  static DateTime? _lastAppResumeTime;
  static final List<FrameTiming> _frameTimings = [];
  static const int _maxFrameTimings = 120;
  static Timer? _debounceTimer;

  /// Schedule a review prompt with safety guardrails
  ///
  /// Returns Future that completes when scheduling decision is made
  /// Does NOT block UI thread - defers execution to post-frame callback
  static Future<bool> schedulePrompt({
    required Future<void> Function() promptAction,
    required String userId,
    bool isInBusyFlow = false,
  }) async {
    // Early guardrail checks (fast, synchronous)
    if (await _shouldSkipPrompt(isInBusyFlow, userId)) {
      return false;
    }

    // Schedule non-blocking execution
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _executePromptSafely(promptAction, userId);
    });

    return true; // Scheduled successfully
  }

  /// Execute prompt with timeout and error handling
  static Future<void> _executePromptSafely(
    Future<void> Function() promptAction,
    String userId,
  ) async {
    try {
      // Apply 2-second delay for UI stability
      await Future<void>.delayed(const Duration(seconds: 2));

      // Final runtime checks before execution
      if (await _shouldSkipPrompt(false, userId)) {
        return;
      }

      // Execute with 2-second timeout
      await Future.any([
        promptAction(),
        Future<void>.delayed(const Duration(seconds: 2)),
      ]).timeout(const Duration(seconds: 2));
    } catch (e) {
      // Silent failure - don't crash the app
      if (kDebugMode) {
        print('PromptScheduler: Prompt execution failed: $e');
      }
    }
  }

  /// Check if prompt should be skipped based on runtime conditions
  static Future<bool> _shouldSkipPrompt(
    bool isInBusyFlow, [
    String? userId,
  ]) async {
    final now = DateTime.now();

    // Skip if in busy flow (checkout/payment/navigation)
    if (isInBusyFlow) {
      return true;
    }

    // Skip if app just resumed (debounce background returns)
    if (_lastAppResumeTime != null &&
        now.difference(_lastAppResumeTime!) < _debounceWindow) {
      return true;
    }

    // Skip if in cooldown period
    final prefs = await SharedPreferences.getInstance();
    final cooldownStartStr = prefs.getString(_cooldownStartKey);
    if (cooldownStartStr != null) {
      final cooldownStart = DateTime.parse(cooldownStartStr);
      if (now.difference(cooldownStart) < _cooldownPeriod) {
        return true;
      }
    }

    // Skip if jank ratio too high (>10% frames >32ms)
    final jankRatio = _calculateJankRatio();
    if (jankRatio > 0.1) {
      // Send telemetry for jank skip if userId provided
      if (userId != null) {
        try {
          await fnd.Telemetry.instance.logEvent(
            'review_prompt.skipped_jank',
            {'user_id_hash': userId, 'jank_ratio': jankRatio, 'threshold': 0.1},
          );
        } catch (e) {
          // Silent failure for telemetry
        }
      }
      return true;
    }

    return false;
  }

  /// Calculate jank ratio from recent frame timings
  static double _calculateJankRatio() {
    if (_frameTimings.isEmpty) return 0.0;

    final jankyFrames = _frameTimings
        .where((timing) => timing.totalSpan.inMilliseconds > 32)
        .length;

    return jankyFrames / _frameTimings.length;
  }

  /// Track app lifecycle for debounce logic
  static void onAppResume() {
    _lastAppResumeTime = DateTime.now();

    // Clear debounce after window expires
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceWindow, () {
      _lastAppResumeTime = null;
    });
  }

  /// Track frame timings for jank detection
  static void trackFrameTiming(FrameTiming timing) {
    _frameTimings.add(timing);
    if (_frameTimings.length > _maxFrameTimings) {
      _frameTimings.removeAt(0);
    }
  }

  /// Mark prompt as shown (updates cooldown)
  static Future<void> markPromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();

    await prefs.setString(_lastPromptKey, now);
    await prefs.setString(_cooldownStartKey, now);
  }

  /// Get current jank ratio for telemetry
  static double getCurrentJankRatio() => _calculateJankRatio();

  /// Get cooldown status for telemetry
  static Future<bool> isInCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    final cooldownStartStr = prefs.getString(_cooldownStartKey);
    if (cooldownStartStr == null) return false;

    final cooldownStart = DateTime.parse(cooldownStartStr);
    return DateTime.now().difference(cooldownStart) < _cooldownPeriod;
  }

  /// Reset cooldown (for testing only)
  static Future<void> resetCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cooldownStartKey);
    await prefs.remove(_lastPromptKey);
  }
}

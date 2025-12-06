// Component: Passwordless Auth Controller
// Created by: CENT-003 Implementation (CENT-004: 2FA/MFA support)
// Purpose: Riverpod controller for Passwordless OTP auth flow with MFA
// Last updated: 2025-11-25

import 'package:auth_shims/auth_shims.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:delivery_ways_clean/config/feature_flags.dart';
import 'package:delivery_ways_clean/state/infra/auth_providers.dart';

typedef PasswordlessClock = DateTime Function();

const Duration _otpRequestCooldown = Duration(seconds: 45);
const int _maxOtpRequestsPerSession = 5;

enum PasswordlessStep {
  enterPhone,
  codeSent,
  verifying,
  // MFA steps (CENT-004)
  mfaRequired,
  mfaVerifying,
  authenticated,
  error,
}

class PasswordlessAuthState {
  final PasswordlessStep step;
  final String? phoneE164;
  final String? errorMessage;
  final DateTime? nextRequestAllowedAt;
  final int requestCount;
  final int maxRequestsPerSession;
  // MFA fields (CENT-004)
  final MfaRequirement? mfaRequirement;
  final MfaChallenge? activeMfaChallenge;
  final AuthSession? pendingSession;

  const PasswordlessAuthState({
    required this.step,
    this.phoneE164,
    this.errorMessage,
    this.nextRequestAllowedAt,
    this.requestCount = 0,
    this.maxRequestsPerSession = _maxOtpRequestsPerSession,
    this.mfaRequirement,
    this.activeMfaChallenge,
    this.pendingSession,
  });

  PasswordlessAuthState copyWith({
    PasswordlessStep? step,
    String? phoneE164,
    String? errorMessage,
    DateTime? nextRequestAllowedAt,
    bool clearNextRequestAllowedAt = false,
    int? requestCount,
    int? maxRequestsPerSession,
    MfaRequirement? mfaRequirement,
    bool clearMfaRequirement = false,
    MfaChallenge? activeMfaChallenge,
    bool clearActiveMfaChallenge = false,
    AuthSession? pendingSession,
    bool clearPendingSession = false,
  }) {
    return PasswordlessAuthState(
      step: step ?? this.step,
      phoneE164: phoneE164 ?? this.phoneE164,
      errorMessage: errorMessage,
      nextRequestAllowedAt:
          clearNextRequestAllowedAt ? null : (nextRequestAllowedAt ?? this.nextRequestAllowedAt),
      requestCount: requestCount ?? this.requestCount,
      maxRequestsPerSession: maxRequestsPerSession ?? this.maxRequestsPerSession,
      mfaRequirement: clearMfaRequirement ? null : (mfaRequirement ?? this.mfaRequirement),
      activeMfaChallenge: clearActiveMfaChallenge ? null : (activeMfaChallenge ?? this.activeMfaChallenge),
      pendingSession: clearPendingSession ? null : (pendingSession ?? this.pendingSession),
    );
  }

  /// Check if we're in an MFA step
  bool get isInMfaFlow => step == PasswordlessStep.mfaRequired || step == PasswordlessStep.mfaVerifying;

  bool canRequestOtp(DateTime now) {
    if (requestCount >= maxRequestsPerSession) return false;
    final nextAllowed = nextRequestAllowedAt;
    if (nextAllowed == null) return true;
    return !nextAllowed.isAfter(now);
  }

  Duration? cooldownRemaining(DateTime now) {
    final nextAllowed = nextRequestAllowedAt;
    if (nextAllowed == null) return null;
    final diff = nextAllowed.difference(now);
    if (diff.isNegative) {
      return Duration.zero;
    }
    return diff;
  }

  int get remainingRequests {
    final remaining = maxRequestsPerSession - requestCount;
    return remaining < 0 ? 0 : remaining;
  }

  static const initial = PasswordlessAuthState(
    step: PasswordlessStep.enterPhone,
    requestCount: 0,
    maxRequestsPerSession: _maxOtpRequestsPerSession,
  );
}

final passwordlessAuthControllerProvider = StateNotifierProvider<
    PasswordlessAuthController, PasswordlessAuthState>((ref) {
  if (!FeatureFlags.enablePasswordlessAuth) {
    throw StateError('Passwordless auth disabled via feature flag.');
  }
  final service = ref.watch(authServiceProvider);
  return PasswordlessAuthController(service);
});

class PasswordlessAuthController extends StateNotifier<PasswordlessAuthState> {
  PasswordlessAuthController(this._service, {PasswordlessClock? clock})
      : _clock = clock ?? _defaultClock,
        super(PasswordlessAuthState.initial);

  final AuthService _service;
  final PasswordlessClock _clock;

  static DateTime _defaultClock() => DateTime.now().toUtc();

  bool get _hasExhaustedRequests =>
      state.requestCount >= state.maxRequestsPerSession;

  bool get _isInCooldown {
    final nextAllowed = state.nextRequestAllowedAt;
    if (nextAllowed == null) return false;
    return nextAllowed.isAfter(_clock());
  }

  Future<void> requestOtp(String phoneE164) async {
    final now = _clock();
    if (_hasExhaustedRequests) {
      state = state.copyWith(
        step: PasswordlessStep.error,
        errorMessage: 'Maximum OTP requests reached. Please try again later.',
      );
      return;
    }
    if (_isInCooldown) {
      final remaining = state.cooldownRemaining(now);
      final message = remaining == null || remaining == Duration.zero
          ? 'Please try again.'
          : 'Please wait ${remaining.inSeconds}s before requesting another code.';
      state = state.copyWith(
        step: PasswordlessStep.error,
        errorMessage: message,
      );
      return;
    }

    state = state.copyWith(
      step: PasswordlessStep.verifying,
      phoneE164: phoneE164.trim(),
      errorMessage: null,
    );

    try {
      final phone = _validatedPhone(phoneE164);
      await _service.requestOtp(phone);
      final afterCall = _clock();
      state = state.copyWith(
        step: PasswordlessStep.codeSent,
        nextRequestAllowedAt: afterCall.add(_otpRequestCooldown),
        requestCount: state.requestCount + 1,
      );
    } on AuthException catch (error) {
      state = _mapAuthException(error);
    } catch (error) {
      state = state.copyWith(
        step: PasswordlessStep.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> verifyOtp(String code) async {
    final phone = state.phoneE164;
    if (phone == null) {
      state = state.copyWith(
        step: PasswordlessStep.error,
        errorMessage: 'Phone number missing. Restart flow.',
      );
      return;
    }

    state = state.copyWith(
      step: PasswordlessStep.verifying,
      errorMessage: null,
    );

    try {
      final otp = _validatedOtp(code);
      final phoneNumber = _validatedPhone(phone);
      final session = await _service.verifyOtp(phoneNumber: phoneNumber, code: otp);

      // Check if MFA is required (CENT-004 - Sale-Only behavior)
      if (FeatureFlags.enableTwoFactorAuth) {
        final mfaRequirement = await _service.evaluateMfaRequirement(
          session: session,
          action: 'login',
        );

        if (mfaRequirement.required) {
          // MFA required - transition to MFA flow
          state = state.copyWith(
            step: PasswordlessStep.mfaRequired,
            mfaRequirement: mfaRequirement,
            pendingSession: session,
            clearNextRequestAllowedAt: true,
          );
          return;
        }
      }

      // No MFA required or 2FA disabled - proceed to authenticated
      state = state.copyWith(
        step: PasswordlessStep.authenticated,
        clearNextRequestAllowedAt: true,
        clearMfaRequirement: true,
        clearPendingSession: true,
      );
    } on AuthException catch (error) {
      state = _mapAuthException(error);
    } catch (error) {
      state = state.copyWith(
        step: PasswordlessStep.error,
        errorMessage: error.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // MFA Methods (CENT-004)
  // ---------------------------------------------------------------------------

  /// Start MFA challenge with the specified method.
  ///
  /// Call this when [state.step] == [PasswordlessStep.mfaRequired].
  Future<void> startMfa(MfaMethodType method) async {
    final pendingSession = state.pendingSession;
    if (pendingSession == null) {
      state = state.copyWith(
        step: PasswordlessStep.error,
        errorMessage: 'No pending session. Restart authentication.',
      );
      return;
    }

    state = state.copyWith(
      step: PasswordlessStep.mfaVerifying,
      errorMessage: null,
    );

    try {
      final challenge = await _service.startMfaChallenge(
        session: pendingSession,
        method: method,
        action: 'login',
      );

      state = state.copyWith(
        step: PasswordlessStep.mfaRequired,
        activeMfaChallenge: challenge,
      );
    } on AuthException catch (error) {
      state = state.copyWith(
        step: PasswordlessStep.error,
        errorMessage: error.message,
      );
    } on MfaException catch (error) {
      state = state.copyWith(
        step: PasswordlessStep.error,
        errorMessage: error.message,
      );
    } catch (error) {
      state = state.copyWith(
        step: PasswordlessStep.error,
        errorMessage: error.toString(),
      );
    }
  }

  /// Submit MFA verification code.
  ///
  /// Call this when [state.activeMfaChallenge] != null.
  Future<void> submitMfaCode(String code) async {
    final challenge = state.activeMfaChallenge;
    if (challenge == null) {
      state = state.copyWith(
        step: PasswordlessStep.error,
        errorMessage: 'No active MFA challenge. Restart authentication.',
      );
      return;
    }

    state = state.copyWith(
      step: PasswordlessStep.mfaVerifying,
      errorMessage: null,
    );

    try {
      final result = await _service.verifyMfaCode(
        challengeId: challenge.challengeId,
        code: code.trim(),
      );

      if (result.success) {
        // MFA successful - complete authentication
        state = state.copyWith(
          step: PasswordlessStep.authenticated,
          clearMfaRequirement: true,
          clearActiveMfaChallenge: true,
          clearPendingSession: true,
        );
      } else if (result.locked) {
        // Account locked
        state = state.copyWith(
          step: PasswordlessStep.error,
          errorMessage: result.message ?? 'Account locked. Try again later.',
          clearActiveMfaChallenge: true,
        );
      } else {
        // Wrong code but not locked
        state = state.copyWith(
          step: PasswordlessStep.mfaRequired,
          errorMessage: result.message ?? 'Invalid code. Please try again.',
        );
      }
    } on AuthException catch (error) {
      state = state.copyWith(
        step: PasswordlessStep.error,
        errorMessage: error.message,
      );
    } on MfaException catch (error) {
      state = state.copyWith(
        step: PasswordlessStep.error,
        errorMessage: error.message,
      );
    } catch (error) {
      state = state.copyWith(
        step: PasswordlessStep.error,
        errorMessage: error.toString(),
      );
    }
  }

  /// Cancel MFA flow and return to phone entry.
  void cancelMfa() {
    state = PasswordlessAuthState.initial;
  }

  Future<void> logout() async {
    await _service.logout();
    state = PasswordlessAuthState.initial;
  }

  PhoneNumber _validatedPhone(String raw) {
    final trimmed = raw.trim();
    final phone = PhoneNumber(trimmed);
    if (!phone.isValid) {
      throw const AuthException.invalidPhone();
    }
    return phone;
  }

  OtpCode _validatedOtp(String raw) {
    final trimmed = raw.trim();
    final code = OtpCode(trimmed);
    if (!code.isValid) {
      throw const AuthException.invalidOtp();
    }
    return code;
  }

  PasswordlessAuthState _mapAuthException(AuthException error) {
    if (error.code == 'rate_limited') {
      return state.copyWith(
        step: PasswordlessStep.error,
        errorMessage: error.message,
        nextRequestAllowedAt: _clock().add(_otpRequestCooldown),
      );
    }
    return state.copyWith(
      step: PasswordlessStep.error,
      errorMessage: error.message,
    );
  }
}


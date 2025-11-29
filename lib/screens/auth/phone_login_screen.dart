// Component: Phone Login Screen
// Created by: CENT-003 Implementation (UX-005: Micro-interactions)
// Purpose: Passwordless OTP phone number entry screen with enhanced UX
// Last updated: 2025-11-25

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/feature_flags.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/auth/passwordless_auth_controller.dart';
import '../../state/infra/auth_providers.dart';
import 'package:b_ui/ui_components.dart';
import 'legacy_auth_placeholder.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _phoneRegex = RegExp(r'^\+[1-9]\d{6,14}$');

  String? _localError;
  Timer? _cooldownTicker;
  DateTime? _cooldownTarget;
  bool _unlocking = false;

  @override
  void dispose() {
    _cooldownTicker?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Track D - Ticket #3: Use Theme.of(context) for unified styling
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final enablePasswordless = FeatureFlags.enablePasswordlessAuth;
    final l10n = AppLocalizations.of(context);

    if (!enablePasswordless) {
      return LegacyAuthPlaceholder(
        title: l10n?.authPhoneLoginTitle ?? 'Sign In',
      );
    }

    ref.listen<PasswordlessAuthState>(
      passwordlessAuthControllerProvider,
      (prev, next) {
        if (!FeatureFlags.enablePasswordlessAuth || !mounted) return;

        if (prev?.step != PasswordlessStep.codeSent &&
            next.step == PasswordlessStep.codeSent) {
          Navigator.of(context).pushNamed(RoutePaths.otpVerification);
        } else if (prev?.step != PasswordlessStep.error &&
            next.step == PasswordlessStep.error &&
            next.errorMessage != null) {
          _showError(next.errorMessage!);
        }
      },
    );

    final flowState = ref.watch(passwordlessAuthControllerProvider);
    final biometricSupportAsync = ref.watch(biometricSupportProvider);
    _syncCooldownTimer(flowState);

    final now = DateTime.now().toUtc();
    final cooldown = flowState.cooldownRemaining(now);
    final isCoolingDown = cooldown != null && cooldown > Duration.zero;
    final cooldownSeconds = cooldown?.inSeconds ?? 0;
    final attemptsRemaining = flowState.remainingRequests;
    final canRequestOtp = flowState.canRequestOtp(now);
    final canUseBiometric = FeatureFlags.enableBiometricAuth &&
        biometricSupportAsync.maybeWhen(
          data: (status) => status.canAuthenticate,
          orElse: () => false,
        );

    if (flowState.phoneE164 != null && _phoneController.text.isEmpty) {
      _phoneController.text = flowState.phoneE164!;
    }

    final notifier = ref.read(passwordlessAuthControllerProvider.notifier);
    final isLoading = flowState.step == PasswordlessStep.verifying;
    final shouldDisableRequest = isLoading || !canRequestOtp;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.authPhoneLoginTitle ?? 'Sign In',
          style: textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome title
              Text(
                l10n?.authPhoneLoginTitle ?? 'Sign In',
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),

              // Helper text
              Text(
                l10n?.authPhoneLoginSubtitle ??
                    'Enter your phone number to receive a verification code.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Phone number input field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  labelText: l10n?.authPhoneFieldLabel ?? 'Phone Number',
                  hintText: l10n?.authPhoneFieldHint ?? '+9665xxxxxxxx',
                  prefixIcon: Icon(Icons.phone, color: colorScheme.onSurfaceVariant),
                  errorText: _localError ?? flowState.errorMessage,
                ),
              ),
              const SizedBox(height: 8),

              // Cooldown message (error style)
              if (isCoolingDown)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _cooldownLabel(l10n, cooldownSeconds: cooldownSeconds),
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),

              // Attempts remaining info
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _attemptsLabel(l10n, attemptsRemaining: attemptsRemaining),
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // Biometric unlock option
              if (canUseBiometric) ...[
                const SizedBox(height: 8),
                AnimatedOpacity(
                  opacity: _unlocking ? 0.7 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: OutlinedButton.icon(
                    onPressed: _unlocking
                        ? null
                        : () => _attemptBiometricUnlock(l10n),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _unlocking
                          ? SizedBox(
                              key: const ValueKey('loading'),
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            )
                          : Icon(
                              Icons.fingerprint,
                              key: const ValueKey('icon'),
                              color: colorScheme.primary,
                            ),
                    ),
                    label: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _unlocking
                            ? (l10n?.loading ?? 'Verifying...')
                            : (l10n?.authBiometricButtonLabel ?? 'Use biometrics'),
                        key: ValueKey(_unlocking ? 'loading' : 'label'),
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Privacy policy link
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(RoutePaths.privacyConsent);
                  },
                  child: Text(
                    l10n?.legalPrivacyPolicyTitle ?? 'Privacy Policy & Terms',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Continue button (full width)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: shouldDisableRequest
                      ? null
                      : () async {
                          final normalized = _validateAndNormalize(l10n);
                          if (normalized == null) return;
                          await notifier.requestOtp(normalized);
                        },
                  child: UiLoadingButtonContent(
                    label: l10n?.authPhoneContinueButton ?? 'Continue',
                    isLoading: isLoading,
                    loadingLabel: l10n?.loading ?? 'Loading...',
                    spinnerColor: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateAndNormalize(AppLocalizations? l10n) {
    final input = _phoneController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _localError = l10n?.authPhoneRequiredError ?? 'Phone number is required';
      });
      return null;
    }

    final normalized = input.startsWith('+') ? input : '+$input';
    if (!_phoneRegex.hasMatch(normalized)) {
      setState(() {
        _localError =
            l10n?.authPhoneInvalidFormatError ?? 'Invalid phone number format';
      });
      return null;
    }

    setState(() => _localError = null);
    return normalized;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _attemptBiometricUnlock(AppLocalizations? l10n) async {
    if (_unlocking) return;
    setState(() => _unlocking = true);
    try {
      final service = ref.read(authServiceProvider);
      final unlocked = await service.unlockStoredSession(
        localizedReason: l10n?.authBiometricReason ?? 'Authenticate to continue.',
      );
      if (!mounted) return;
      if (unlocked) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RoutePaths.home,
          (route) => false,
        );
      } else {
        _showError(
          l10n?.authBiometricUnlockError ??
              'Unable to unlock with biometrics. Please request a new code.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _unlocking = false);
      }
    }
  }

  void _syncCooldownTimer(PasswordlessAuthState state) {
    final target = state.nextRequestAllowedAt;
    if (_cooldownTarget == target) return;

    _cooldownTicker?.cancel();
    _cooldownTarget = target;

    if (target == null || !target.isAfter(DateTime.now().toUtc())) {
      _cooldownTarget = null;
      return;
    }

    _cooldownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _cooldownTicker?.cancel();
        return;
      }

      final stillActive =
          state.nextRequestAllowedAt?.isAfter(DateTime.now().toUtc()) ?? false;
      if (!stillActive) {
        _cooldownTicker?.cancel();
        _cooldownTarget = null;
      }
      setState(() {});
    });
  }

  String _cooldownLabel(
    AppLocalizations? l10n, {
    required int cooldownSeconds,
  }) {
    if (cooldownSeconds <= 0) {
      return l10n?.authCooldownReady ?? 'You can resend now.';
    }
    return l10n?.authCooldownMessage(cooldownSeconds) ??
        'Please wait ${cooldownSeconds}s before trying again.';
  }

  String _attemptsLabel(
    AppLocalizations? l10n, {
    required int attemptsRemaining,
  }) {
    if (attemptsRemaining <= 0) {
      return l10n?.authNoAttemptsRemaining ?? 'No attempts remaining.';
    }
    return l10n?.authAttemptsRemaining(attemptsRemaining) ??
        '$attemptsRemaining attempts remaining';
  }
}


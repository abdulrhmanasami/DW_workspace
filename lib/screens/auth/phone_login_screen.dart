// Component: Phone Login Screen
// Created by: CENT-003 Implementation (UX-005: Micro-interactions)
// Purpose: Passwordless OTP phone number entry screen with enhanced UX
// Last updated: 2025-11-25

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:delivery_ways_clean/config/feature_flags.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/state/auth/passwordless_auth_controller.dart';
import 'package:delivery_ways_clean/state/infra/auth_providers.dart';
import 'package:delivery_ways_clean/widgets/app_shell.dart';
import 'package:b_ui/ui_components.dart';
import 'legacy_auth_placeholder.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key, this.forceEnablePasswordless = false});

  /// Force enable passwordless auth for testing purposes
  final bool forceEnablePasswordless;

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _phoneRegex = RegExp(r'^\+[1-9]\d{6,14}$');

  String? _localError;
  bool _unlocking = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Track D - Ticket #3: Use Theme.of(context) for unified styling
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final enablePasswordless = FeatureFlags.enablePasswordlessAuth || widget.forceEnablePasswordless;
    final l10n = AppLocalizations.of(context);

    if (!enablePasswordless) {
      return LegacyAuthPlaceholder(
        title: l10n?.authPhoneLoginTitle ?? 'Sign In',
      );
    }

    // Listen to PasswordlessAuthController state for navigation and errors
    ref.listen(passwordlessAuthControllerProvider, (prev, next) {
      if (!FeatureFlags.enablePasswordlessAuth || !mounted) return;

      // Navigate to OTP screen when code is sent successfully
      if (prev?.step != PasswordlessStep.codeSent && next.step == PasswordlessStep.codeSent) {
        Navigator.of(context).pushNamed(RoutePaths.otpVerification, arguments: next.phoneE164);
      }

      // Show error message if request fails
      if (next.step == PasswordlessStep.error && next.errorMessage != null &&
          (prev?.errorMessage != next.errorMessage)) {
        _showError(next.errorMessage!);
      }
    });

    final authState = ref.watch(passwordlessAuthControllerProvider);
    final biometricSupportAsync = ref.watch(biometricSupportProvider);

    final canUseBiometric = FeatureFlags.enableBiometricAuth &&
        biometricSupportAsync.maybeWhen(
          data: (status) => status.canAuthenticate,
          orElse: () => false,
        );

    final isLoading = authState.step == PasswordlessStep.verifying;
    final shouldDisableRequest = isLoading;

    return AppShell(
      title: l10n?.authPhoneLoginTitle ?? 'Sign In',
      showAppBar: true,
      showBottomNav: false,
      safeArea: true,
      body: Padding(
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
                errorText: _localError ?? authState.errorMessage,
              ),
            ),
            const SizedBox(height: 8),

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
                        await ref.read(passwordlessAuthControllerProvider.notifier).requestOtp(normalized);
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

}


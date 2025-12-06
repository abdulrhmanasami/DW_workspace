// Component: Two-Factor Authentication Screen
// Created by: CENT-004 Implementation (UX-005: Micro-interactions)
// Purpose: 2FA/MFA verification screen with Sale-Only behavior and enhanced UX
// Last updated: 2025-11-25

import 'package:auth_shims/auth_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:delivery_ways_clean/config/feature_flags.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/state/auth/passwordless_auth_controller.dart';
import 'package:delivery_ways_clean/state/infra/auth_providers.dart';
import 'package:delivery_ways_clean/state/guidance/guidance_providers.dart';
import 'package:delivery_ways_clean/widgets/in_app_hint_banner.dart';
import 'package:b_ui/ui_components.dart';

/// Two-Factor Authentication screen.
///
/// This screen is ONLY shown when:
/// 1. [FeatureFlags.enableTwoFactorAuth] is true
/// 2. Backend returns [MfaRequirement.required] == true
///
/// Sale-Only behavior: If 2FA is disabled or not required by backend,
/// this screen will never be displayed (no fake/demo UI).
class TwoFactorScreen extends ConsumerStatefulWidget {
  const TwoFactorScreen({super.key});

  @override
  ConsumerState<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends ConsumerState<TwoFactorScreen> {
  final _codeController = TextEditingController();
  final _codeRegex = RegExp(r'^\d{4,8}$');
  bool _completed = false;
  String? _localError;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Sale-Only check: If 2FA is disabled, navigate away
    if (!FeatureFlags.enableTwoFactorAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(RoutePaths.home);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Listen for auth state changes
    ref.listen<PasswordlessAuthState>(
      passwordlessAuthControllerProvider,
      (prev, next) {
        if (!mounted || _completed) return;

        // Navigate to home on successful authentication
        if (next.step == PasswordlessStep.authenticated) {
          _completed = true;
          Navigator.of(context).pushNamedAndRemoveUntil(
            RoutePaths.home,
            (route) => false,
          );
        }

        // Navigate back to phone entry if flow is cancelled/reset
        if (next.step == PasswordlessStep.enterPhone) {
          Navigator.of(context).pushReplacementNamed(RoutePaths.phoneLogin);
        }

        // Show error snackbar on new errors
        if (_localError == null &&
            prev?.step != PasswordlessStep.error &&
            next.step == PasswordlessStep.error &&
            next.errorMessage != null) {
          _showError(next.errorMessage!);
        }
      },
    );

    // Also listen to auth state provider for redundancy
    ref.listen(authStateProvider, (prev, next) {
      if (!mounted || _completed) return;
      next.whenData((authState) {
        if (authState.isAuthenticated) {
          _completed = true;
          Navigator.of(context).pushNamedAndRemoveUntil(
            RoutePaths.home,
            (route) => false,
          );
        }
      });
    });

    final flowState = ref.watch(passwordlessAuthControllerProvider);
    final notifier = ref.read(passwordlessAuthControllerProvider.notifier);

    // Sale-Only: If not in MFA flow, redirect
    if (!flowState.isInMfaFlow && flowState.step != PasswordlessStep.error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(RoutePaths.phoneLogin);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final mfaRequirement = flowState.mfaRequirement;
    final activeChallenge = flowState.activeMfaChallenge;
    final isVerifying = flowState.step == PasswordlessStep.mfaVerifying;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.auth2faTitle ?? 'Two-Factor Authentication'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            notifier.cancelMfa();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 2FA Hint Banner
            _TwoFactorHintBanner(),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: activeChallenge != null
                    ? _buildCodeEntryView(
                        context,
                        l10n,
                        notifier,
                        activeChallenge,
                        flowState,
                        isVerifying,
                      )
                    : _buildMethodSelectionView(
                        context,
                        l10n,
                        notifier,
                        mfaRequirement,
                        isVerifying,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the MFA method selection view
  Widget _buildMethodSelectionView(
    BuildContext context,
    AppLocalizations? l10n,
    PasswordlessAuthController notifier,
    MfaRequirement? requirement,
    bool isLoading,
  ) {
    final methods = requirement?.allowedMethods ?? <MfaMethodType>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n?.auth2faSubtitle ??
              'An additional verification step is required for your security.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        Text(
          l10n?.auth2faSelectMethod ?? 'Select verification method',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (methods.isEmpty)
          Center(
            child: Text(
              'No verification methods available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          )
        else
          ...methods.map(
            (method) => _buildMethodTile(context, l10n, notifier, method, isLoading),
          ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: isLoading ? null : () => notifier.cancelMfa(),
          child: Text(l10n?.auth2faCancelButton ?? 'Cancel'),
        ),
      ],
    );
  }

  /// Build a single method selection tile
  Widget _buildMethodTile(
    BuildContext context,
    AppLocalizations? l10n,
    PasswordlessAuthController notifier,
    MfaMethodType method,
    bool isLoading,
  ) {
    final (title, description, icon) = _getMethodInfo(l10n, method);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(description),
        trailing: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right),
        onTap: isLoading ? null : () => notifier.startMfa(method),
      ),
    );
  }

  /// Build the code entry view
  Widget _buildCodeEntryView(
    BuildContext context,
    AppLocalizations? l10n,
    PasswordlessAuthController notifier,
    MfaChallenge challenge,
    PasswordlessAuthState flowState,
    bool isVerifying,
  ) {
    final (title, _, icon) = _getMethodInfo(l10n, challenge.method);
    final errorMessage = _localError ?? flowState.errorMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Method indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (challenge.maskedDestination != null)
          Text(
            challenge.maskedDestination!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
        const SizedBox(height: 32),

        // Code input
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 8,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8),
          decoration: InputDecoration(
            labelText: l10n?.auth2faEnterCode ?? 'Enter verification code',
            hintText: l10n?.auth2faCodeHint ?? 'Enter the 6-digit code',
            counterText: '',
            errorText: errorMessage,
          ),
          onChanged: (_) {
            if (_localError != null) {
              setState(() => _localError = null);
            }
          },
        ),
        const SizedBox(height: 8),

        // Expiry indicator
        if (!challenge.isExpired)
          _buildExpiryIndicator(context, l10n, challenge),

        // Attempts remaining
        if (challenge.attemptsRemaining != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n?.authAttemptsRemaining(challenge.attemptsRemaining!) ??
                  '${challenge.attemptsRemaining} attempts remaining',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: challenge.attemptsRemaining! <= 1
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
            ),
          ),

        const SizedBox(height: 24),

        // Verify button
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: isVerifying
                ? null
                : () {
                    final code = _validateCode(l10n);
                    if (code != null) {
                      notifier.submitMfaCode(code);
                    }
                  },
            child: UiLoadingButtonContent(
              label: l10n?.auth2faVerifyButton ?? 'Verify',
              isLoading: isVerifying,
              loadingLabel: l10n?.loading ?? 'Verifying...',
              spinnerColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Resend code button (for sms/email methods)
        if (challenge.method == MfaMethodType.sms ||
            challenge.method == MfaMethodType.email)
          TextButton(
            onPressed: isVerifying
                ? null
                : () => notifier.startMfa(challenge.method),
            child: Text(l10n?.auth2faResendCode ?? 'Resend code'),
          ),

        // Back to method selection
        TextButton(
          onPressed: isVerifying ? null : () => notifier.cancelMfa(),
          child: Text(l10n?.auth2faCancelButton ?? 'Cancel'),
        ),
      ],
    );
  }

  /// Build expiry countdown indicator
  Widget _buildExpiryIndicator(
    BuildContext context,
    AppLocalizations? l10n,
    MfaChallenge challenge,
  ) {
    final remaining = challenge.timeRemaining;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    return Text(
      'Code expires in $minutes:${seconds.toString().padLeft(2, '0')}',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: minutes < 1
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.secondary,
          ),
    );
  }

  /// Get display info for an MFA method
  (String title, String description, IconData icon) _getMethodInfo(
    AppLocalizations? l10n,
    MfaMethodType method,
  ) {
    switch (method) {
      case MfaMethodType.sms:
        return (
          l10n?.auth2faMethodSms ?? 'Text Message (SMS)',
          l10n?.auth2faMethodSmsDescription('***') ?? 'Receive a code via SMS',
          Icons.sms_outlined,
        );
      case MfaMethodType.totp:
        return (
          l10n?.auth2faMethodTotp ?? 'Authenticator App',
          l10n?.auth2faMethodTotpDescription ??
              'Use your authenticator app to generate a code',
          Icons.security_outlined,
        );
      case MfaMethodType.email:
        return (
          l10n?.auth2faMethodEmail ?? 'Email',
          l10n?.auth2faMethodEmailDescription('***') ??
              'Receive a code via email',
          Icons.email_outlined,
        );
      case MfaMethodType.push:
        return (
          l10n?.auth2faMethodPush ?? 'Push Notification',
          l10n?.auth2faMethodPushDescription ??
              'Approve the request on your registered device',
          Icons.notifications_outlined,
        );
    }
  }

  /// Validate the entered code
  String? _validateCode(AppLocalizations? l10n) {
    final input = _codeController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _localError =
            l10n?.authOtpRequiredError ?? 'Verification code is required';
      });
      return null;
    }

    if (!_codeRegex.hasMatch(input)) {
      setState(() {
        _localError = l10n?.auth2faInvalidCode ?? 'Invalid verification code';
      });
      return null;
    }

    setState(() => _localError = null);
    return input;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

/// 2FA Hint Banner widget that shows security hint.
class _TwoFactorHintBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintsAsync = ref.watch(auth2faHintsProvider);

    return hintsAsync.when(
      data: (hints) {
        if (hints.isEmpty) return const SizedBox.shrink();
        return InAppHintBanner(hint: hints.first);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}


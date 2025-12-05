/// OTP Verification Screen
/// Created by: Track D - Ticket #36
/// Updated by: Track D - Ticket #58 (Auth Flow Integration)
/// Purpose: OTP code entry for authentication flow
/// Last updated: 2025-11-29
///
/// This screen allows users to enter the verification code
/// sent to their phone to complete authentication.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart'
    show DWButton, DWTextField, DWSpacing;

import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/auth/passwordless_auth_controller.dart';
import '../../widgets/app_shell.dart';

/// Screen for entering OTP verification code.
///
/// Part of the simple Phone + OTP authentication flow (Ticket #36).
/// Updated in Ticket #58 to navigate to Home/AppShell after verification.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key, this.forceEnablePasswordless = false});

  /// Force enable passwordless auth for testing purposes
  final bool forceEnablePasswordless;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends ConsumerState<OtpVerificationScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final authState = ref.watch(passwordlessAuthControllerProvider);

    // Get phone number from auth state
    final phoneNumberString = authState.phoneE164;
    if (phoneNumberString == null) {
      // If no phone number in state, go back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Listen to PasswordlessAuthController state for success/error handling
    ref.listen(passwordlessAuthControllerProvider, (prev, next) {
      if (!mounted) return;

      // Navigate to home when authentication succeeds
      if (prev?.step != PasswordlessStep.authenticated && next.step == PasswordlessStep.authenticated) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RoutePaths.home,
          (route) => false,
        );
      }

      // Show error if verification fails
      if (next.step == PasswordlessStep.error && next.errorMessage != null &&
          (prev?.errorMessage != next.errorMessage)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colors.error,
          ),
        );
      }
    });

    final isLoading = authState.step == PasswordlessStep.verifying;

    void onVerify() {
      final code = _codeController.text.trim();
      if (code.isEmpty || isLoading) return;

      ref.read(passwordlessAuthControllerProvider.notifier).verifyOtp(code);
    }

    return AppShell(
      title: l10n.authOtpTitle,
      showAppBar: true,
      showBottomNav: false,
      safeArea: true,
      body: Padding(
        padding: const EdgeInsets.all(DWSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.authOtpSubtitle,
              style: textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DWSpacing.lg),
            DWTextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              hintText: l10n.authOtpFieldHint,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onVerify(),
            ),
            // Show error message if present
            if (authState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: DWSpacing.sm),
                child: Text(
                  authState.errorMessage!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const Spacer(),
            DWButton.primary(
              label: l10n.authOtpVerifyCta,
              onPressed: isLoading ? null : onVerify,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

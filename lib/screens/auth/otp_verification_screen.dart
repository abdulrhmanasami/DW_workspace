/// OTP Verification Screen
/// Created by: Track D - Ticket #36
/// Purpose: OTP code entry for authentication flow
/// Last updated: 2025-11-28
///
/// This screen allows users to enter the verification code
/// sent to their phone to complete authentication.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart'
    show DWButton, DWTextField, DWSpacing;

import '../../l10n/generated/app_localizations.dart';
import '../../state/auth/auth_state.dart';

/// Screen for entering OTP verification code.
///
/// Part of the simple Phone + OTP authentication flow (Ticket #36).
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

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

  void _onVerify(BuildContext context) {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    ref.read(simpleAuthStateProvider.notifier).verifyOtpCode(code);

    // After successful verification: go back to Home
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authOtpTitle),
      ),
      body: SafeArea(
        child: Padding(
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
                onSubmitted: (_) => _onVerify(context),
              ),
              const Spacer(),
              DWButton.primary(
                label: l10n.authOtpVerifyCta,
                onPressed: () => _onVerify(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

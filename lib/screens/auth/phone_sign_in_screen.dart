/// Phone Sign-In Screen
/// Created by: Track D - Ticket #36
/// Purpose: Phone number entry for authentication flow
/// Last updated: 2025-11-28
///
/// This screen allows users to enter their phone number to begin
/// the authentication process.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart'
    show DWButton, DWTextField, DWSpacing;

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/state/auth/auth_state.dart';
import 'otp_verification_screen.dart';

/// Screen for entering phone number to sign in.
///
/// Part of the simple Phone + OTP authentication flow (Ticket #36).
class PhoneSignInScreen extends ConsumerStatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  ConsumerState<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends ConsumerState<PhoneSignInScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContinue(BuildContext context) {
    final phone = _controller.text.trim();
    if (phone.isEmpty) return;

    ref.read(simpleAuthStateProvider.notifier).startPhoneSignIn(phone);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const OtpVerificationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authPhoneTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DWSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.authPhoneSubtitle,
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DWSpacing.lg),
              DWTextField(
                controller: _controller,
                keyboardType: TextInputType.phone,
                hintText: l10n.authPhoneFieldHint,
                prefixIcon: const Icon(Icons.phone_iphone),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onContinue(context),
              ),
              const Spacer(),
              DWButton.primary(
                label: l10n.authPhoneContinueCta,
                onPressed: () => _onContinue(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


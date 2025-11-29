import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_card_unified.dart';

/// Component: Preferences Screen
/// Created by: Track D - Onboarding Implementation
/// Purpose: Configure user preferences during onboarding
/// Last updated: 2025-11-27

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  String _selectedLanguage = 'en';
  bool _notificationsEnabled = true;
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);

    return AppShell(
      title: 'Preferences',
      showBottomNav: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(theme),
              SizedBox(height: theme.spacing.lg),

              // Language selection
              _buildLanguageSection(theme),
              SizedBox(height: theme.spacing.lg),

              // Notification preferences
              _buildNotificationSection(theme),
              SizedBox(height: theme.spacing.lg),

              // Terms and conditions
              _buildTermsSection(theme),
              SizedBox(height: theme.spacing.lg),

              // Action buttons
              _buildActionButtons(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences',
          style: theme.typography.headline5.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: theme.spacing.sm),
        Text(
          'Customize your experience',
          style: theme.typography.body2.copyWith(
            color: theme.colors.onBackground.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection(AppThemeData theme) {
    final languages = [
      ('English', 'en'),
      ('Deutsch', 'de'),
      ('العربية', 'ar'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language',
          style: theme.typography.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: theme.spacing.md),
        ...languages.map((lang) {
          return Padding(
            padding: EdgeInsets.only(bottom: theme.spacing.sm),
            child: AppCardUnified(
              onTap: () {
                setState(() {
                  _selectedLanguage = lang.$2;
                });
              },
              child: Row(
                children: [
                  // ignore: deprecated_member_use
                  Radio<String>(
                    value: lang.$2,
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      }
                    },
                  ),
                  SizedBox(width: theme.spacing.md),
                  Text(
                    lang.$1,
                    style: theme.typography.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNotificationSection(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: theme.typography.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: theme.spacing.md),
        AppCardUnified(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enable Notifications',
                    style: theme.typography.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: theme.spacing.xs),
                  Text(
                    'Get updates about your rides and deliveries',
                    style: theme.typography.body2.copyWith(
                      color: theme.colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            // ignore: deprecated_member_use
            Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsSection(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal',
          style: theme.typography.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: theme.spacing.md),
        AppCardUnified(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        _termsAccepted = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: theme.spacing.sm),
                      child: RichText(
                        text: TextSpan(
                          style: theme.typography.body2,
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: theme.typography.body2.copyWith(
                                color: theme.colors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: theme.typography.body2.copyWith(
                                color: theme.colors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppThemeData theme) {
    return Column(
      children: [
        AppButtonUnified(
          label: 'Complete Onboarding',
          fullWidth: true,
          style: AppButtonStyle.primary,
          isEnabled: _termsAccepted,
          onPressed: () {
            // Mark onboarding as complete and navigate to home
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/',
              (route) => false,
            );
          },
        ),
        SizedBox(height: theme.spacing.md),
        AppButtonUnified(
          label: 'Back',
          fullWidth: true,
          style: AppButtonStyle.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

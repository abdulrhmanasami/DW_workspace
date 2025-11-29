import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_card_unified.dart';

/// Component: Data Deletion Screen
/// Created by: Track D - DSR Implementation
/// Purpose: Request permanent data deletion
/// Last updated: 2025-11-27

class DataDeletionScreen extends ConsumerStatefulWidget {
  const DataDeletionScreen({super.key});

  @override
  ConsumerState<DataDeletionScreen> createState() => _DataDeletionScreenState();
}

class _DataDeletionScreenState extends ConsumerState<DataDeletionScreen> {
  bool _understandConsequences = false;
  bool _confirmDeletion = false;
  bool _requestSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);

    return AppShell(
      title: 'Delete Your Data',
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

              if (!_requestSubmitted) ...[
                // Warning box
                _buildWarningBox(theme),
                SizedBox(height: theme.spacing.lg),

                // What will be deleted
                _buildDeletionDetailsSection(theme),
                SizedBox(height: theme.spacing.lg),

                // Consequences
                _buildConsequencesSection(theme),
                SizedBox(height: theme.spacing.lg),

                // Confirmation checkboxes
                _buildConfirmationSection(theme),
                SizedBox(height: theme.spacing.lg),

                // Action buttons
                _buildActionButtons(context, theme),
              ] else ...[
                // Success message
                _buildSuccessMessage(theme),
                SizedBox(height: theme.spacing.lg),

                // Back button
                AppButtonUnified(
                  label: 'Back to Home',
                  fullWidth: true,
                  style: AppButtonStyle.primary,
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                    );
                  },
                ),
              ],
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
          'Delete Your Data',
          style: theme.typography.headline5.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: theme.spacing.sm),
        Text(
          'Permanently delete your account and all associated data',
          style: theme.typography.body2.copyWith(
            color: theme.colors.onBackground.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBox(AppThemeData theme) {
    return AppCardUnified(
      backgroundColor: theme.colors.error.withValues(alpha: 0.05),
      borderSide: BorderSide(
        color: theme.colors.error.withValues(alpha: 0.3),
        width: 1.5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_outlined,
            color: theme.colors.error,
            size: 28,
          ),
          SizedBox(width: theme.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This action cannot be undone',
                  style: theme.typography.subtitle2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.error,
                  ),
                ),
                SizedBox(height: theme.spacing.sm),
                Text(
                  'Deleting your account will permanently remove all your data from our servers.',
                  style: theme.typography.body2.copyWith(
                    color: theme.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeletionDetailsSection(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What Will Be Deleted',
          style: theme.typography.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: theme.spacing.md),
        _buildDeletionItem(theme, 'Profile Information', 'Name, email, phone number'),
        SizedBox(height: theme.spacing.sm),
        _buildDeletionItem(theme, 'Trip History', 'All rides and deliveries'),
        SizedBox(height: theme.spacing.sm),
        _buildDeletionItem(theme, 'Payment Information', 'Payment methods and history'),
        SizedBox(height: theme.spacing.sm),
        _buildDeletionItem(theme, 'Communication', 'Messages and support tickets'),
        SizedBox(height: theme.spacing.sm),
        _buildDeletionItem(theme, 'Account Settings', 'All preferences and settings'),
      ],
    );
  }

  Widget _buildDeletionItem(AppThemeData theme, String title, String description) {
    return AppCardUnified(
      child: Row(
        children: [
          Icon(
            Icons.delete_outline,
            color: theme.colors.error,
            size: 20,
          ),
          SizedBox(width: theme.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.typography.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: theme.typography.caption.copyWith(
                    color: theme.colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsequencesSection(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consequences',
          style: theme.typography.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: theme.spacing.md),
        AppCardUnified(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConsequenceItem(theme, 'You will no longer be able to access your account'),
              SizedBox(height: theme.spacing.sm),
              _buildConsequenceItem(theme, 'Your trip history and ratings will be deleted'),
              SizedBox(height: theme.spacing.sm),
              _buildConsequenceItem(theme, 'You cannot recover your data after deletion'),
              SizedBox(height: theme.spacing.sm),
              _buildConsequenceItem(theme, 'You can create a new account with the same email'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsequenceItem(AppThemeData theme, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.circle,
          size: 6,
          color: theme.colors.onSurface.withValues(alpha: 0.6),
        ),
        SizedBox(width: theme.spacing.md),
        Expanded(
          child: Text(
            text,
            style: theme.typography.body2.copyWith(
              color: theme.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationSection(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirmation',
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
                    value: _understandConsequences,
                    onChanged: (value) {
                      setState(() {
                        _understandConsequences = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: theme.spacing.sm),
                      child: Text(
                        'I understand that this action is permanent and cannot be undone',
                        style: theme.typography.body2,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: theme.spacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _confirmDeletion,
                    onChanged: (value) {
                      setState(() {
                        _confirmDeletion = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: theme.spacing.sm),
                      child: Text(
                        'I want to delete my account and all my data',
                        style: theme.typography.body2,
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
    final isEnabled = _understandConsequences && _confirmDeletion;

    return Column(
      children: [
        AppButtonUnified(
          label: 'Delete My Account',
          fullWidth: true,
          style: AppButtonStyle.danger,
          isEnabled: isEnabled,
          onPressed: isEnabled
              ? () {
                  setState(() {
                    _requestSubmitted = true;
                  });
                }
              : null,
        ),
        SizedBox(height: theme.spacing.md),
        AppButtonUnified(
          label: 'Cancel',
          fullWidth: true,
          style: AppButtonStyle.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage(AppThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.red,
            ),
          ),
        ),
        SizedBox(height: theme.spacing.md),
        Text(
          'Account Deletion Requested',
          style: theme.typography.headline6.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colors.onBackground,
          ),
        ),
        SizedBox(height: theme.spacing.sm),
        Text(
          'Your account deletion request has been submitted. Your data will be permanently deleted within 30 days.',
          style: theme.typography.body2.copyWith(
            color: theme.colors.onBackground.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: theme.spacing.lg),
      ],
    );
  }
}

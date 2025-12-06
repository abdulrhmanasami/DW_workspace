import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_card_unified.dart';

/// Component: Data Export Screen
/// Created by: Track D - DSR Implementation
/// Purpose: Request and download personal data export
/// Last updated: 2025-11-27

class DataExportScreen extends ConsumerStatefulWidget {
  const DataExportScreen({super.key});

  @override
  ConsumerState<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends ConsumerState<DataExportScreen> {
  String _selectedFormat = 'json';
  bool _requestSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);

    return AppShell(
      title: 'Download Your Data',
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
                // Format selection
                _buildFormatSection(theme),
                SizedBox(height: theme.spacing.lg),

                // Data types
                _buildDataTypesSection(theme),
                SizedBox(height: theme.spacing.lg),

                // Info box
                _buildInfoBox(theme),
                SizedBox(height: theme.spacing.lg),

                // Action buttons
                _buildActionButtons(context, theme),
              ] else ...[
                // Success message
                _buildSuccessMessage(theme),
                SizedBox(height: theme.spacing.lg),

                // Download button
                AppButtonUnified(
                  label: 'Download Data',
                  fullWidth: true,
                  style: AppButtonStyle.primary,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Download started...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                SizedBox(height: theme.spacing.md),

                // Back button
                AppButtonUnified(
                  label: 'Back',
                  fullWidth: true,
                  style: AppButtonStyle.secondary,
                  onPressed: () => Navigator.of(context).pop(),
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
          'Download Your Data',
          style: theme.typography.headline5.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: theme.spacing.sm),
        Text(
          'Request a copy of your personal data in a portable format',
          style: theme.typography.body2.copyWith(
            color: theme.colors.onBackground.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSection(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Format',
          style: theme.typography.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: theme.spacing.md),
        _buildFormatOption(theme, 'JSON', 'json', 'Machine-readable format'),
        SizedBox(height: theme.spacing.sm),
        _buildFormatOption(theme, 'CSV', 'csv', 'Spreadsheet format'),
      ],
    );
  }

  Widget _buildFormatOption(AppThemeData theme, String label, String value, String description) {
    return AppCardUnified(
      child: Row(
        children: [
          // ignore: deprecated_member_use
          Radio<String>(
            value: value,
            groupValue: _selectedFormat,
            onChanged: (newValue) {
              setState(() {
                _selectedFormat = newValue ?? 'json';
              });
            },
          ),
          SizedBox(width: theme.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
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

  Widget _buildDataTypesSection(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Included',
          style: theme.typography.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: theme.spacing.md),
        _buildDataTypeItem(theme, 'Profile Information', 'Name, email, phone number'),
        SizedBox(height: theme.spacing.sm),
        _buildDataTypeItem(theme, 'Trip History', 'All rides and deliveries'),
        SizedBox(height: theme.spacing.sm),
        _buildDataTypeItem(theme, 'Payment Information', 'Payment methods and history'),
        SizedBox(height: theme.spacing.sm),
        _buildDataTypeItem(theme, 'Communication', 'Messages and support tickets'),
      ],
    );
  }

  Widget _buildDataTypeItem(AppThemeData theme, String title, String description) {
    return AppCardUnified(
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
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

  Widget _buildInfoBox(AppThemeData theme) {
    return AppCardUnified(
      backgroundColor: Colors.blue.withValues(alpha: 0.05),
      borderSide: BorderSide(
        color: Colors.blue.withValues(alpha: 0.2),
        width: 1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outlined,
            color: Colors.blue,
            size: 24,
          ),
          SizedBox(width: theme.spacing.md),
          Expanded(
            child: Text(
              'Your data export will be prepared and available for download within 30 days. You\'ll receive an email notification when it\'s ready.',
              style: theme.typography.body2.copyWith(
                color: theme.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppThemeData theme) {
    return Column(
      children: [
        AppButtonUnified(
          label: 'Request Data Export',
          fullWidth: true,
          style: AppButtonStyle.primary,
          onPressed: () {
            setState(() {
              _requestSubmitted = true;
            });
          },
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
            color: Colors.green.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.green,
            ),
          ),
        ),
        SizedBox(height: theme.spacing.md),
        Text(
          'Request Submitted',
          style: theme.typography.headline6.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colors.onBackground,
          ),
        ),
        SizedBox(height: theme.spacing.sm),
        Text(
          'Your data export request has been submitted. You\'ll receive an email when your data is ready for download.',
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

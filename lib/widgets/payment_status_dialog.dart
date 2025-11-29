import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';

/// Component: PaymentStatusDialog
/// Created by: Cursor (auto-generated)
/// Purpose: Dialog to show payment status (success, failure, etc.)
/// Last updated: 2025-01-27

/// Dialog to show payment status
class PaymentStatusDialog extends StatelessWidget {
  // Design tokens
  static final _colors = DwColors();
  static final _typography = DwTypography();
  static final _spacing = DwSpacing();
  final String title;
  final String message;
  final bool isSuccess;
  final VoidCallback? onClose;

  const PaymentStatusDialog({
    super.key,
    required this.title,
    required this.message,
    required this.isSuccess,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_spacing.largeRadius),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Status icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSuccess
                  ? _colors.success.withValues(alpha: 0.1)
                  : _colors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              size: 32,
              color: isSuccess ? _colors.success : _colors.error,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: _typography.headline5.copyWith(
              fontWeight: FontWeight.w600,
              color: isSuccess ? _colors.success : _colors.error,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Message
          Text(message, style: _typography.body1, textAlign: TextAlign.center),

          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? _colors.success : _colors.error,
                foregroundColor: _colors.onPrimary,
                padding: EdgeInsets.symmetric(vertical: _spacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_spacing.smallRadius),
                ),
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }
}

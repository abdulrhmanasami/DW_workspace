/// Material Design Notice Implementation
/// Created by: Cursor B-ux
/// Purpose: Material Design implementation of notice/feedback system using global ScaffoldMessenger
/// Last updated: 2025-11-12

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'notice_host.dart';

/// Material implementation of notice presenter using global ScaffoldMessenger
class MaterialNoticePresenter {
  static void showNotice(AppNotice notice) {
    final scaffoldMessenger = dsScaffoldMessengerKey.currentState;
    if (scaffoldMessenger == null) {
      // Fallback: debugPrint to console if ScaffoldMessenger not available
      debugPrint('NoticeHost not available, cannot show notice: ${notice.message}');
      return;
    }

    final snackBar = SnackBar(
      content: Text(notice.message),
      duration: notice.duration,
      backgroundColor: _getBackgroundColor(notice.type),
      action: notice.action != null
          ? SnackBarAction(
              label: notice.action!.label,
              onPressed: notice.action!.onPressed,
              textColor: _getActionColor(notice.type),
            )
          : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }

  static Color _getBackgroundColor(AppNoticeType type) {
    switch (type) {
      case AppNoticeType.success:
        return Colors.green.shade100;
      case AppNoticeType.error:
        return Colors.red.shade100;
      case AppNoticeType.warning:
        return Colors.orange.shade100;
      case AppNoticeType.info:
        return Colors.blue.shade100;
    }
  }

  static Color _getActionColor(AppNoticeType type) {
    switch (type) {
      case AppNoticeType.success:
        return Colors.green.shade800;
      case AppNoticeType.error:
        return Colors.red.shade800;
      case AppNoticeType.warning:
        return Colors.orange.shade800;
      case AppNoticeType.info:
        return Colors.blue.shade800;
    }
  }
}

/// Function that creates a notice presenter using global key
AppNoticePresenter createMaterialNoticePresenter() {
  return MaterialNoticePresenter.showNotice;
}

/// Material design overrides for notice system
final materialNoticeOverrides = <Override>[
  appNoticePresenterProvider.overrideWithValue(createMaterialNoticePresenter()),
];

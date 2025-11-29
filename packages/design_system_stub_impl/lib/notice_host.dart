/// Notice Host - Global ScaffoldMessenger wrapper
/// Created by: Cursor B-ux
/// Purpose: Global ScaffoldMessenger for notice system
/// Last updated: 2025-11-12

import 'package:flutter/material.dart';

/// Global key for ScaffoldMessenger to enable notices from anywhere in the app
final GlobalKey<ScaffoldMessengerState> dsScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// NoticeHost widget that wraps the app with ScaffoldMessenger
class NoticeHost extends StatelessWidget {
  final Widget child;

  const NoticeHost({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: dsScaffoldMessengerKey,
      child: child,
    );
  }
}

import 'package:flutter/widgets.dart';

import '../screens/notifications/promotions_notifications_screen.dart';
import '../screens/notifications/system_notification_detail_screen.dart';
import '../screens/notifications/system_notifications_screen.dart';

/// Centralized route path definitions for UI screens contributed by B-ui.
class RoutePaths {
  RoutePaths._();

  static const String notificationsPromotions = '/notifications/promotions';
  static const String notificationsSystem = '/notifications/system';
  static const String notificationsSystemDetail = '/notifications/system/detail';
}

/// Arguments passed to the system notification detail route.
class SystemNotificationDetailRouteArgs {
  const SystemNotificationDetailRouteArgs({required this.messageId});

  final String messageId;
}

/// Local helper to expose B-ui notification routes to the host router.
Map<String, WidgetBuilder> buildNotificationRoutes() {
  return {
    RoutePaths.notificationsPromotions: (_) => const PromotionsNotificationsScreen(),
    RoutePaths.notificationsSystem: (_) => const SystemNotificationsScreen(),
    RoutePaths.notificationsSystemDetail: (_) => const SystemNotificationDetailScreen(),
  };
}


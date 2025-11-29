/// Component: BUiPublicApi
/// Created by: DW-UI-PHASE4-UI-RESOLVERS-APPBUTTON
/// Purpose: Public barrel exposing B-ui surface and resolver binding
/// Last updated: 2025-11-25

library b_ui;

export 'b_ui_design_system_binding.dart'
    show registerDesignSystemResolvers;
export 'router/app_router.dart';
export 'screens/inbox/notifications_inbox_screen.dart';
export 'screens/legal/about_legal_screen.dart';
export 'screens/legal/licenses_browser_screen.dart';
export 'screens/legal/privacy_markdown_screen.dart';
export 'screens/legal/terms_markdown_screen.dart';
export 'screens/notifications/promotions_notifications_screen.dart';
export 'screens/notifications/system_notification_detail_screen.dart';
export 'screens/notifications/system_notifications_screen.dart';
export 'screens/settings/dsr_erasure_screen.dart';
export 'screens/settings/dsr_export_screen.dart';
export 'screens/settings/notifications_settings_screen.dart';
export 'ui/providers/legal_content_providers.dart';
export 'ui/routes/registry.dart';
export 'ui/routes/ui_routes.dart';
export 'ui/ui.dart';


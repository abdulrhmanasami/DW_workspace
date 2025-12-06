// ignore_for_file: uri_does_not_exist, undefined_class, creation_with_non_type
import 'package:b_ui/ui/screens/legal/about_legal_screen.dart';
import 'package:b_ui/ui/screens/legal/licenses_browser_screen.dart';
import 'package:b_ui/ui/screens/legal/privacy_markdown_screen.dart';
import 'package:b_ui/ui/screens/legal/terms_markdown_screen.dart';
import 'package:b_ui/ui/screens/settings/dsr_export_screen.dart';
import 'package:b_ui/ui/screens/settings/dsr_erasure_screen.dart';
import 'package:b_ui/router/app_router.dart';

typedef UiRoutes = Map<String, Widget Function(BuildContext)>;

UiRoutes buildUiRoutes() => {
  '/settings/about': (_) => const AboutLegalScreen(),
  '/settings/licenses': (_) => const LicensesBrowserScreen(),
  '/settings/legal/privacy': (_) => const PrivacyMarkdownScreen(),
  '/settings/legal/terms': (_) => const TermsMarkdownScreen(),
  '/settings/dsr/export': (_) => const DsrExportScreen(),
  '/settings/dsr/erasure': (_) => const DsrErasureScreen(),
  ...buildNotificationRoutes(),
};

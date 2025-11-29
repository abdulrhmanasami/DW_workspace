import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;
import 'package:design_system_stub_impl/design_system_stub_impl.dart'
    as ds_stub;
import 'package:accounts_stub_impl/accounts_stub_impl.dart';
import 'package:accounts_shims/accounts.dart' as acc;
import 'package:b_ui/b_ui.dart' as bui;
import 'wiring/mobility_binding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'feature/in_app_review/in_app_review_service.dart';
import 'state/infra/maintenance_banner.dart';
import 'state/infra/kill_switch_overrides.dart';
import 'wiring/maps_binding.dart';
import 'package:design_system_stub_impl/notice_host.dart';
import 'package:network_shims/index.dart';
import 'state/infra/app_providers.dart';
import 'config/feature_flags.dart';
import 'config/service_locator.dart';
import 'config/config_manager.dart' as app_cfg;
import 'config/local_config_service.dart';
import 'router/app_router.dart';
import 'screens/settings/privacy_consent_gate.dart';

/// Provider for In-App Review service
final inAppReviewServiceProvider = Provider<InAppReviewService>((ref) {
  return InAppReviewService(fnd.Telemetry.instance);
});

/// Component: Delivery Ways App with SSL Pinning
/// Created by: Cursor (auto-generated)
/// Purpose: Main application entry point with certificate pinning integration
/// Last updated: 2025-01-27

void main() async {
  final configManager = app_cfg.ConfigManager(
    localService: LocalConfigService(),
  );
  app_cfg.ConfigManager.registerGlobal(configManager);

  // SLO/SLA: Setup global error handling
  FlutterError.onError = (FlutterErrorDetails details) async {
    await fnd.Telemetry.instance.error(
      'Flutter Error',
      context: {
        'error': details.exception.toString(),
        'stack': details.stack.toString(),
        'library': details.library,
      },
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    fnd.Telemetry.instance.error(
      'Platform Error',
      context: {'error': error.toString(), 'stack': stack.toString()},
    );
    return false;
  };

  // Show privacy consent screen first (GDPR compliance)
  WidgetsFlutterBinding.ensureInitialized();

  // Wire B-ui design system resolvers before any widgets use AppButton/AppCard.
  bui.registerDesignSystemResolvers();

  // Run app with privacy consent flow
  runApp(const PrivacyConsentWrapper());
}

class PrivacyConsentWrapper extends StatefulWidget {
  const PrivacyConsentWrapper({super.key});

  @override
  State<PrivacyConsentWrapper> createState() => _PrivacyConsentWrapperState();
}

class _PrivacyConsentWrapperState extends State<PrivacyConsentWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // بعد شاشة الموافقة (privacy/onboarding):
    await fnd.TelemetryConsent.instance.grant(); // أو deny()

    await fnd.Telemetry.init(
      sentryDsn: const String.fromEnvironment('SENTRY_DSN', defaultValue: ''),
      environment: const String.fromEnvironment(
        'APP_ENV',
        defaultValue: 'production',
      ),
      release: const String.fromEnvironment(
        'APP_RELEASE',
        defaultValue: '0.3.2',
      ),
      enableFirebasePerformance: true,
    );

    // Initialize ImageCache manager to prevent OOM issues
    // BL-102-004: Safe ImageCache management
    fnd.ImageCacheManager.initialize();

    // Warm up payment wiring early to surface configuration issues
    await ServiceLocator.ensurePaymentsReady();

    await _setupTlsPinning();

    // Note: RemoteConfig fetch will be handled by fetchRemoteConfigProvider in app bootstrap

    // Trace app startup only after consent
    final fnd.TelemetrySpan appStartTrace = await fnd.Telemetry.instance
        .startTrace('app.startup');
    await appStartTrace.setAttributes(<String, String>{
      'phase': 'initialization',
    });

    if (mounted) {
      setState(() {}); // Trigger rebuild to show main app
    }

    // Complete startup trace
    appStartTrace.setAttributes(<String, String>{'phase': 'ui_ready'});
    appStartTrace.stop();
  }

  Future<void> _setupTlsPinning() async {
    final telemetry = fnd.Telemetry.instance;
    final certPinningEnabled = FeatureFlags.enableCertPinning;

    if (!certPinningEnabled) {
      await telemetry.logEvent('tls.pinning_skipped', {
        'reason': 'feature_flag_disabled',
      });
      await _registerUnpinnedHttpClient();
      return;
    }

    try {
      initializeCertificatePinning(
        DefaultHttpClientFactory(
          allowUnpinnedClients: false,
        ),
      );
      await telemetry.logEvent('tls.pinning_initialized', {
        'mode': 'pinned',
      });
    } catch (error, stackTrace) {
      await telemetry.error(
        'tls.pinning_init_failed',
        context: {
          'error': error.toString(),
          'stackTrace': stackTrace.toString(),
        },
      );
      await _registerUnpinnedHttpClient();
    }
  }

  Future<void> _registerUnpinnedHttpClient() async {
    try {
      initializeCertificatePinning(
        DefaultHttpClientFactory(
          allowUnpinnedClients: true,
        ),
      );
    } catch (error, stackTrace) {
      await fnd.Telemetry.instance.error(
        'tls.pinning_fallback_failed',
        context: {
          'error': error.toString(),
          'stackTrace': stackTrace.toString(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen until consent is handled
    if (!fnd.TelemetryConsent.instance.isAllowed) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing...'),
              ],
            ),
          ),
        ),
      );
    }

    return ProviderScope(
      overrides: [
        ...ds_stub
            .materialDesignOverrides, // AppButton/AppCard/AppNotice/AppThemeData
        acc.dsrFactoryProvider.overrideWithValue(NoOpDsrFactory()),
        ...appOverrides,
        ...mobilityOverrides,
        ...mapsOverrides,
        ...killSwitchOverrides,
      ],
      child: const MaintenanceBanner(child: DeliveryWaysApp()),
    );
  }
}

class DeliveryWaysApp extends StatefulWidget {
  const DeliveryWaysApp({super.key});

  @override
  State<DeliveryWaysApp> createState() => _DeliveryWaysAppState();
}

class _DeliveryWaysAppState extends State<DeliveryWaysApp>
    with WidgetsBindingObserver {
  DateTime? _installDate;
  int _appOpenCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAppLifecycle();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Check for in-app review prompt when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _checkAndPromptReview();
    }
  }

  Future<void> _initializeAppLifecycle() async {
    // SLO/SLA: Record app start event
    final startTime = DateTime.now();
    await fnd.Telemetry.instance.logEvent('app_start', {
      'timestamp': startTime.toIso8601String(),
      'platform': Theme.of(context).platform.toString(),
    });

    // Track install date and app open count
    final prefs = await SharedPreferences.getInstance();
    _installDate = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt('install_date') ?? DateTime.now().millisecondsSinceEpoch,
    );
    _appOpenCount = prefs.getInt('app_open_count') ?? 0;

    // Increment app open count
    _appOpenCount++;
    await prefs.setInt('app_open_count', _appOpenCount);
    await prefs.setInt('install_date', _installDate!.millisecondsSinceEpoch);

    // Check for third day trigger
    final daysSinceInstall = DateTime.now().difference(_installDate!).inDays;
    if (daysSinceInstall >= 3) {
      // Trigger third day review prompt check
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkThirdDayReview();
      });
    }
  }

  Future<void> _checkAndPromptReview() async {
    // Use Riverpod to access the service
    final container = ProviderScope.containerOf(context);
    final reviewService = container.read(inAppReviewServiceProvider);
    await reviewService.maybePromptReview();
  }

  Future<void> _checkThirdDayReview() async {
    final container = ProviderScope.containerOf(context);
    final reviewService = container.read(inAppReviewServiceProvider);
    await reviewService.onThirdDayReached();
  }

  @override
  Widget build(BuildContext context) {
    return NoticeHost(
      child: ProviderScope(
        overrides: [
          fnd.navigatorKeyProvider.overrideWithValue(
            GlobalKey<NavigatorState>(),
          ),
          ...appOverrides,
        ],
        child: const PrivacyConsentGate(child: RootApp()),
      ),
    );
  }
}

class RootApp extends ConsumerWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorKey = ref.read(fnd.navigatorKeyProvider);

    return MaterialApp(
      title: 'Delivery Ways',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: AppRouter.generateRoutes(ref),
    );
  }
}

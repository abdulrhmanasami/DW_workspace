/// Application Router Barrel
/// Centralizes all routing logic and route definitions
/// Created by: B-central ROUTE-SETTINGS-015
/// Purpose: Single source of truth for app navigation
/// Last updated: 2025-11-25 (CENT-004: 2FA route)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;
import 'package:payments/payments.dart' as payments;
import 'package:core/rbac/rbac_models.dart';
import 'package:b_ui/router/app_router.dart' as bui show RoutePaths, buildNotificationRoutes;

import '../config/feature_flags.dart';
import '../screens/_placeholders.dart';
import '../screens/onboarding/onboarding_root_screen.dart';
import '../screens/home_screen.dart';
import '../screens/mobility/location_selection_screen.dart';
import '../screens/mobility/ride_booking_screen.dart';
import '../screens/mobility/trip_tracking_screen.dart';
import '../screens/mobility/trip_completion_screen.dart';
import '../screens/parcels/parcels_list_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/onboarding/permissions_screen.dart';
import '../screens/onboarding/preferences_screen.dart';
import '../screens/dsr/dsr_root_screen.dart';
import '../screens/dsr/data_export_screen.dart';
import '../screens/dsr/data_deletion_screen.dart';
import '../state/onboarding/onboarding_providers.dart';
import '../screens/admin_panel_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/phone_login_screen.dart';
import '../screens/auth/two_factor_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/mobility/tracking_screen.dart';
import '../screens/order_tracking_screen.dart';
import '../screens/orders_history_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/settings/privacy_consent_screen.dart';
import '../screens/settings/privacy_data_screen.dart';
import '../screens/tracking_map_screen.dart';
import '../state/infra/auth_providers.dart';
import '../widgets/rbac_guard.dart';
import '../ui/ui.dart' as ui;

/// Route Path Definitions
/// Centralized route path constants
class RoutePaths {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String ordersHistory = '/orders/history';
  static const String tracking = '/tracking';
  static const String trackingMap = '/tracking/map';
  static const String mobilityTracking = '/mobility/tracking';
  static const String payment = '/payment';
  static const String admin = '/admin';
  static const String privacyConsent = '/settings/privacy-consent';
  static const String privacyData = '/settings/privacy-data';
  static const String phoneLogin = '/auth/login-phone';
  static const String otpVerification = '/auth/otp';
  static const String twoFactor = '/auth/two-factor';
}

Map<String, WidgetBuilder> buildNotificationRoutesWithRbac() {
  final rawRoutes = bui.buildNotificationRoutes();

  WidgetBuilder guard(String path, String screenId) {
    final inner = rawRoutes[path];
    if (inner == null) {
      throw StateError('Missing inner notification route for $path');
    }

    return (context) => RbacGuard(
          screenId: screenId,
          child: Builder(
            builder: (ctx) => inner(ctx),
          ),
        );
  }

  return <String, WidgetBuilder>{
    bui.RoutePaths.notificationsPromotions:
        guard(bui.RoutePaths.notificationsPromotions, 'notifications_promotions'),
    bui.RoutePaths.notificationsSystem:
        guard(bui.RoutePaths.notificationsSystem, 'notifications_system'),
    bui.RoutePaths.notificationsSystemDetail:
        guard(bui.RoutePaths.notificationsSystemDetail, 'notifications_system'),
  };
}

/// Application Router
/// Provides centralized route generation and management
class AppRouter {
  /// Generate routes map for MaterialApp
  static Map<String, WidgetBuilder> generateRoutes(WidgetRef ref) {
    final uiRoutes =
        Map<String, WidgetBuilder>.from(ui.buildUiRoutes(ref));
    final notificationRoutes = buildNotificationRoutesWithRbac();

    uiRoutes.remove(bui.RoutePaths.notificationsPromotions);
    uiRoutes.remove(bui.RoutePaths.notificationsSystem);
    uiRoutes.remove(bui.RoutePaths.notificationsSystemDetail);

    return {
      // Onboarding route
      RoutePaths.onboarding: (context) => const OnboardingRootScreen(),

      // Core app routes
      RoutePaths.home: (context) => const OnboardingGateScreen(),
      RoutePaths.cart: (c) =>
          const RbacGuard(screenId: 'cart', child: CartScreen()),
      RoutePaths.checkout: (c) =>
          const RbacGuard(screenId: 'checkout', child: CheckoutScreen()),
      RoutePaths.orders: (c) =>
          const RbacGuard(screenId: 'orders', child: OrdersScreen()),
      RoutePaths.ordersHistory: (c) => const RbacGuard(
        screenId: 'orders_history',
        child: OrdersHistoryScreen(),
      ),
      RoutePaths.tracking: (c) =>
          const RbacGuard(screenId: 'tracking', child: OrderTrackingScreen()),

      // Feature-gated routes
      RoutePaths.trackingMap: (c) => _buildTrackingMapRoute(),
      RoutePaths.mobilityTracking: (c) => _buildMobilityTrackingRoute(),
      '/mobility/location-selection': (c) => const RbacGuard(
        child: LocationSelectionScreen(),
      ),
      '/mobility/ride-booking': (c) => const RbacGuard(
        child: RideBookingScreen(),
      ),
      '/mobility/trip-tracking': (c) => const RbacGuard(
        child: TripTrackingScreen(),
      ),
      '/mobility/trip-completion': (c) => const RbacGuard(
        child: TripCompletionScreen(),
      ),

      // Parcels routes
      '/parcels': (c) => const RbacGuard(
        child: ParcelsListScreen(),
      ),

      // Onboarding routes
      '/onboarding/welcome': (c) => const WelcomeScreen(),
      '/onboarding/permissions': (c) => const PermissionsScreen(),
      '/onboarding/preferences': (c) => const PreferencesScreen(),

      // DSR routes
      '/dsr': (c) => const RbacGuard(
        child: DSRRootScreen(),
      ),
      '/dsr/export': (c) => const RbacGuard(
        child: DataExportScreen(),
      ),
      '/dsr/deletion': (c) => const RbacGuard(
        child: DataDeletionScreen(),
      ),
      RoutePaths.payment: (c) => const RbacGuard(
        screenId: 'payment',
        child: PaymentScreen(
          amount: 0,
          currency: 'EUR',
          serviceType: payments.PaymentServiceType.defaultService,
        ),
      ),
      RoutePaths.admin: (c) => const RbacGuard(
        screenId: 'admin_panel',
        child: AdminPanelScreen(
          userId: 'current_user',
          userRole: UserRole.admin,
        ),
      ),

      // Settings routes
      RoutePaths.privacyConsent: (c) => const RbacGuard(
        screenId: 'privacy_consent',
        child: PrivacyConsentScreen(),
      ),
      RoutePaths.privacyData: (c) =>
          const RbacGuard(screenId: 'privacy_data', child: PrivacyDataScreen()),

      // Auth routes (CENT-003 + CENT-004)
      RoutePaths.phoneLogin: (c) => const PhoneLoginScreen(),
      RoutePaths.otpVerification: (c) => const OtpVerificationScreen(),
      RoutePaths.twoFactor: (c) => const TwoFactorScreen(),

      // UI layer routes (feature-gated)
      ...uiRoutes,
      ...notificationRoutes,
    };
  }

  /// Build tracking map route with feature gating
  static Widget _buildTrackingMapRoute() {
    return Consumer(
      builder: (context, ref, child) {
        final mapsEnabled = ref.watch(fnd.mapsProviderKeyProvider) != 'none';
        return mapsEnabled
            ? const RbacGuard(
                screenId: 'tracking_map',
                child: TrackingMapScreen(),
              )
            : const RbacGuard(
                screenId: 'tracking_map',
                child: MapsDisabledPlaceholder(),
              );
      },
    );
  }

  /// Build mobility tracking route with feature gating
  static Widget _buildMobilityTrackingRoute() {
    return Consumer(
      builder: (context, ref, child) {
        final trackingEnabled = ref.watch(fnd.trackingEnabledProvider);
        return trackingEnabled
            ? const RbacGuard(
                screenId: 'mobility_tracking',
                child: TrackingScreen(),
              )
            : const RbacGuard(
                screenId: 'mobility_tracking',
                child: TrackingDisabledPlaceholder(),
              );
      },
    );
  }

  /// Get initial route
  static String get initialRoute => RoutePaths.home;

  /// Get navigator key from foundation shims
  static GlobalKey<NavigatorState> get navigatorKey =>
      throw UnimplementedError('Use navigatorKeyProvider');

  /// Navigation helpers using foundation shims
  static Future<T?> push<T>(BuildContext context, String routeName) {
    return Navigator.of(context).pushNamed<T>(routeName);
  }

  static Future<T?> pushReplacement<T>(BuildContext context, String routeName) {
    return Navigator.of(context).pushReplacementNamed(routeName);
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  static Future<bool> maybePop<T>(BuildContext context, [T? result]) {
    return Navigator.of(context).maybePop<T>(result);
  }
}

/// Provider for app routes (alternative to static method)
final appRoutesProvider =
    Provider.family<Map<String, WidgetBuilder>, WidgetRef>((ref, widgetRef) {
      return AppRouter.generateRoutes(widgetRef);
    });

/// Provider for initial route
final initialRouteProvider = Provider<String>((ref) => AppRouter.initialRoute);

/// Onboarding gate that shows onboarding for new users before auth.
class OnboardingGateScreen extends ConsumerWidget {
  const OnboardingGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableOnboarding = ref.watch(enableProductOnboardingProvider);

    if (!enableOnboarding) {
      return const AuthGateScreen();
    }

    final onboardingCompleted = ref.watch(shouldShowCustomerOnboardingProvider);

    return onboardingCompleted.when(
      data: (shouldShow) {
        if (shouldShow) {
          return OnboardingRootScreen(
            onComplete: () {
              // Force rebuild to show auth gate
              ref.invalidate(shouldShowCustomerOnboardingProvider);
            },
          );
        }
        return const AuthGateScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) {
        // On error, skip onboarding and show auth
        return const AuthGateScreen();
      },
    );
  }
}

/// Auth gate that switches between authenticated home and phone login.
class AuthGateScreen extends ConsumerWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!FeatureFlags.enablePasswordlessAuth) {
      return const CartScreen();
    }

    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (state) {
        if (state.isAuthenticated) {
          return const HomeScreen();
        }
        return const PhoneLoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Auth state unavailable: $error'),
        ),
      ),
    );
  }
}

/// Application Router Barrel
/// Centralizes all routing logic and route definitions
/// Created by: B-central ROUTE-SETTINGS-015
/// Purpose: Single source of truth for app navigation
/// Last updated: 2025-11-25 (CENT-004: 2FA route)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;
import 'package:payments/payments.dart' as payments;
import 'package:core/rbac/rbac_models.dart';
import 'package:b_ui/router/app_router.dart' as bui show RoutePaths, buildNotificationRoutes;

import '../config/feature_flags.dart';
import '../screens/_placeholders.dart';
import '../screens/onboarding/onboarding_root_screen.dart';
import '../state/onboarding/onboarding_providers.dart';
import '../screens/admin_panel_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/phone_login_screen.dart';
import '../screens/auth/two_factor_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/mobility/ride_active_trip_screen.dart';
import '../screens/mobility/ride_booking_screen.dart';
import '../screens/mobility/ride_confirmation_screen.dart';
import '../screens/mobility/ride_destination_screen.dart';
import '../screens/mobility/ride_trip_summary_screen.dart';
import '../screens/mobility/tracking_screen.dart';
import '../screens/parcels/parcel_destination_screen.dart';
import '../screens/parcels/parcel_details_screen.dart';
import '../screens/parcels/parcel_quote_screen.dart';
import '../screens/parcels/parcels_active_shipment_screen.dart';
import '../screens/parcels/parcels_entry_screen.dart';
import '../screens/parcels/parcels_list_screen.dart'; // Track C - Ticket #72
import '../screens/parcels/parcels_shipments_list_screen.dart'; // Track C - Ticket #149
import '../screens/parcels/parcels_create_shipment_screen.dart'; // Track C - Ticket #150
import '../screens/parcels/parcels_shipment_details_screen.dart';
import '../screens/home/home_hub_screen.dart'; // Track C - Ticket #151
import '../screens/order_tracking_screen.dart';
import '../screens/orders_history_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/settings/dsr_erasure_screen.dart';
import '../screens/settings/dsr_export_screen.dart';
import '../screens/settings/notifications_settings_screen.dart';
import '../screens/settings/privacy_consent_screen.dart';
import '../screens/settings/privacy_data_screen.dart';
import '../screens/tracking_map_screen.dart';
import '../state/infra/auth_providers.dart';
import '../widgets/rbac_guard.dart';
import '../ui/ui.dart' as ui;
import '../app_shell/app_shell.dart';

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
  static const String dsrExport = '/settings/dsr-export';
  static const String dsrErasure = '/settings/dsr-erasure';
  // Track A - Ticket #227: Settings routes for Profile tab
  static const String settingsPersonalInfo = '/settings/personal-info';
  static const String settingsRidePreferences = '/settings/ride-preferences';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsHelpSupport = '/settings/help-support';
  static const String phoneLogin = '/auth/login-phone';
  static const String otpVerification = '/auth/otp';
  static const String twoFactor = '/auth/two-factor';
  static const String rideDestination = '/ride/destination';
  static const String rideBooking = '/ride/booking';
  static const String rideConfirmation = '/ride/confirmation';
  static const String rideTripConfirmation = '/ride/trip_confirmation';
  static const String rideActive = '/ride/active';
  static const String rideTripSummary = '/ride/trip_summary'; // Track B - Ticket #23

  // Track C - Parcels routes (Ticket #40+)
  static const String parcelsHome = '/parcels';
  static const String parcelsList = '/parcels/list'; // Ticket #72: My Shipments list
  static const String parcelsShipmentsList = '/parcels/shipments'; // Ticket #149: New shipments list
  static const String parcelsCreateShipment = '/parcels/create-shipment'; // Ticket #150: Create shipment
  static const String parcelsShipmentDetails = '/parcels/shipment-details'; // Ticket #151: Shipment details
  static const String parcelsDestination = '/parcels/destination'; // Ticket #41
  static const String parcelsDetails = '/parcels/details'; // Ticket #42
  static const String parcelsQuote = '/parcels/quote'; // Ticket #43
  static const String parcelsActiveShipment = '/parcels/active'; // Ticket #70
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

      // Payment and admin routes
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

      // DSR routes (Track D - Ticket #5)
      RoutePaths.dsrExport: (c) => const RbacGuard(
        screenId: 'dsr_export',
        child: DsrExportScreen(),
      ),
      RoutePaths.dsrErasure: (c) => const RbacGuard(
        screenId: 'dsr_erasure',
        child: DsrErasureScreen(),
      ),

      // Track A - Ticket #227: Settings routes for Profile tab
      RoutePaths.settingsPersonalInfo: (c) => const RbacGuard(
        screenId: 'settings_personal_info',
        child: Placeholder(), // TODO: Implement PersonalInfoScreen
      ),
      RoutePaths.settingsRidePreferences: (c) => const RbacGuard(
        screenId: 'settings_ride_preferences',
        child: Placeholder(), // TODO: Implement RidePreferencesScreen
      ),
      RoutePaths.settingsNotifications: (c) => const RbacGuard(
        screenId: 'settings_notifications',
        child: NotificationsSettingsScreen(),
      ),
      RoutePaths.settingsHelpSupport: (c) => const RbacGuard(
        screenId: 'settings_help_support',
        child: Placeholder(), // TODO: Implement HelpSupportScreen
      ),

      // Auth routes (CENT-003 + CENT-004)
      RoutePaths.phoneLogin: (c) => const PhoneLoginScreen(),
      RoutePaths.otpVerification: (c) => const OtpVerificationScreen(),
      RoutePaths.twoFactor: (c) => const TwoFactorScreen(),

      // Ride Destination route (Track B - Ticket #20)
      RoutePaths.rideDestination: (c) => const RideDestinationScreen(),

      // Ride Booking route (Track B - Ticket #6)
      RoutePaths.rideBooking: (c) => const RideBookingScreen(),

      // Ride Trip Confirmation route (Track B - Ticket #7)
      RoutePaths.rideConfirmation: (c) => const RideConfirmationScreen(),

      // Ride Trip Confirmation route (Track B - Ticket #21) - alias for Screen 9
      RoutePaths.rideTripConfirmation: (c) => const RideConfirmationScreen(),

      // Ride Active Trip route (Track B - Ticket #15)
      RoutePaths.rideActive: (c) => const RideActiveTripScreen(),

      // Ride Trip Summary route (Track B - Ticket #23, #98)
      // Track B - Ticket #98: Now supports RideTripSummaryArgs for history navigation
      RoutePaths.rideTripSummary: (c) {
        final args = ModalRoute.of(c)?.settings.arguments;
        if (args is RideTripSummaryArgs) {
          return RideTripSummaryScreen(historyEntry: args.historyEntry);
        }
        return const RideTripSummaryScreen();
      },

      // Track C - Parcels routes (Ticket #40, #41, #42, #43, #70, #72, #149, #150)
      RoutePaths.parcelsHome: (c) => const ParcelsEntryScreen(),
      RoutePaths.parcelsList: (c) => const ParcelsListScreen(), // Ticket #72
      RoutePaths.parcelsShipmentsList: (c) => ParcelsShipmentsListScreen(
        onCreateShipment: () {
          // Navigate to create shipment screen
          Navigator.of(c).pushNamed(RoutePaths.parcelsCreateShipment);
        },
      ), // Ticket #149
      RoutePaths.parcelsCreateShipment: (c) => 
          const ParcelsCreateShipmentScreen(), // Ticket #150
      RoutePaths.parcelsShipmentDetails: (c) {
        final args = ModalRoute.of(c)!.settings.arguments;
        final shipment = args as ParcelShipment;
        return ParcelsShipmentDetailsScreen(shipment: shipment);
      }, // Ticket #151
      RoutePaths.parcelsDestination: (c) => const ParcelDestinationScreen(),
      RoutePaths.parcelsDetails: (c) => const ParcelDetailsScreen(),
      RoutePaths.parcelsQuote: (c) => const ParcelQuoteScreen(),
      RoutePaths.parcelsActiveShipment: (c) =>
          const ParcelsActiveShipmentScreen(),

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

/// Auth gate that switches between authenticated home (AppShell) and phone login.
/// Track A - Ticket #2: AppShell is now the root UI for authenticated users.
class AuthGateScreen extends ConsumerWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!FeatureFlags.enablePasswordlessAuth) {
      // Track A - Ticket #217: AppShell v1 with Bottom Navigation
      return const AppShell();
    }

    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (state) {
        if (state.isAuthenticated) {
          // Track A - Ticket #217: AppShell v1 with Bottom Navigation
          return const AppShell();
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

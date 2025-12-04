// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Delivery Ways';

  @override
  String get authPhoneTitle => 'Sign in';

  @override
  String get authPhoneSubtitle =>
      'Enter your mobile number to sign in to Delivery Ways.';

  @override
  String get authPhoneFieldHint => '+9665xxxxxxxx';

  @override
  String get authPhoneContinueCta => 'Continue';

  @override
  String get authOtpTitle => 'Enter code';

  @override
  String get authOtpSubtitle =>
      'We\'ve sent a verification code to your phone.';

  @override
  String get authOtpFieldHint => 'Verification code';

  @override
  String get authOtpVerifyCta => 'Verify and continue';

  @override
  String get accountSheetTitle => 'Account';

  @override
  String get accountSheetSignedOutSubtitle =>
      'You are not signed in. Sign in to sync your rides and deliveries.';

  @override
  String get accountSheetSignInCta => 'Sign in with phone';

  @override
  String get accountSheetSignedInTitle => 'Signed in';

  @override
  String get accountSheetSignOutCta => 'Sign out';

  @override
  String get accountSheetFooterText => 'More account options coming soon.';

  @override
  String get initializing => 'Initializing...';

  @override
  String get back => 'Back';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading...';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get authPhoneLoginTitle => 'Sign In';

  @override
  String get authPhoneLoginSubtitle =>
      'Enter your phone number to sign in or create a new account.';

  @override
  String get authPhoneFieldLabel => 'Phone Number';

  @override
  String get authPhoneContinueButton => 'Continue';

  @override
  String get authPhoneRequiredError => 'Please enter your phone number.';

  @override
  String get authPhoneInvalidFormatError =>
      'Please enter a valid phone number.';

  @override
  String get authPhoneSubmitError =>
      'Unable to send verification code. Please try again.';

  @override
  String get authOtpFieldLabel => 'Verification Code';

  @override
  String get authOtpConfirmButton => 'Verify';

  @override
  String get authOtpRequiredError => 'Please enter the verification code.';

  @override
  String get authOtpInvalidFormatError =>
      'Please enter a valid 4-6 digit code.';

  @override
  String get authOtpSubmitError => 'Invalid or expired verification code.';

  @override
  String get authOtpResendButton => 'Resend Code';

  @override
  String authOtpResendCountdown(int seconds) {
    return 'Resend code in $seconds seconds';
  }

  @override
  String get authBiometricButtonLabel => 'Use biometrics';

  @override
  String get authBiometricReason => 'Authenticate to continue.';

  @override
  String get authBiometricUnlockError =>
      'Unable to unlock with biometrics. Please request a new code.';

  @override
  String authCooldownMessage(int seconds) {
    return 'Please wait ${seconds}s before trying again.';
  }

  @override
  String get authCooldownReady => 'You can resend now.';

  @override
  String authAttemptsRemaining(int count) {
    return '$count attempts remaining';
  }

  @override
  String get authNoAttemptsRemaining => 'No attempts remaining.';

  @override
  String get auth2faTitle => 'Two-Factor Authentication';

  @override
  String get auth2faSubtitle =>
      'An additional verification step is required for your security.';

  @override
  String get auth2faSelectMethod => 'Select verification method';

  @override
  String get auth2faMethodSms => 'Text Message (SMS)';

  @override
  String auth2faMethodSmsDescription(String destination) {
    return 'Receive a code via SMS to $destination';
  }

  @override
  String get auth2faMethodTotp => 'Authenticator App';

  @override
  String get auth2faMethodTotpDescription =>
      'Use your authenticator app to generate a code';

  @override
  String get auth2faMethodEmail => 'Email';

  @override
  String auth2faMethodEmailDescription(String destination) {
    return 'Receive a code via email to $destination';
  }

  @override
  String get auth2faMethodPush => 'Push Notification';

  @override
  String get auth2faMethodPushDescription =>
      'Approve the request on your registered device';

  @override
  String get auth2faEnterCode => 'Enter verification code';

  @override
  String get auth2faCodeHint => 'Enter the 6-digit code';

  @override
  String get auth2faVerifyButton => 'Verify';

  @override
  String get auth2faCancelButton => 'Cancel';

  @override
  String get auth2faResendCode => 'Resend code';

  @override
  String get auth2faCodeExpired => 'Code expired. Please request a new one.';

  @override
  String get auth2faInvalidCode => 'Invalid code. Please try again.';

  @override
  String get auth2faAccountLocked =>
      'Too many attempts. Account temporarily locked.';

  @override
  String auth2faLockoutMessage(int minutes) {
    return 'Please try again after $minutes minutes.';
  }

  @override
  String get notificationsSettingsTitle => 'Notification Settings';

  @override
  String get notificationsSettingsOrderStatusTitle =>
      'Order Status Notifications';

  @override
  String get notificationsSettingsOrderStatusSubtitle =>
      'Receive real-time updates about your active orders.';

  @override
  String get notificationsSettingsPromotionsTitle => 'Promotional Offers';

  @override
  String get notificationsSettingsPromotionsSubtitle =>
      'Receive personalized offers and discounts.';

  @override
  String get notificationsSettingsSystemTitle => 'System Notifications';

  @override
  String get notificationsSettingsSystemSubtitle =>
      'Important alerts about your account and system.';

  @override
  String get notificationsSettingsConsentRequired =>
      'Grant notification permission to enable these settings.';

  @override
  String get notificationsSettingsErrorGeneric =>
      'Unable to load notification settings. Please try again.';

  @override
  String get notificationsSettingsErrorLoading =>
      'Error loading notification settings';

  @override
  String get notificationsSettingsSystemSettingsButton =>
      'Open System Settings';

  @override
  String get notificationsSettingsSystemSettingsPlaceholder =>
      'System settings will open soon';

  @override
  String get notificationsSettingsQuietHoursTitle => 'Quiet Hours';

  @override
  String get notificationsSettingsQuietHoursNotEnabled =>
      'Do Not Disturb mode not enabled';

  @override
  String get settingsSectionNotifications => 'Notification Settings';

  @override
  String get notificationsInboxTitle => 'Notifications';

  @override
  String get notificationsInboxErrorGeneric =>
      'Unable to load notifications. Please try again.';

  @override
  String get notificationsInboxRetryButtonLabel => 'Retry';

  @override
  String get notificationsInboxEmptyTitle => 'No notifications yet';

  @override
  String get notificationsInboxEmptySubtitle =>
      'Important alerts about your orders and offers will appear here.';

  @override
  String get notificationsInboxEmptyCtaBackToHomeLabel => 'Back to Home';

  @override
  String get notificationsInboxMarkAsReadTooltip => 'Mark as read';

  @override
  String get notificationsInboxMarkAllAsReadTooltip => 'Mark all as read';

  @override
  String get notificationsInboxClearAllTooltip => 'Clear all';

  @override
  String get notificationsInboxClearAllDialogTitle => 'Clear All Notifications';

  @override
  String get notificationsInboxClearAllDialogMessage =>
      'Are you sure you want to delete all notifications? This action cannot be undone.';

  @override
  String get notificationsInboxClearAllConfirm => 'Clear All';

  @override
  String get notificationsInboxTappedGeneric => 'Notification opened';

  @override
  String get notificationsInboxTimeNow => 'now';

  @override
  String notificationsInboxTimeMinutes(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String notificationsInboxTimeHours(int hours) {
    return '${hours}h ago';
  }

  @override
  String notificationsInboxTimeDays(int days) {
    return '${days}d ago';
  }

  @override
  String get privacyConsentTitle => 'Privacy & Consent';

  @override
  String get privacyConsentHeadline => 'Control your privacy';

  @override
  String get privacyConsentDescription =>
      'Choose what to share with us to improve your experience';

  @override
  String get privacyConsentAnalyticsTitle => 'Usage Analytics';

  @override
  String get privacyConsentAnalyticsDescription =>
      'Helps us understand how the app is used to improve performance and features';

  @override
  String get privacyConsentCrashReportsTitle => 'Crash Reports';

  @override
  String get privacyConsentCrashReportsDescription =>
      'Automatically sends crash reports to help us fix issues';

  @override
  String get privacyConsentBackgroundLocationTitle => 'Background Location';

  @override
  String get privacyConsentBackgroundLocationDescription =>
      'Allows location tracking even when the app is closed to improve delivery services';

  @override
  String get privacyConsentSaveSuccess => 'Privacy settings saved';

  @override
  String privacyConsentErrorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get dsrExportTitle => 'Export Data';

  @override
  String get dsrExportHeadline => 'Export your personal data';

  @override
  String get dsrExportDescription =>
      'You will receive a secure link to download all your data. The link is valid for 7 days only.';

  @override
  String get dsrExportIncludePaymentsTitle => 'Include payment history';

  @override
  String get dsrExportIncludePaymentsDescription =>
      'Payment history may contain sensitive information. Please review the file carefully.';

  @override
  String get dsrExportStartButton => 'Start Export';

  @override
  String get dsrExportRequestStatus => 'Request Status';

  @override
  String dsrExportRequestDate(String date) {
    return 'Request date: $date';
  }

  @override
  String get dsrExportDownloadLink => 'Download Link';

  @override
  String dsrExportLinkExpires(String date) {
    return 'Expires: $date';
  }

  @override
  String get dsrExportCopyLink => 'Copy Link';

  @override
  String get dsrExportLinkCopied => 'Link copied';

  @override
  String get dsrExportPreparingFile => 'Preparing your file…';

  @override
  String get dsrExportSendingRequest => 'Sending export request…';

  @override
  String get dsrExportRequestFailed => 'Failed to send request';

  @override
  String get dsrErasureTitle => 'Delete Account';

  @override
  String get dsrErasureHeadline => 'Permanently delete your account';

  @override
  String get dsrErasureDescription =>
      'This action cannot be undone. All your data and account information will be deleted.';

  @override
  String get dsrErasureRequestButton => 'Request Account Deletion';

  @override
  String get dsrErasureWarningTitle => 'Important Warning';

  @override
  String get dsrErasureWarningPoint1 =>
      'All your personal data will be permanently deleted';

  @override
  String get dsrErasureWarningPoint2 =>
      'You will not be able to recover your account or data';

  @override
  String get dsrErasureWarningPoint3 =>
      'All active orders and reservations will be cancelled';

  @override
  String get dsrErasureWarningPoint4 =>
      'Your payment and transaction history will be deleted';

  @override
  String get dsrErasureWarningPoint5 =>
      'The request may take several days to process';

  @override
  String get dsrErasureLegalNotice =>
      'Account deletion is subject to the General Data Protection Regulation (GDPR). We will send you confirmation before executing the final deletion.';

  @override
  String get dsrErasureRequestStatus => 'Request Status';

  @override
  String get dsrErasureStatusPending => 'Pending review';

  @override
  String get dsrErasureStatusInProgress => 'Processing';

  @override
  String get dsrErasureStatusReady => 'Ready for confirmation';

  @override
  String get dsrErasureStatusCompleted => 'Completed';

  @override
  String get dsrErasureStatusFailed => 'Processing failed';

  @override
  String get dsrErasureStatusCanceled => 'Canceled';

  @override
  String get dsrErasureReviewingRequest => 'Reviewing your request…';

  @override
  String get dsrErasureSendingRequest => 'Sending deletion request…';

  @override
  String get dsrErasureRequestFailed => 'Failed to send request';

  @override
  String get dsrErasureNewRequest => 'Request New Deletion';

  @override
  String get dsrErasureConfirmTitle => 'Confirm Final Deletion';

  @override
  String get dsrErasureConfirmMessage =>
      'This is the final step. After confirmation, your account will be permanently deleted within 30 days and this decision cannot be reversed.';

  @override
  String get dsrErasureConfirmButton => 'Confirm Deletion';

  @override
  String get legalPrivacyPolicyTitle => 'Privacy Policy';

  @override
  String get legalPrivacyPolicyUnavailable =>
      'Privacy policy is not available at this time.';

  @override
  String get legalTermsOfServiceTitle => 'Terms of Service';

  @override
  String get legalTermsOfServiceUnavailable =>
      'Terms of service are not available at this time.';

  @override
  String get legalAboutTitle => 'Legal Information';

  @override
  String get legalPrivacyButton => 'Privacy Policy';

  @override
  String get legalTermsButton => 'Terms of Service';

  @override
  String get legalOpenSourceLicenses => 'Open Source Licenses';

  @override
  String get ordersTitle => 'Orders';

  @override
  String ordersOrderLabel(String orderId) {
    return 'Order: $orderId';
  }

  @override
  String get cartTitle => 'Cart';

  @override
  String cartItemsLabel(int count) {
    return 'Items: $count';
  }

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentInitializing => 'Initializing payment system...';

  @override
  String get paymentDebugTitle => 'Payments Debug';

  @override
  String paymentEnabled(String enabled) {
    return 'Payments enabled: $enabled';
  }

  @override
  String paymentMissingKeys(String keys) {
    return 'Missing config keys: $keys';
  }

  @override
  String paymentGatewayStatus(String status) {
    return 'Gateway status: $status';
  }

  @override
  String paymentGateway(String type) {
    return 'Gateway: $type';
  }

  @override
  String paymentSheetStatus(String status) {
    return 'Sheet status: $status';
  }

  @override
  String paymentSheet(String type) {
    return 'Sheet: $type';
  }

  @override
  String get paymentApplePay => 'Pay with Apple Pay';

  @override
  String get paymentGooglePay => 'Pay with Google Pay';

  @override
  String get paymentDigitalWallet => 'Pay with Digital Wallet';

  @override
  String get paymentCash => 'Pay with Cash';

  @override
  String get trackingTitle => 'Tracking';

  @override
  String get trackingLocationTitle => 'Location Tracking';

  @override
  String get trackingCurrentLocation => 'Current Location';

  @override
  String get trackingTripRoute => 'Trip Route';

  @override
  String get trackingRealtimeUnavailableTitle => 'Live Tracking Unavailable';

  @override
  String get trackingRealtimeUnavailableBody =>
      'Real-time tracking is currently unavailable. Your order status will be updated automatically.';

  @override
  String get trackingOrderStatus => 'Order Status';

  @override
  String get trackingNoActiveTrip => 'No active trip';

  @override
  String get mapTitle => 'Map';

  @override
  String get mapSmokeTestTitle => 'Maps Smoke Test';

  @override
  String get mapTestLocation => 'Test Location';

  @override
  String get mobilityBgTestsTitle => 'Mobility Background Tests (Phase-3)';

  @override
  String get mobilityTestBackgroundTracking => 'Test Background Tracking';

  @override
  String get mobilityTestGeofence => 'Test Geofence';

  @override
  String get mobilityTestTripRecording => 'Test Trip Recording';

  @override
  String get adminPanelTitle => 'Admin Panel';

  @override
  String get adminUserInfo => 'User Information';

  @override
  String adminUserLabel(String userId) {
    return 'User: $userId';
  }

  @override
  String adminRoleLabel(String role) {
    return 'Role: $role';
  }

  @override
  String get adminUserManagement => 'User Management';

  @override
  String get adminAnalyticsReports => 'Analytics & Reports';

  @override
  String get adminAnalyticsAccess => 'You have access to analytics';

  @override
  String get adminSystemMonitoring => 'System Monitoring';

  @override
  String get adminRbacStats => 'RBAC Statistics';

  @override
  String adminRbacEnabled(String status) {
    return 'Status: $status';
  }

  @override
  String get adminRbacStatusEnabled => 'Enabled';

  @override
  String get adminRbacStatusDisabled => 'Disabled';

  @override
  String adminCanaryPercentage(int percentage) {
    return 'Canary percentage: $percentage%';
  }

  @override
  String adminRolesCount(int count) {
    return 'Roles count: $count';
  }

  @override
  String adminTotalPermissions(int count) {
    return 'Total permissions: $count';
  }

  @override
  String get trackingCheckingAvailability =>
      'Checking tracking availability...';

  @override
  String get trackingLoadingRoute => 'Loading route...';

  @override
  String get ordersHistoryTitle => 'My Orders';

  @override
  String get ordersHistoryEmptyTitle => 'No orders yet';

  @override
  String get ordersHistoryEmptySubtitle =>
      'You don\'t have any orders yet. Start by creating a new shipment.';

  @override
  String get ordersHistoryUnavailableTitle => 'Orders Unavailable';

  @override
  String get ordersHistoryLoadError => 'Unable to load order history';

  @override
  String get ordersFilterAll => 'All';

  @override
  String get ordersFilterParcels => 'Parcels';

  @override
  String get ordersFilterRides => 'Rides';

  @override
  String get ordersSectionRidesTitle => 'Rides';

  @override
  String ordersRideItemTitleToDestination(String destination) {
    return 'Ride to $destination';
  }

  @override
  String ordersRideItemTitleWithService(
    String serviceName,
    String destination,
  ) {
    return '$serviceName to $destination';
  }

  @override
  String ordersRideItemSubtitleWithOrigin(String origin, String date) {
    return 'From $origin · $date';
  }

  @override
  String get ordersRideStatusCompleted => 'Completed';

  @override
  String get ordersRideStatusCancelled => 'Cancelled';

  @override
  String get ordersRideStatusFailed => 'Failed';

  @override
  String get paymentMethodsTitle => 'Payment Methods';

  @override
  String get paymentMethodsEmptyTitle => 'No payment methods';

  @override
  String get paymentMethodsEmptySubtitle =>
      'Add a payment method to get started';

  @override
  String get paymentMethodsAddButton => 'Add payment method';

  @override
  String get paymentMethodsLoadError => 'Unable to load payment methods';

  @override
  String get paymentMethodsSaving => 'Saving...';

  @override
  String get authVerifying => 'Verifying...';

  @override
  String get authSendingCode => 'Sending code...';

  @override
  String get featureUnavailableTitle => 'Feature Unavailable';

  @override
  String get featureUnavailableGeneric =>
      'This feature is currently unavailable. Please try again later.';

  @override
  String get onbWelcomeTitle => 'Welcome to Delivery Ways';

  @override
  String get onbWelcomeBody =>
      'Your reliable delivery partner. Order what you need and track your delivery in real-time.';

  @override
  String get onbAppIntroTitle => 'How It Works';

  @override
  String get onbAppIntroBody =>
      'Browse products, place your order, and we\'ll deliver it to your door. Simple and fast.';

  @override
  String get onbOrderingTitle => 'Easy Ordering';

  @override
  String get onbOrderingBody =>
      'Find what you need, add to cart, and checkout in seconds. Multiple payment options available where supported.';

  @override
  String get onbTrackingTitle => 'Track Your Order';

  @override
  String get onbTrackingBody =>
      'Follow your delivery in real-time when tracking is available in your area. You\'ll see updates at every step.';

  @override
  String get onbSecurityTitle => 'Your Security Matters';

  @override
  String get onbSecurityBody =>
      'Your data is protected with industry-standard security. We never share your personal information without consent.';

  @override
  String get onbNotificationsTitle => 'Stay Updated';

  @override
  String get onbNotificationsBody =>
      'Enable notifications to receive order updates, delivery alerts, and exclusive offers.';

  @override
  String get onbReadyTitle => 'You\'re All Set!';

  @override
  String get onbReadyBody =>
      'Start exploring and place your first order. We\'re here to help whenever you need us.';

  @override
  String get onbRideTitle => 'Get a Ride, Instantly.';

  @override
  String get onbRideBody =>
      'Tap, ride, and arrive. Fast, reliable, and affordable transport at your fingertips.';

  @override
  String get onbParcelsTitle => 'Deliver Anything, Effortlessly.';

  @override
  String get onbParcelsBody =>
      'Send packages across town or across the country. Track every step of the journey.';

  @override
  String get onbFoodTitle => 'Your Favorite Food, Delivered.';

  @override
  String get onbFoodBody =>
      'Craving something delicious? Order from top restaurants and enjoy fast delivery to your door.';

  @override
  String get onbRiderWelcomeTitle => 'Welcome, Rider!';

  @override
  String get onbRiderWelcomeBody =>
      'Join our delivery network and start earning. Flexible hours, fair compensation.';

  @override
  String get onbRiderHowItWorksTitle => 'Your Journey Starts Here';

  @override
  String get onbRiderHowItWorksBody =>
      'Accept deliveries, navigate to pickup, deliver to customers. Track your earnings in the app.';

  @override
  String get onbRiderLocationTitle => 'Enable Location';

  @override
  String get onbRiderLocationBody =>
      'We use your location to match you with nearby deliveries and provide navigation. Your location is only shared during active deliveries.';

  @override
  String get onbRiderSecurityTitle => 'Safe & Secure';

  @override
  String get onbRiderSecurityBody =>
      'Your earnings and personal data are protected. Multi-factor authentication keeps your account safe.';

  @override
  String get onbRiderNotificationsTitle => 'Never Miss a Delivery';

  @override
  String get onbRiderNotificationsBody =>
      'Get instant alerts for new delivery requests and important updates.';

  @override
  String get onbRiderReadyTitle => 'Ready to Deliver!';

  @override
  String get onbRiderReadyBody =>
      'You\'re set up and ready to go. Start accepting deliveries now.';

  @override
  String get onbCtaGetStarted => 'Get Started';

  @override
  String get onbCtaNext => 'Next';

  @override
  String get onbCtaSkip => 'Skip';

  @override
  String get onbCtaEnableNotifications => 'Enable Notifications';

  @override
  String get onbCtaEnableLocation => 'Enable Location';

  @override
  String get onbCtaStartOrdering => 'Start Ordering';

  @override
  String get onbCtaStartDelivering => 'Start Delivering';

  @override
  String get onbCtaMaybeLater => 'Maybe Later';

  @override
  String get onbCtaDone => 'Done';

  @override
  String get onbCtaBack => 'Back';

  @override
  String get hintAuthPhoneTitle => 'Secure Sign-In';

  @override
  String get hintAuthPhoneBody =>
      'We\'ll send a verification code to this number. Your phone number helps us keep your account secure.';

  @override
  String get hintAuthOtpTitle => 'Check Your Messages';

  @override
  String get hintAuthOtpBody =>
      'Enter the code we sent to your phone. This verifies that it\'s really you.';

  @override
  String get hintAuth2faTitle => 'Extra Protection';

  @override
  String get hintAuth2faBody =>
      'Two-factor authentication adds an extra layer of security to your account.';

  @override
  String get hintAuthBiometricTitle => 'Quick Access';

  @override
  String get hintAuthBiometricBody =>
      'Use your fingerprint or face to sign in faster while keeping your account secure.';

  @override
  String get hintPaymentsMethodsTitle => 'Payment Options';

  @override
  String get hintPaymentsMethodsBody =>
      'Add a payment method to speed up checkout. Your payment information is securely encrypted.';

  @override
  String get hintPaymentsSecurityTitle => 'Secure Payment';

  @override
  String get hintPaymentsSecurityBody =>
      'Your card details are encrypted and never stored on our servers. Payments are processed by trusted providers.';

  @override
  String get hintPaymentsLimitedTitle => 'Limited Payment Options';

  @override
  String get hintPaymentsLimitedBody =>
      'Some payment methods may not be available in your region. Cash on delivery is available where supported.';

  @override
  String get hintTrackingExplanationTitle => 'Live Tracking';

  @override
  String get hintTrackingExplanationBody =>
      'Watch your order\'s journey from pickup to delivery on the map.';

  @override
  String get hintTrackingUnavailableTitle => 'Tracking Not Available';

  @override
  String get hintTrackingUnavailableBody =>
      'Real-time tracking is not available for this order. You\'ll receive status updates via notifications.';

  @override
  String get hintTrackingRealtimeTitle => 'Real-Time Updates';

  @override
  String get hintTrackingRealtimeBody =>
      'The map updates automatically as your delivery progresses.';

  @override
  String get hintNotificationsImportanceTitle => 'Why Notifications Matter';

  @override
  String get hintNotificationsImportanceBody =>
      'Get instant updates about your order status, delivery arrival, and special offers.';

  @override
  String get hintNotificationsPermissionTitle => 'Enable Notifications';

  @override
  String get hintNotificationsPermissionBody =>
      'To receive order updates and delivery alerts, please enable notifications.';

  @override
  String get hintNotificationsPermissionCta => 'Enable Now';

  @override
  String get hintOrdersFirstTitle => 'Your First Order';

  @override
  String get hintOrdersFirstBody =>
      'Congratulations on your first order! Track its progress here.';

  @override
  String get hintOrdersEmptyTitle => 'No Orders Yet';

  @override
  String get hintOrdersEmptyBody =>
      'Start browsing and place your first order. Your order history will appear here.';

  @override
  String get hintOrdersEmptyCta => 'Browse Now';

  @override
  String get settingsReplayOnboarding => 'View App Introduction';

  @override
  String get settingsReplayOnboardingDescription =>
      'See the welcome guide again';

  @override
  String get rideBookingTitle => 'Book a Ride';

  @override
  String get rideBookingMapStubLabel => 'Map preview (stub – Ride Booking)';

  @override
  String get rideBookingSheetTitle => 'Where do you want to go?';

  @override
  String get rideBookingSheetSubtitle =>
      'Choose your pickup point and destination to see options and pricing.';

  @override
  String get rideBookingPickupLabel => 'Pickup';

  @override
  String get rideBookingPickupCurrentLocation => 'Current location';

  @override
  String get rideBookingDestinationLabel => 'Destination';

  @override
  String get rideBookingDestinationHint => 'Where to?';

  @override
  String get rideBookingRecentTitle => 'Recent places';

  @override
  String get rideBookingRecentHome => 'Home';

  @override
  String get rideBookingRecentHomeSubtitle => 'Saved home address';

  @override
  String get rideBookingRecentWork => 'Work';

  @override
  String get rideBookingRecentWorkSubtitle => 'Saved work address';

  @override
  String get rideBookingRecentAddNew => 'Add new place';

  @override
  String get rideBookingRecentAddNewSubtitle =>
      'Save a new frequent destination';

  @override
  String get rideBookingSeeOptionsCta => 'See options';

  @override
  String get rideConfirmTitle => 'Confirm your ride';

  @override
  String get rideConfirmMapStubLabel =>
      'Route preview (stub – the actual map will show your driver and destination).';

  @override
  String get rideConfirmSheetTitle => 'Choose your ride';

  @override
  String get rideConfirmSheetSubtitle =>
      'Select a ride option, review pricing, and confirm your trip.';

  @override
  String get rideConfirmOptionEconomyTitle => 'Economy';

  @override
  String get rideConfirmOptionEconomySubtitle =>
      'Affordable everyday rides for up to 4 people.';

  @override
  String get rideConfirmOptionXlTitle => 'XL';

  @override
  String get rideConfirmOptionXlSubtitle =>
      'Extra space for groups and larger items.';

  @override
  String get rideConfirmOptionPremiumTitle => 'Premium';

  @override
  String get rideConfirmOptionPremiumSubtitle =>
      'High-comfort rides with top-rated drivers.';

  @override
  String rideConfirmOptionEtaFormat(String minutes) {
    return '$minutes min away';
  }

  @override
  String rideConfirmOptionPriceApprox(String amount) {
    return '≈ $amount SAR';
  }

  @override
  String get rideConfirmPaymentLabel => 'Payment method';

  @override
  String get rideConfirmPaymentStubValue => 'Visa •• 4242 (stub)';

  @override
  String get rideConfirmPrimaryCta => 'Request Ride';

  @override
  String get rideConfirmRequestedStubMessage =>
      'Ride request stub – backend integration coming soon.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSectionSettingsTitle => 'Settings';

  @override
  String get profileSectionPrivacyTitle => 'Privacy & Data';

  @override
  String get profileUserFallbackName => 'User';

  @override
  String get profileUserPhoneLabel => 'Phone number';

  @override
  String get profileSettingsPersonalInfoTitle => 'Personal info';

  @override
  String get profileSettingsPersonalInfoSubtitle =>
      'Manage your name and details.';

  @override
  String get profileSettingsRidePrefsTitle => 'Ride preferences';

  @override
  String get profileSettingsRidePrefsSubtitle => 'Coming soon.';

  @override
  String get profileSettingsNotificationsTitle => 'Notifications';

  @override
  String get profileSettingsNotificationsSubtitle =>
      'Control alerts and offers.';

  @override
  String get profileSettingsHelpTitle => 'Help & support';

  @override
  String get profileSettingsHelpSubtitle =>
      'Get help with your trips and orders.';

  @override
  String get profilePrivacyExportTitle => 'Export my data';

  @override
  String get profilePrivacyExportSubtitle =>
      'Request a copy of your personal data.';

  @override
  String get profilePrivacyErasureTitle => 'Erase my data';

  @override
  String get profilePrivacyErasureSubtitle =>
      'Request deletion of your personal data.';

  @override
  String get profileLogoutTitle => 'Logout';

  @override
  String get profileLogoutSubtitle => 'Sign out of your account';

  @override
  String get profileLogoutDialogTitle => 'Logout';

  @override
  String get profileLogoutDialogBody => 'Are you sure you want to sign out?';

  @override
  String get profileLogoutDialogCancel => 'Cancel';

  @override
  String get profileLogoutDialogConfirm => 'Logout';

  @override
  String get profileGuestName => 'Guest User';

  @override
  String get profileGuestPhonePlaceholder => 'Add your phone number';

  @override
  String get profileLogoutSnack => 'Logout not fully wired yet';

  @override
  String get ridePhaseDraftLabel => 'Draft';

  @override
  String get ridePhaseQuotingLabel => 'Getting quote…';

  @override
  String get ridePhaseRequestingLabel => 'Requesting…';

  @override
  String get ridePhaseFindingDriverLabel => 'Finding driver…';

  @override
  String get ridePhaseDriverAcceptedLabel => 'Driver accepted';

  @override
  String get ridePhaseDriverArrivedLabel => 'Driver arrived';

  @override
  String get ridePhaseInProgressLabel => 'Trip in progress';

  @override
  String get ridePhasePaymentLabel => 'Payment';

  @override
  String get ridePhaseCompletedLabel => 'Completed';

  @override
  String get ridePhaseCancelledLabel => 'Cancelled';

  @override
  String get ridePhaseFailedLabel => 'Failed';

  @override
  String get rideErrorOptionsLoadFailed =>
      'Failed to load ride options. Please try again.';

  @override
  String get rideErrorRetryCta => 'Retry';

  @override
  String get rideActiveNoTripTitle => 'No active trip';

  @override
  String get rideActiveNoTripBody =>
      'You do not have an active trip right now.';

  @override
  String get rideActiveAppBarTitle => 'Your trip';

  @override
  String rideActiveEtaFormat(String minutes) {
    return 'ETA ~ $minutes min';
  }

  @override
  String get rideActiveContactDriverCta => 'Contact driver';

  @override
  String get rideActiveShareTripCta => 'Share trip status';

  @override
  String get rideActiveCancelTripCta => 'Cancel ride';

  @override
  String get rideActiveShareTripCopied =>
      'Trip status copied. You can paste it into any app.';

  @override
  String get rideActiveContactNoPhoneError =>
      'Driver contact details are not available yet.';

  @override
  String get rideActiveShareGenericError =>
      'Unable to prepare trip status right now. Please try again.';

  @override
  String rideActiveShareMessageTemplate(String destination, String link) {
    return 'I\'m on a Delivery Ways ride to $destination. Track my trip status here: $link';
  }

  @override
  String get rideActiveCancelErrorGeneric =>
      'Could not cancel the ride. Please try again.';

  @override
  String get rideCancelDialogTitle => 'Cancel this ride?';

  @override
  String get rideCancelDialogMessage =>
      'If you cancel now, your driver will stop heading to your pickup location.';

  @override
  String get rideCancelDialogKeepRideCta => 'Keep ride';

  @override
  String get rideCancelDialogConfirmCta => 'Cancel ride';

  @override
  String get rideCancelSuccessSnackbar => 'Your ride has been cancelled.';

  @override
  String get rideCancelReasonByRider => 'Cancelled by rider';

  @override
  String get rideActiveHeadlineFindingDriver => 'Finding a driver…';

  @override
  String rideActiveHeadlineDriverEta(String minutes) {
    return 'Driver is $minutes min away';
  }

  @override
  String get rideActiveHeadlineDriverOnTheWay => 'Driver on the way';

  @override
  String get rideActiveHeadlineDriverArrived => 'Driver has arrived';

  @override
  String get rideActiveHeadlineInProgress => 'Trip in progress';

  @override
  String get rideActiveHeadlinePayment => 'Completing payment';

  @override
  String get rideActiveHeadlineCompleted => 'Trip completed';

  @override
  String get rideActiveHeadlineCancelled => 'Trip cancelled';

  @override
  String get rideActiveHeadlineFailed => 'Trip failed';

  @override
  String get rideActiveHeadlinePreparing => 'Preparing your trip';

  @override
  String get rideActiveGoBackCta => 'Go back';

  @override
  String get rideActiveCancelledTitle => 'Trip cancelled';

  @override
  String get rideActiveCancelledBody =>
      'Your trip was cancelled. You can request a new ride at any time.';

  @override
  String get rideActiveFailedTitle => 'Something went wrong';

  @override
  String get rideActiveFailedBody =>
      'We couldn\'t complete this trip. Please try again in a moment.';

  @override
  String get rideActiveBackToHomeCta => 'Back to home';

  @override
  String get rideActiveRequestNewRideCta => 'Request new ride';

  @override
  String rideActiveDestinationLabel(String destination) {
    return 'To $destination';
  }

  @override
  String rideActiveSummaryServiceAndPrice(String serviceName, String price) {
    return '$serviceName · $price';
  }

  @override
  String rideActivePayingWith(String method) {
    return 'Paying with $method';
  }

  @override
  String get rideActivePriceNotAvailable => 'Price not available yet';

  @override
  String homeActiveRidePriceAndPayment(String price, String paymentMethod) {
    return '$price · $paymentMethod';
  }

  @override
  String get rideDebugFsmTitle => 'Debug FSM Controls';

  @override
  String rideDebugCurrentPhase(String phase) {
    return 'Current phase: $phase';
  }

  @override
  String get rideDebugDriverFound => 'Driver Found';

  @override
  String get rideDebugDriverArrived => 'Driver Arrived';

  @override
  String get rideDebugStartTrip => 'Start Trip';

  @override
  String get rideDebugCompleteTrip => 'Complete Trip';

  @override
  String get rideDebugConfirmPayment => 'Confirm Payment';

  @override
  String get rideStatusFindingDriver => 'Looking for a driver...';

  @override
  String get rideStatusDriverAccepted => 'Driver on the way';

  @override
  String get rideStatusDriverArrived => 'Driver has arrived';

  @override
  String get rideStatusInProgress => 'Trip in progress';

  @override
  String get rideStatusPaymentPending => 'Waiting for payment';

  @override
  String get rideStatusCompleted => 'Trip completed';

  @override
  String get rideStatusUnknown => 'Preparing your trip...';

  @override
  String get homeActiveRideViewTripCta => 'View trip';

  @override
  String get homeActiveRideTitleGeneric => 'Active ride';

  @override
  String homeActiveRideEtaTitle(int minutes) {
    return 'Arriving in $minutes min';
  }

  @override
  String homeActiveRideSubtitleToDestination(String destination) {
    return 'To $destination';
  }

  @override
  String get homeHubTitle => 'Where do you want to go?';

  @override
  String get homeHubCurrentLocationLabel => 'Current location';

  @override
  String get homeHubCurrentLocationLoading => 'Detecting your location...';

  @override
  String get homeHubCurrentLocationUnavailable => 'Location not available';

  @override
  String get homeHubServiceRide => 'Ride';

  @override
  String get homeHubServiceParcels => 'Parcels';

  @override
  String get homeHubServiceFood => 'Food';

  @override
  String get homeHubActiveRideTitle => 'Ride in progress';

  @override
  String get homeHubActiveRideSubtitle => 'Continue your active trip';

  @override
  String get homeHubParcelsComingSoonMessage =>
      'Parcels service is coming soon to your city.';

  @override
  String get homeHubFoodComingSoonMessage =>
      'Food ordering is coming soon to your city.';

  @override
  String get homeHubSearchPlaceholder => 'Where to?';

  @override
  String get rideDestinationTitle => 'Where to?';

  @override
  String get rideDestinationPickupLabel => 'Pick-up';

  @override
  String get rideDestinationPickupCurrentLocation => 'Current location';

  @override
  String get rideDestinationRecentLocationsSection => 'Recent locations';

  @override
  String get rideLocationPickerTitle => 'Choose your trip';

  @override
  String get rideLocationPickerPickupLabel => 'Pickup';

  @override
  String get rideLocationPickerDestinationLabel => 'Destination';

  @override
  String get rideLocationPickerPickupPlaceholder =>
      'Where should we pick you up?';

  @override
  String get rideLocationPickerDestinationPlaceholder => 'Where are you going?';

  @override
  String get rideLocationPickerMapHint =>
      'Adjust the pin or use search to set your locations.';

  @override
  String get rideLocationPickerContinueCta => 'See prices';

  @override
  String get rideTripConfirmationTitle => 'Confirm your trip';

  @override
  String get rideTripConfirmationRequestRideCta => 'Request ride';

  @override
  String get rideTripConfirmationPaymentSectionTitle => 'Payment';

  @override
  String get rideTripConfirmationPaymentMethodCash => 'Cash';

  @override
  String get rideTripSummaryTitle => 'Trip summary';

  @override
  String get rideTripSummaryCompletedTitle => 'Trip completed';

  @override
  String get rideTripSummaryCompletedSubtitle =>
      'Thanks for riding with Delivery Ways';

  @override
  String get rideTripSummaryCancelledTitle => 'Trip cancelled';

  @override
  String get rideTripSummaryCancelledSubtitle => 'Your ride was cancelled';

  @override
  String get rideTripSummaryFailedTitle => 'Ride failed';

  @override
  String get rideTripSummaryFailedSubtitle => 'We couldn\'t complete this ride';

  @override
  String get rideFailReasonNoDriverFound => 'No driver found';

  @override
  String get rideFailNoDriverFoundSnackbar =>
      'We couldn\'t find a driver for this ride.';

  @override
  String get rideFailNoDriverFoundCta => 'No drivers available? Try later';

  @override
  String get rideTripSummaryRouteSectionTitle => 'Route';

  @override
  String get rideTripSummaryFareSectionTitle => 'Fare';

  @override
  String get rideTripSummaryTotalLabel => 'Total';

  @override
  String get rideTripSummaryDriverSectionTitle => 'Your driver';

  @override
  String get rideTripSummaryRatingLabel => 'Rate your driver';

  @override
  String get rideTripSummaryDoneCta => 'Done';

  @override
  String rideTripCompletionServiceLabel(String serviceName) {
    return '$serviceName ride';
  }

  @override
  String get rideConfirmLoadingTitle => 'Fetching ride options...';

  @override
  String get rideConfirmLoadingSubtitle =>
      'Please wait while we find the best rides for you.';

  @override
  String get rideConfirmErrorTitle => 'We couldn\'t load ride options';

  @override
  String get rideConfirmErrorSubtitle =>
      'Please check your connection and try again.';

  @override
  String get rideConfirmEmptyTitle => 'No rides available';

  @override
  String get rideConfirmEmptySubtitle => 'Please try again in a few minutes.';

  @override
  String get rideConfirmRetryCta => 'Retry';

  @override
  String get rideConfirmRecommendedBadge => 'Recommended';

  @override
  String get rideQuoteErrorTitle => 'We couldn\'t load ride options';

  @override
  String get rideQuoteErrorGeneric =>
      'Please check your connection and try again.';

  @override
  String get rideQuoteErrorNoOptions =>
      'No ride options are available for this route right now.';

  @override
  String get ridePricingErrorGeneric =>
      'We couldn\'t load prices. Please try again.';

  @override
  String get rideQuoteRetryCta => 'Retry';

  @override
  String get rideQuoteEmptyTitle => 'No rides available';

  @override
  String get rideQuoteEmptyDescription => 'Please try again in a few minutes.';

  @override
  String get rideConfirmFromLabel => 'From';

  @override
  String get rideConfirmToLabel => 'To';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Delivery Ways';

  @override
  String get onboardingWelcomeSubtitle =>
      'All your rides, parcels, and deliveries in one place.';

  @override
  String get onboardingWelcomeGetStartedCta => 'Get started';

  @override
  String get onboardingPermissionsTitle => 'Allow permissions';

  @override
  String get onboardingPermissionsLocation => 'Location access';

  @override
  String get onboardingPermissionsLocationSubtitle =>
      'We use your location to find nearby drivers.';

  @override
  String get onboardingPermissionsNotifications => 'Notifications';

  @override
  String get onboardingPermissionsNotificationsSubtitle =>
      'Stay updated about your rides and deliveries.';

  @override
  String get onboardingPermissionsContinueCta => 'Continue';

  @override
  String get onboardingPermissionsSkipCta => 'Skip for now';

  @override
  String get onboardingPreferencesTitle => 'Set your preferences';

  @override
  String get onboardingPreferencesSubtitle =>
      'You can change these later in Settings.';

  @override
  String get onboardingPreferencesPrimaryServiceTitle =>
      'What do you use most?';

  @override
  String get onboardingPreferencesServiceRides => 'Rides';

  @override
  String get onboardingPreferencesServiceRidesDesc =>
      'Get picked up and dropped off';

  @override
  String get onboardingPreferencesServiceParcels => 'Parcels';

  @override
  String get onboardingPreferencesServiceParcelsDesc =>
      'Send and receive packages';

  @override
  String get onboardingPreferencesServiceFood => 'Food';

  @override
  String get onboardingPreferencesServiceFoodDesc => 'Order from restaurants';

  @override
  String get onboardingPreferencesDoneCta => 'Start using Delivery Ways';

  @override
  String get onboardingPreferencesNotificationsTitle => 'Notifications';

  @override
  String get onboardingPreferencesMarketingTitle => 'Marketing notifications';

  @override
  String get onboardingPreferencesMarketingSubtitle =>
      'Receive updates about promotions and new features';

  @override
  String get parcelsEntryTitle => 'Parcels';

  @override
  String get parcelsEntrySubtitle =>
      'Ship and track your parcels in one place.';

  @override
  String get parcelsEntryCreateShipmentCta => 'Create shipment';

  @override
  String get parcelsEntryViewShipmentsCta => 'View shipments list';

  @override
  String get parcelsEntryComingSoonMessage => 'Parcels flows are coming soon.';

  @override
  String get parcelsEntryFooterNote =>
      'Parcels MVP is under active development.';

  @override
  String get parcelsComingSoonMessage => 'Parcels is coming soon.';

  @override
  String get parcelsDestinationTitle => 'Create shipment';

  @override
  String get parcelsDestinationSubtitle =>
      'Enter where to pick up and where to deliver your parcel.';

  @override
  String get parcelsDestinationPickupLabel => 'Pickup address';

  @override
  String get parcelsDestinationPickupHint => 'Enter pickup address';

  @override
  String get parcelsDestinationDropoffLabel => 'Delivery address';

  @override
  String get parcelsDestinationDropoffHint => 'Enter delivery address';

  @override
  String get parcelsDestinationContinueCta => 'Continue';

  @override
  String get parcelsDetailsTitle => 'Parcel details';

  @override
  String get parcelsDetailsSubtitle =>
      'Tell us more about your parcel to get accurate pricing.';

  @override
  String get parcelsDetailsSizeLabel => 'Size';

  @override
  String get parcelsDetailsWeightLabel => 'Weight';

  @override
  String get parcelsDetailsWeightHint => 'e.g. 2.5 kg';

  @override
  String get parcelsDetailsContentsLabel => 'What are you sending?';

  @override
  String get parcelsDetailsContentsHint => 'Briefly describe the contents';

  @override
  String get parcelsDetailsFragileLabel => 'This parcel is fragile';

  @override
  String get parcelsDetailsContinueCta => 'Review price';

  @override
  String get parcelsDetailsErrorWeightRequired =>
      'Please enter the parcel weight';

  @override
  String get parcelsDetailsErrorPositiveNumber =>
      'Enter a valid positive number';

  @override
  String get parcelsDetailsErrorContentsRequired =>
      'Please describe what you are sending';

  @override
  String get parcelsDetailsErrorSizeRequired => 'Please select a parcel size';

  @override
  String get parcelsDetailsSectionParcelTitle => 'Parcel details';

  @override
  String get parcelsQuoteTitle => 'Shipment pricing';

  @override
  String get parcelsQuoteSubtitle =>
      'Choose how fast you want it delivered and how much you want to pay.';

  @override
  String get parcelsQuoteLoadingTitle => 'Fetching price options...';

  @override
  String get parcelsQuoteErrorTitle => 'We couldn\'t load price options';

  @override
  String get parcelsQuoteErrorSubtitle =>
      'Please check your connection and try again.';

  @override
  String get parcelsQuoteEmptyTitle => 'No options available';

  @override
  String get parcelsQuoteEmptySubtitle =>
      'Please adjust the parcel details and try again.';

  @override
  String get parcelsQuoteRetryCta => 'Retry';

  @override
  String get parcelsQuoteConfirmCta => 'Confirm shipment';

  @override
  String get parcelsQuoteSummaryTitle => 'Shipment summary';

  @override
  String get parcelsQuoteFromLabel => 'From';

  @override
  String get parcelsQuoteToLabel => 'To';

  @override
  String get parcelsQuoteWeightLabel => 'Weight';

  @override
  String get parcelsQuoteSizeLabel => 'Size';

  @override
  String parcelsQuoteTotalLabel(String amount) {
    return 'Total: $amount';
  }

  @override
  String get parcelsQuoteBreakdownStubNote =>
      'This is an estimated price. Final price may change after integration with the live pricing service.';

  @override
  String get parcelsListTitle => 'Your shipments';

  @override
  String get parcelsListSectionTitle => 'My shipments';

  @override
  String get parcelsListEmptyTitle => 'No shipments yet';

  @override
  String get parcelsListEmptySubtitle =>
      'When you create a shipment, it will appear here.';

  @override
  String get parcelsListEmptyCta => 'Create first shipment';

  @override
  String get parcelsListNewShipmentTooltip => 'New shipment';

  @override
  String parcelsListCreatedAtLabel(String date) {
    return 'Created on $date';
  }

  @override
  String get parcelsListUnknownDestinationLabel => 'Unknown destination';

  @override
  String get parcelsFilterAllLabel => 'All';

  @override
  String get parcelsFilterInProgressLabel => 'In progress';

  @override
  String get parcelsFilterDeliveredLabel => 'Delivered';

  @override
  String get parcelsFilterCancelledLabel => 'Cancelled';

  @override
  String get parcelsStatusScheduled => 'Scheduled';

  @override
  String get parcelsStatusPickupPending => 'Pickup pending';

  @override
  String get parcelsStatusPickedUp => 'Picked up';

  @override
  String get parcelsStatusInTransit => 'In transit';

  @override
  String get parcelsStatusDelivered => 'Delivered';

  @override
  String get parcelsStatusCancelled => 'Cancelled';

  @override
  String get parcelsStatusFailed => 'Failed';

  @override
  String get parcelsCreateShipmentTitle => 'Create shipment';

  @override
  String get parcelsCreateSenderSectionTitle => 'Sender';

  @override
  String get parcelsCreateReceiverSectionTitle => 'Receiver';

  @override
  String get parcelsCreateDetailsSectionTitle => 'Parcel details';

  @override
  String get parcelsCreateServiceSectionTitle => 'Service type';

  @override
  String get parcelsCreateSenderNameLabel => 'Sender name';

  @override
  String get parcelsCreateSenderPhoneLabel => 'Sender phone';

  @override
  String get parcelsCreateSenderAddressLabel => 'Sender address';

  @override
  String get parcelsCreateReceiverNameLabel => 'Receiver name';

  @override
  String get parcelsCreateReceiverPhoneLabel => 'Receiver phone';

  @override
  String get parcelsCreateReceiverAddressLabel => 'Receiver address';

  @override
  String get parcelsCreateWeightLabel => 'Weight (kg)';

  @override
  String get parcelsCreateSizeLabel => 'Size';

  @override
  String get parcelsCreateNotesLabel => 'Notes (optional)';

  @override
  String get parcelsCreateServiceExpress => 'Express';

  @override
  String get parcelsCreateServiceStandard => 'Standard';

  @override
  String get parcelsCreateShipmentCtaGetEstimate => 'Get estimate';

  @override
  String get parcelsCreateErrorRequired => 'This field is required';

  @override
  String get parcelsCreateErrorInvalidNumber => 'Please enter a valid number';

  @override
  String get parcelsCreateErrorInvalidPhone =>
      'Please enter a valid phone number';

  @override
  String get parcelsCreateWeightInvalidError => 'Please enter a valid weight.';

  @override
  String get parcelsCreateEstimateComingSoonSnackbar =>
      'Shipment estimate is coming soon.';

  @override
  String get parcelsCreateSizeSmallLabel => 'Small';

  @override
  String get parcelsCreateSizeMediumLabel => 'Medium';

  @override
  String get parcelsCreateSizeLargeLabel => 'Large';

  @override
  String get parcelsCreateSizeOversizeLabel => 'Oversize';

  @override
  String get parcelsShipmentDetailsTitle => 'Shipment details';

  @override
  String parcelsShipmentDetailsCreatedAt(String date) {
    return 'Created on $date';
  }

  @override
  String get parcelsShipmentDetailsRouteSectionTitle => 'Route';

  @override
  String get parcelsShipmentDetailsPickupLabel => 'Pickup';

  @override
  String get parcelsShipmentDetailsDropoffLabel => 'Dropoff';

  @override
  String get parcelsShipmentDetailsAddressSectionTitle => 'Addresses';

  @override
  String get parcelsShipmentDetailsSenderLabel => 'Sender';

  @override
  String get parcelsShipmentDetailsReceiverLabel => 'Receiver';

  @override
  String get parcelsShipmentDetailsMetaSectionTitle => 'Parcel details';

  @override
  String get parcelsShipmentDetailsWeightLabel => 'Weight';

  @override
  String get parcelsShipmentDetailsSizeLabel => 'Size';

  @override
  String get parcelsShipmentDetailsNotesLabel => 'Notes';

  @override
  String get parcelsShipmentDetailsNotAvailable => 'N/A';

  @override
  String get parcelsShipmentDetailsSizeSmall => 'Small';

  @override
  String get parcelsShipmentDetailsSizeMedium => 'Medium';

  @override
  String get parcelsShipmentDetailsSizeLarge => 'Large';

  @override
  String get parcelsShipmentDetailsSizeOversize => 'Oversize';

  @override
  String get parcelsDetailsPriceLabel => 'Price';

  @override
  String get foodComingSoonAppBarTitle => 'Food delivery';

  @override
  String get foodComingSoonTitle => 'Food delivery is coming soon';

  @override
  String get foodComingSoonSubtitle =>
      'We\'re working hard to bring food delivery to your area. Stay tuned!';

  @override
  String get foodComingSoonPrimaryCta => 'Back to home';

  @override
  String get foodRestaurantsAppBarTitle => 'Food delivery';

  @override
  String get foodRestaurantsSearchPlaceholder =>
      'Search restaurants or cuisines';

  @override
  String get foodRestaurantsFilterAll => 'All';

  @override
  String get foodRestaurantsFilterBurgers => 'Burgers';

  @override
  String get foodRestaurantsFilterItalian => 'Italian';

  @override
  String get foodRestaurantsEmptyTitle => 'No restaurants found';

  @override
  String get foodRestaurantsEmptySubtitle =>
      'Try changing the filters or search for a different cuisine.';

  @override
  String get foodRestaurantMenuError =>
      'Could not load menu. Please try again.';

  @override
  String foodCartSummaryCta(String itemCount, String totalPrice) {
    return '$itemCount items · $totalPrice total';
  }

  @override
  String foodCartCheckoutStub(String itemCount, String totalPrice) {
    return 'Checkout not implemented yet. $itemCount items, total $totalPrice.';
  }

  @override
  String get ordersSectionParcelsTitle => 'Parcels';

  @override
  String get ordersSectionFoodTitle => 'Food';

  @override
  String get ordersFilterFood => 'Food';

  @override
  String get ordersFoodStatusPending => 'Pending';

  @override
  String get ordersFoodStatusInPreparation => 'In preparation';

  @override
  String get ordersFoodStatusOnTheWay => 'On the way';

  @override
  String get ordersFoodStatusDelivered => 'Delivered';

  @override
  String get ordersFoodStatusCancelled => 'Cancelled';

  @override
  String ordersFoodCreatedAtLabel(String date) {
    return 'Ordered on $date';
  }

  @override
  String foodCartOrderCreatedSnackbar(String restaurant) {
    return 'Your order from $restaurant has been created.';
  }

  @override
  String get homeFoodComingSoonLabel => 'Coming soon';

  @override
  String get homeFoodComingSoonMessage =>
      'Food delivery is not available yet in your area.';

  @override
  String get homeFoodCardTitle => 'Food';

  @override
  String get homeFoodCardSubtitle => 'Your favorite food, delivered.';

  @override
  String get onboardingRideTitle => 'Get a Ride, Instantly.';

  @override
  String get onboardingRideBody =>
      'Tap, ride, and arrive. Fast, reliable, and affordable transport at your fingertips.';

  @override
  String get onboardingParcelsTitle => 'Deliver Anything, Effortlessly.';

  @override
  String get onboardingParcelsBody =>
      'From documents to gifts, send and track your parcels with ease and confidence.';

  @override
  String get onboardingFoodTitle => 'Your Favorite Food, Delivered.';

  @override
  String get onboardingFoodBody =>
      'Explore local restaurants and enjoy fast delivery right to your door.';

  @override
  String get onboardingButtonContinue => 'Continue';

  @override
  String get onboardingButtonGetStarted => 'Get Started';

  @override
  String get homeRideCardTitle => 'Ride';

  @override
  String get homeRideCardSubtitle => 'Get a ride, instantly.';

  @override
  String get rideDestinationDestinationLabel => 'Destination';

  @override
  String get rideDestinationDestinationPlaceholder => 'Where to?';

  @override
  String get rideDestinationRecentTitle => 'Recent destinations';

  @override
  String get rideDestinationRecentHomeLabel => 'Home';

  @override
  String get rideDestinationRecentHomeSubtitle => 'Saved home address';

  @override
  String get rideDestinationRecentWorkLabel => 'Work';

  @override
  String get rideDestinationRecentWorkSubtitle => 'Saved work address';

  @override
  String get rideDestinationRecentLastLabel => 'Last trip';

  @override
  String get rideDestinationRecentLastSubtitle =>
      'Use the destination from your last ride';

  @override
  String get rideDestinationNextCta => 'Next';

  @override
  String get rideDestinationComingSoonSnackbar =>
      'Trip summary is coming soon.';

  @override
  String get rideSummaryReceiptTitle => 'Receipt';

  @override
  String get rideSummaryReceiptFareLabel => 'Fare';

  @override
  String get rideSummaryReceiptFeesLabel => 'Fees';

  @override
  String get rideSummaryReceiptTotalLabel => 'Total';

  @override
  String get rideSummaryRatingTitle => 'Rate your driver';

  @override
  String get rideSummaryRatingSubtitle =>
      'Your feedback helps keep rides safe and comfortable.';

  @override
  String get rideSummaryCommentPlaceholder => 'Add a comment (optional)';

  @override
  String rideReceiptTripIdLabel(String id) {
    return 'Trip ID: $id';
  }

  @override
  String rideReceiptCompletedAt(String date, String time) {
    return '$date at $time';
  }

  @override
  String get rideReceiptFromLabel => 'From';

  @override
  String get rideReceiptToLabel => 'To';

  @override
  String get rideReceiptFareSectionTitle => 'Trip fare';

  @override
  String get rideReceiptBaseFareLabel => 'Base fare';

  @override
  String get rideReceiptDistanceFareLabel => 'Distance';

  @override
  String get rideReceiptTimeFareLabel => 'Time';

  @override
  String get rideReceiptFeesLabel => 'Fees & surcharges';

  @override
  String get rideReceiptTotalLabel => 'Total';

  @override
  String get rideReceiptDriverSectionTitle => 'Driver & vehicle';

  @override
  String get rideReceiptRateDriverTitle => 'Rate your driver';

  @override
  String get rideReceiptRateDriverSubtitle =>
      'Your feedback helps keep rides safe and comfortable.';

  @override
  String get rideReceiptDoneCta => 'Done';

  @override
  String get rideDriverMockName => 'Ahmad M.';

  @override
  String get rideDriverMockCarInfo => 'Toyota Camry • ABC 1234';

  @override
  String get rideDriverMockRating => '4.9';

  @override
  String get rideSummaryEndTripDebugCta => 'End trip';

  @override
  String get rideSummaryThankYouSnackbar => 'Thanks for your feedback.';

  @override
  String get homeActiveParcelTitleGeneric => 'Active shipment';

  @override
  String homeActiveParcelSubtitleToDestination(String destination) {
    return 'To $destination';
  }

  @override
  String get homeActiveParcelViewShipmentCta => 'View shipment';

  @override
  String get homeActiveParcelStatusPreparing => 'Preparing your shipment...';

  @override
  String get homeActiveParcelStatusScheduled => 'Pickup scheduled';

  @override
  String get homeActiveParcelStatusPickupPending => 'Waiting for pickup';

  @override
  String get homeActiveParcelStatusPickedUp => 'Picked up';

  @override
  String get homeActiveParcelStatusInTransit => 'In transit';

  @override
  String get homeActiveParcelStatusDelivered => 'Delivered';

  @override
  String get homeActiveParcelStatusCancelled => 'Shipment cancelled';

  @override
  String get homeActiveParcelStatusFailed => 'Delivery failed';

  @override
  String get parcelsActiveShipmentTitle => 'Active shipment';

  @override
  String get parcelsActiveShipmentNoActiveTitle => 'No active shipment';

  @override
  String get parcelsActiveShipmentNoActiveSubtitle =>
      'You don\'t have any active shipments right now.';

  @override
  String get parcelsActiveShipmentMapStub => 'Map tracking (coming soon)';

  @override
  String parcelsActiveShipmentStatusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String parcelsActiveShipmentIdLabel(String id) {
    return 'Shipment ID: $id';
  }

  @override
  String get parcelsActiveShipmentStubNote =>
      'Full tracking will be available in a future update.';

  @override
  String get parcelsDetailsCancelShipmentCta => 'Cancel shipment';

  @override
  String get parcelsCancelDialogTitle => 'Cancel this shipment?';

  @override
  String get parcelsCancelDialogSubtitle =>
      'If you cancel now, this shipment will be stopped and will no longer appear as active.';

  @override
  String get parcelsCancelDialogConfirmCta => 'Yes, cancel';

  @override
  String get parcelsCancelDialogDismissCta => 'Keep shipment';

  @override
  String get parcelsCancelSuccessMessage => 'Shipment has been cancelled.';

  @override
  String get bottomNavHomeLabel => 'Home';

  @override
  String get bottomNavOrdersLabel => 'Orders';

  @override
  String get bottomNavPaymentsLabel => 'Payments';

  @override
  String get bottomNavProfileLabel => 'Profile';

  @override
  String get homeCurrentLocationLabel => 'Current location';

  @override
  String get homeCurrentLocationPlaceholder => 'Set pickup location';

  @override
  String get homeServiceRideTitle => 'Ride';

  @override
  String get homeServiceParcelsTitle => 'Parcels';

  @override
  String get homeServiceFoodTitle => 'Food';

  @override
  String get homeServiceRideSubtitle => 'Get a ride in minutes';

  @override
  String get homeServiceParcelsSubtitle => 'Send and track parcels';

  @override
  String get homeServiceFoodSubtitle => 'Order food from nearby restaurants';

  @override
  String get homeSearchPlaceholder => 'Where to?';

  @override
  String get paymentsEntryTitle => 'Payments';

  @override
  String get paymentsEntryStubBody =>
      'Payments management will be available in a future update.';

  @override
  String get paymentsTitle => 'Payments';

  @override
  String get paymentsAddMethodCta => 'Add new payment method';

  @override
  String get paymentsEmptyTitle => 'No payment methods saved';

  @override
  String get paymentsEmptyBody =>
      'Your saved cards and payment options will appear here.';

  @override
  String get paymentsMethodTypeCash => 'Cash';

  @override
  String get paymentsMethodTypeCard => 'Card';

  @override
  String get paymentsDefaultBadge => 'Default';

  @override
  String get paymentsAddMethodComingSoon =>
      'Adding new payment methods will be available soon.';

  @override
  String paymentsCardExpiry(int month, int year) {
    return 'Expiry $month/$year';
  }

  @override
  String get paymentsMethodTypeApplePay => 'Apple Pay';

  @override
  String get paymentsMethodTypeGooglePay => 'Google Pay';

  @override
  String get paymentsMethodTypeDigitalWallet => 'Digital Wallet';

  @override
  String get paymentsMethodTypeBankTransfer => 'Bank Transfer';

  @override
  String get paymentsMethodTypeCashOnDelivery => 'Cash on Delivery';

  @override
  String get profileEntryTitle => 'Profile';

  @override
  String get profileEntryStubBody =>
      'Profile and account settings will be available in a future update.';

  @override
  String get rideStatusShortDraft => 'Draft';

  @override
  String get rideStatusShortQuoting => 'Getting price';

  @override
  String get rideStatusShortRequesting => 'Requesting ride';

  @override
  String get rideStatusShortFindingDriver => 'Finding driver';

  @override
  String get rideStatusShortDriverAccepted => 'Driver accepted';

  @override
  String get rideStatusShortDriverArrived => 'Driver arrived';

  @override
  String get rideStatusShortInProgress => 'In progress';

  @override
  String get rideStatusShortPayment => 'Payment in progress';

  @override
  String get rideStatusShortCompleted => 'Completed';

  @override
  String get rideStatusShortCancelled => 'Cancelled';

  @override
  String get rideStatusShortFailed => 'Failed';

  @override
  String get homeActiveRideStatusPreparing => 'Preparing your trip...';

  @override
  String get homeActiveRideStatusFindingDriver => 'Looking for a driver...';

  @override
  String get homeActiveRideStatusDriverAccepted => 'Driver on the way';

  @override
  String get homeActiveRideStatusDriverArrived => 'Driver has arrived';

  @override
  String get homeActiveRideStatusInProgress => 'Trip in progress';

  @override
  String get homeActiveRideStatusPayment => 'Finalizing payment';

  @override
  String get homeActiveRideStatusCompleted => 'Trip completed';

  @override
  String get homeActiveRideStatusCancelled => 'Trip cancelled';

  @override
  String get homeActiveRideStatusFailed => 'Trip failed';

  @override
  String get rideActiveTripTitle => 'Active trip';

  @override
  String rideActiveTripFromLabel(String pickup) {
    return 'From: $pickup';
  }

  @override
  String rideActiveTripToLabel(String dropoff) {
    return 'To: $dropoff';
  }

  @override
  String rideActiveTripIdLabel(String id) {
    return 'Trip ID: $id';
  }

  @override
  String get rideActiveTripMapStub => 'Live map tracking (coming soon)';

  @override
  String get rideActiveTripStubNote =>
      'Full live tracking will be available after integration with the mobility service.';

  @override
  String rideActiveTripStatusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String get rideActiveTripDriverSectionTitle => 'Driver & vehicle';

  @override
  String get rideActiveTripDriverSectionStubBody =>
      'Driver and vehicle details will be available once the mobility integration is connected.';

  @override
  String get ordersHistoryEmptyAllTitle => 'No orders yet';

  @override
  String get ordersHistoryEmptyAllDescription =>
      'Your rides, parcels and food orders will appear here.';

  @override
  String get ordersHistoryEmptyRidesTitle => 'No rides yet';

  @override
  String get ordersHistoryEmptyRidesDescription =>
      'Your completed rides will appear here.';

  @override
  String get ordersHistoryEmptyParcelsTitle => 'No parcels yet';

  @override
  String get ordersHistoryEmptyParcelsDescription =>
      'Your shipments will appear here.';

  @override
  String get ordersHistoryEmptyFoodTitle => 'No food orders yet';

  @override
  String get ordersHistoryEmptyFoodDescription =>
      'Your food delivery orders will appear here.';

  @override
  String get ordersServiceRideSemanticLabel => 'Ride order';

  @override
  String get ordersServiceParcelSemanticLabel => 'Parcel shipment';

  @override
  String get ordersServiceFoodSemanticLabel => 'Food order';

  @override
  String get parcelsShipmentsTitle => 'My Shipments';

  @override
  String get parcelsShipmentsNewShipmentTooltip => 'New shipment';

  @override
  String get parcelsShipmentsEmptyTitle => 'No shipments yet';

  @override
  String get parcelsShipmentsEmptyDescription =>
      'You don\'t have any shipments yet. Create your first shipment to start sending parcels.';

  @override
  String get parcelsShipmentsEmptyCta => 'Create first shipment';

  @override
  String get parcelsShipmentStatusCreated => 'Created';

  @override
  String get parcelsShipmentStatusInTransit => 'In Transit';

  @override
  String get parcelsShipmentStatusDelivered => 'Delivered';

  @override
  String get parcelsShipmentStatusCancelled => 'Cancelled';

  @override
  String get parcelsShipmentsErrorTitle => 'Something went wrong';

  @override
  String get parcelsCreateShipmentCta => 'Create shipment';

  @override
  String get parcelsCreateShipmentSenderSectionTitle => 'Sender details';

  @override
  String get parcelsCreateShipmentReceiverSectionTitle => 'Receiver details';

  @override
  String get parcelsCreateShipmentParcelDetailsSectionTitle => 'Parcel details';

  @override
  String get parcelsCreateShipmentSenderNameLabel => 'Sender name';

  @override
  String get parcelsCreateShipmentSenderPhoneLabel => 'Sender phone';

  @override
  String get parcelsCreateShipmentReceiverNameLabel => 'Receiver name';

  @override
  String get parcelsCreateShipmentReceiverPhoneLabel => 'Receiver phone';

  @override
  String get parcelsCreateShipmentPickupAddressLabel => 'Pickup address';

  @override
  String get parcelsCreateShipmentDropoffAddressLabel => 'Dropoff address';

  @override
  String get parcelsCreateShipmentWeightLabel => 'Weight (kg)';

  @override
  String get parcelsCreateShipmentSizeLabel => 'Size';

  @override
  String get parcelsCreateShipmentNotesLabel => 'Notes';

  @override
  String get parcelsCreateShipmentServiceTypeLabel => 'Service type';

  @override
  String get parcelsCreateShipmentServiceTypeExpress => 'Express';

  @override
  String get parcelsCreateShipmentServiceTypeStandard => 'Standard';

  @override
  String get parcelsCreateShipmentServiceTypeError =>
      'Please select a service type';

  @override
  String get parcelsCreateShipmentSuccessMessage =>
      'Shipment created successfully';

  @override
  String get commonErrorFieldRequired => 'This field is required';

  @override
  String get commonAddressesTitle => 'Addresses';

  @override
  String get parcelsShipmentDetailsContactsSectionTitle => 'Contacts';

  @override
  String get parcelsShipmentDetailsDetailsSectionTitle => 'Parcel details';

  @override
  String get parcelsShipmentDetailsServiceTypeLabel => 'Service type';

  @override
  String get commonTotalLabel => 'Total';

  @override
  String get homeHubRecentDestinationsTitle => 'Recent destinations';

  @override
  String get homeHubRecentDestinationsSeeAll => 'See all';
}

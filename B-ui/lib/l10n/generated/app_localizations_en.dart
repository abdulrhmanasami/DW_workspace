// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get notificationsSettingsTitle => 'Notification Settings';

  @override
  String get notificationsSettingsOrderStatusTitle => 'Order Status Notifications';

  @override
  String get notificationsSettingsOrderStatusSubtitle => 'Receive real-time updates about your active orders.';

  @override
  String get notificationsSettingsPromotionsTitle => 'Promotional Offers';

  @override
  String get notificationsSettingsPromotionsSubtitle => 'Receive personalized offers and discounts.';

  @override
  String get notificationsSettingsSystemTitle => 'System Notifications';

  @override
  String get notificationsSettingsSystemSubtitle => 'Important alerts about your account and system.';

  @override
  String get notificationsSettingsConsentRequired => 'To enable notifications, you must grant basic data collection consent from privacy settings.';

  @override
  String get notificationsSettingsErrorGeneric => 'Unable to load notification settings. Please try again.';

  @override
  String get notificationsSettingsSystemSettingsButton => 'Open System Settings';

  @override
  String get notificationsSettingsSystemSettingsPlaceholder => 'System notification settings will be opened (placeholder)';

  @override
  String get notificationsSettingsTooltip => 'Notification settings';

  @override
  String get settingsSectionNotifications => 'Notification Settings';

  @override
  String get retry => 'Retry';

  @override
  String get back => 'Back';

  @override
  String get notificationsInboxTitle => 'Notifications';

  @override
  String get notificationsInboxErrorGeneric => 'Unable to load notifications. Please try again.';

  @override
  String get notificationsInboxRetryButtonLabel => 'Retry';

  @override
  String get notificationsInboxEmptyTitle => 'No notifications yet';

  @override
  String get notificationsInboxEmptySubtitle => 'Important alerts about your orders and offers will appear here.';

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
  String get notificationsInboxClearAllDialogMessage => 'Are you sure you want to delete all notifications? This action cannot be undone.';

  @override
  String get notificationsInboxClearAllConfirm => 'Clear All';

  @override
  String get notificationsInboxTappedGeneric => 'Notification opened';

  @override
  String get notificationsInboxTimeNow => 'now';

  @override
  String notificationsInboxTimeMinutes(Object minutes) {
    return '${minutes}m ago';
  }

  @override
  String notificationsInboxTimeHours(Object hours) {
    return '${hours}h ago';
  }

  @override
  String notificationsInboxTimeDays(Object days) {
    return '${days}d ago';
  }

  @override
  String get notificationsPromotionsTitle => 'Promotions';

  @override
  String get notificationsPromotionsEmptyTitle => 'No promotions yet';

  @override
  String get notificationsPromotionsEmptyDescription => 'You\'ll see personalized offers and campaigns here when they are available.';

  @override
  String get notificationsPromotionsErrorTitle => 'Unable to load promotions';

  @override
  String get notificationsPromotionsErrorDescription => 'Something went wrong while loading your promotional notifications. Please try again later.';

  @override
  String get notificationsSystemTitle => 'System notifications';

  @override
  String get notificationsSystemEmptyTitle => 'No system messages';

  @override
  String get notificationsSystemEmptyDescription => 'You don\'t have any system or policy updates at the moment.';

  @override
  String get notificationsSystemErrorTitle => 'Unable to load system notifications';

  @override
  String get notificationsSystemErrorDescription => 'Something went wrong while loading system notifications. Please try again later.';

  @override
  String get notificationsQuietHoursTitle => 'Quiet hours';

  @override
  String get notificationsQuietHoursDescription => 'Notifications will be muted during the selected time range.';

  @override
  String get notificationsQuietHoursInactive => 'Do Not Disturb is currently turned off.';

  @override
  String get notificationsQuietHoursEdit => 'Set quiet hours';

  @override
  String get notificationsQuietHoursEditActive => 'Edit quiet hours';

  @override
  String get notificationsQuietHoursDisable => 'Disable quiet hours';

  @override
  String get notificationsQuietHoursInvalidRange => 'Please pick different start and end times.';

  @override
  String get notificationsQuietHoursSaveError => 'Unable to update quiet hours. Try again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get authPhoneLoginTitle => 'Sign In';

  @override
  String get authPhoneLoginSubtitle => 'Enter your phone number to sign in or create a new account.';

  @override
  String get authPhoneFieldLabel => 'Phone Number';

  @override
  String get authPhoneFieldHint => '+9665xxxxxxxx';

  @override
  String get authPhoneContinueButton => 'Continue';

  @override
  String get authPhoneRequiredError => 'Please enter your phone number.';

  @override
  String get authPhoneInvalidFormatError => 'Please enter a valid phone number.';

  @override
  String get authPhoneSubmitError => 'Unable to send verification code. Please try again.';

  @override
  String get authOtpTitle => 'Verification Code';

  @override
  String authOtpSubtitle(Object phone) {
    return 'We sent a verification code to $phone';
  }

  @override
  String get authOtpFieldLabel => 'Verification Code';

  @override
  String get authOtpFieldHint => 'Enter code';

  @override
  String get authOtpConfirmButton => 'Verify';

  @override
  String get authOtpRequiredError => 'Please enter the verification code.';

  @override
  String get authOtpInvalidFormatError => 'Please enter a valid 4-6 digit code.';

  @override
  String get authOtpSubmitError => 'Invalid or expired verification code.';

  @override
  String get authOtpResendButton => 'Resend Code';

  @override
  String authOtpResendCountdown(Object seconds) {
    return 'Resend code in $seconds seconds';
  }
}

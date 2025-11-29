import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @notificationsSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationsSettingsTitle;

  /// No description provided for @notificationsSettingsOrderStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Status Notifications'**
  String get notificationsSettingsOrderStatusTitle;

  /// No description provided for @notificationsSettingsOrderStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive real-time updates about your active orders.'**
  String get notificationsSettingsOrderStatusSubtitle;

  /// No description provided for @notificationsSettingsPromotionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Promotional Offers'**
  String get notificationsSettingsPromotionsTitle;

  /// No description provided for @notificationsSettingsPromotionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive personalized offers and discounts.'**
  String get notificationsSettingsPromotionsSubtitle;

  /// No description provided for @notificationsSettingsSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'System Notifications'**
  String get notificationsSettingsSystemTitle;

  /// No description provided for @notificationsSettingsSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Important alerts about your account and system.'**
  String get notificationsSettingsSystemSubtitle;

  /// No description provided for @notificationsSettingsConsentRequired.
  ///
  /// In en, this message translates to:
  /// **'To enable notifications, you must grant basic data collection consent from privacy settings.'**
  String get notificationsSettingsConsentRequired;

  /// No description provided for @notificationsSettingsErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unable to load notification settings. Please try again.'**
  String get notificationsSettingsErrorGeneric;

  /// No description provided for @notificationsSettingsSystemSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Open System Settings'**
  String get notificationsSettingsSystemSettingsButton;

  /// No description provided for @notificationsSettingsSystemSettingsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'System notification settings will be opened (placeholder)'**
  String get notificationsSettingsSystemSettingsPlaceholder;

  /// No description provided for @notificationsSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationsSettingsTooltip;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get settingsSectionNotifications;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @notificationsInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsInboxTitle;

  /// No description provided for @notificationsInboxErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unable to load notifications. Please try again.'**
  String get notificationsInboxErrorGeneric;

  /// No description provided for @notificationsInboxRetryButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get notificationsInboxRetryButtonLabel;

  /// No description provided for @notificationsInboxEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsInboxEmptyTitle;

  /// No description provided for @notificationsInboxEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Important alerts about your orders and offers will appear here.'**
  String get notificationsInboxEmptySubtitle;

  /// No description provided for @notificationsInboxEmptyCtaBackToHomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get notificationsInboxEmptyCtaBackToHomeLabel;

  /// No description provided for @notificationsInboxMarkAsReadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get notificationsInboxMarkAsReadTooltip;

  /// No description provided for @notificationsInboxMarkAllAsReadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsInboxMarkAllAsReadTooltip;

  /// No description provided for @notificationsInboxClearAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get notificationsInboxClearAllTooltip;

  /// No description provided for @notificationsInboxClearAllDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Notifications'**
  String get notificationsInboxClearAllDialogTitle;

  /// No description provided for @notificationsInboxClearAllDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all notifications? This action cannot be undone.'**
  String get notificationsInboxClearAllDialogMessage;

  /// No description provided for @notificationsInboxClearAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get notificationsInboxClearAllConfirm;

  /// No description provided for @notificationsInboxTappedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Notification opened'**
  String get notificationsInboxTappedGeneric;

  /// No description provided for @notificationsInboxTimeNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get notificationsInboxTimeNow;

  /// No description provided for @notificationsInboxTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String notificationsInboxTimeMinutes(Object minutes);

  /// No description provided for @notificationsInboxTimeHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String notificationsInboxTimeHours(Object hours);

  /// No description provided for @notificationsInboxTimeDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String notificationsInboxTimeDays(Object days);

  /// No description provided for @notificationsPromotionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get notificationsPromotionsTitle;

  /// No description provided for @notificationsPromotionsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No promotions yet'**
  String get notificationsPromotionsEmptyTitle;

  /// No description provided for @notificationsPromotionsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see personalized offers and campaigns here when they are available.'**
  String get notificationsPromotionsEmptyDescription;

  /// No description provided for @notificationsPromotionsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load promotions'**
  String get notificationsPromotionsErrorTitle;

  /// No description provided for @notificationsPromotionsErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading your promotional notifications. Please try again later.'**
  String get notificationsPromotionsErrorDescription;

  /// No description provided for @notificationsSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'System notifications'**
  String get notificationsSystemTitle;

  /// No description provided for @notificationsSystemEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No system messages'**
  String get notificationsSystemEmptyTitle;

  /// No description provided for @notificationsSystemEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any system or policy updates at the moment.'**
  String get notificationsSystemEmptyDescription;

  /// No description provided for @notificationsSystemErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load system notifications'**
  String get notificationsSystemErrorTitle;

  /// No description provided for @notificationsSystemErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading system notifications. Please try again later.'**
  String get notificationsSystemErrorDescription;

  /// No description provided for @notificationsQuietHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get notificationsQuietHoursTitle;

  /// No description provided for @notificationsQuietHoursDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifications will be muted during the selected time range.'**
  String get notificationsQuietHoursDescription;

  /// No description provided for @notificationsQuietHoursInactive.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb is currently turned off.'**
  String get notificationsQuietHoursInactive;

  /// No description provided for @notificationsQuietHoursEdit.
  ///
  /// In en, this message translates to:
  /// **'Set quiet hours'**
  String get notificationsQuietHoursEdit;

  /// No description provided for @notificationsQuietHoursEditActive.
  ///
  /// In en, this message translates to:
  /// **'Edit quiet hours'**
  String get notificationsQuietHoursEditActive;

  /// No description provided for @notificationsQuietHoursDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable quiet hours'**
  String get notificationsQuietHoursDisable;

  /// No description provided for @notificationsQuietHoursInvalidRange.
  ///
  /// In en, this message translates to:
  /// **'Please pick different start and end times.'**
  String get notificationsQuietHoursInvalidRange;

  /// No description provided for @notificationsQuietHoursSaveError.
  ///
  /// In en, this message translates to:
  /// **'Unable to update quiet hours. Try again.'**
  String get notificationsQuietHoursSaveError;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @authPhoneLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authPhoneLoginTitle;

  /// No description provided for @authPhoneLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to sign in or create a new account.'**
  String get authPhoneLoginSubtitle;

  /// No description provided for @authPhoneFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneFieldLabel;

  /// No description provided for @authPhoneFieldHint.
  ///
  /// In en, this message translates to:
  /// **'+9665xxxxxxxx'**
  String get authPhoneFieldHint;

  /// No description provided for @authPhoneContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authPhoneContinueButton;

  /// No description provided for @authPhoneRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number.'**
  String get authPhoneRequiredError;

  /// No description provided for @authPhoneInvalidFormatError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number.'**
  String get authPhoneInvalidFormatError;

  /// No description provided for @authPhoneSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Unable to send verification code. Please try again.'**
  String get authPhoneSubmitError;

  /// No description provided for @authOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get authOtpTitle;

  /// No description provided for @authOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to {phone}'**
  String authOtpSubtitle(Object phone);

  /// No description provided for @authOtpFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get authOtpFieldLabel;

  /// No description provided for @authOtpFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get authOtpFieldHint;

  /// No description provided for @authOtpConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authOtpConfirmButton;

  /// No description provided for @authOtpRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code.'**
  String get authOtpRequiredError;

  /// No description provided for @authOtpInvalidFormatError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 4-6 digit code.'**
  String get authOtpInvalidFormatError;

  /// No description provided for @authOtpSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired verification code.'**
  String get authOtpSubmitError;

  /// No description provided for @authOtpResendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get authOtpResendButton;

  /// No description provided for @authOtpResendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds} seconds'**
  String authOtpResendCountdown(Object seconds);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

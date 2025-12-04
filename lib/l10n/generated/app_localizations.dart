import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Delivery Ways'**
  String get appTitle;

  /// Title for phone sign-in screen (Ticket #36)
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authPhoneTitle;

  /// Subtitle for phone sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number to sign in to Delivery Ways.'**
  String get authPhoneSubtitle;

  /// Hint text for phone number field
  ///
  /// In en, this message translates to:
  /// **'+9665xxxxxxxx'**
  String get authPhoneFieldHint;

  /// Continue button on phone sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authPhoneContinueCta;

  /// Title for OTP verification screen (Ticket #36)
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get authOtpTitle;

  /// Subtitle for OTP verification screen
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification code to your phone.'**
  String get authOtpSubtitle;

  /// Hint text for OTP code field
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get authOtpFieldHint;

  /// Verify button on OTP screen
  ///
  /// In en, this message translates to:
  /// **'Verify and continue'**
  String get authOtpVerifyCta;

  /// Title for account bottom sheet (Ticket #37)
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSheetTitle;

  /// Subtitle when user is not signed in
  ///
  /// In en, this message translates to:
  /// **'You are not signed in. Sign in to sync your rides and deliveries.'**
  String get accountSheetSignedOutSubtitle;

  /// Sign in button in account sheet
  ///
  /// In en, this message translates to:
  /// **'Sign in with phone'**
  String get accountSheetSignInCta;

  /// Title when user is signed in
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get accountSheetSignedInTitle;

  /// Sign out button in account sheet
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSheetSignOutCta;

  /// Footer text in account sheet
  ///
  /// In en, this message translates to:
  /// **'More account options coming soon.'**
  String get accountSheetFooterText;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

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

  /// No description provided for @authOtpFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get authOtpFieldLabel;

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
  String authOtpResendCountdown(int seconds);

  /// No description provided for @authBiometricButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get authBiometricButtonLabel;

  /// No description provided for @authBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to continue.'**
  String get authBiometricReason;

  /// No description provided for @authBiometricUnlockError.
  ///
  /// In en, this message translates to:
  /// **'Unable to unlock with biometrics. Please request a new code.'**
  String get authBiometricUnlockError;

  /// No description provided for @authCooldownMessage.
  ///
  /// In en, this message translates to:
  /// **'Please wait {seconds}s before trying again.'**
  String authCooldownMessage(int seconds);

  /// No description provided for @authCooldownReady.
  ///
  /// In en, this message translates to:
  /// **'You can resend now.'**
  String get authCooldownReady;

  /// No description provided for @authAttemptsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} attempts remaining'**
  String authAttemptsRemaining(int count);

  /// No description provided for @authNoAttemptsRemaining.
  ///
  /// In en, this message translates to:
  /// **'No attempts remaining.'**
  String get authNoAttemptsRemaining;

  /// No description provided for @auth2faTitle.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get auth2faTitle;

  /// No description provided for @auth2faSubtitle.
  ///
  /// In en, this message translates to:
  /// **'An additional verification step is required for your security.'**
  String get auth2faSubtitle;

  /// No description provided for @auth2faSelectMethod.
  ///
  /// In en, this message translates to:
  /// **'Select verification method'**
  String get auth2faSelectMethod;

  /// No description provided for @auth2faMethodSms.
  ///
  /// In en, this message translates to:
  /// **'Text Message (SMS)'**
  String get auth2faMethodSms;

  /// No description provided for @auth2faMethodSmsDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive a code via SMS to {destination}'**
  String auth2faMethodSmsDescription(String destination);

  /// No description provided for @auth2faMethodTotp.
  ///
  /// In en, this message translates to:
  /// **'Authenticator App'**
  String get auth2faMethodTotp;

  /// No description provided for @auth2faMethodTotpDescription.
  ///
  /// In en, this message translates to:
  /// **'Use your authenticator app to generate a code'**
  String get auth2faMethodTotpDescription;

  /// No description provided for @auth2faMethodEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth2faMethodEmail;

  /// No description provided for @auth2faMethodEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive a code via email to {destination}'**
  String auth2faMethodEmailDescription(String destination);

  /// No description provided for @auth2faMethodPush.
  ///
  /// In en, this message translates to:
  /// **'Push Notification'**
  String get auth2faMethodPush;

  /// No description provided for @auth2faMethodPushDescription.
  ///
  /// In en, this message translates to:
  /// **'Approve the request on your registered device'**
  String get auth2faMethodPushDescription;

  /// No description provided for @auth2faEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get auth2faEnterCode;

  /// No description provided for @auth2faCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get auth2faCodeHint;

  /// No description provided for @auth2faVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get auth2faVerifyButton;

  /// No description provided for @auth2faCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get auth2faCancelButton;

  /// No description provided for @auth2faResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get auth2faResendCode;

  /// No description provided for @auth2faCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired. Please request a new one.'**
  String get auth2faCodeExpired;

  /// No description provided for @auth2faInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please try again.'**
  String get auth2faInvalidCode;

  /// No description provided for @auth2faAccountLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Account temporarily locked.'**
  String get auth2faAccountLocked;

  /// No description provided for @auth2faLockoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Please try again after {minutes} minutes.'**
  String auth2faLockoutMessage(int minutes);

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
  /// **'Grant notification permission to enable these settings.'**
  String get notificationsSettingsConsentRequired;

  /// No description provided for @notificationsSettingsErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unable to load notification settings. Please try again.'**
  String get notificationsSettingsErrorGeneric;

  /// No description provided for @notificationsSettingsErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading notification settings'**
  String get notificationsSettingsErrorLoading;

  /// No description provided for @notificationsSettingsSystemSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Open System Settings'**
  String get notificationsSettingsSystemSettingsButton;

  /// No description provided for @notificationsSettingsSystemSettingsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'System settings will open soon'**
  String get notificationsSettingsSystemSettingsPlaceholder;

  /// No description provided for @notificationsSettingsQuietHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiet Hours'**
  String get notificationsSettingsQuietHoursTitle;

  /// No description provided for @notificationsSettingsQuietHoursNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb mode not enabled'**
  String get notificationsSettingsQuietHoursNotEnabled;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get settingsSectionNotifications;

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
  String notificationsInboxTimeMinutes(int minutes);

  /// No description provided for @notificationsInboxTimeHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String notificationsInboxTimeHours(int hours);

  /// No description provided for @notificationsInboxTimeDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String notificationsInboxTimeDays(int days);

  /// No description provided for @privacyConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Consent'**
  String get privacyConsentTitle;

  /// No description provided for @privacyConsentHeadline.
  ///
  /// In en, this message translates to:
  /// **'Control your privacy'**
  String get privacyConsentHeadline;

  /// No description provided for @privacyConsentDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose what to share with us to improve your experience'**
  String get privacyConsentDescription;

  /// No description provided for @privacyConsentAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage Analytics'**
  String get privacyConsentAnalyticsTitle;

  /// No description provided for @privacyConsentAnalyticsDescription.
  ///
  /// In en, this message translates to:
  /// **'Helps us understand how the app is used to improve performance and features'**
  String get privacyConsentAnalyticsDescription;

  /// No description provided for @privacyConsentCrashReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Crash Reports'**
  String get privacyConsentCrashReportsTitle;

  /// No description provided for @privacyConsentCrashReportsDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically sends crash reports to help us fix issues'**
  String get privacyConsentCrashReportsDescription;

  /// No description provided for @privacyConsentBackgroundLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Background Location'**
  String get privacyConsentBackgroundLocationTitle;

  /// No description provided for @privacyConsentBackgroundLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Allows location tracking even when the app is closed to improve delivery services'**
  String get privacyConsentBackgroundLocationDescription;

  /// No description provided for @privacyConsentSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings saved'**
  String get privacyConsentSaveSuccess;

  /// No description provided for @privacyConsentErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String privacyConsentErrorPrefix(String message);

  /// No description provided for @dsrExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get dsrExportTitle;

  /// No description provided for @dsrExportHeadline.
  ///
  /// In en, this message translates to:
  /// **'Export your personal data'**
  String get dsrExportHeadline;

  /// No description provided for @dsrExportDescription.
  ///
  /// In en, this message translates to:
  /// **'You will receive a secure link to download all your data. The link is valid for 7 days only.'**
  String get dsrExportDescription;

  /// No description provided for @dsrExportIncludePaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Include payment history'**
  String get dsrExportIncludePaymentsTitle;

  /// No description provided for @dsrExportIncludePaymentsDescription.
  ///
  /// In en, this message translates to:
  /// **'Payment history may contain sensitive information. Please review the file carefully.'**
  String get dsrExportIncludePaymentsDescription;

  /// No description provided for @dsrExportStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start Export'**
  String get dsrExportStartButton;

  /// No description provided for @dsrExportRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get dsrExportRequestStatus;

  /// No description provided for @dsrExportRequestDate.
  ///
  /// In en, this message translates to:
  /// **'Request date: {date}'**
  String dsrExportRequestDate(String date);

  /// No description provided for @dsrExportDownloadLink.
  ///
  /// In en, this message translates to:
  /// **'Download Link'**
  String get dsrExportDownloadLink;

  /// No description provided for @dsrExportLinkExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String dsrExportLinkExpires(String date);

  /// No description provided for @dsrExportCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get dsrExportCopyLink;

  /// No description provided for @dsrExportLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get dsrExportLinkCopied;

  /// No description provided for @dsrExportPreparingFile.
  ///
  /// In en, this message translates to:
  /// **'Preparing your file…'**
  String get dsrExportPreparingFile;

  /// No description provided for @dsrExportSendingRequest.
  ///
  /// In en, this message translates to:
  /// **'Sending export request…'**
  String get dsrExportSendingRequest;

  /// No description provided for @dsrExportRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send request'**
  String get dsrExportRequestFailed;

  /// No description provided for @dsrErasureTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get dsrErasureTitle;

  /// No description provided for @dsrErasureHeadline.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get dsrErasureHeadline;

  /// No description provided for @dsrErasureDescription.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data and account information will be deleted.'**
  String get dsrErasureDescription;

  /// No description provided for @dsrErasureRequestButton.
  ///
  /// In en, this message translates to:
  /// **'Request Account Deletion'**
  String get dsrErasureRequestButton;

  /// No description provided for @dsrErasureWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Important Warning'**
  String get dsrErasureWarningTitle;

  /// No description provided for @dsrErasureWarningPoint1.
  ///
  /// In en, this message translates to:
  /// **'All your personal data will be permanently deleted'**
  String get dsrErasureWarningPoint1;

  /// No description provided for @dsrErasureWarningPoint2.
  ///
  /// In en, this message translates to:
  /// **'You will not be able to recover your account or data'**
  String get dsrErasureWarningPoint2;

  /// No description provided for @dsrErasureWarningPoint3.
  ///
  /// In en, this message translates to:
  /// **'All active orders and reservations will be cancelled'**
  String get dsrErasureWarningPoint3;

  /// No description provided for @dsrErasureWarningPoint4.
  ///
  /// In en, this message translates to:
  /// **'Your payment and transaction history will be deleted'**
  String get dsrErasureWarningPoint4;

  /// No description provided for @dsrErasureWarningPoint5.
  ///
  /// In en, this message translates to:
  /// **'The request may take several days to process'**
  String get dsrErasureWarningPoint5;

  /// No description provided for @dsrErasureLegalNotice.
  ///
  /// In en, this message translates to:
  /// **'Account deletion is subject to the General Data Protection Regulation (GDPR). We will send you confirmation before executing the final deletion.'**
  String get dsrErasureLegalNotice;

  /// No description provided for @dsrErasureRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get dsrErasureRequestStatus;

  /// No description provided for @dsrErasureStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get dsrErasureStatusPending;

  /// No description provided for @dsrErasureStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get dsrErasureStatusInProgress;

  /// No description provided for @dsrErasureStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready for confirmation'**
  String get dsrErasureStatusReady;

  /// No description provided for @dsrErasureStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get dsrErasureStatusCompleted;

  /// No description provided for @dsrErasureStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Processing failed'**
  String get dsrErasureStatusFailed;

  /// No description provided for @dsrErasureStatusCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get dsrErasureStatusCanceled;

  /// No description provided for @dsrErasureReviewingRequest.
  ///
  /// In en, this message translates to:
  /// **'Reviewing your request…'**
  String get dsrErasureReviewingRequest;

  /// No description provided for @dsrErasureSendingRequest.
  ///
  /// In en, this message translates to:
  /// **'Sending deletion request…'**
  String get dsrErasureSendingRequest;

  /// No description provided for @dsrErasureRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send request'**
  String get dsrErasureRequestFailed;

  /// No description provided for @dsrErasureNewRequest.
  ///
  /// In en, this message translates to:
  /// **'Request New Deletion'**
  String get dsrErasureNewRequest;

  /// No description provided for @dsrErasureConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Final Deletion'**
  String get dsrErasureConfirmTitle;

  /// No description provided for @dsrErasureConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This is the final step. After confirmation, your account will be permanently deleted within 30 days and this decision cannot be reversed.'**
  String get dsrErasureConfirmMessage;

  /// No description provided for @dsrErasureConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get dsrErasureConfirmButton;

  /// No description provided for @legalPrivacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyPolicyTitle;

  /// No description provided for @legalPrivacyPolicyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy is not available at this time.'**
  String get legalPrivacyPolicyUnavailable;

  /// No description provided for @legalTermsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTermsOfServiceTitle;

  /// No description provided for @legalTermsOfServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Terms of service are not available at this time.'**
  String get legalTermsOfServiceUnavailable;

  /// No description provided for @legalAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Information'**
  String get legalAboutTitle;

  /// No description provided for @legalPrivacyButton.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyButton;

  /// No description provided for @legalTermsButton.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTermsButton;

  /// No description provided for @legalOpenSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get legalOpenSourceLicenses;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order: {orderId}'**
  String ordersOrderLabel(String orderId);

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @cartItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Items: {count}'**
  String cartItemsLabel(int count);

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentTitle;

  /// No description provided for @paymentInitializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing payment system...'**
  String get paymentInitializing;

  /// No description provided for @paymentDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments Debug'**
  String get paymentDebugTitle;

  /// No description provided for @paymentEnabled.
  ///
  /// In en, this message translates to:
  /// **'Payments enabled: {enabled}'**
  String paymentEnabled(String enabled);

  /// No description provided for @paymentMissingKeys.
  ///
  /// In en, this message translates to:
  /// **'Missing config keys: {keys}'**
  String paymentMissingKeys(String keys);

  /// No description provided for @paymentGatewayStatus.
  ///
  /// In en, this message translates to:
  /// **'Gateway status: {status}'**
  String paymentGatewayStatus(String status);

  /// No description provided for @paymentGateway.
  ///
  /// In en, this message translates to:
  /// **'Gateway: {type}'**
  String paymentGateway(String type);

  /// No description provided for @paymentSheetStatus.
  ///
  /// In en, this message translates to:
  /// **'Sheet status: {status}'**
  String paymentSheetStatus(String status);

  /// No description provided for @paymentSheet.
  ///
  /// In en, this message translates to:
  /// **'Sheet: {type}'**
  String paymentSheet(String type);

  /// No description provided for @paymentApplePay.
  ///
  /// In en, this message translates to:
  /// **'Pay with Apple Pay'**
  String get paymentApplePay;

  /// No description provided for @paymentGooglePay.
  ///
  /// In en, this message translates to:
  /// **'Pay with Google Pay'**
  String get paymentGooglePay;

  /// No description provided for @paymentDigitalWallet.
  ///
  /// In en, this message translates to:
  /// **'Pay with Digital Wallet'**
  String get paymentDigitalWallet;

  /// No description provided for @paymentCash.
  ///
  /// In en, this message translates to:
  /// **'Pay with Cash'**
  String get paymentCash;

  /// No description provided for @trackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get trackingTitle;

  /// No description provided for @trackingLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Tracking'**
  String get trackingLocationTitle;

  /// No description provided for @trackingCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get trackingCurrentLocation;

  /// No description provided for @trackingTripRoute.
  ///
  /// In en, this message translates to:
  /// **'Trip Route'**
  String get trackingTripRoute;

  /// No description provided for @trackingRealtimeUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking Unavailable'**
  String get trackingRealtimeUnavailableTitle;

  /// No description provided for @trackingRealtimeUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Real-time tracking is currently unavailable. Your order status will be updated automatically.'**
  String get trackingRealtimeUnavailableBody;

  /// No description provided for @trackingOrderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get trackingOrderStatus;

  /// No description provided for @trackingNoActiveTrip.
  ///
  /// In en, this message translates to:
  /// **'No active trip'**
  String get trackingNoActiveTrip;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// No description provided for @mapSmokeTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Maps Smoke Test'**
  String get mapSmokeTestTitle;

  /// No description provided for @mapTestLocation.
  ///
  /// In en, this message translates to:
  /// **'Test Location'**
  String get mapTestLocation;

  /// No description provided for @mobilityBgTestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobility Background Tests (Phase-3)'**
  String get mobilityBgTestsTitle;

  /// No description provided for @mobilityTestBackgroundTracking.
  ///
  /// In en, this message translates to:
  /// **'Test Background Tracking'**
  String get mobilityTestBackgroundTracking;

  /// No description provided for @mobilityTestGeofence.
  ///
  /// In en, this message translates to:
  /// **'Test Geofence'**
  String get mobilityTestGeofence;

  /// No description provided for @mobilityTestTripRecording.
  ///
  /// In en, this message translates to:
  /// **'Test Trip Recording'**
  String get mobilityTestTripRecording;

  /// No description provided for @adminPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanelTitle;

  /// No description provided for @adminUserInfo.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get adminUserInfo;

  /// No description provided for @adminUserLabel.
  ///
  /// In en, this message translates to:
  /// **'User: {userId}'**
  String adminUserLabel(String userId);

  /// No description provided for @adminRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String adminRoleLabel(String role);

  /// No description provided for @adminUserManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get adminUserManagement;

  /// No description provided for @adminAnalyticsReports.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Reports'**
  String get adminAnalyticsReports;

  /// No description provided for @adminAnalyticsAccess.
  ///
  /// In en, this message translates to:
  /// **'You have access to analytics'**
  String get adminAnalyticsAccess;

  /// No description provided for @adminSystemMonitoring.
  ///
  /// In en, this message translates to:
  /// **'System Monitoring'**
  String get adminSystemMonitoring;

  /// No description provided for @adminRbacStats.
  ///
  /// In en, this message translates to:
  /// **'RBAC Statistics'**
  String get adminRbacStats;

  /// No description provided for @adminRbacEnabled.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String adminRbacEnabled(String status);

  /// No description provided for @adminRbacStatusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get adminRbacStatusEnabled;

  /// No description provided for @adminRbacStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get adminRbacStatusDisabled;

  /// No description provided for @adminCanaryPercentage.
  ///
  /// In en, this message translates to:
  /// **'Canary percentage: {percentage}%'**
  String adminCanaryPercentage(int percentage);

  /// No description provided for @adminRolesCount.
  ///
  /// In en, this message translates to:
  /// **'Roles count: {count}'**
  String adminRolesCount(int count);

  /// No description provided for @adminTotalPermissions.
  ///
  /// In en, this message translates to:
  /// **'Total permissions: {count}'**
  String adminTotalPermissions(int count);

  /// No description provided for @trackingCheckingAvailability.
  ///
  /// In en, this message translates to:
  /// **'Checking tracking availability...'**
  String get trackingCheckingAvailability;

  /// No description provided for @trackingLoadingRoute.
  ///
  /// In en, this message translates to:
  /// **'Loading route...'**
  String get trackingLoadingRoute;

  /// AppBar title for the orders history screen (Track C - Ticket #51)
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get ordersHistoryTitle;

  /// Empty state title when no orders exist
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersHistoryEmptyTitle;

  /// Empty state subtitle when no orders exist
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any orders yet. Start by creating a new shipment.'**
  String get ordersHistoryEmptySubtitle;

  /// No description provided for @ordersHistoryUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders Unavailable'**
  String get ordersHistoryUnavailableTitle;

  /// No description provided for @ordersHistoryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load order history'**
  String get ordersHistoryLoadError;

  /// Filter label for all orders (Track C - Ticket #51)
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ordersFilterAll;

  /// Filter label for parcels only (Track C - Ticket #51)
  ///
  /// In en, this message translates to:
  /// **'Parcels'**
  String get ordersFilterParcels;

  /// Filter label for rides only (Track B - Ticket #96)
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get ordersFilterRides;

  /// Section title for rides in My Orders screen (Track B - Ticket #96)
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get ordersSectionRidesTitle;

  /// Title for ride order item (Track B - Ticket #96)
  ///
  /// In en, this message translates to:
  /// **'Ride to {destination}'**
  String ordersRideItemTitleToDestination(String destination);

  /// Title for ride order item with service name (Track B - Ticket #108)
  ///
  /// In en, this message translates to:
  /// **'{serviceName} to {destination}'**
  String ordersRideItemTitleWithService(String serviceName, String destination);

  /// Subtitle for ride order item with origin (Track B - Ticket #108)
  ///
  /// In en, this message translates to:
  /// **'From {origin} · {date}'**
  String ordersRideItemSubtitleWithOrigin(String origin, String date);

  /// Ride order status: completed (Track B - Ticket #96)
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ordersRideStatusCompleted;

  /// Ride order status: cancelled (Track B - Ticket #96)
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersRideStatusCancelled;

  /// Ride order status: failed (Track B - Ticket #96)
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get ordersRideStatusFailed;

  /// No description provided for @paymentMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethodsTitle;

  /// No description provided for @paymentMethodsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payment methods'**
  String get paymentMethodsEmptyTitle;

  /// No description provided for @paymentMethodsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a payment method to get started'**
  String get paymentMethodsEmptySubtitle;

  /// No description provided for @paymentMethodsAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add payment method'**
  String get paymentMethodsAddButton;

  /// No description provided for @paymentMethodsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load payment methods'**
  String get paymentMethodsLoadError;

  /// No description provided for @paymentMethodsSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get paymentMethodsSaving;

  /// No description provided for @authVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get authVerifying;

  /// No description provided for @authSendingCode.
  ///
  /// In en, this message translates to:
  /// **'Sending code...'**
  String get authSendingCode;

  /// No description provided for @featureUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Feature Unavailable'**
  String get featureUnavailableTitle;

  /// No description provided for @featureUnavailableGeneric.
  ///
  /// In en, this message translates to:
  /// **'This feature is currently unavailable. Please try again later.'**
  String get featureUnavailableGeneric;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Delivery Ways'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your reliable delivery partner. Order what you need and track your delivery in real-time.'**
  String get onbWelcomeBody;

  /// No description provided for @onbAppIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get onbAppIntroTitle;

  /// No description provided for @onbAppIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Browse products, place your order, and we\'ll deliver it to your door. Simple and fast.'**
  String get onbAppIntroBody;

  /// No description provided for @onbOrderingTitle.
  ///
  /// In en, this message translates to:
  /// **'Easy Ordering'**
  String get onbOrderingTitle;

  /// No description provided for @onbOrderingBody.
  ///
  /// In en, this message translates to:
  /// **'Find what you need, add to cart, and checkout in seconds. Multiple payment options available where supported.'**
  String get onbOrderingBody;

  /// No description provided for @onbTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Your Order'**
  String get onbTrackingTitle;

  /// No description provided for @onbTrackingBody.
  ///
  /// In en, this message translates to:
  /// **'Follow your delivery in real-time when tracking is available in your area. You\'ll see updates at every step.'**
  String get onbTrackingBody;

  /// No description provided for @onbSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Security Matters'**
  String get onbSecurityTitle;

  /// No description provided for @onbSecurityBody.
  ///
  /// In en, this message translates to:
  /// **'Your data is protected with industry-standard security. We never share your personal information without consent.'**
  String get onbSecurityBody;

  /// No description provided for @onbNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Updated'**
  String get onbNotificationsTitle;

  /// No description provided for @onbNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications to receive order updates, delivery alerts, and exclusive offers.'**
  String get onbNotificationsBody;

  /// No description provided for @onbReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set!'**
  String get onbReadyTitle;

  /// No description provided for @onbReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Start exploring and place your first order. We\'re here to help whenever you need us.'**
  String get onbReadyBody;

  /// No description provided for @onbRideTitle.
  ///
  /// In en, this message translates to:
  /// **'Get a Ride, Instantly.'**
  String get onbRideTitle;

  /// No description provided for @onbRideBody.
  ///
  /// In en, this message translates to:
  /// **'Tap, ride, and arrive. Fast, reliable, and affordable transport at your fingertips.'**
  String get onbRideBody;

  /// No description provided for @onbParcelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deliver Anything, Effortlessly.'**
  String get onbParcelsTitle;

  /// No description provided for @onbParcelsBody.
  ///
  /// In en, this message translates to:
  /// **'Send packages across town or across the country. Track every step of the journey.'**
  String get onbParcelsBody;

  /// No description provided for @onbFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Favorite Food, Delivered.'**
  String get onbFoodTitle;

  /// No description provided for @onbFoodBody.
  ///
  /// In en, this message translates to:
  /// **'Craving something delicious? Order from top restaurants and enjoy fast delivery to your door.'**
  String get onbFoodBody;

  /// No description provided for @onbRiderWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Rider!'**
  String get onbRiderWelcomeTitle;

  /// No description provided for @onbRiderWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Join our delivery network and start earning. Flexible hours, fair compensation.'**
  String get onbRiderWelcomeBody;

  /// No description provided for @onbRiderHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Journey Starts Here'**
  String get onbRiderHowItWorksTitle;

  /// No description provided for @onbRiderHowItWorksBody.
  ///
  /// In en, this message translates to:
  /// **'Accept deliveries, navigate to pickup, deliver to customers. Track your earnings in the app.'**
  String get onbRiderHowItWorksBody;

  /// No description provided for @onbRiderLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get onbRiderLocationTitle;

  /// No description provided for @onbRiderLocationBody.
  ///
  /// In en, this message translates to:
  /// **'We use your location to match you with nearby deliveries and provide navigation. Your location is only shared during active deliveries.'**
  String get onbRiderLocationBody;

  /// No description provided for @onbRiderSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe & Secure'**
  String get onbRiderSecurityTitle;

  /// No description provided for @onbRiderSecurityBody.
  ///
  /// In en, this message translates to:
  /// **'Your earnings and personal data are protected. Multi-factor authentication keeps your account safe.'**
  String get onbRiderSecurityBody;

  /// No description provided for @onbRiderNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Never Miss a Delivery'**
  String get onbRiderNotificationsTitle;

  /// No description provided for @onbRiderNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Get instant alerts for new delivery requests and important updates.'**
  String get onbRiderNotificationsBody;

  /// No description provided for @onbRiderReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to Deliver!'**
  String get onbRiderReadyTitle;

  /// No description provided for @onbRiderReadyBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re set up and ready to go. Start accepting deliveries now.'**
  String get onbRiderReadyBody;

  /// No description provided for @onbCtaGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onbCtaGetStarted;

  /// No description provided for @onbCtaNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbCtaNext;

  /// No description provided for @onbCtaSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbCtaSkip;

  /// No description provided for @onbCtaEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get onbCtaEnableNotifications;

  /// No description provided for @onbCtaEnableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get onbCtaEnableLocation;

  /// No description provided for @onbCtaStartOrdering.
  ///
  /// In en, this message translates to:
  /// **'Start Ordering'**
  String get onbCtaStartOrdering;

  /// No description provided for @onbCtaStartDelivering.
  ///
  /// In en, this message translates to:
  /// **'Start Delivering'**
  String get onbCtaStartDelivering;

  /// No description provided for @onbCtaMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get onbCtaMaybeLater;

  /// No description provided for @onbCtaDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get onbCtaDone;

  /// No description provided for @onbCtaBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onbCtaBack;

  /// No description provided for @hintAuthPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Sign-In'**
  String get hintAuthPhoneTitle;

  /// No description provided for @hintAuthPhoneBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a verification code to this number. Your phone number helps us keep your account secure.'**
  String get hintAuthPhoneBody;

  /// No description provided for @hintAuthOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Check Your Messages'**
  String get hintAuthOtpTitle;

  /// No description provided for @hintAuthOtpBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent to your phone. This verifies that it\'s really you.'**
  String get hintAuthOtpBody;

  /// No description provided for @hintAuth2faTitle.
  ///
  /// In en, this message translates to:
  /// **'Extra Protection'**
  String get hintAuth2faTitle;

  /// No description provided for @hintAuth2faBody.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication adds an extra layer of security to your account.'**
  String get hintAuth2faBody;

  /// No description provided for @hintAuthBiometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get hintAuthBiometricTitle;

  /// No description provided for @hintAuthBiometricBody.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint or face to sign in faster while keeping your account secure.'**
  String get hintAuthBiometricBody;

  /// No description provided for @hintPaymentsMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Options'**
  String get hintPaymentsMethodsTitle;

  /// No description provided for @hintPaymentsMethodsBody.
  ///
  /// In en, this message translates to:
  /// **'Add a payment method to speed up checkout. Your payment information is securely encrypted.'**
  String get hintPaymentsMethodsBody;

  /// No description provided for @hintPaymentsSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Payment'**
  String get hintPaymentsSecurityTitle;

  /// No description provided for @hintPaymentsSecurityBody.
  ///
  /// In en, this message translates to:
  /// **'Your card details are encrypted and never stored on our servers. Payments are processed by trusted providers.'**
  String get hintPaymentsSecurityBody;

  /// No description provided for @hintPaymentsLimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Limited Payment Options'**
  String get hintPaymentsLimitedTitle;

  /// No description provided for @hintPaymentsLimitedBody.
  ///
  /// In en, this message translates to:
  /// **'Some payment methods may not be available in your region. Cash on delivery is available where supported.'**
  String get hintPaymentsLimitedBody;

  /// No description provided for @hintTrackingExplanationTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get hintTrackingExplanationTitle;

  /// No description provided for @hintTrackingExplanationBody.
  ///
  /// In en, this message translates to:
  /// **'Watch your order\'s journey from pickup to delivery on the map.'**
  String get hintTrackingExplanationBody;

  /// No description provided for @hintTrackingUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking Not Available'**
  String get hintTrackingUnavailableTitle;

  /// No description provided for @hintTrackingUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Real-time tracking is not available for this order. You\'ll receive status updates via notifications.'**
  String get hintTrackingUnavailableBody;

  /// No description provided for @hintTrackingRealtimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Real-Time Updates'**
  String get hintTrackingRealtimeTitle;

  /// No description provided for @hintTrackingRealtimeBody.
  ///
  /// In en, this message translates to:
  /// **'The map updates automatically as your delivery progresses.'**
  String get hintTrackingRealtimeBody;

  /// No description provided for @hintNotificationsImportanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Why Notifications Matter'**
  String get hintNotificationsImportanceTitle;

  /// No description provided for @hintNotificationsImportanceBody.
  ///
  /// In en, this message translates to:
  /// **'Get instant updates about your order status, delivery arrival, and special offers.'**
  String get hintNotificationsImportanceBody;

  /// No description provided for @hintNotificationsPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get hintNotificationsPermissionTitle;

  /// No description provided for @hintNotificationsPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'To receive order updates and delivery alerts, please enable notifications.'**
  String get hintNotificationsPermissionBody;

  /// No description provided for @hintNotificationsPermissionCta.
  ///
  /// In en, this message translates to:
  /// **'Enable Now'**
  String get hintNotificationsPermissionCta;

  /// No description provided for @hintOrdersFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Your First Order'**
  String get hintOrdersFirstTitle;

  /// No description provided for @hintOrdersFirstBody.
  ///
  /// In en, this message translates to:
  /// **'Congratulations on your first order! Track its progress here.'**
  String get hintOrdersFirstBody;

  /// No description provided for @hintOrdersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Orders Yet'**
  String get hintOrdersEmptyTitle;

  /// No description provided for @hintOrdersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Start browsing and place your first order. Your order history will appear here.'**
  String get hintOrdersEmptyBody;

  /// No description provided for @hintOrdersEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Browse Now'**
  String get hintOrdersEmptyCta;

  /// No description provided for @settingsReplayOnboarding.
  ///
  /// In en, this message translates to:
  /// **'View App Introduction'**
  String get settingsReplayOnboarding;

  /// No description provided for @settingsReplayOnboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'See the welcome guide again'**
  String get settingsReplayOnboardingDescription;

  /// No description provided for @rideBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Book a Ride'**
  String get rideBookingTitle;

  /// No description provided for @rideBookingMapStubLabel.
  ///
  /// In en, this message translates to:
  /// **'Map preview (stub – Ride Booking)'**
  String get rideBookingMapStubLabel;

  /// No description provided for @rideBookingSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to go?'**
  String get rideBookingSheetTitle;

  /// No description provided for @rideBookingSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your pickup point and destination to see options and pricing.'**
  String get rideBookingSheetSubtitle;

  /// No description provided for @rideBookingPickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get rideBookingPickupLabel;

  /// No description provided for @rideBookingPickupCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get rideBookingPickupCurrentLocation;

  /// No description provided for @rideBookingDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get rideBookingDestinationLabel;

  /// No description provided for @rideBookingDestinationHint.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get rideBookingDestinationHint;

  /// No description provided for @rideBookingRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent places'**
  String get rideBookingRecentTitle;

  /// No description provided for @rideBookingRecentHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get rideBookingRecentHome;

  /// No description provided for @rideBookingRecentHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved home address'**
  String get rideBookingRecentHomeSubtitle;

  /// No description provided for @rideBookingRecentWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get rideBookingRecentWork;

  /// No description provided for @rideBookingRecentWorkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved work address'**
  String get rideBookingRecentWorkSubtitle;

  /// No description provided for @rideBookingRecentAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add new place'**
  String get rideBookingRecentAddNew;

  /// No description provided for @rideBookingRecentAddNewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a new frequent destination'**
  String get rideBookingRecentAddNewSubtitle;

  /// No description provided for @rideBookingSeeOptionsCta.
  ///
  /// In en, this message translates to:
  /// **'See options'**
  String get rideBookingSeeOptionsCta;

  /// No description provided for @rideConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your ride'**
  String get rideConfirmTitle;

  /// No description provided for @rideConfirmMapStubLabel.
  ///
  /// In en, this message translates to:
  /// **'Route preview (stub – the actual map will show your driver and destination).'**
  String get rideConfirmMapStubLabel;

  /// No description provided for @rideConfirmSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your ride'**
  String get rideConfirmSheetTitle;

  /// No description provided for @rideConfirmSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a ride option, review pricing, and confirm your trip.'**
  String get rideConfirmSheetSubtitle;

  /// No description provided for @rideConfirmOptionEconomyTitle.
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get rideConfirmOptionEconomyTitle;

  /// No description provided for @rideConfirmOptionEconomySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Affordable everyday rides for up to 4 people.'**
  String get rideConfirmOptionEconomySubtitle;

  /// No description provided for @rideConfirmOptionXlTitle.
  ///
  /// In en, this message translates to:
  /// **'XL'**
  String get rideConfirmOptionXlTitle;

  /// No description provided for @rideConfirmOptionXlSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extra space for groups and larger items.'**
  String get rideConfirmOptionXlSubtitle;

  /// No description provided for @rideConfirmOptionPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get rideConfirmOptionPremiumTitle;

  /// No description provided for @rideConfirmOptionPremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'High-comfort rides with top-rated drivers.'**
  String get rideConfirmOptionPremiumSubtitle;

  /// No description provided for @rideConfirmOptionEtaFormat.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min away'**
  String rideConfirmOptionEtaFormat(String minutes);

  /// No description provided for @rideConfirmOptionPriceApprox.
  ///
  /// In en, this message translates to:
  /// **'≈ {amount} SAR'**
  String rideConfirmOptionPriceApprox(String amount);

  /// No description provided for @rideConfirmPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get rideConfirmPaymentLabel;

  /// No description provided for @rideConfirmPaymentStubValue.
  ///
  /// In en, this message translates to:
  /// **'Visa •• 4242 (stub)'**
  String get rideConfirmPaymentStubValue;

  /// No description provided for @rideConfirmPrimaryCta.
  ///
  /// In en, this message translates to:
  /// **'Request Ride'**
  String get rideConfirmPrimaryCta;

  /// No description provided for @rideConfirmRequestedStubMessage.
  ///
  /// In en, this message translates to:
  /// **'Ride request stub – backend integration coming soon.'**
  String get rideConfirmRequestedStubMessage;

  /// Profile tab title in the bottom navigation / header
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Title for the Settings section in the Profile tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSectionSettingsTitle;

  /// Title for the Privacy & Data section (DSR entry points)
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data'**
  String get profileSectionPrivacyTitle;

  /// Fallback display name when user has no name set
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get profileUserFallbackName;

  /// Label for the phone number in the user info card
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profileUserPhoneLabel;

  /// Settings item - personal information
  ///
  /// In en, this message translates to:
  /// **'Personal info'**
  String get profileSettingsPersonalInfoTitle;

  /// Subtitle for personal info settings item
  ///
  /// In en, this message translates to:
  /// **'Manage your name and details.'**
  String get profileSettingsPersonalInfoSubtitle;

  /// Settings item - ride preferences
  ///
  /// In en, this message translates to:
  /// **'Ride preferences'**
  String get profileSettingsRidePrefsTitle;

  /// Subtitle for ride preferences (placeholder)
  ///
  /// In en, this message translates to:
  /// **'Coming soon.'**
  String get profileSettingsRidePrefsSubtitle;

  /// Settings item - notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileSettingsNotificationsTitle;

  /// Subtitle for notifications settings item
  ///
  /// In en, this message translates to:
  /// **'Control alerts and offers.'**
  String get profileSettingsNotificationsSubtitle;

  /// Settings item - help and support
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get profileSettingsHelpTitle;

  /// Subtitle for help & support settings item
  ///
  /// In en, this message translates to:
  /// **'Get help with your trips and orders.'**
  String get profileSettingsHelpSubtitle;

  /// DSR item - export my data
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get profilePrivacyExportTitle;

  /// Subtitle for export my data item
  ///
  /// In en, this message translates to:
  /// **'Request a copy of your personal data.'**
  String get profilePrivacyExportSubtitle;

  /// DSR item - erase my data
  ///
  /// In en, this message translates to:
  /// **'Erase my data'**
  String get profilePrivacyErasureTitle;

  /// Subtitle for erase my data item
  ///
  /// In en, this message translates to:
  /// **'Request deletion of your personal data.'**
  String get profilePrivacyErasureSubtitle;

  /// Logout item title
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogoutTitle;

  /// Subtitle for logout item
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get profileLogoutSubtitle;

  /// Title of the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogoutDialogTitle;

  /// Body text of the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileLogoutDialogBody;

  /// Cancel button label in logout dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileLogoutDialogCancel;

  /// Confirm button label in logout dialog
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogoutDialogConfirm;

  /// Display name for guest/unregistered users in profile header
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get profileGuestName;

  /// Placeholder text for phone number when not set
  ///
  /// In en, this message translates to:
  /// **'Add your phone number'**
  String get profileGuestPhonePlaceholder;

  /// Snackbar message when logout is tapped but not fully implemented
  ///
  /// In en, this message translates to:
  /// **'Logout not fully wired yet'**
  String get profileLogoutSnack;

  /// No description provided for @ridePhaseDraftLabel.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get ridePhaseDraftLabel;

  /// No description provided for @ridePhaseQuotingLabel.
  ///
  /// In en, this message translates to:
  /// **'Getting quote…'**
  String get ridePhaseQuotingLabel;

  /// No description provided for @ridePhaseRequestingLabel.
  ///
  /// In en, this message translates to:
  /// **'Requesting…'**
  String get ridePhaseRequestingLabel;

  /// No description provided for @ridePhaseFindingDriverLabel.
  ///
  /// In en, this message translates to:
  /// **'Finding driver…'**
  String get ridePhaseFindingDriverLabel;

  /// No description provided for @ridePhaseDriverAcceptedLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver accepted'**
  String get ridePhaseDriverAcceptedLabel;

  /// No description provided for @ridePhaseDriverArrivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver arrived'**
  String get ridePhaseDriverArrivedLabel;

  /// No description provided for @ridePhaseInProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Trip in progress'**
  String get ridePhaseInProgressLabel;

  /// No description provided for @ridePhasePaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get ridePhasePaymentLabel;

  /// No description provided for @ridePhaseCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ridePhaseCompletedLabel;

  /// No description provided for @ridePhaseCancelledLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ridePhaseCancelledLabel;

  /// No description provided for @ridePhaseFailedLabel.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get ridePhaseFailedLabel;

  /// No description provided for @rideErrorOptionsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load ride options. Please try again.'**
  String get rideErrorOptionsLoadFailed;

  /// No description provided for @rideErrorRetryCta.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get rideErrorRetryCta;

  /// No description provided for @rideActiveNoTripTitle.
  ///
  /// In en, this message translates to:
  /// **'No active trip'**
  String get rideActiveNoTripTitle;

  /// No description provided for @rideActiveNoTripBody.
  ///
  /// In en, this message translates to:
  /// **'You do not have an active trip right now.'**
  String get rideActiveNoTripBody;

  /// No description provided for @rideActiveAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Your trip'**
  String get rideActiveAppBarTitle;

  /// No description provided for @rideActiveEtaFormat.
  ///
  /// In en, this message translates to:
  /// **'ETA ~ {minutes} min'**
  String rideActiveEtaFormat(String minutes);

  /// No description provided for @rideActiveContactDriverCta.
  ///
  /// In en, this message translates to:
  /// **'Contact driver'**
  String get rideActiveContactDriverCta;

  /// No description provided for @rideActiveShareTripCta.
  ///
  /// In en, this message translates to:
  /// **'Share trip status'**
  String get rideActiveShareTripCta;

  /// No description provided for @rideActiveCancelTripCta.
  ///
  /// In en, this message translates to:
  /// **'Cancel ride'**
  String get rideActiveCancelTripCta;

  /// Snackbar message after copying trip status to clipboard (Track B - Ticket #68)
  ///
  /// In en, this message translates to:
  /// **'Trip status copied. You can paste it into any app.'**
  String get rideActiveShareTripCopied;

  /// Error message when driver phone is not available (Track B - Ticket #68)
  ///
  /// In en, this message translates to:
  /// **'Driver contact details are not available yet.'**
  String get rideActiveContactNoPhoneError;

  /// Generic error message for share trip failures (Track B - Ticket #68)
  ///
  /// In en, this message translates to:
  /// **'Unable to prepare trip status right now. Please try again.'**
  String get rideActiveShareGenericError;

  /// Template message for sharing trip status (Track B - Ticket #68)
  ///
  /// In en, this message translates to:
  /// **'I\'m on a Delivery Ways ride to {destination}. Track my trip status here: {link}'**
  String rideActiveShareMessageTemplate(String destination, String link);

  /// Generic error message when ride cancellation fails (Track B - Ticket #22)
  ///
  /// In en, this message translates to:
  /// **'Could not cancel the ride. Please try again.'**
  String get rideActiveCancelErrorGeneric;

  /// Title for cancel ride confirmation dialog (Track B - Ticket #67)
  ///
  /// In en, this message translates to:
  /// **'Cancel this ride?'**
  String get rideCancelDialogTitle;

  /// Message in cancel ride confirmation dialog (Track B - Ticket #67)
  ///
  /// In en, this message translates to:
  /// **'If you cancel now, your driver will stop heading to your pickup location.'**
  String get rideCancelDialogMessage;

  /// Button to dismiss cancel dialog and keep the ride (Track B - Ticket #67)
  ///
  /// In en, this message translates to:
  /// **'Keep ride'**
  String get rideCancelDialogKeepRideCta;

  /// Button to confirm ride cancellation in dialog (Track B - Ticket #67)
  ///
  /// In en, this message translates to:
  /// **'Cancel ride'**
  String get rideCancelDialogConfirmCta;

  /// Snackbar message after successful ride cancellation (Track B - Ticket #67)
  ///
  /// In en, this message translates to:
  /// **'Your ride has been cancelled.'**
  String get rideCancelSuccessSnackbar;

  /// Cancel reason label when rider cancels the trip (Track B - Ticket #120)
  ///
  /// In en, this message translates to:
  /// **'Cancelled by rider'**
  String get rideCancelReasonByRider;

  /// No description provided for @rideActiveHeadlineFindingDriver.
  ///
  /// In en, this message translates to:
  /// **'Finding a driver…'**
  String get rideActiveHeadlineFindingDriver;

  /// No description provided for @rideActiveHeadlineDriverEta.
  ///
  /// In en, this message translates to:
  /// **'Driver is {minutes} min away'**
  String rideActiveHeadlineDriverEta(String minutes);

  /// No description provided for @rideActiveHeadlineDriverOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Driver on the way'**
  String get rideActiveHeadlineDriverOnTheWay;

  /// No description provided for @rideActiveHeadlineDriverArrived.
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived'**
  String get rideActiveHeadlineDriverArrived;

  /// No description provided for @rideActiveHeadlineInProgress.
  ///
  /// In en, this message translates to:
  /// **'Trip in progress'**
  String get rideActiveHeadlineInProgress;

  /// No description provided for @rideActiveHeadlinePayment.
  ///
  /// In en, this message translates to:
  /// **'Completing payment'**
  String get rideActiveHeadlinePayment;

  /// No description provided for @rideActiveHeadlineCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trip completed'**
  String get rideActiveHeadlineCompleted;

  /// No description provided for @rideActiveHeadlineCancelled.
  ///
  /// In en, this message translates to:
  /// **'Trip cancelled'**
  String get rideActiveHeadlineCancelled;

  /// No description provided for @rideActiveHeadlineFailed.
  ///
  /// In en, this message translates to:
  /// **'Trip failed'**
  String get rideActiveHeadlineFailed;

  /// No description provided for @rideActiveHeadlinePreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your trip'**
  String get rideActiveHeadlinePreparing;

  /// No description provided for @rideActiveGoBackCta.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get rideActiveGoBackCta;

  /// Title for cancelled trip terminal view (Track B - Ticket #95)
  ///
  /// In en, this message translates to:
  /// **'Trip cancelled'**
  String get rideActiveCancelledTitle;

  /// Body text for cancelled trip terminal view (Track B - Ticket #95)
  ///
  /// In en, this message translates to:
  /// **'Your trip was cancelled. You can request a new ride at any time.'**
  String get rideActiveCancelledBody;

  /// Title for failed trip terminal view (Track B - Ticket #95)
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get rideActiveFailedTitle;

  /// Body text for failed trip terminal view (Track B - Ticket #95)
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete this trip. Please try again in a moment.'**
  String get rideActiveFailedBody;

  /// CTA button to return to home from terminal trip view (Track B - Ticket #95)
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get rideActiveBackToHomeCta;

  /// CTA button to request a new ride from terminal trip view (Track B - Ticket #95)
  ///
  /// In en, this message translates to:
  /// **'Request new ride'**
  String get rideActiveRequestNewRideCta;

  /// No description provided for @rideActiveDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'To {destination}'**
  String rideActiveDestinationLabel(String destination);

  /// Service name and price display in active trip (Track B - Ticket #105)
  ///
  /// In en, this message translates to:
  /// **'{serviceName} · {price}'**
  String rideActiveSummaryServiceAndPrice(String serviceName, String price);

  /// Payment method label in active trip (Track B - Ticket #105)
  ///
  /// In en, this message translates to:
  /// **'Paying with {method}'**
  String rideActivePayingWith(String method);

  /// Fallback when price is not available in active trip (Track B - Ticket #105)
  ///
  /// In en, this message translates to:
  /// **'Price not available yet'**
  String get rideActivePriceNotAvailable;

  /// Price and payment method in home active ride card (Track B - Ticket #105)
  ///
  /// In en, this message translates to:
  /// **'{price} · {paymentMethod}'**
  String homeActiveRidePriceAndPayment(String price, String paymentMethod);

  /// Title for debug FSM section (only shown in debug mode)
  ///
  /// In en, this message translates to:
  /// **'Debug FSM Controls'**
  String get rideDebugFsmTitle;

  /// No description provided for @rideDebugCurrentPhase.
  ///
  /// In en, this message translates to:
  /// **'Current phase: {phase}'**
  String rideDebugCurrentPhase(String phase);

  /// No description provided for @rideDebugDriverFound.
  ///
  /// In en, this message translates to:
  /// **'Driver Found'**
  String get rideDebugDriverFound;

  /// No description provided for @rideDebugDriverArrived.
  ///
  /// In en, this message translates to:
  /// **'Driver Arrived'**
  String get rideDebugDriverArrived;

  /// No description provided for @rideDebugStartTrip.
  ///
  /// In en, this message translates to:
  /// **'Start Trip'**
  String get rideDebugStartTrip;

  /// No description provided for @rideDebugCompleteTrip.
  ///
  /// In en, this message translates to:
  /// **'Complete Trip'**
  String get rideDebugCompleteTrip;

  /// No description provided for @rideDebugConfirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get rideDebugConfirmPayment;

  /// No description provided for @rideStatusFindingDriver.
  ///
  /// In en, this message translates to:
  /// **'Looking for a driver...'**
  String get rideStatusFindingDriver;

  /// No description provided for @rideStatusDriverAccepted.
  ///
  /// In en, this message translates to:
  /// **'Driver on the way'**
  String get rideStatusDriverAccepted;

  /// No description provided for @rideStatusDriverArrived.
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived'**
  String get rideStatusDriverArrived;

  /// No description provided for @rideStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'Trip in progress'**
  String get rideStatusInProgress;

  /// No description provided for @rideStatusPaymentPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get rideStatusPaymentPending;

  /// No description provided for @rideStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trip completed'**
  String get rideStatusCompleted;

  /// No description provided for @rideStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Preparing your trip...'**
  String get rideStatusUnknown;

  /// CTA button on Home Hub active ride card to open the active trip screen.
  ///
  /// In en, this message translates to:
  /// **'View trip'**
  String get homeActiveRideViewTripCta;

  /// Generic fallback title for active ride card on Home Hub (Track B - Ticket #65)
  ///
  /// In en, this message translates to:
  /// **'Active ride'**
  String get homeActiveRideTitleGeneric;

  /// Title with ETA for active ride card on Home Hub (Track B - Ticket #114)
  ///
  /// In en, this message translates to:
  /// **'Arriving in {minutes} min'**
  String homeActiveRideEtaTitle(int minutes);

  /// Subtitle showing destination on active ride card
  ///
  /// In en, this message translates to:
  /// **'To {destination}'**
  String homeActiveRideSubtitleToDestination(String destination);

  /// Main title for Home Hub screen - greeting asking user destination (Ticket #182)
  ///
  /// In en, this message translates to:
  /// **'Where do you want to go?'**
  String get homeHubTitle;

  /// Label for current location indicator (Ticket #182)
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get homeHubCurrentLocationLabel;

  /// Temporary message while fetching current location on Home Hub
  ///
  /// In en, this message translates to:
  /// **'Detecting your location...'**
  String get homeHubCurrentLocationLoading;

  /// Fallback message when current location cannot be determined on Home Hub
  ///
  /// In en, this message translates to:
  /// **'Location not available'**
  String get homeHubCurrentLocationUnavailable;

  /// Label for Ride service chip (Ticket #182)
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get homeHubServiceRide;

  /// Label for Parcels service chip (Ticket #182)
  ///
  /// In en, this message translates to:
  /// **'Parcels'**
  String get homeHubServiceParcels;

  /// Label for Food service chip (Ticket #182)
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get homeHubServiceFood;

  /// Title for active ride card on home hub (Ticket #183)
  ///
  /// In en, this message translates to:
  /// **'Ride in progress'**
  String get homeHubActiveRideTitle;

  /// Subtitle for active ride card on home hub (Ticket #183)
  ///
  /// In en, this message translates to:
  /// **'Continue your active trip'**
  String get homeHubActiveRideSubtitle;

  /// SnackBar message shown when user taps Parcels chip on HomeHub (Ticket #184)
  ///
  /// In en, this message translates to:
  /// **'Parcels service is coming soon to your city.'**
  String get homeHubParcelsComingSoonMessage;

  /// SnackBar message shown when user taps Food chip on HomeHub (Ticket #184)
  ///
  /// In en, this message translates to:
  /// **'Food ordering is coming soon to your city.'**
  String get homeHubFoodComingSoonMessage;

  /// Placeholder text for the HomeHub search bar used to start a new ride (Ticket #188)
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get homeHubSearchPlaceholder;

  /// Title for the ride destination input screen (Screen 8)
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get rideDestinationTitle;

  /// Label for the pickup location field
  ///
  /// In en, this message translates to:
  /// **'Pick-up'**
  String get rideDestinationPickupLabel;

  /// Default text for pickup when using current GPS location
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get rideDestinationPickupCurrentLocation;

  /// Section header for the list of recent/saved locations
  ///
  /// In en, this message translates to:
  /// **'Recent locations'**
  String get rideDestinationRecentLocationsSection;

  /// Title for the location picker screen (Ticket #93)
  ///
  /// In en, this message translates to:
  /// **'Choose your trip'**
  String get rideLocationPickerTitle;

  /// Label for the pickup location field (Ticket #93)
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get rideLocationPickerPickupLabel;

  /// Label for the destination field (Ticket #93)
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get rideLocationPickerDestinationLabel;

  /// Placeholder for the pickup location field (Ticket #93)
  ///
  /// In en, this message translates to:
  /// **'Where should we pick you up?'**
  String get rideLocationPickerPickupPlaceholder;

  /// Placeholder for the destination field (Ticket #93)
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get rideLocationPickerDestinationPlaceholder;

  /// Hint text displayed above the map (Ticket #93)
  ///
  /// In en, this message translates to:
  /// **'Adjust the pin or use search to set your locations.'**
  String get rideLocationPickerMapHint;

  /// Continue CTA button text (Ticket #93)
  ///
  /// In en, this message translates to:
  /// **'See prices'**
  String get rideLocationPickerContinueCta;

  /// Title for the trip confirmation screen (Screen 9)
  ///
  /// In en, this message translates to:
  /// **'Confirm your trip'**
  String get rideTripConfirmationTitle;

  /// CTA button to request the ride
  ///
  /// In en, this message translates to:
  /// **'Request ride'**
  String get rideTripConfirmationRequestRideCta;

  /// Section title for payment method
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get rideTripConfirmationPaymentSectionTitle;

  /// Cash payment method label
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get rideTripConfirmationPaymentMethodCash;

  /// Title for the trip summary screen (Track B - Ticket #23)
  ///
  /// In en, this message translates to:
  /// **'Trip summary'**
  String get rideTripSummaryTitle;

  /// Header title when trip is completed
  ///
  /// In en, this message translates to:
  /// **'Trip completed'**
  String get rideTripSummaryCompletedTitle;

  /// Subtitle shown after trip completion
  ///
  /// In en, this message translates to:
  /// **'Thanks for riding with Delivery Ways'**
  String get rideTripSummaryCompletedSubtitle;

  /// Header title when trip is cancelled (Track B - Ticket #120)
  ///
  /// In en, this message translates to:
  /// **'Trip cancelled'**
  String get rideTripSummaryCancelledTitle;

  /// Subtitle shown when viewing a cancelled trip (Track B - Ticket #120)
  ///
  /// In en, this message translates to:
  /// **'Your ride was cancelled'**
  String get rideTripSummaryCancelledSubtitle;

  /// Title shown when viewing a failed trip (Track B - Ticket #122)
  ///
  /// In en, this message translates to:
  /// **'Ride failed'**
  String get rideTripSummaryFailedTitle;

  /// Subtitle shown when viewing a failed trip (Track B - Ticket #122)
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete this ride'**
  String get rideTripSummaryFailedSubtitle;

  /// Reason label when no driver was available (Track B - Ticket #122)
  ///
  /// In en, this message translates to:
  /// **'No driver found'**
  String get rideFailReasonNoDriverFound;

  /// SnackBar message shown when no driver is found (Track B - Ticket #122)
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find a driver for this ride.'**
  String get rideFailNoDriverFoundSnackbar;

  /// CTA button text for no driver found action (Track B - Ticket #122)
  ///
  /// In en, this message translates to:
  /// **'No drivers available? Try later'**
  String get rideFailNoDriverFoundCta;

  /// Section title for route summary
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get rideTripSummaryRouteSectionTitle;

  /// Section title for fare/receipt
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get rideTripSummaryFareSectionTitle;

  /// Label for total fare amount
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get rideTripSummaryTotalLabel;

  /// Section title for driver info
  ///
  /// In en, this message translates to:
  /// **'Your driver'**
  String get rideTripSummaryDriverSectionTitle;

  /// Label prompting user to rate the driver
  ///
  /// In en, this message translates to:
  /// **'Rate your driver'**
  String get rideTripSummaryRatingLabel;

  /// CTA button to finish and return home
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get rideTripSummaryDoneCta;

  /// Service name label in trip completion screen (Track B - Ticket #107)
  ///
  /// In en, this message translates to:
  /// **'{serviceName} ride'**
  String rideTripCompletionServiceLabel(String serviceName);

  /// Title shown while loading ride options (Ticket #26)
  ///
  /// In en, this message translates to:
  /// **'Fetching ride options...'**
  String get rideConfirmLoadingTitle;

  /// Subtitle shown while loading ride options
  ///
  /// In en, this message translates to:
  /// **'Please wait while we find the best rides for you.'**
  String get rideConfirmLoadingSubtitle;

  /// Title shown when quote loading fails
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load ride options'**
  String get rideConfirmErrorTitle;

  /// Subtitle shown when quote loading fails
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get rideConfirmErrorSubtitle;

  /// Title shown when no ride options are available
  ///
  /// In en, this message translates to:
  /// **'No rides available'**
  String get rideConfirmEmptyTitle;

  /// Subtitle shown when no ride options are available
  ///
  /// In en, this message translates to:
  /// **'Please try again in a few minutes.'**
  String get rideConfirmEmptySubtitle;

  /// CTA button to retry loading ride options
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get rideConfirmRetryCta;

  /// Badge shown on recommended ride option (Ticket #91)
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get rideConfirmRecommendedBadge;

  /// Title for the error state when ride pricing fails (Track B - Ticket #121)
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load ride options'**
  String get rideQuoteErrorTitle;

  /// Generic error message for pricing failures (Track B - Ticket #121)
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get rideQuoteErrorGeneric;

  /// Error message when no ride options are returned (Track B - Ticket #121)
  ///
  /// In en, this message translates to:
  /// **'No ride options are available for this route right now.'**
  String get rideQuoteErrorNoOptions;

  /// Generic error message for pricing failures (Ticket #196)
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load prices. Please try again.'**
  String get ridePricingErrorGeneric;

  /// CTA button text to retry fetching ride prices (Track B - Ticket #121)
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get rideQuoteRetryCta;

  /// Title for empty state when no ride options (Track B - Ticket #121)
  ///
  /// In en, this message translates to:
  /// **'No rides available'**
  String get rideQuoteEmptyTitle;

  /// Description for empty state when no ride options (Track B - Ticket #121)
  ///
  /// In en, this message translates to:
  /// **'Please try again in a few minutes.'**
  String get rideQuoteEmptyDescription;

  /// Label for pickup location in trip summary (Ticket #91)
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get rideConfirmFromLabel;

  /// Label for destination in trip summary (Ticket #91)
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get rideConfirmToLabel;

  /// Title for the welcome onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Delivery Ways'**
  String get onboardingWelcomeTitle;

  /// Subtitle for the welcome onboarding screen
  ///
  /// In en, this message translates to:
  /// **'All your rides, parcels, and deliveries in one place.'**
  String get onboardingWelcomeSubtitle;

  /// CTA button to start onboarding flow
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingWelcomeGetStartedCta;

  /// Title for the permissions onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Allow permissions'**
  String get onboardingPermissionsTitle;

  /// Location permission title
  ///
  /// In en, this message translates to:
  /// **'Location access'**
  String get onboardingPermissionsLocation;

  /// Location permission description
  ///
  /// In en, this message translates to:
  /// **'We use your location to find nearby drivers.'**
  String get onboardingPermissionsLocationSubtitle;

  /// Notifications permission title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get onboardingPermissionsNotifications;

  /// Notifications permission description
  ///
  /// In en, this message translates to:
  /// **'Stay updated about your rides and deliveries.'**
  String get onboardingPermissionsNotificationsSubtitle;

  /// Continue button on permissions screen
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingPermissionsContinueCta;

  /// Skip button on permissions screen
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingPermissionsSkipCta;

  /// Title for the preferences onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Set your preferences'**
  String get onboardingPreferencesTitle;

  /// Subtitle for the preferences onboarding screen
  ///
  /// In en, this message translates to:
  /// **'You can change these later in Settings.'**
  String get onboardingPreferencesSubtitle;

  /// Section title for service selection
  ///
  /// In en, this message translates to:
  /// **'What do you use most?'**
  String get onboardingPreferencesPrimaryServiceTitle;

  /// Rides service option title
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get onboardingPreferencesServiceRides;

  /// Rides service option description
  ///
  /// In en, this message translates to:
  /// **'Get picked up and dropped off'**
  String get onboardingPreferencesServiceRidesDesc;

  /// Parcels service option title
  ///
  /// In en, this message translates to:
  /// **'Parcels'**
  String get onboardingPreferencesServiceParcels;

  /// Parcels service option description
  ///
  /// In en, this message translates to:
  /// **'Send and receive packages'**
  String get onboardingPreferencesServiceParcelsDesc;

  /// Food service option title
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get onboardingPreferencesServiceFood;

  /// Food service option description
  ///
  /// In en, this message translates to:
  /// **'Order from restaurants'**
  String get onboardingPreferencesServiceFoodDesc;

  /// Done button to complete onboarding
  ///
  /// In en, this message translates to:
  /// **'Start using Delivery Ways'**
  String get onboardingPreferencesDoneCta;

  /// Title for Parcels entry screen (Track C - Ticket #40)
  ///
  /// In en, this message translates to:
  /// **'Parcels'**
  String get parcelsEntryTitle;

  /// Subtitle for Parcels entry screen
  ///
  /// In en, this message translates to:
  /// **'Ship and track your parcels in one place.'**
  String get parcelsEntrySubtitle;

  /// Primary CTA button to create a new shipment
  ///
  /// In en, this message translates to:
  /// **'Create shipment'**
  String get parcelsEntryCreateShipmentCta;

  /// Secondary CTA button to view shipments list
  ///
  /// In en, this message translates to:
  /// **'View shipments list'**
  String get parcelsEntryViewShipmentsCta;

  /// Snackbar message when parcels flows are not yet implemented
  ///
  /// In en, this message translates to:
  /// **'Parcels flows are coming soon.'**
  String get parcelsEntryComingSoonMessage;

  /// Footer note on Parcels entry screen
  ///
  /// In en, this message translates to:
  /// **'Parcels MVP is under active development.'**
  String get parcelsEntryFooterNote;

  /// Snackbar message when Parcels feature is disabled
  ///
  /// In en, this message translates to:
  /// **'Parcels is coming soon.'**
  String get parcelsComingSoonMessage;

  /// Title for Parcel Destination screen (Track C - Ticket #41)
  ///
  /// In en, this message translates to:
  /// **'Create shipment'**
  String get parcelsDestinationTitle;

  /// Subtitle for Parcel Destination screen
  ///
  /// In en, this message translates to:
  /// **'Enter where to pick up and where to deliver your parcel.'**
  String get parcelsDestinationSubtitle;

  /// Label for pickup address field
  ///
  /// In en, this message translates to:
  /// **'Pickup address'**
  String get parcelsDestinationPickupLabel;

  /// Hint text for pickup address field
  ///
  /// In en, this message translates to:
  /// **'Enter pickup address'**
  String get parcelsDestinationPickupHint;

  /// Label for delivery address field
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get parcelsDestinationDropoffLabel;

  /// Hint text for delivery address field
  ///
  /// In en, this message translates to:
  /// **'Enter delivery address'**
  String get parcelsDestinationDropoffHint;

  /// Continue button on Parcel Destination screen
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get parcelsDestinationContinueCta;

  /// Title for Parcel Details screen (Track C - Ticket #42)
  ///
  /// In en, this message translates to:
  /// **'Parcel details'**
  String get parcelsDetailsTitle;

  /// Subtitle for Parcel Details screen
  ///
  /// In en, this message translates to:
  /// **'Tell us more about your parcel to get accurate pricing.'**
  String get parcelsDetailsSubtitle;

  /// Label for size selection
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get parcelsDetailsSizeLabel;

  /// Label for weight field
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get parcelsDetailsWeightLabel;

  /// Hint text for weight field
  ///
  /// In en, this message translates to:
  /// **'e.g. 2.5 kg'**
  String get parcelsDetailsWeightHint;

  /// Label for contents description field
  ///
  /// In en, this message translates to:
  /// **'What are you sending?'**
  String get parcelsDetailsContentsLabel;

  /// Hint text for contents description field
  ///
  /// In en, this message translates to:
  /// **'Briefly describe the contents'**
  String get parcelsDetailsContentsHint;

  /// Label for fragile toggle
  ///
  /// In en, this message translates to:
  /// **'This parcel is fragile'**
  String get parcelsDetailsFragileLabel;

  /// Continue button on Parcel Details screen
  ///
  /// In en, this message translates to:
  /// **'Review price'**
  String get parcelsDetailsContinueCta;

  /// Error when weight field is empty (Track C - Ticket #76)
  ///
  /// In en, this message translates to:
  /// **'Please enter the parcel weight'**
  String get parcelsDetailsErrorWeightRequired;

  /// Error when weight is not a positive number (Track C - Ticket #76)
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive number'**
  String get parcelsDetailsErrorPositiveNumber;

  /// Error when contents field is empty (Track C - Ticket #76)
  ///
  /// In en, this message translates to:
  /// **'Please describe what you are sending'**
  String get parcelsDetailsErrorContentsRequired;

  /// Error when size is not selected (Track C - Ticket #76)
  ///
  /// In en, this message translates to:
  /// **'Please select a parcel size'**
  String get parcelsDetailsErrorSizeRequired;

  /// Section header for parcel details (Track C - Ticket #76)
  ///
  /// In en, this message translates to:
  /// **'Parcel details'**
  String get parcelsDetailsSectionParcelTitle;

  /// Title for Parcel Quote screen (Track C - Ticket #43)
  ///
  /// In en, this message translates to:
  /// **'Shipment pricing'**
  String get parcelsQuoteTitle;

  /// Subtitle for Parcel Quote screen
  ///
  /// In en, this message translates to:
  /// **'Choose how fast you want it delivered and how much you want to pay.'**
  String get parcelsQuoteSubtitle;

  /// Loading text while fetching price options
  ///
  /// In en, this message translates to:
  /// **'Fetching price options...'**
  String get parcelsQuoteLoadingTitle;

  /// Error title when pricing fails
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load price options'**
  String get parcelsQuoteErrorTitle;

  /// Error subtitle when pricing fails
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get parcelsQuoteErrorSubtitle;

  /// Empty state title when no pricing options
  ///
  /// In en, this message translates to:
  /// **'No options available'**
  String get parcelsQuoteEmptyTitle;

  /// Empty state subtitle when no pricing options
  ///
  /// In en, this message translates to:
  /// **'Please adjust the parcel details and try again.'**
  String get parcelsQuoteEmptySubtitle;

  /// Retry button on error state
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get parcelsQuoteRetryCta;

  /// Confirm button on Parcel Quote screen
  ///
  /// In en, this message translates to:
  /// **'Confirm shipment'**
  String get parcelsQuoteConfirmCta;

  /// Title for the shipment summary card (Track C - Ticket #77)
  ///
  /// In en, this message translates to:
  /// **'Shipment summary'**
  String get parcelsQuoteSummaryTitle;

  /// Label for pickup address in summary (Track C - Ticket #77)
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get parcelsQuoteFromLabel;

  /// Label for dropoff address in summary (Track C - Ticket #77)
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get parcelsQuoteToLabel;

  /// Label for weight in summary (Track C - Ticket #77)
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get parcelsQuoteWeightLabel;

  /// Label for size in summary (Track C - Ticket #77)
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get parcelsQuoteSizeLabel;

  /// Total price label with amount (Track C - Ticket #77)
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String parcelsQuoteTotalLabel(String amount);

  /// Stub note about estimated pricing (Track C - Ticket #77)
  ///
  /// In en, this message translates to:
  /// **'This is an estimated price. Final price may change after integration with the live pricing service.'**
  String get parcelsQuoteBreakdownStubNote;

  /// AppBar title for parcels list screen (Track C - Ticket #72)
  ///
  /// In en, this message translates to:
  /// **'Your shipments'**
  String get parcelsListTitle;

  /// Section title for the shipments list (Track C - Ticket #45)
  ///
  /// In en, this message translates to:
  /// **'My shipments'**
  String get parcelsListSectionTitle;

  /// Title shown when no parcels exist
  ///
  /// In en, this message translates to:
  /// **'No shipments yet'**
  String get parcelsListEmptyTitle;

  /// Subtitle shown when no parcels exist
  ///
  /// In en, this message translates to:
  /// **'When you create a shipment, it will appear here.'**
  String get parcelsListEmptySubtitle;

  /// CTA button in empty state to create first shipment (Track C - Ticket #73)
  ///
  /// In en, this message translates to:
  /// **'Create first shipment'**
  String get parcelsListEmptyCta;

  /// Tooltip for the + button in AppBar (Track C - Ticket #73)
  ///
  /// In en, this message translates to:
  /// **'New shipment'**
  String get parcelsListNewShipmentTooltip;

  /// Label showing parcel creation date (Track C - Ticket #73)
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String parcelsListCreatedAtLabel(String date);

  /// Fallback label when destination is not set (Track C - Ticket #73)
  ///
  /// In en, this message translates to:
  /// **'Unknown destination'**
  String get parcelsListUnknownDestinationLabel;

  /// Filter label for all parcels
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get parcelsFilterAllLabel;

  /// Filter label for in-progress parcels
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get parcelsFilterInProgressLabel;

  /// Filter label for delivered parcels
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get parcelsFilterDeliveredLabel;

  /// Filter label for cancelled parcels
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get parcelsFilterCancelledLabel;

  /// Parcel status: scheduled for pickup
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get parcelsStatusScheduled;

  /// Parcel status: waiting for pickup
  ///
  /// In en, this message translates to:
  /// **'Pickup pending'**
  String get parcelsStatusPickupPending;

  /// Parcel status: picked up by courier
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get parcelsStatusPickedUp;

  /// Parcel status: on the way
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get parcelsStatusInTransit;

  /// Parcel status: delivered to recipient
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get parcelsStatusDelivered;

  /// Parcel status: cancelled by user or system
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get parcelsStatusCancelled;

  /// Parcel status: delivery failed
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get parcelsStatusFailed;

  /// Title for create shipment screen (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Create shipment'**
  String get parcelsCreateShipmentTitle;

  /// Section title for sender information
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get parcelsCreateSenderSectionTitle;

  /// Section title for receiver information
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get parcelsCreateReceiverSectionTitle;

  /// Section title for parcel details
  ///
  /// In en, this message translates to:
  /// **'Parcel details'**
  String get parcelsCreateDetailsSectionTitle;

  /// Section title for service type selection
  ///
  /// In en, this message translates to:
  /// **'Service type'**
  String get parcelsCreateServiceSectionTitle;

  /// Label for sender name field
  ///
  /// In en, this message translates to:
  /// **'Sender name'**
  String get parcelsCreateSenderNameLabel;

  /// Label for sender phone field
  ///
  /// In en, this message translates to:
  /// **'Sender phone'**
  String get parcelsCreateSenderPhoneLabel;

  /// Label for sender address field
  ///
  /// In en, this message translates to:
  /// **'Sender address'**
  String get parcelsCreateSenderAddressLabel;

  /// Label for receiver name field
  ///
  /// In en, this message translates to:
  /// **'Receiver name'**
  String get parcelsCreateReceiverNameLabel;

  /// Label for receiver phone field
  ///
  /// In en, this message translates to:
  /// **'Receiver phone'**
  String get parcelsCreateReceiverPhoneLabel;

  /// Label for receiver address field
  ///
  /// In en, this message translates to:
  /// **'Receiver address'**
  String get parcelsCreateReceiverAddressLabel;

  /// Label for weight input field
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get parcelsCreateWeightLabel;

  /// Label for size selection
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get parcelsCreateSizeLabel;

  /// Label for notes input field
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get parcelsCreateNotesLabel;

  /// Express service type option
  ///
  /// In en, this message translates to:
  /// **'Express'**
  String get parcelsCreateServiceExpress;

  /// Standard service type option
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get parcelsCreateServiceStandard;

  /// CTA button to submit and get shipment estimate
  ///
  /// In en, this message translates to:
  /// **'Get estimate'**
  String get parcelsCreateShipmentCtaGetEstimate;

  /// Validation error for required fields
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get parcelsCreateErrorRequired;

  /// Validation error for invalid numeric input
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get parcelsCreateErrorInvalidNumber;

  /// Validation error for invalid phone number
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get parcelsCreateErrorInvalidPhone;

  /// Validation error for invalid weight input (Track C - Ticket #69)
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight.'**
  String get parcelsCreateWeightInvalidError;

  /// Snackbar message when estimate feature is not yet available (Track C - Ticket #69)
  ///
  /// In en, this message translates to:
  /// **'Shipment estimate is coming soon.'**
  String get parcelsCreateEstimateComingSoonSnackbar;

  /// Size option label: Small (Track C - Ticket #69)
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get parcelsCreateSizeSmallLabel;

  /// Size option label: Medium (Track C - Ticket #69)
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get parcelsCreateSizeMediumLabel;

  /// Size option label: Large (Track C - Ticket #69)
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get parcelsCreateSizeLargeLabel;

  /// Size option label: Oversize (Track C - Ticket #69)
  ///
  /// In en, this message translates to:
  /// **'Oversize'**
  String get parcelsCreateSizeOversizeLabel;

  /// Shipment details screen title (Track C - Ticket #151)
  ///
  /// In en, this message translates to:
  /// **'Shipment details'**
  String get parcelsShipmentDetailsTitle;

  /// Label showing creation date
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String parcelsShipmentDetailsCreatedAt(String date);

  /// Route section title (Track C - Ticket #151)
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get parcelsShipmentDetailsRouteSectionTitle;

  /// Pickup address label (Track C - Ticket #151)
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get parcelsShipmentDetailsPickupLabel;

  /// Dropoff address label (Track C - Ticket #151)
  ///
  /// In en, this message translates to:
  /// **'Dropoff'**
  String get parcelsShipmentDetailsDropoffLabel;

  /// Section title for sender/receiver addresses
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get parcelsShipmentDetailsAddressSectionTitle;

  /// Sender label (Track C - Ticket #151)
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get parcelsShipmentDetailsSenderLabel;

  /// Receiver label (Track C - Ticket #151)
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get parcelsShipmentDetailsReceiverLabel;

  /// Section title for parcel meta information
  ///
  /// In en, this message translates to:
  /// **'Parcel details'**
  String get parcelsShipmentDetailsMetaSectionTitle;

  /// Weight label (Track C - Ticket #151)
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get parcelsShipmentDetailsWeightLabel;

  /// Size label (Track C - Ticket #151)
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get parcelsShipmentDetailsSizeLabel;

  /// Notes label (Track C - Ticket #151)
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get parcelsShipmentDetailsNotesLabel;

  /// Placeholder for unavailable data
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get parcelsShipmentDetailsNotAvailable;

  /// Size label for small parcels
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get parcelsShipmentDetailsSizeSmall;

  /// Size label for medium parcels
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get parcelsShipmentDetailsSizeMedium;

  /// Size label for large parcels
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get parcelsShipmentDetailsSizeLarge;

  /// Size label for oversize parcels
  ///
  /// In en, this message translates to:
  /// **'Oversize'**
  String get parcelsShipmentDetailsSizeOversize;

  /// Label for parcel price in shipment details (Track C - Ticket #50)
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get parcelsDetailsPriceLabel;

  /// AppBar title for Food Coming Soon screen (Track C - Ticket #48)
  ///
  /// In en, this message translates to:
  /// **'Food delivery'**
  String get foodComingSoonAppBarTitle;

  /// Main title on Food Coming Soon screen
  ///
  /// In en, this message translates to:
  /// **'Food delivery is coming soon'**
  String get foodComingSoonTitle;

  /// Subtitle on Food Coming Soon screen
  ///
  /// In en, this message translates to:
  /// **'We\'re working hard to bring food delivery to your area. Stay tuned!'**
  String get foodComingSoonSubtitle;

  /// CTA button on Food Coming Soon screen to return to home
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get foodComingSoonPrimaryCta;

  /// AppBar title for the Food Restaurants List screen (Track C - Ticket #52)
  ///
  /// In en, this message translates to:
  /// **'Food delivery'**
  String get foodRestaurantsAppBarTitle;

  /// Placeholder text for search input field
  ///
  /// In en, this message translates to:
  /// **'Search restaurants or cuisines'**
  String get foodRestaurantsSearchPlaceholder;

  /// Filter chip label for showing all restaurants
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get foodRestaurantsFilterAll;

  /// Filter chip label for burger restaurants
  ///
  /// In en, this message translates to:
  /// **'Burgers'**
  String get foodRestaurantsFilterBurgers;

  /// Filter chip label for Italian restaurants
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get foodRestaurantsFilterItalian;

  /// Title shown when no restaurants match the filters
  ///
  /// In en, this message translates to:
  /// **'No restaurants found'**
  String get foodRestaurantsEmptyTitle;

  /// Subtitle shown when no restaurants match the filters
  ///
  /// In en, this message translates to:
  /// **'Try changing the filters or search for a different cuisine.'**
  String get foodRestaurantsEmptySubtitle;

  /// Error message when menu fails to load (Track C - Ticket #53)
  ///
  /// In en, this message translates to:
  /// **'Could not load menu. Please try again.'**
  String get foodRestaurantMenuError;

  /// Cart summary button text
  ///
  /// In en, this message translates to:
  /// **'{itemCount} items · {totalPrice} total'**
  String foodCartSummaryCta(String itemCount, String totalPrice);

  /// Temporary message shown when checkout is tapped
  ///
  /// In en, this message translates to:
  /// **'Checkout not implemented yet. {itemCount} items, total {totalPrice}.'**
  String foodCartCheckoutStub(String itemCount, String totalPrice);

  /// Section title for parcels orders in My Orders screen (Track C - Ticket #54)
  ///
  /// In en, this message translates to:
  /// **'Parcels'**
  String get ordersSectionParcelsTitle;

  /// Section title for food orders in My Orders screen (Track C - Ticket #54)
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get ordersSectionFoodTitle;

  /// Filter label for food orders only (Track C - Ticket #54)
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get ordersFilterFood;

  /// Food order status: pending (Track C - Ticket #54)
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ordersFoodStatusPending;

  /// Food order status: in preparation (Track C - Ticket #54)
  ///
  /// In en, this message translates to:
  /// **'In preparation'**
  String get ordersFoodStatusInPreparation;

  /// Food order status: on the way (Track C - Ticket #54)
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get ordersFoodStatusOnTheWay;

  /// Food order status: delivered (Track C - Ticket #54)
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get ordersFoodStatusDelivered;

  /// Food order status: cancelled (Track C - Ticket #54)
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersFoodStatusCancelled;

  /// Label showing when the food order was created (Track C - Ticket #54)
  ///
  /// In en, this message translates to:
  /// **'Ordered on {date}'**
  String ordersFoodCreatedAtLabel(String date);

  /// Snackbar message shown after successfully creating a food order (Track C - Ticket #54)
  ///
  /// In en, this message translates to:
  /// **'Your order from {restaurant} has been created.'**
  String foodCartOrderCreatedSnackbar(String restaurant);

  /// Label shown on Food service card when feature is disabled (Track C - Ticket #55)
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get homeFoodComingSoonLabel;

  /// Message shown when user taps disabled Food card (Track C - Ticket #55)
  ///
  /// In en, this message translates to:
  /// **'Food delivery is not available yet in your area.'**
  String get homeFoodComingSoonMessage;

  /// Title for the Food service card on Home Hub (Track C - Ticket #56)
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get homeFoodCardTitle;

  /// Subtitle for the Food service card on Home Hub (Track C - Ticket #56)
  ///
  /// In en, this message translates to:
  /// **'Your favorite food, delivered.'**
  String get homeFoodCardSubtitle;

  /// Title for Ride onboarding screen (Track D - Ticket #57)
  ///
  /// In en, this message translates to:
  /// **'Get a Ride, Instantly.'**
  String get onboardingRideTitle;

  /// Body text for Ride onboarding screen (Track D - Ticket #57)
  ///
  /// In en, this message translates to:
  /// **'Tap, ride, and arrive. Fast, reliable, and affordable transport at your fingertips.'**
  String get onboardingRideBody;

  /// Title for Parcels onboarding screen (Track D - Ticket #57)
  ///
  /// In en, this message translates to:
  /// **'Deliver Anything, Effortlessly.'**
  String get onboardingParcelsTitle;

  /// Body text for Parcels onboarding screen (Track D - Ticket #57)
  ///
  /// In en, this message translates to:
  /// **'From documents to gifts, send and track your parcels with ease and confidence.'**
  String get onboardingParcelsBody;

  /// Title for Food onboarding screen (Track D - Ticket #57)
  ///
  /// In en, this message translates to:
  /// **'Your Favorite Food, Delivered.'**
  String get onboardingFoodTitle;

  /// Body text for Food onboarding screen (Track D - Ticket #57)
  ///
  /// In en, this message translates to:
  /// **'Explore local restaurants and enjoy fast delivery right to your door.'**
  String get onboardingFoodBody;

  /// Continue button text for onboarding screens (Track D - Ticket #57)
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingButtonContinue;

  /// Get Started button text for final onboarding screen (Track D - Ticket #57)
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingButtonGetStarted;

  /// Title for the Ride service card on Home Hub (Track B - Ticket #60)
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get homeRideCardTitle;

  /// Subtitle for the Ride service card on Home Hub (Track B - Ticket #60)
  ///
  /// In en, this message translates to:
  /// **'Get a ride, instantly.'**
  String get homeRideCardSubtitle;

  /// Label for the destination field (Track B - Ticket #60)
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get rideDestinationDestinationLabel;

  /// Placeholder text for destination input (Track B - Ticket #60)
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get rideDestinationDestinationPlaceholder;

  /// Section title for recent destinations (Track B - Ticket #60)
  ///
  /// In en, this message translates to:
  /// **'Recent destinations'**
  String get rideDestinationRecentTitle;

  /// Label for Home in recent destinations (Track B - Ticket #60)
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get rideDestinationRecentHomeLabel;

  /// Subtitle for Home in recent destinations (Track B - Ticket #60)
  ///
  /// In en, this message translates to:
  /// **'Saved home address'**
  String get rideDestinationRecentHomeSubtitle;

  /// Label for Work in recent destinations (Track B - Ticket #60)
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get rideDestinationRecentWorkLabel;

  /// Subtitle for Work in recent destinations (Track B - Ticket #60)
  ///
  /// In en, this message translates to:
  /// **'Saved work address'**
  String get rideDestinationRecentWorkSubtitle;

  /// Label for last trip in recent destinations (Track B - Ticket #60)
  ///
  /// In en, this message translates to:
  /// **'Last trip'**
  String get rideDestinationRecentLastLabel;

  /// Subtitle for last trip in recent destinations (Track B - Ticket #60)
  ///
  /// In en, this message translates to:
  /// **'Use the destination from your last ride'**
  String get rideDestinationRecentLastSubtitle;

  /// CTA button text on ride destination screen (Track B - Ticket #60)
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get rideDestinationNextCta;

  /// Snackbar message when trip summary is not yet implemented (Track B - Ticket #60)
  ///
  /// In en, this message translates to:
  /// **'Trip summary is coming soon.'**
  String get rideDestinationComingSoonSnackbar;

  /// Title for the receipt section in trip summary (Track B - Ticket #62)
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get rideSummaryReceiptTitle;

  /// Label for the fare amount in receipt breakdown (Track B - Ticket #62)
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get rideSummaryReceiptFareLabel;

  /// Label for the fees amount in receipt breakdown (Track B - Ticket #62)
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get rideSummaryReceiptFeesLabel;

  /// Label for the total amount in receipt breakdown (Track B - Ticket #62)
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get rideSummaryReceiptTotalLabel;

  /// Title for the driver rating section (Track B - Ticket #62)
  ///
  /// In en, this message translates to:
  /// **'Rate your driver'**
  String get rideSummaryRatingTitle;

  /// Subtitle for the driver rating section (Track B - Ticket #62)
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps keep rides safe and comfortable.'**
  String get rideSummaryRatingSubtitle;

  /// Placeholder text for the optional comment field (Track B - Ticket #62)
  ///
  /// In en, this message translates to:
  /// **'Add a comment (optional)'**
  String get rideSummaryCommentPlaceholder;

  /// Trip ID label with value (Ticket #92)
  ///
  /// In en, this message translates to:
  /// **'Trip ID: {id}'**
  String rideReceiptTripIdLabel(String id);

  /// Completed timestamp format (Ticket #92)
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String rideReceiptCompletedAt(String date, String time);

  /// From label for pickup location (Ticket #92)
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get rideReceiptFromLabel;

  /// To label for destination (Ticket #92)
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get rideReceiptToLabel;

  /// Section title for fare breakdown (Ticket #92)
  ///
  /// In en, this message translates to:
  /// **'Trip fare'**
  String get rideReceiptFareSectionTitle;

  /// Base fare label (Ticket #92)
  ///
  /// In en, this message translates to:
  /// **'Base fare'**
  String get rideReceiptBaseFareLabel;

  /// Distance fare label (Ticket #92)
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get rideReceiptDistanceFareLabel;

  /// Time fare label (Ticket #92)
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get rideReceiptTimeFareLabel;

  /// Fees label (Ticket #92)
  ///
  /// In en, this message translates to:
  /// **'Fees & surcharges'**
  String get rideReceiptFeesLabel;

  /// Total label (Ticket #92)
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get rideReceiptTotalLabel;

  /// Driver section title (Ticket #92)
  ///
  /// In en, this message translates to:
  /// **'Driver & vehicle'**
  String get rideReceiptDriverSectionTitle;

  /// Rate driver title (Ticket #92)
  ///
  /// In en, this message translates to:
  /// **'Rate your driver'**
  String get rideReceiptRateDriverTitle;

  /// Rate driver subtitle (Ticket #92)
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps keep rides safe and comfortable.'**
  String get rideReceiptRateDriverSubtitle;

  /// Done CTA button (Ticket #92)
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get rideReceiptDoneCta;

  /// Mock driver name for development (Track C - Ticket #171)
  ///
  /// In en, this message translates to:
  /// **'Ahmad M.'**
  String get rideDriverMockName;

  /// Mock driver car info for development (Track C - Ticket #171)
  ///
  /// In en, this message translates to:
  /// **'Toyota Camry • ABC 1234'**
  String get rideDriverMockCarInfo;

  /// Mock driver rating for development (Track C - Ticket #171)
  ///
  /// In en, this message translates to:
  /// **'4.9'**
  String get rideDriverMockRating;

  /// Debug CTA button to end trip (Track B - Ticket #62)
  ///
  /// In en, this message translates to:
  /// **'End trip'**
  String get rideSummaryEndTripDebugCta;

  /// Snackbar message after submitting feedback (Track B - Ticket #62)
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback.'**
  String get rideSummaryThankYouSnackbar;

  /// Generic title for active parcel card on Home Hub (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'Active shipment'**
  String get homeActiveParcelTitleGeneric;

  /// Subtitle showing destination on active parcel card (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'To {destination}'**
  String homeActiveParcelSubtitleToDestination(String destination);

  /// CTA button on Home Hub active parcel card (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'View shipment'**
  String get homeActiveParcelViewShipmentCta;

  /// Parcel status label for draft/quoting phase (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'Preparing your shipment...'**
  String get homeActiveParcelStatusPreparing;

  /// Parcel status label for scheduled (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'Pickup scheduled'**
  String get homeActiveParcelStatusScheduled;

  /// Parcel status label for pickup pending (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'Waiting for pickup'**
  String get homeActiveParcelStatusPickupPending;

  /// Parcel status label for picked up (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get homeActiveParcelStatusPickedUp;

  /// Parcel status label for in transit (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get homeActiveParcelStatusInTransit;

  /// Parcel status label for delivered (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get homeActiveParcelStatusDelivered;

  /// Parcel status label for cancelled (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'Shipment cancelled'**
  String get homeActiveParcelStatusCancelled;

  /// Parcel status label for failed (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'Delivery failed'**
  String get homeActiveParcelStatusFailed;

  /// AppBar title for active shipment screen (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'Active shipment'**
  String get parcelsActiveShipmentTitle;

  /// Title when no active shipment exists (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'No active shipment'**
  String get parcelsActiveShipmentNoActiveTitle;

  /// Subtitle when no active shipment exists (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any active shipments right now.'**
  String get parcelsActiveShipmentNoActiveSubtitle;

  /// Map placeholder text (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'Map tracking (coming soon)'**
  String get parcelsActiveShipmentMapStub;

  /// Status label with value (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String parcelsActiveShipmentStatusLabel(String status);

  /// Shipment ID label (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'Shipment ID: {id}'**
  String parcelsActiveShipmentIdLabel(String id);

  /// Note explaining this is a stub screen (Track C - Ticket #70)
  ///
  /// In en, this message translates to:
  /// **'Full tracking will be available in a future update.'**
  String get parcelsActiveShipmentStubNote;

  /// Cancel shipment button text (Track C - Ticket #81)
  ///
  /// In en, this message translates to:
  /// **'Cancel shipment'**
  String get parcelsDetailsCancelShipmentCta;

  /// Cancel confirmation dialog title (Track C - Ticket #81)
  ///
  /// In en, this message translates to:
  /// **'Cancel this shipment?'**
  String get parcelsCancelDialogTitle;

  /// Cancel confirmation dialog subtitle (Track C - Ticket #81)
  ///
  /// In en, this message translates to:
  /// **'If you cancel now, this shipment will be stopped and will no longer appear as active.'**
  String get parcelsCancelDialogSubtitle;

  /// Cancel confirmation dialog confirm button (Track C - Ticket #81)
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel'**
  String get parcelsCancelDialogConfirmCta;

  /// Cancel confirmation dialog dismiss button (Track C - Ticket #81)
  ///
  /// In en, this message translates to:
  /// **'Keep shipment'**
  String get parcelsCancelDialogDismissCta;

  /// Success message after cancelling shipment (Track C - Ticket #81)
  ///
  /// In en, this message translates to:
  /// **'Shipment has been cancelled.'**
  String get parcelsCancelSuccessMessage;

  /// Bottom navigation Home tab label (Track A - Ticket #82)
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHomeLabel;

  /// Bottom navigation Orders tab label (Track A - Ticket #82)
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get bottomNavOrdersLabel;

  /// Bottom navigation Payments tab label (Track A - Ticket #82)
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get bottomNavPaymentsLabel;

  /// Bottom navigation Profile tab label (Track A - Ticket #82)
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get bottomNavProfileLabel;

  /// Label for current location in Home tab top bar (Track A - Ticket #228)
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get homeCurrentLocationLabel;

  /// Placeholder text for pickup location in Home tab top bar (Track A - Ticket #228)
  ///
  /// In en, this message translates to:
  /// **'Set pickup location'**
  String get homeCurrentLocationPlaceholder;

  /// Title for ride service card in Home tab (Track A - Ticket #228)
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get homeServiceRideTitle;

  /// Title for parcels service card in Home tab (Track A - Ticket #228)
  ///
  /// In en, this message translates to:
  /// **'Parcels'**
  String get homeServiceParcelsTitle;

  /// Title for food service card in Home tab (Track A - Ticket #228)
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get homeServiceFoodTitle;

  /// Subtitle for ride service card in Home tab (Track A - Ticket #228)
  ///
  /// In en, this message translates to:
  /// **'Get a ride in minutes'**
  String get homeServiceRideSubtitle;

  /// Subtitle for parcels service card in Home tab (Track A - Ticket #228)
  ///
  /// In en, this message translates to:
  /// **'Send and track parcels'**
  String get homeServiceParcelsSubtitle;

  /// Subtitle for food service card in Home tab (Track A - Ticket #228)
  ///
  /// In en, this message translates to:
  /// **'Order food from nearby restaurants'**
  String get homeServiceFoodSubtitle;

  /// Placeholder text for search input in Home tab (Track A - Ticket #228)
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get homeSearchPlaceholder;

  /// Payments stub screen title (Track A - Ticket #82)
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsEntryTitle;

  /// Payments stub screen body text (Track A - Ticket #82)
  ///
  /// In en, this message translates to:
  /// **'Payments management will be available in a future update.'**
  String get paymentsEntryStubBody;

  /// Payments screen title (Track B - Ticket #99)
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsTitle;

  /// CTA button to add a new payment method (Track B - Ticket #99)
  ///
  /// In en, this message translates to:
  /// **'Add new payment method'**
  String get paymentsAddMethodCta;

  /// Empty state title when no payment methods (Track B - Ticket #99)
  ///
  /// In en, this message translates to:
  /// **'No payment methods saved'**
  String get paymentsEmptyTitle;

  /// Empty state body text for payments (Track B - Ticket #99)
  ///
  /// In en, this message translates to:
  /// **'Your saved cards and payment options will appear here.'**
  String get paymentsEmptyBody;

  /// Payment method type label for Cash (Track B - Ticket #99)
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentsMethodTypeCash;

  /// Payment method type label for Card (Track B - Ticket #99)
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentsMethodTypeCard;

  /// Badge label for default payment method (Track B - Ticket #99)
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get paymentsDefaultBadge;

  /// Coming soon message for add payment method (Track B - Ticket #99)
  ///
  /// In en, this message translates to:
  /// **'Adding new payment methods will be available soon.'**
  String get paymentsAddMethodComingSoon;

  /// Card expiry format for payment method subtitle (Track A - Ticket #225)
  ///
  /// In en, this message translates to:
  /// **'Expiry {month}/{year}'**
  String paymentsCardExpiry(int month, int year);

  /// Payment method type label for Apple Pay (Track A - Ticket #225)
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get paymentsMethodTypeApplePay;

  /// Payment method type label for Google Pay (Track A - Ticket #225)
  ///
  /// In en, this message translates to:
  /// **'Google Pay'**
  String get paymentsMethodTypeGooglePay;

  /// Payment method type label for Digital Wallet (Track A - Ticket #225)
  ///
  /// In en, this message translates to:
  /// **'Digital Wallet'**
  String get paymentsMethodTypeDigitalWallet;

  /// Payment method type label for Bank Transfer (Track A - Ticket #225)
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get paymentsMethodTypeBankTransfer;

  /// Payment method type label for Cash on Delivery (Track A - Ticket #225)
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get paymentsMethodTypeCashOnDelivery;

  /// Profile stub screen title - unused as full profile exists (Track A - Ticket #82)
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileEntryTitle;

  /// Profile stub screen body text - unused as full profile exists (Track A - Ticket #82)
  ///
  /// In en, this message translates to:
  /// **'Profile and account settings will be available in a future update.'**
  String get profileEntryStubBody;

  /// Short status label for ride in draft phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get rideStatusShortDraft;

  /// Short status label for ride in quoting phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Getting price'**
  String get rideStatusShortQuoting;

  /// Short status label for ride in requesting phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Requesting ride'**
  String get rideStatusShortRequesting;

  /// Short status label for ride in findingDriver phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Finding driver'**
  String get rideStatusShortFindingDriver;

  /// Short status label for ride in driverAccepted phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Driver accepted'**
  String get rideStatusShortDriverAccepted;

  /// Short status label for ride in driverArrived phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Driver arrived'**
  String get rideStatusShortDriverArrived;

  /// Short status label for ride in inProgress phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get rideStatusShortInProgress;

  /// Short status label for ride in payment phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Payment in progress'**
  String get rideStatusShortPayment;

  /// Short status label for ride in completed phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get rideStatusShortCompleted;

  /// Short status label for ride in cancelled phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get rideStatusShortCancelled;

  /// Short status label for ride in failed phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get rideStatusShortFailed;

  /// Long status label for ride in draft/quoting/requesting phases (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Preparing your trip...'**
  String get homeActiveRideStatusPreparing;

  /// Long status label for ride in findingDriver phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Looking for a driver...'**
  String get homeActiveRideStatusFindingDriver;

  /// Long status label for ride in driverAccepted phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Driver on the way'**
  String get homeActiveRideStatusDriverAccepted;

  /// Long status label for ride in driverArrived phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived'**
  String get homeActiveRideStatusDriverArrived;

  /// Long status label for ride in inProgress phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Trip in progress'**
  String get homeActiveRideStatusInProgress;

  /// Long status label for ride in payment phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Finalizing payment'**
  String get homeActiveRideStatusPayment;

  /// Long status label for ride in completed phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Trip completed'**
  String get homeActiveRideStatusCompleted;

  /// Long status label for ride in cancelled phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Trip cancelled'**
  String get homeActiveRideStatusCancelled;

  /// Long status label for ride in failed phase (Track B - Ticket #85)
  ///
  /// In en, this message translates to:
  /// **'Trip failed'**
  String get homeActiveRideStatusFailed;

  /// AppBar title for active trip screen (Track B - Ticket #87)
  ///
  /// In en, this message translates to:
  /// **'Active trip'**
  String get rideActiveTripTitle;

  /// Pickup address label with value (Track B - Ticket #87)
  ///
  /// In en, this message translates to:
  /// **'From: {pickup}'**
  String rideActiveTripFromLabel(String pickup);

  /// Dropoff address label with value (Track B - Ticket #87)
  ///
  /// In en, this message translates to:
  /// **'To: {dropoff}'**
  String rideActiveTripToLabel(String dropoff);

  /// Trip ID label with value (Track B - Ticket #87)
  ///
  /// In en, this message translates to:
  /// **'Trip ID: {id}'**
  String rideActiveTripIdLabel(String id);

  /// [RESERVED - Ticket #88] Fallback text when map fails to load. Currently unused as real MapWidget is active.
  ///
  /// In en, this message translates to:
  /// **'Live map tracking (coming soon)'**
  String get rideActiveTripMapStub;

  /// [RESERVED - Ticket #88] Fallback note for map stub. Currently unused.
  ///
  /// In en, this message translates to:
  /// **'Full live tracking will be available after integration with the mobility service.'**
  String get rideActiveTripStubNote;

  /// [RESERVED - Ticket #88] Generic status label. Prefer specific headline keys for UI.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String rideActiveTripStatusLabel(String status);

  /// Driver section title (Track B - Ticket #87, #88)
  ///
  /// In en, this message translates to:
  /// **'Driver & vehicle'**
  String get rideActiveTripDriverSectionTitle;

  /// [RESERVED - Ticket #88] Fallback when driver data unavailable. Currently using mock data.
  ///
  /// In en, this message translates to:
  /// **'Driver and vehicle details will be available once the mobility integration is connected.'**
  String get rideActiveTripDriverSectionStubBody;

  /// Empty state title when no orders at all (Track B - Ticket #125)
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersHistoryEmptyAllTitle;

  /// Empty state description when no orders at all (Track B - Ticket #125)
  ///
  /// In en, this message translates to:
  /// **'Your rides, parcels and food orders will appear here.'**
  String get ordersHistoryEmptyAllDescription;

  /// Empty state title when no ride orders (Track B - Ticket #125)
  ///
  /// In en, this message translates to:
  /// **'No rides yet'**
  String get ordersHistoryEmptyRidesTitle;

  /// Empty state description when no ride orders (Track B - Ticket #125)
  ///
  /// In en, this message translates to:
  /// **'Your completed rides will appear here.'**
  String get ordersHistoryEmptyRidesDescription;

  /// Empty state title when no parcel orders (Track B - Ticket #125)
  ///
  /// In en, this message translates to:
  /// **'No parcels yet'**
  String get ordersHistoryEmptyParcelsTitle;

  /// Empty state description when no parcel orders (Track B - Ticket #125)
  ///
  /// In en, this message translates to:
  /// **'Your shipments will appear here.'**
  String get ordersHistoryEmptyParcelsDescription;

  /// Empty state title when no food orders (Track B - Ticket #125)
  ///
  /// In en, this message translates to:
  /// **'No food orders yet'**
  String get ordersHistoryEmptyFoodTitle;

  /// Empty state description when no food orders (Track B - Ticket #125)
  ///
  /// In en, this message translates to:
  /// **'Your food delivery orders will appear here.'**
  String get ordersHistoryEmptyFoodDescription;

  /// Accessibility label for ride order service icon (Track B - Ticket #127)
  ///
  /// In en, this message translates to:
  /// **'Ride order'**
  String get ordersServiceRideSemanticLabel;

  /// Accessibility label for parcel order card (Track B - Ticket #127)
  ///
  /// In en, this message translates to:
  /// **'Parcel shipment'**
  String get ordersServiceParcelSemanticLabel;

  /// Accessibility label for food order service icon (Track B - Ticket #127)
  ///
  /// In en, this message translates to:
  /// **'Food order'**
  String get ordersServiceFoodSemanticLabel;

  /// Title for parcels shipments list screen (Track C - Ticket #149)
  ///
  /// In en, this message translates to:
  /// **'My Shipments'**
  String get parcelsShipmentsTitle;

  /// Tooltip for new shipment button (Track C - Ticket #149)
  ///
  /// In en, this message translates to:
  /// **'New shipment'**
  String get parcelsShipmentsNewShipmentTooltip;

  /// Empty state title for shipments list (Track C - Ticket #149)
  ///
  /// In en, this message translates to:
  /// **'No shipments yet'**
  String get parcelsShipmentsEmptyTitle;

  /// Empty state description for shipments list (Track C - Ticket #149)
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any shipments yet. Create your first shipment to start sending parcels.'**
  String get parcelsShipmentsEmptyDescription;

  /// CTA button for empty shipments state (Track C - Ticket #149)
  ///
  /// In en, this message translates to:
  /// **'Create first shipment'**
  String get parcelsShipmentsEmptyCta;

  /// Shipment status: created (Track C - Ticket #149)
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get parcelsShipmentStatusCreated;

  /// Shipment status: in transit (Track C - Ticket #149)
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get parcelsShipmentStatusInTransit;

  /// Shipment status: delivered (Track C - Ticket #149)
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get parcelsShipmentStatusDelivered;

  /// Shipment status: cancelled (Track C - Ticket #149)
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get parcelsShipmentStatusCancelled;

  /// Error state title for shipments list (Track C - Ticket #149)
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get parcelsShipmentsErrorTitle;

  /// Create shipment button label (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Create shipment'**
  String get parcelsCreateShipmentCta;

  /// Sender section title (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Sender details'**
  String get parcelsCreateShipmentSenderSectionTitle;

  /// Receiver section title (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Receiver details'**
  String get parcelsCreateShipmentReceiverSectionTitle;

  /// Parcel details section title (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Parcel details'**
  String get parcelsCreateShipmentParcelDetailsSectionTitle;

  /// Sender name field label (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Sender name'**
  String get parcelsCreateShipmentSenderNameLabel;

  /// Sender phone field label (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Sender phone'**
  String get parcelsCreateShipmentSenderPhoneLabel;

  /// Receiver name field label (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Receiver name'**
  String get parcelsCreateShipmentReceiverNameLabel;

  /// Receiver phone field label (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Receiver phone'**
  String get parcelsCreateShipmentReceiverPhoneLabel;

  /// Pickup address field label (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Pickup address'**
  String get parcelsCreateShipmentPickupAddressLabel;

  /// Dropoff address field label (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Dropoff address'**
  String get parcelsCreateShipmentDropoffAddressLabel;

  /// Weight field label (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get parcelsCreateShipmentWeightLabel;

  /// Size field label (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get parcelsCreateShipmentSizeLabel;

  /// Notes field label (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get parcelsCreateShipmentNotesLabel;

  /// Service type section label (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Service type'**
  String get parcelsCreateShipmentServiceTypeLabel;

  /// Express service type (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Express'**
  String get parcelsCreateShipmentServiceTypeExpress;

  /// Standard service type (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get parcelsCreateShipmentServiceTypeStandard;

  /// Service type validation error (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Please select a service type'**
  String get parcelsCreateShipmentServiceTypeError;

  /// Success message after creating shipment (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Shipment created successfully'**
  String get parcelsCreateShipmentSuccessMessage;

  /// Generic field required error (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get commonErrorFieldRequired;

  /// Addresses section title (Track C - Ticket #150)
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get commonAddressesTitle;

  /// Contacts section title (Track C - Ticket #151)
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get parcelsShipmentDetailsContactsSectionTitle;

  /// Details section title (Track C - Ticket #151)
  ///
  /// In en, this message translates to:
  /// **'Parcel details'**
  String get parcelsShipmentDetailsDetailsSectionTitle;

  /// Service type label (Track C - Ticket #151)
  ///
  /// In en, this message translates to:
  /// **'Service type'**
  String get parcelsShipmentDetailsServiceTypeLabel;

  /// Total price label (Track C - Ticket #151)
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotalLabel;

  /// Title for the recent destinations shortcuts section on the HomeHub screen (Ticket #189)
  ///
  /// In en, this message translates to:
  /// **'Recent destinations'**
  String get homeHubRecentDestinationsTitle;

  /// Button label to show all recent destinations from HomeHub (Ticket #194)
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeHubRecentDestinationsSeeAll;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Delivery Ways';

  @override
  String get authPhoneTitle => 'Anmelden';

  @override
  String get authPhoneSubtitle =>
      'Geben Sie Ihre Handynummer ein, um sich bei Delivery Ways anzumelden.';

  @override
  String get authPhoneFieldHint => 'Handynummer';

  @override
  String get authPhoneContinueCta => 'Weiter';

  @override
  String get authOtpTitle => 'Code eingeben';

  @override
  String get authOtpSubtitle =>
      'Wir haben einen Verifizierungscode an Ihr Telefon gesendet.';

  @override
  String get authOtpFieldHint => 'Verifizierungscode';

  @override
  String get authOtpVerifyCta => 'Verifizieren und fortfahren';

  @override
  String get accountSheetTitle => 'Konto';

  @override
  String get accountSheetSignedOutSubtitle =>
      'Sie sind nicht angemeldet. Melden Sie sich an, um Ihre Fahrten und Lieferungen zu synchronisieren.';

  @override
  String get accountSheetSignInCta => 'Mit Telefon anmelden';

  @override
  String get accountSheetSignedInTitle => 'Angemeldet';

  @override
  String get accountSheetSignOutCta => 'Abmelden';

  @override
  String get accountSheetFooterText =>
      'Weitere Kontooptionen demnächst verfügbar.';

  @override
  String get initializing => 'Initialisierung...';

  @override
  String get back => 'Zurück';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Schließen';

  @override
  String get error => 'Fehler';

  @override
  String get loading => 'Laden...';

  @override
  String get comingSoon => 'Demnächst verfügbar';

  @override
  String get authPhoneLoginTitle => 'Anmelden';

  @override
  String get authPhoneLoginSubtitle =>
      'Geben Sie Ihre Telefonnummer ein, um sich anzumelden oder ein neues Konto zu erstellen.';

  @override
  String get authPhoneFieldLabel => 'Telefonnummer';

  @override
  String get authPhoneContinueButton => 'Weiter';

  @override
  String get authPhoneRequiredError =>
      'Bitte geben Sie Ihre Telefonnummer ein.';

  @override
  String get authPhoneInvalidFormatError =>
      'Bitte geben Sie eine gültige Telefonnummer ein.';

  @override
  String get authPhoneSubmitError =>
      'Verifizierungscode konnte nicht gesendet werden. Bitte versuchen Sie es erneut.';

  @override
  String get authOtpFieldLabel => 'Verifizierungscode';

  @override
  String get authOtpConfirmButton => 'Verifizieren';

  @override
  String get authOtpRequiredError =>
      'Bitte geben Sie den Verifizierungscode ein.';

  @override
  String get authOtpInvalidFormatError =>
      'Bitte geben Sie einen gültigen 4-6-stelligen Code ein.';

  @override
  String get authOtpSubmitError =>
      'Ungültiger oder abgelaufener Verifizierungscode.';

  @override
  String get authOtpResendButton => 'Code erneut senden';

  @override
  String authOtpResendCountdown(int seconds) {
    return 'Code erneut senden in $seconds Sekunden';
  }

  @override
  String get authBiometricButtonLabel => 'Biometrie verwenden';

  @override
  String get authBiometricReason =>
      'Authentifizieren Sie sich, um fortzufahren.';

  @override
  String get authBiometricUnlockError =>
      'Entsperren mit Biometrie nicht möglich. Bitte fordern Sie einen neuen Code an.';

  @override
  String authCooldownMessage(int seconds) {
    return 'Bitte warten Sie ${seconds}s, bevor Sie es erneut versuchen.';
  }

  @override
  String get authCooldownReady => 'Sie können jetzt erneut senden.';

  @override
  String authAttemptsRemaining(int count) {
    return '$count Versuche übrig';
  }

  @override
  String get authNoAttemptsRemaining => 'Keine Versuche mehr übrig.';

  @override
  String get auth2faTitle => 'Zwei-Faktor-Authentifizierung';

  @override
  String get auth2faSubtitle =>
      'Ein zusätzlicher Verifizierungsschritt ist für Ihre Sicherheit erforderlich.';

  @override
  String get auth2faSelectMethod => 'Verifizierungsmethode auswählen';

  @override
  String get auth2faMethodSms => 'SMS';

  @override
  String auth2faMethodSmsDescription(String destination) {
    return 'Code per SMS an $destination erhalten';
  }

  @override
  String get auth2faMethodTotp => 'Authenticator-App';

  @override
  String get auth2faMethodTotpDescription =>
      'Verwenden Sie Ihre Authenticator-App, um einen Code zu generieren';

  @override
  String get auth2faMethodEmail => 'E-Mail';

  @override
  String auth2faMethodEmailDescription(String destination) {
    return 'Code per E-Mail an $destination erhalten';
  }

  @override
  String get auth2faMethodPush => 'Push-Benachrichtigung';

  @override
  String get auth2faMethodPushDescription =>
      'Bestätigen Sie die Anfrage auf Ihrem registrierten Gerät';

  @override
  String get auth2faEnterCode => 'Verifizierungscode eingeben';

  @override
  String get auth2faCodeHint => '6-stelligen Code eingeben';

  @override
  String get auth2faVerifyButton => 'Verifizieren';

  @override
  String get auth2faCancelButton => 'Abbrechen';

  @override
  String get auth2faResendCode => 'Code erneut senden';

  @override
  String get auth2faCodeExpired =>
      'Code abgelaufen. Bitte fordern Sie einen neuen an.';

  @override
  String get auth2faInvalidCode =>
      'Ungültiger Code. Bitte versuchen Sie es erneut.';

  @override
  String get auth2faAccountLocked =>
      'Zu viele Versuche. Konto vorübergehend gesperrt.';

  @override
  String auth2faLockoutMessage(int minutes) {
    return 'Bitte versuchen Sie es nach $minutes Minuten erneut.';
  }

  @override
  String get notificationsSettingsTitle => 'Benachrichtigungseinstellungen';

  @override
  String get notificationsSettingsOrderStatusTitle =>
      'Bestellstatus-Benachrichtigungen';

  @override
  String get notificationsSettingsOrderStatusSubtitle =>
      'Erhalten Sie Echtzeit-Updates zu Ihren aktiven Bestellungen.';

  @override
  String get notificationsSettingsPromotionsTitle => 'Werbeaktionen';

  @override
  String get notificationsSettingsPromotionsSubtitle =>
      'Erhalten Sie personalisierte Angebote und Rabatte.';

  @override
  String get notificationsSettingsSystemTitle => 'Systembenachrichtigungen';

  @override
  String get notificationsSettingsSystemSubtitle =>
      'Wichtige Hinweise zu Ihrem Konto und System.';

  @override
  String get notificationsSettingsConsentRequired =>
      'Erteilen Sie die Benachrichtigungsberechtigung, um diese Einstellungen zu aktivieren.';

  @override
  String get notificationsSettingsErrorGeneric =>
      'Benachrichtigungseinstellungen konnten nicht geladen werden. Bitte versuchen Sie es erneut.';

  @override
  String get notificationsSettingsErrorLoading =>
      'Fehler beim Laden der Benachrichtigungseinstellungen';

  @override
  String get notificationsSettingsSystemSettingsButton =>
      'Systemeinstellungen öffnen';

  @override
  String get notificationsSettingsSystemSettingsPlaceholder =>
      'Systemeinstellungen werden bald geöffnet';

  @override
  String get notificationsSettingsQuietHoursTitle => 'Ruhezeiten';

  @override
  String get notificationsSettingsQuietHoursNotEnabled =>
      'Bitte-nicht-stören-Modus nicht aktiviert';

  @override
  String get settingsSectionNotifications => 'Benachrichtigungseinstellungen';

  @override
  String get notificationsInboxTitle => 'Benachrichtigungen';

  @override
  String get notificationsInboxErrorGeneric =>
      'Benachrichtigungen konnten nicht geladen werden. Bitte versuchen Sie es erneut.';

  @override
  String get notificationsInboxRetryButtonLabel => 'Erneut versuchen';

  @override
  String get notificationsInboxEmptyTitle => 'Noch keine Benachrichtigungen';

  @override
  String get notificationsInboxEmptySubtitle =>
      'Wichtige Hinweise zu Ihren Bestellungen und Angeboten werden hier angezeigt.';

  @override
  String get notificationsInboxEmptyCtaBackToHomeLabel =>
      'Zurück zur Startseite';

  @override
  String get notificationsInboxMarkAsReadTooltip => 'Als gelesen markieren';

  @override
  String get notificationsInboxMarkAllAsReadTooltip =>
      'Alle als gelesen markieren';

  @override
  String get notificationsInboxClearAllTooltip => 'Alle löschen';

  @override
  String get notificationsInboxClearAllDialogTitle =>
      'Alle Benachrichtigungen löschen';

  @override
  String get notificationsInboxClearAllDialogMessage =>
      'Möchten Sie wirklich alle Benachrichtigungen löschen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get notificationsInboxClearAllConfirm => 'Alle löschen';

  @override
  String get notificationsInboxTappedGeneric => 'Benachrichtigung geöffnet';

  @override
  String get notificationsInboxTimeNow => 'jetzt';

  @override
  String notificationsInboxTimeMinutes(int minutes) {
    return 'vor ${minutes}min';
  }

  @override
  String notificationsInboxTimeHours(int hours) {
    return 'vor ${hours}h';
  }

  @override
  String notificationsInboxTimeDays(int days) {
    return 'vor ${days}T';
  }

  @override
  String get privacyConsentTitle => 'Datenschutz & Einwilligung';

  @override
  String get privacyConsentHeadline => 'Kontrollieren Sie Ihre Privatsphäre';

  @override
  String get privacyConsentDescription =>
      'Wählen Sie, was Sie mit uns teilen möchten, um Ihre Erfahrung zu verbessern';

  @override
  String get privacyConsentAnalyticsTitle => 'Nutzungsanalysen';

  @override
  String get privacyConsentAnalyticsDescription =>
      'Hilft uns zu verstehen, wie die App genutzt wird, um Leistung und Funktionen zu verbessern';

  @override
  String get privacyConsentCrashReportsTitle => 'Absturzberichte';

  @override
  String get privacyConsentCrashReportsDescription =>
      'Sendet automatisch Absturzberichte, um uns bei der Behebung von Problemen zu helfen';

  @override
  String get privacyConsentBackgroundLocationTitle => 'Standort im Hintergrund';

  @override
  String get privacyConsentBackgroundLocationDescription =>
      'Ermöglicht Standortverfolgung auch bei geschlossener App zur Verbesserung der Lieferservices';

  @override
  String get privacyConsentSaveSuccess =>
      'Datenschutzeinstellungen gespeichert';

  @override
  String privacyConsentErrorPrefix(String message) {
    return 'Fehler: $message';
  }

  @override
  String get dsrExportTitle => 'Daten exportieren';

  @override
  String get dsrExportHeadline => 'Exportieren Sie Ihre persönlichen Daten';

  @override
  String get dsrExportDescription =>
      'Sie erhalten einen sicheren Link zum Herunterladen aller Ihrer Daten. Der Link ist nur 7 Tage gültig.';

  @override
  String get dsrExportIncludePaymentsTitle => 'Zahlungsverlauf einschließen';

  @override
  String get dsrExportIncludePaymentsDescription =>
      'Der Zahlungsverlauf kann sensible Informationen enthalten. Bitte überprüfen Sie die Datei sorgfältig.';

  @override
  String get dsrExportStartButton => 'Export starten';

  @override
  String get dsrExportRequestStatus => 'Anfragestatus';

  @override
  String dsrExportRequestDate(String date) {
    return 'Antragsdatum: $date';
  }

  @override
  String get dsrExportDownloadLink => 'Download-Link';

  @override
  String dsrExportLinkExpires(String date) {
    return 'Läuft ab: $date';
  }

  @override
  String get dsrExportCopyLink => 'Link kopieren';

  @override
  String get dsrExportLinkCopied => 'Link kopiert';

  @override
  String get dsrExportPreparingFile => 'Ihre Datei wird vorbereitet…';

  @override
  String get dsrExportSendingRequest => 'Exportanfrage wird gesendet…';

  @override
  String get dsrExportRequestFailed => 'Anfrage konnte nicht gesendet werden';

  @override
  String get dsrErasureTitle => 'Konto löschen';

  @override
  String get dsrErasureHeadline => 'Konto dauerhaft löschen';

  @override
  String get dsrErasureDescription =>
      'Diese Aktion kann nicht rückgängig gemacht werden. Alle Ihre Daten und Kontoinformationen werden gelöscht.';

  @override
  String get dsrErasureRequestButton => 'Kontolöschung beantragen';

  @override
  String get dsrErasureWarningTitle => 'Wichtige Warnung';

  @override
  String get dsrErasureWarningPoint1 =>
      'Alle Ihre persönlichen Daten werden dauerhaft gelöscht';

  @override
  String get dsrErasureWarningPoint2 =>
      'Sie können Ihr Konto oder Ihre Daten nicht wiederherstellen';

  @override
  String get dsrErasureWarningPoint3 =>
      'Alle aktiven Bestellungen und Reservierungen werden storniert';

  @override
  String get dsrErasureWarningPoint4 =>
      'Ihr Zahlungs- und Transaktionsverlauf wird gelöscht';

  @override
  String get dsrErasureWarningPoint5 =>
      'Die Bearbeitung der Anfrage kann mehrere Tage dauern';

  @override
  String get dsrErasureLegalNotice =>
      'Die Kontolöschung unterliegt der Datenschutz-Grundverordnung (DSGVO). Wir senden Ihnen vor der endgültigen Löschung eine Bestätigung.';

  @override
  String get dsrErasureRequestStatus => 'Anfragestatus';

  @override
  String get dsrErasureStatusPending => 'Wartet auf Überprüfung';

  @override
  String get dsrErasureStatusInProgress => 'In Bearbeitung';

  @override
  String get dsrErasureStatusReady => 'Bereit zur Bestätigung';

  @override
  String get dsrErasureStatusCompleted => 'Abgeschlossen';

  @override
  String get dsrErasureStatusFailed => 'Verarbeitung fehlgeschlagen';

  @override
  String get dsrErasureStatusCanceled => 'Abgebrochen';

  @override
  String get dsrErasureReviewingRequest => 'Ihre Anfrage wird überprüft…';

  @override
  String get dsrErasureSendingRequest => 'Löschanfrage wird gesendet…';

  @override
  String get dsrErasureRequestFailed => 'Anfrage konnte nicht gesendet werden';

  @override
  String get dsrErasureNewRequest => 'Neue Löschung beantragen';

  @override
  String get dsrErasureConfirmTitle => 'Endgültige Löschung bestätigen';

  @override
  String get dsrErasureConfirmMessage =>
      'Dies ist der letzte Schritt. Nach der Bestätigung wird Ihr Konto innerhalb von 30 Tagen dauerhaft gelöscht und diese Entscheidung kann nicht rückgängig gemacht werden.';

  @override
  String get dsrErasureConfirmButton => 'Löschung bestätigen';

  @override
  String get legalPrivacyPolicyTitle => 'Datenschutzrichtlinie';

  @override
  String get legalPrivacyPolicyUnavailable =>
      'Die Datenschutzrichtlinie ist derzeit nicht verfügbar.';

  @override
  String get legalTermsOfServiceTitle => 'Nutzungsbedingungen';

  @override
  String get legalTermsOfServiceUnavailable =>
      'Die Nutzungsbedingungen sind derzeit nicht verfügbar.';

  @override
  String get legalAboutTitle => 'Rechtliche Informationen';

  @override
  String get legalPrivacyButton => 'Datenschutzrichtlinie';

  @override
  String get legalTermsButton => 'Nutzungsbedingungen';

  @override
  String get legalOpenSourceLicenses => 'Open-Source-Lizenzen';

  @override
  String get ordersTitle => 'Bestellungen';

  @override
  String ordersOrderLabel(String orderId) {
    return 'Bestellung: $orderId';
  }

  @override
  String get cartTitle => 'Warenkorb';

  @override
  String cartItemsLabel(int count) {
    return 'Artikel: $count';
  }

  @override
  String get checkoutTitle => 'Zur Kasse';

  @override
  String get paymentTitle => 'Zahlung';

  @override
  String get paymentInitializing => 'Zahlungssystem wird initialisiert...';

  @override
  String get paymentDebugTitle => 'Zahlungs-Debug';

  @override
  String paymentEnabled(String enabled) {
    return 'Zahlungen aktiviert: $enabled';
  }

  @override
  String paymentMissingKeys(String keys) {
    return 'Fehlende Konfigurationsschlüssel: $keys';
  }

  @override
  String paymentGatewayStatus(String status) {
    return 'Gateway-Status: $status';
  }

  @override
  String paymentGateway(String type) {
    return 'Gateway: $type';
  }

  @override
  String paymentSheetStatus(String status) {
    return 'Sheet-Status: $status';
  }

  @override
  String paymentSheet(String type) {
    return 'Sheet: $type';
  }

  @override
  String get paymentApplePay => 'Mit Apple Pay bezahlen';

  @override
  String get paymentGooglePay => 'Mit Google Pay bezahlen';

  @override
  String get paymentDigitalWallet => 'Mit Digital Wallet bezahlen';

  @override
  String get paymentCash => 'Bar bezahlen';

  @override
  String get trackingTitle => 'Sendungsverfolgung';

  @override
  String get trackingLocationTitle => 'Standortverfolgung';

  @override
  String get trackingCurrentLocation => 'Aktueller Standort';

  @override
  String get trackingTripRoute => 'Fahrtroute';

  @override
  String get trackingRealtimeUnavailableTitle =>
      'Live-Tracking nicht verfügbar';

  @override
  String get trackingRealtimeUnavailableBody =>
      'Die Echtzeit-Sendungsverfolgung ist derzeit nicht verfügbar. Ihr Bestellstatus wird automatisch aktualisiert.';

  @override
  String get trackingOrderStatus => 'Bestellstatus';

  @override
  String get trackingNoActiveTrip => 'Keine aktive Fahrt';

  @override
  String get mapTitle => 'Karte';

  @override
  String get mapSmokeTestTitle => 'Karten-Smoke-Test';

  @override
  String get mapTestLocation => 'Teststandort';

  @override
  String get mobilityBgTestsTitle => 'Mobilitäts-Hintergrundtests (Phase-3)';

  @override
  String get mobilityTestBackgroundTracking => 'Hintergrundverfolgung testen';

  @override
  String get mobilityTestGeofence => 'Geofence testen';

  @override
  String get mobilityTestTripRecording => 'Fahrtaufzeichnung testen';

  @override
  String get adminPanelTitle => 'Admin-Panel';

  @override
  String get adminUserInfo => 'Benutzerinformationen';

  @override
  String adminUserLabel(String userId) {
    return 'Benutzer: $userId';
  }

  @override
  String adminRoleLabel(String role) {
    return 'Rolle: $role';
  }

  @override
  String get adminUserManagement => 'Benutzerverwaltung';

  @override
  String get adminAnalyticsReports => 'Analysen & Berichte';

  @override
  String get adminAnalyticsAccess => 'Sie haben Zugriff auf Analysen';

  @override
  String get adminSystemMonitoring => 'Systemüberwachung';

  @override
  String get adminRbacStats => 'RBAC-Statistiken';

  @override
  String adminRbacEnabled(String status) {
    return 'Status: $status';
  }

  @override
  String get adminRbacStatusEnabled => 'Aktiviert';

  @override
  String get adminRbacStatusDisabled => 'Deaktiviert';

  @override
  String adminCanaryPercentage(int percentage) {
    return 'Canary-Prozentsatz: $percentage%';
  }

  @override
  String adminRolesCount(int count) {
    return 'Anzahl der Rollen: $count';
  }

  @override
  String adminTotalPermissions(int count) {
    return 'Gesamtberechtigungen: $count';
  }

  @override
  String get trackingCheckingAvailability =>
      'Prüfe Verfügbarkeit der Sendungsverfolgung...';

  @override
  String get trackingLoadingRoute => 'Route wird geladen...';

  @override
  String get ordersHistoryTitle => 'Meine Bestellungen';

  @override
  String get ordersHistoryEmptyTitle => 'Noch keine Bestellungen';

  @override
  String get ordersHistoryEmptySubtitle =>
      'Sie haben noch keine Bestellungen. Erstellen Sie zuerst eine neue Sendung.';

  @override
  String get ordersHistoryUnavailableTitle => 'Bestellungen nicht verfügbar';

  @override
  String get ordersHistoryLoadError =>
      'Bestellverlauf konnte nicht geladen werden';

  @override
  String get ordersFilterAll => 'Alle';

  @override
  String get ordersFilterParcels => 'Pakete';

  @override
  String get ordersFilterRides => 'Fahrten';

  @override
  String get ordersSectionRidesTitle => 'Fahrten';

  @override
  String ordersRideItemTitleToDestination(String destination) {
    return 'Fahrt nach $destination';
  }

  @override
  String ordersRideItemTitleWithService(
    String serviceName,
    String destination,
  ) {
    return '$serviceName nach $destination';
  }

  @override
  String ordersRideItemSubtitleWithOrigin(String origin, String date) {
    return 'Von $origin · $date';
  }

  @override
  String get ordersRideStatusCompleted => 'Abgeschlossen';

  @override
  String get ordersRideStatusCancelled => 'Storniert';

  @override
  String get ordersRideStatusFailed => 'Fehlgeschlagen';

  @override
  String get paymentMethodsTitle => 'Zahlungsmethoden';

  @override
  String get paymentMethodsEmptyTitle => 'Keine Zahlungsmethoden';

  @override
  String get paymentMethodsEmptySubtitle =>
      'Fügen Sie eine Zahlungsmethode hinzu, um zu beginnen';

  @override
  String get paymentMethodsAddButton => 'Zahlungsmethode hinzufügen';

  @override
  String get paymentMethodsLoadError =>
      'Zahlungsmethoden konnten nicht geladen werden';

  @override
  String get paymentMethodsSaving => 'Wird gespeichert...';

  @override
  String get authVerifying => 'Wird verifiziert...';

  @override
  String get authSendingCode => 'Code wird gesendet...';

  @override
  String get featureUnavailableTitle => 'Funktion nicht verfügbar';

  @override
  String get featureUnavailableGeneric =>
      'Diese Funktion ist derzeit nicht verfügbar. Bitte versuchen Sie es später erneut.';

  @override
  String get onbWelcomeTitle => 'Willkommen bei Delivery Ways';

  @override
  String get onbWelcomeBody =>
      'Ihr zuverlässiger Lieferpartner. Bestellen Sie, was Sie brauchen, und verfolgen Sie Ihre Lieferung in Echtzeit.';

  @override
  String get onbAppIntroTitle => 'So funktioniert\'s';

  @override
  String get onbAppIntroBody =>
      'Produkte durchsuchen, bestellen und wir liefern an Ihre Tür. Einfach und schnell.';

  @override
  String get onbOrderingTitle => 'Einfach Bestellen';

  @override
  String get onbOrderingBody =>
      'Finden Sie, was Sie brauchen, legen Sie es in den Warenkorb und bezahlen Sie in Sekunden. Mehrere Zahlungsoptionen wo unterstützt.';

  @override
  String get onbTrackingTitle => 'Bestellung Verfolgen';

  @override
  String get onbTrackingBody =>
      'Verfolgen Sie Ihre Lieferung in Echtzeit, wenn Tracking in Ihrer Region verfügbar ist. Sie erhalten Updates bei jedem Schritt.';

  @override
  String get onbSecurityTitle => 'Ihre Sicherheit ist wichtig';

  @override
  String get onbSecurityBody =>
      'Ihre Daten sind mit branchenüblicher Sicherheit geschützt. Wir geben Ihre persönlichen Daten niemals ohne Zustimmung weiter.';

  @override
  String get onbNotificationsTitle => 'Bleiben Sie informiert';

  @override
  String get onbNotificationsBody =>
      'Aktivieren Sie Benachrichtigungen, um Bestellupdates, Lieferbenachrichtigungen und exklusive Angebote zu erhalten.';

  @override
  String get onbReadyTitle => 'Alles bereit!';

  @override
  String get onbReadyBody =>
      'Starten Sie und geben Sie Ihre erste Bestellung auf. Wir sind hier, um Ihnen zu helfen.';

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
  String get onbRiderWelcomeTitle => 'Willkommen, Fahrer!';

  @override
  String get onbRiderWelcomeBody =>
      'Werden Sie Teil unseres Liefernetzwerks und verdienen Sie. Flexible Arbeitszeiten, faire Vergütung.';

  @override
  String get onbRiderHowItWorksTitle => 'Ihre Reise beginnt hier';

  @override
  String get onbRiderHowItWorksBody =>
      'Lieferungen annehmen, zur Abholung navigieren, an Kunden liefern. Verfolgen Sie Ihre Einnahmen in der App.';

  @override
  String get onbRiderLocationTitle => 'Standort aktivieren';

  @override
  String get onbRiderLocationBody =>
      'Wir verwenden Ihren Standort, um Sie mit Lieferungen in der Nähe zu verbinden. Ihr Standort wird nur während aktiver Lieferungen geteilt.';

  @override
  String get onbRiderSecurityTitle => 'Sicher & Geschützt';

  @override
  String get onbRiderSecurityBody =>
      'Ihre Einnahmen und persönlichen Daten sind geschützt. Multi-Faktor-Authentifizierung hält Ihr Konto sicher.';

  @override
  String get onbRiderNotificationsTitle => 'Keine Lieferung verpassen';

  @override
  String get onbRiderNotificationsBody =>
      'Erhalten Sie sofortige Benachrichtigungen für neue Lieferanfragen und wichtige Updates.';

  @override
  String get onbRiderReadyTitle => 'Bereit zum Liefern!';

  @override
  String get onbRiderReadyBody =>
      'Sie sind eingerichtet und startklar. Beginnen Sie jetzt mit der Annahme von Lieferungen.';

  @override
  String get onbCtaGetStarted => 'Los geht\'s';

  @override
  String get onbCtaNext => 'Weiter';

  @override
  String get onbCtaSkip => 'Überspringen';

  @override
  String get onbCtaEnableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get onbCtaEnableLocation => 'Standort aktivieren';

  @override
  String get onbCtaStartOrdering => 'Jetzt bestellen';

  @override
  String get onbCtaStartDelivering => 'Jetzt liefern';

  @override
  String get onbCtaMaybeLater => 'Vielleicht später';

  @override
  String get onbCtaDone => 'Fertig';

  @override
  String get onbCtaBack => 'Zurück';

  @override
  String get hintAuthPhoneTitle => 'Sichere Anmeldung';

  @override
  String get hintAuthPhoneBody =>
      'Wir senden einen Bestätigungscode an diese Nummer. Ihre Telefonnummer hilft uns, Ihr Konto zu schützen.';

  @override
  String get hintAuthOtpTitle => 'Prüfen Sie Ihre Nachrichten';

  @override
  String get hintAuthOtpBody =>
      'Geben Sie den Code ein, den wir an Ihr Telefon gesendet haben. Dies bestätigt, dass Sie es wirklich sind.';

  @override
  String get hintAuth2faTitle => 'Zusätzlicher Schutz';

  @override
  String get hintAuth2faBody =>
      'Zwei-Faktor-Authentifizierung fügt eine zusätzliche Sicherheitsebene zu Ihrem Konto hinzu.';

  @override
  String get hintAuthBiometricTitle => 'Schneller Zugriff';

  @override
  String get hintAuthBiometricBody =>
      'Verwenden Sie Ihren Fingerabdruck oder Ihr Gesicht, um sich schneller anzumelden und Ihr Konto sicher zu halten.';

  @override
  String get hintPaymentsMethodsTitle => 'Zahlungsoptionen';

  @override
  String get hintPaymentsMethodsBody =>
      'Fügen Sie eine Zahlungsmethode hinzu, um den Checkout zu beschleunigen. Ihre Zahlungsinformationen sind sicher verschlüsselt.';

  @override
  String get hintPaymentsSecurityTitle => 'Sichere Zahlung';

  @override
  String get hintPaymentsSecurityBody =>
      'Ihre Kartendaten werden verschlüsselt und nie auf unseren Servern gespeichert. Zahlungen werden von vertrauenswürdigen Anbietern verarbeitet.';

  @override
  String get hintPaymentsLimitedTitle => 'Begrenzte Zahlungsoptionen';

  @override
  String get hintPaymentsLimitedBody =>
      'Einige Zahlungsmethoden sind möglicherweise nicht in Ihrer Region verfügbar. Nachnahme ist verfügbar, wo unterstützt.';

  @override
  String get hintTrackingExplanationTitle => 'Live-Tracking';

  @override
  String get hintTrackingExplanationBody =>
      'Beobachten Sie die Reise Ihrer Bestellung von der Abholung bis zur Lieferung auf der Karte.';

  @override
  String get hintTrackingUnavailableTitle => 'Tracking nicht verfügbar';

  @override
  String get hintTrackingUnavailableBody =>
      'Echtzeit-Tracking ist für diese Bestellung nicht verfügbar. Sie erhalten Statusaktualisierungen per Benachrichtigung.';

  @override
  String get hintTrackingRealtimeTitle => 'Echtzeit-Updates';

  @override
  String get hintTrackingRealtimeBody =>
      'Die Karte wird automatisch aktualisiert, während Ihre Lieferung fortschreitet.';

  @override
  String get hintNotificationsImportanceTitle =>
      'Warum Benachrichtigungen wichtig sind';

  @override
  String get hintNotificationsImportanceBody =>
      'Erhalten Sie sofortige Updates über Ihren Bestellstatus, die Ankunft der Lieferung und Sonderangebote.';

  @override
  String get hintNotificationsPermissionTitle =>
      'Benachrichtigungen aktivieren';

  @override
  String get hintNotificationsPermissionBody =>
      'Um Bestellupdates und Lieferbenachrichtigungen zu erhalten, aktivieren Sie bitte Benachrichtigungen.';

  @override
  String get hintNotificationsPermissionCta => 'Jetzt aktivieren';

  @override
  String get hintOrdersFirstTitle => 'Ihre erste Bestellung';

  @override
  String get hintOrdersFirstBody =>
      'Herzlichen Glückwunsch zu Ihrer ersten Bestellung! Verfolgen Sie den Fortschritt hier.';

  @override
  String get hintOrdersEmptyTitle => 'Noch keine Bestellungen';

  @override
  String get hintOrdersEmptyBody =>
      'Beginnen Sie zu stöbern und geben Sie Ihre erste Bestellung auf. Ihr Bestellverlauf erscheint hier.';

  @override
  String get hintOrdersEmptyCta => 'Jetzt stöbern';

  @override
  String get settingsReplayOnboarding => 'App-Einführung anzeigen';

  @override
  String get settingsReplayOnboardingDescription =>
      'Die Willkommensanleitung erneut ansehen';

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
  String get rideConfirmTitle => 'Fahrt bestätigen';

  @override
  String get rideConfirmMapStubLabel =>
      'Route preview (stub – the actual map will show your driver and destination).';

  @override
  String get rideConfirmSheetTitle => 'Wähle deine Fahrt';

  @override
  String get rideConfirmSheetSubtitle =>
      'Wähle eine Fahrtoption, prüfe den Preis und bestätige deine Fahrt.';

  @override
  String get rideConfirmOptionEconomyTitle => 'Economy';

  @override
  String get rideConfirmOptionEconomySubtitle =>
      'Günstige Alltagsfahrten für bis zu 4 Personen.';

  @override
  String get rideConfirmOptionXlTitle => 'XL';

  @override
  String get rideConfirmOptionXlSubtitle =>
      'Extra Platz für Gruppen und größere Gegenstände.';

  @override
  String get rideConfirmOptionPremiumTitle => 'Premium';

  @override
  String get rideConfirmOptionPremiumSubtitle =>
      'Komfortable Fahrten mit erstklassig bewerteten Fahrern.';

  @override
  String rideConfirmOptionEtaFormat(String minutes) {
    return '$minutes Min. entfernt';
  }

  @override
  String rideConfirmOptionPriceApprox(String amount) {
    return '≈ $amount EUR';
  }

  @override
  String get rideConfirmPaymentLabel => 'Zahlungsmethode';

  @override
  String get rideConfirmPaymentStubValue => 'Visa •• 4242 (Stub)';

  @override
  String get rideConfirmPrimaryCta => 'Fahrt anfordern';

  @override
  String get rideConfirmRequestedStubMessage =>
      'Fahrtanfrage Stub – Backend-Integration folgt.';

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
  String get rideActiveContactDriverCta => 'Fahrer kontaktieren';

  @override
  String get rideActiveShareTripCta => 'Fahrtstatus teilen';

  @override
  String get rideActiveCancelTripCta => 'Fahrt stornieren';

  @override
  String get rideActiveShareTripCopied =>
      'Fahrtstatus kopiert. Du kannst ihn in jeder App einfügen.';

  @override
  String get rideActiveContactNoPhoneError =>
      'Fahrerkontaktdaten sind noch nicht verfügbar.';

  @override
  String get rideActiveShareGenericError =>
      'Fahrtstatus kann gerade nicht vorbereitet werden. Bitte versuche es erneut.';

  @override
  String rideActiveShareMessageTemplate(String destination, String link) {
    return 'Ich bin mit Delivery Ways auf dem Weg nach $destination. Du kannst meinen Fahrtstatus hier verfolgen: $link';
  }

  @override
  String get rideActiveCancelErrorGeneric =>
      'Could not cancel the ride. Please try again.';

  @override
  String get rideCancelDialogTitle => 'Diese Fahrt stornieren?';

  @override
  String get rideCancelDialogMessage =>
      'Wenn du jetzt stornierst, fährt der Fahrer nicht mehr zu deinem Abholort.';

  @override
  String get rideCancelDialogKeepRideCta => 'Fahrt behalten';

  @override
  String get rideCancelDialogConfirmCta => 'Fahrt stornieren';

  @override
  String get rideCancelSuccessSnackbar => 'Deine Fahrt wurde storniert.';

  @override
  String get rideCancelReasonByRider => 'Vom Fahrgast storniert';

  @override
  String get rideActiveHeadlineFindingDriver => 'Fahrer wird gesucht…';

  @override
  String rideActiveHeadlineDriverEta(String minutes) {
    return 'Fahrer ist $minutes Min. entfernt';
  }

  @override
  String get rideActiveHeadlineDriverOnTheWay => 'Fahrer unterwegs';

  @override
  String get rideActiveHeadlineDriverArrived => 'Fahrer ist angekommen';

  @override
  String get rideActiveHeadlineInProgress => 'Fahrt läuft';

  @override
  String get rideActiveHeadlinePayment => 'Zahlung wird abgeschlossen';

  @override
  String get rideActiveHeadlineCompleted => 'Fahrt abgeschlossen';

  @override
  String get rideActiveHeadlineCancelled => 'Fahrt storniert';

  @override
  String get rideActiveHeadlineFailed => 'Fahrt fehlgeschlagen';

  @override
  String get rideActiveHeadlinePreparing => 'Ihre Fahrt wird vorbereitet';

  @override
  String get rideActiveGoBackCta => 'Go back';

  @override
  String get rideActiveCancelledTitle => 'Fahrt storniert';

  @override
  String get rideActiveCancelledBody =>
      'Deine Fahrt wurde storniert. Du kannst jederzeit eine neue Fahrt anfordern.';

  @override
  String get rideActiveFailedTitle => 'Etwas ist schiefgelaufen';

  @override
  String get rideActiveFailedBody =>
      'Wir konnten diese Fahrt nicht abschließen. Bitte versuche es in Kürze erneut.';

  @override
  String get rideActiveBackToHomeCta => 'Zur Startseite';

  @override
  String get rideActiveRequestNewRideCta => 'Neue Fahrt anfordern';

  @override
  String rideActiveDestinationLabel(String destination) {
    return 'Nach $destination';
  }

  @override
  String rideActiveSummaryServiceAndPrice(String serviceName, String price) {
    return '$serviceName · $price';
  }

  @override
  String rideActivePayingWith(String method) {
    return 'Bezahlen mit $method';
  }

  @override
  String get rideActivePriceNotAvailable => 'Preis noch nicht verfügbar';

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
  String get rideStatusFindingDriver => 'Suche nach Fahrer...';

  @override
  String get rideStatusDriverAccepted => 'Fahrer unterwegs';

  @override
  String get rideStatusDriverArrived => 'Fahrer ist angekommen';

  @override
  String get rideStatusInProgress => 'Fahrt läuft';

  @override
  String get rideStatusPaymentPending => 'Warten auf Zahlung';

  @override
  String get rideStatusCompleted => 'Fahrt abgeschlossen';

  @override
  String get rideStatusUnknown => 'Fahrt wird vorbereitet...';

  @override
  String get homeActiveRideViewTripCta => 'Fahrt ansehen';

  @override
  String get homeActiveRideTitleGeneric => 'Aktive Fahrt';

  @override
  String homeActiveRideEtaTitle(int minutes) {
    return 'Ankunft in $minutes Min.';
  }

  @override
  String homeActiveRideSubtitleToDestination(String destination) {
    return 'Nach $destination';
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
  String get homeHubActiveRideTitle => 'Fahrt läuft';

  @override
  String get homeHubActiveRideSubtitle => 'Aktive Fahrt fortsetzen';

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
  String get rideLocationPickerTitle => 'Fahrtziel wählen';

  @override
  String get rideLocationPickerPickupLabel => 'Abholort';

  @override
  String get rideLocationPickerDestinationLabel => 'Ziel';

  @override
  String get rideLocationPickerPickupPlaceholder =>
      'Wo sollen wir dich abholen?';

  @override
  String get rideLocationPickerDestinationPlaceholder =>
      'Wohin möchtest du fahren?';

  @override
  String get rideLocationPickerMapHint =>
      'Verschiebe die Markierung oder nutze die Suche, um Orte festzulegen.';

  @override
  String get rideLocationPickerContinueCta => 'Preise anzeigen';

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
  String get rideTripSummaryFailedTitle => 'Fahrt fehlgeschlagen';

  @override
  String get rideTripSummaryFailedSubtitle =>
      'Diese Fahrt konnte nicht abgeschlossen werden';

  @override
  String get rideFailReasonNoDriverFound => 'Kein Fahrer gefunden';

  @override
  String get rideFailNoDriverFoundSnackbar =>
      'Es konnte kein Fahrer für diese Fahrt gefunden werden.';

  @override
  String get rideFailNoDriverFoundCta =>
      'Keine Fahrer verfügbar? Später versuchen';

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
    return '$serviceName Fahrt';
  }

  @override
  String get rideConfirmLoadingTitle => 'Fahrtoptionen werden geladen...';

  @override
  String get rideConfirmLoadingSubtitle =>
      'Bitte warte, während wir die besten Fahrten für dich finden.';

  @override
  String get rideConfirmErrorTitle =>
      'Fahrtoptionen konnten nicht geladen werden';

  @override
  String get rideConfirmErrorSubtitle =>
      'Bitte überprüfe deine Verbindung und versuche es erneut.';

  @override
  String get rideConfirmEmptyTitle => 'Keine Fahrten verfügbar';

  @override
  String get rideConfirmEmptySubtitle =>
      'Bitte versuche es in ein paar Minuten erneut.';

  @override
  String get rideConfirmRetryCta => 'Erneut versuchen';

  @override
  String get rideConfirmRecommendedBadge => 'Empfohlen';

  @override
  String get rideQuoteErrorTitle =>
      'Fahrtoptionen konnten nicht geladen werden';

  @override
  String get rideQuoteErrorGeneric =>
      'Bitte überprüfe deine Verbindung und versuche es erneut.';

  @override
  String get rideQuoteErrorNoOptions =>
      'Für diese Strecke sind derzeit keine Fahrtoptionen verfügbar.';

  @override
  String get ridePricingErrorGeneric =>
      'Die Preise konnten nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get rideQuoteRetryCta => 'Erneut versuchen';

  @override
  String get rideQuoteEmptyTitle => 'Keine Fahrten verfügbar';

  @override
  String get rideQuoteEmptyDescription =>
      'Bitte versuchen Sie es in ein paar Minuten erneut.';

  @override
  String get rideConfirmFromLabel => 'Von';

  @override
  String get rideConfirmToLabel => 'Nach';

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
  String get parcelsEntryTitle => 'Pakete';

  @override
  String get parcelsEntrySubtitle =>
      'Versenden und verfolgen Sie Ihre Pakete an einem Ort.';

  @override
  String get parcelsEntryCreateShipmentCta => 'Sendung erstellen';

  @override
  String get parcelsEntryViewShipmentsCta => 'Sendungen anzeigen';

  @override
  String get parcelsEntryComingSoonMessage =>
      'Paketfunktionen werden bald verfügbar sein.';

  @override
  String get parcelsEntryFooterNote =>
      'Parcels MVP befindet sich in aktiver Entwicklung.';

  @override
  String get parcelsComingSoonMessage => 'Pakete sind bald verfügbar.';

  @override
  String get parcelsDestinationTitle => 'Sendung erstellen';

  @override
  String get parcelsDestinationSubtitle =>
      'Geben Sie Abhol- und Lieferadresse für Ihre Sendung ein.';

  @override
  String get parcelsDestinationPickupLabel => 'Abholadresse';

  @override
  String get parcelsDestinationPickupHint => 'Abholadresse eingeben';

  @override
  String get parcelsDestinationDropoffLabel => 'Lieferadresse';

  @override
  String get parcelsDestinationDropoffHint => 'Lieferadresse eingeben';

  @override
  String get parcelsDestinationContinueCta => 'Weiter';

  @override
  String get parcelsDetailsTitle => 'Sendungsdetails';

  @override
  String get parcelsDetailsSubtitle =>
      'Geben Sie Details zu Ihrer Sendung für eine genaue Preisberechnung ein.';

  @override
  String get parcelsDetailsSizeLabel => 'Größe';

  @override
  String get parcelsDetailsWeightLabel => 'Gewicht';

  @override
  String get parcelsDetailsWeightHint => 'z.B. 2,5 kg';

  @override
  String get parcelsDetailsContentsLabel => 'Was senden Sie?';

  @override
  String get parcelsDetailsContentsHint => 'Kurz den Inhalt beschreiben';

  @override
  String get parcelsDetailsFragileLabel => 'Dieses Paket ist zerbrechlich';

  @override
  String get parcelsDetailsContinueCta => 'Preis prüfen';

  @override
  String get parcelsDetailsErrorWeightRequired =>
      'Bitte geben Sie das Gewicht des Pakets ein';

  @override
  String get parcelsDetailsErrorPositiveNumber =>
      'Bitte eine gültige positive Zahl eingeben';

  @override
  String get parcelsDetailsErrorContentsRequired =>
      'Bitte beschreiben Sie, was Sie versenden';

  @override
  String get parcelsDetailsErrorSizeRequired =>
      'Bitte wählen Sie eine Paketgröße';

  @override
  String get parcelsDetailsSectionParcelTitle => 'Paketdetails';

  @override
  String get parcelsQuoteTitle => 'Sendungspreise';

  @override
  String get parcelsQuoteSubtitle =>
      'Wählen Sie, wie schnell und zu welchem Preis Sie liefern möchten.';

  @override
  String get parcelsQuoteLoadingTitle => 'Preise werden geladen...';

  @override
  String get parcelsQuoteErrorTitle => 'Preise konnten nicht geladen werden';

  @override
  String get parcelsQuoteErrorSubtitle =>
      'Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.';

  @override
  String get parcelsQuoteEmptyTitle => 'Keine Optionen verfügbar';

  @override
  String get parcelsQuoteEmptySubtitle =>
      'Bitte passen Sie die Sendungsdetails an und versuchen Sie es erneut.';

  @override
  String get parcelsQuoteRetryCta => 'Erneut versuchen';

  @override
  String get parcelsQuoteConfirmCta => 'Sendung bestätigen';

  @override
  String get parcelsQuoteSummaryTitle => 'Sendungsübersicht';

  @override
  String get parcelsQuoteFromLabel => 'Von';

  @override
  String get parcelsQuoteToLabel => 'Nach';

  @override
  String get parcelsQuoteWeightLabel => 'Gewicht';

  @override
  String get parcelsQuoteSizeLabel => 'Größe';

  @override
  String parcelsQuoteTotalLabel(String amount) {
    return 'Gesamt: $amount';
  }

  @override
  String get parcelsQuoteBreakdownStubNote =>
      'Dies ist ein geschätzter Preis. Der endgültige Preis kann sich nach der Integration mit dem Live-Pricing-Service ändern.';

  @override
  String get parcelsListTitle => 'Deine Sendungen';

  @override
  String get parcelsListSectionTitle => 'Meine Sendungen';

  @override
  String get parcelsListEmptyTitle => 'Noch keine Sendungen';

  @override
  String get parcelsListEmptySubtitle =>
      'Wenn Sie eine Sendung erstellen, erscheint sie hier.';

  @override
  String get parcelsListEmptyCta => 'Erste Sendung erstellen';

  @override
  String get parcelsListNewShipmentTooltip => 'Neue Sendung';

  @override
  String parcelsListCreatedAtLabel(String date) {
    return 'Erstellt am $date';
  }

  @override
  String get parcelsListUnknownDestinationLabel => 'Unbekanntes Ziel';

  @override
  String get parcelsFilterAllLabel => 'Alle';

  @override
  String get parcelsFilterInProgressLabel => 'In Bearbeitung';

  @override
  String get parcelsFilterDeliveredLabel => 'Zugestellt';

  @override
  String get parcelsFilterCancelledLabel => 'Storniert';

  @override
  String get parcelsStatusScheduled => 'Geplant';

  @override
  String get parcelsStatusPickupPending => 'Abholung ausstehend';

  @override
  String get parcelsStatusPickedUp => 'Abgeholt';

  @override
  String get parcelsStatusInTransit => 'Unterwegs';

  @override
  String get parcelsStatusDelivered => 'Zugestellt';

  @override
  String get parcelsStatusCancelled => 'Storniert';

  @override
  String get parcelsStatusFailed => 'Fehlgeschlagen';

  @override
  String get parcelsCreateShipmentTitle => 'Sendung erstellen';

  @override
  String get parcelsCreateSenderSectionTitle => 'Absender';

  @override
  String get parcelsCreateReceiverSectionTitle => 'Empfänger';

  @override
  String get parcelsCreateDetailsSectionTitle => 'Sendungsdetails';

  @override
  String get parcelsCreateServiceSectionTitle => 'Serviceart';

  @override
  String get parcelsCreateSenderNameLabel => 'Absendername';

  @override
  String get parcelsCreateSenderPhoneLabel => 'Absendertelefon';

  @override
  String get parcelsCreateSenderAddressLabel => 'Absenderadresse';

  @override
  String get parcelsCreateReceiverNameLabel => 'Empfängername';

  @override
  String get parcelsCreateReceiverPhoneLabel => 'Empfängertelefon';

  @override
  String get parcelsCreateReceiverAddressLabel => 'Empfängeradresse';

  @override
  String get parcelsCreateWeightLabel => 'Gewicht (kg)';

  @override
  String get parcelsCreateSizeLabel => 'Größe';

  @override
  String get parcelsCreateNotesLabel => 'Notizen (optional)';

  @override
  String get parcelsCreateServiceExpress => 'Express';

  @override
  String get parcelsCreateServiceStandard => 'Standard';

  @override
  String get parcelsCreateShipmentCtaGetEstimate => 'Kostenvoranschlag';

  @override
  String get parcelsCreateErrorRequired => 'Dieses Feld ist erforderlich';

  @override
  String get parcelsCreateErrorInvalidNumber =>
      'Bitte geben Sie eine gültige Zahl ein';

  @override
  String get parcelsCreateErrorInvalidPhone =>
      'Bitte geben Sie eine gültige Telefonnummer ein';

  @override
  String get parcelsCreateWeightInvalidError =>
      'Bitte ein gültiges Gewicht eingeben.';

  @override
  String get parcelsCreateEstimateComingSoonSnackbar =>
      'Der Versandpreis ist bald verfügbar.';

  @override
  String get parcelsCreateSizeSmallLabel => 'Klein';

  @override
  String get parcelsCreateSizeMediumLabel => 'Mittel';

  @override
  String get parcelsCreateSizeLargeLabel => 'Groß';

  @override
  String get parcelsCreateSizeOversizeLabel => 'Übergröße';

  @override
  String get parcelsShipmentDetailsTitle => 'Sendungsdetails';

  @override
  String parcelsShipmentDetailsCreatedAt(String date) {
    return 'Erstellt am $date';
  }

  @override
  String get parcelsShipmentDetailsRouteSectionTitle => 'Route';

  @override
  String get parcelsShipmentDetailsPickupLabel => 'Abholadresse';

  @override
  String get parcelsShipmentDetailsDropoffLabel => 'Lieferadresse';

  @override
  String get parcelsShipmentDetailsAddressSectionTitle => 'Adressen';

  @override
  String get parcelsShipmentDetailsSenderLabel => 'Absender';

  @override
  String get parcelsShipmentDetailsReceiverLabel => 'Empfänger';

  @override
  String get parcelsShipmentDetailsMetaSectionTitle => 'Paketdetails';

  @override
  String get parcelsShipmentDetailsWeightLabel => 'Gewicht';

  @override
  String get parcelsShipmentDetailsSizeLabel => 'Größe';

  @override
  String get parcelsShipmentDetailsNotesLabel => 'Notizen';

  @override
  String get parcelsShipmentDetailsNotAvailable => 'N/V';

  @override
  String get parcelsShipmentDetailsSizeSmall => 'Klein';

  @override
  String get parcelsShipmentDetailsSizeMedium => 'Mittel';

  @override
  String get parcelsShipmentDetailsSizeLarge => 'Groß';

  @override
  String get parcelsShipmentDetailsSizeOversize => 'Übergröße';

  @override
  String get parcelsDetailsPriceLabel => 'Preis';

  @override
  String get foodComingSoonAppBarTitle => 'Essenslieferung';

  @override
  String get foodComingSoonTitle => 'Essenslieferung kommt bald';

  @override
  String get foodComingSoonSubtitle =>
      'Wir arbeiten daran, Essenslieferung in deine Region zu bringen. Bleib dran!';

  @override
  String get foodComingSoonPrimaryCta => 'Zurück zur Startseite';

  @override
  String get foodRestaurantsAppBarTitle => 'Essenslieferung';

  @override
  String get foodRestaurantsSearchPlaceholder =>
      'Suche nach Restaurants oder Küchen';

  @override
  String get foodRestaurantsFilterAll => 'Alle';

  @override
  String get foodRestaurantsFilterBurgers => 'Burger';

  @override
  String get foodRestaurantsFilterItalian => 'Italienisch';

  @override
  String get foodRestaurantsEmptyTitle => 'Keine Restaurants gefunden';

  @override
  String get foodRestaurantsEmptySubtitle =>
      'Ändere die Filter oder suche nach einer anderen Küche.';

  @override
  String get foodRestaurantMenuError =>
      'Menü konnte nicht geladen werden. Bitte versuche es erneut.';

  @override
  String foodCartSummaryCta(String itemCount, String totalPrice) {
    return '$itemCount Artikel · Gesamt $totalPrice';
  }

  @override
  String foodCartCheckoutStub(String itemCount, String totalPrice) {
    return 'Checkout ist noch nicht implementiert. $itemCount Artikel, insgesamt $totalPrice.';
  }

  @override
  String get ordersSectionParcelsTitle => 'Pakete';

  @override
  String get ordersSectionFoodTitle => 'Essen';

  @override
  String get ordersFilterFood => 'Essen';

  @override
  String get ordersFoodStatusPending => 'Ausstehend';

  @override
  String get ordersFoodStatusInPreparation => 'In Zubereitung';

  @override
  String get ordersFoodStatusOnTheWay => 'Unterwegs';

  @override
  String get ordersFoodStatusDelivered => 'Geliefert';

  @override
  String get ordersFoodStatusCancelled => 'Storniert';

  @override
  String ordersFoodCreatedAtLabel(String date) {
    return 'Bestellt am $date';
  }

  @override
  String foodCartOrderCreatedSnackbar(String restaurant) {
    return 'Deine Bestellung bei $restaurant wurde erstellt.';
  }

  @override
  String get homeFoodComingSoonLabel => 'Kommt bald';

  @override
  String get homeFoodComingSoonMessage =>
      'Essenslieferung ist in deiner Region noch nicht verfügbar.';

  @override
  String get homeFoodCardTitle => 'Essen';

  @override
  String get homeFoodCardSubtitle => 'Dein Lieblingsessen, geliefert.';

  @override
  String get onboardingRideTitle => 'Sofort eine Fahrt bekommen.';

  @override
  String get onboardingRideBody =>
      'Tippen, fahren und ankommen. Schneller, zuverlässiger und günstiger Transport.';

  @override
  String get onboardingParcelsTitle => 'Alles einfach versenden.';

  @override
  String get onboardingParcelsBody =>
      'Von Dokumenten bis Geschenken – sende und verfolge deine Pakete mit Leichtigkeit.';

  @override
  String get onboardingFoodTitle => 'Dein Lieblingsessen, geliefert.';

  @override
  String get onboardingFoodBody =>
      'Entdecke lokale Restaurants und genieße schnelle Lieferung bis vor deine Tür.';

  @override
  String get onboardingButtonContinue => 'Weiter';

  @override
  String get onboardingButtonGetStarted => 'Los geht\'s';

  @override
  String get homeRideCardTitle => 'Fahrt';

  @override
  String get homeRideCardSubtitle => 'Sofort eine Fahrt bekommen.';

  @override
  String get rideDestinationDestinationLabel => 'Ziel';

  @override
  String get rideDestinationDestinationPlaceholder => 'Wohin?';

  @override
  String get rideDestinationRecentTitle => 'Letzte Ziele';

  @override
  String get rideDestinationRecentHomeLabel => 'Zuhause';

  @override
  String get rideDestinationRecentHomeSubtitle => 'Gespeicherte Privatadresse';

  @override
  String get rideDestinationRecentWorkLabel => 'Arbeit';

  @override
  String get rideDestinationRecentWorkSubtitle => 'Gespeicherte Arbeitsadresse';

  @override
  String get rideDestinationRecentLastLabel => 'Letzte Fahrt';

  @override
  String get rideDestinationRecentLastSubtitle =>
      'Ziel deiner letzten Fahrt verwenden';

  @override
  String get rideDestinationNextCta => 'Weiter';

  @override
  String get rideDestinationComingSoonSnackbar =>
      'Die Fahrzusammenfassung wird bald verfügbar sein.';

  @override
  String get rideSummaryReceiptTitle => 'Beleg';

  @override
  String get rideSummaryReceiptFareLabel => 'Fahrtpreis';

  @override
  String get rideSummaryReceiptFeesLabel => 'Gebühren';

  @override
  String get rideSummaryReceiptTotalLabel => 'Gesamt';

  @override
  String get rideSummaryRatingTitle => 'Bewerte deinen Fahrer';

  @override
  String get rideSummaryRatingSubtitle =>
      'Dein Feedback hilft uns, Fahrten sicher und angenehm zu halten.';

  @override
  String get rideSummaryCommentPlaceholder => 'Kommentar hinzufügen (optional)';

  @override
  String rideReceiptTripIdLabel(String id) {
    return 'Fahrt-ID: $id';
  }

  @override
  String rideReceiptCompletedAt(String date, String time) {
    return '$date um $time';
  }

  @override
  String get rideReceiptFromLabel => 'Von';

  @override
  String get rideReceiptToLabel => 'Nach';

  @override
  String get rideReceiptFareSectionTitle => 'Fahrpreis';

  @override
  String get rideReceiptBaseFareLabel => 'Grundpreis';

  @override
  String get rideReceiptDistanceFareLabel => 'Strecke';

  @override
  String get rideReceiptTimeFareLabel => 'Zeit';

  @override
  String get rideReceiptFeesLabel => 'Gebühren & Zuschläge';

  @override
  String get rideReceiptTotalLabel => 'Gesamt';

  @override
  String get rideReceiptDriverSectionTitle => 'Fahrer & Fahrzeug';

  @override
  String get rideReceiptRateDriverTitle => 'Fahrer bewerten';

  @override
  String get rideReceiptRateDriverSubtitle =>
      'Dein Feedback hilft, Fahrten sicher und angenehm zu halten.';

  @override
  String get rideReceiptDoneCta => 'Fertig';

  @override
  String get rideDriverMockName => 'Ahmad M.';

  @override
  String get rideDriverMockCarInfo => 'Toyota Camry • ABC 1234';

  @override
  String get rideDriverMockRating => '4.9';

  @override
  String get rideSummaryEndTripDebugCta => 'Fahrt beenden';

  @override
  String get rideSummaryThankYouSnackbar => 'Danke für dein Feedback.';

  @override
  String get homeActiveParcelTitleGeneric => 'Aktive Sendung';

  @override
  String homeActiveParcelSubtitleToDestination(String destination) {
    return 'Nach $destination';
  }

  @override
  String get homeActiveParcelViewShipmentCta => 'Sendung ansehen';

  @override
  String get homeActiveParcelStatusPreparing =>
      'Deine Sendung wird vorbereitet...';

  @override
  String get homeActiveParcelStatusScheduled => 'Abholung geplant';

  @override
  String get homeActiveParcelStatusPickupPending => 'Warten auf Abholung';

  @override
  String get homeActiveParcelStatusPickedUp => 'Abgeholt';

  @override
  String get homeActiveParcelStatusInTransit => 'Unterwegs';

  @override
  String get homeActiveParcelStatusDelivered => 'Zugestellt';

  @override
  String get homeActiveParcelStatusCancelled => 'Sendung storniert';

  @override
  String get homeActiveParcelStatusFailed => 'Zustellung fehlgeschlagen';

  @override
  String get parcelsActiveShipmentTitle => 'Aktive Sendung';

  @override
  String get parcelsActiveShipmentNoActiveTitle => 'Keine aktive Sendung';

  @override
  String get parcelsActiveShipmentNoActiveSubtitle =>
      'Du hast derzeit keine aktiven Sendungen.';

  @override
  String get parcelsActiveShipmentMapStub =>
      'Kartenverfolgung (bald verfügbar)';

  @override
  String parcelsActiveShipmentStatusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String parcelsActiveShipmentIdLabel(String id) {
    return 'Sendungs-ID: $id';
  }

  @override
  String get parcelsActiveShipmentStubNote =>
      'Vollständige Verfolgung wird in einem zukünftigen Update verfügbar sein.';

  @override
  String get parcelsDetailsCancelShipmentCta => 'Sendung stornieren';

  @override
  String get parcelsCancelDialogTitle => 'Diese Sendung stornieren?';

  @override
  String get parcelsCancelDialogSubtitle =>
      'Wenn du jetzt stornierst, wird diese Sendung gestoppt und nicht mehr als aktiv angezeigt.';

  @override
  String get parcelsCancelDialogConfirmCta => 'Ja, stornieren';

  @override
  String get parcelsCancelDialogDismissCta => 'Sendung behalten';

  @override
  String get parcelsCancelSuccessMessage => 'Die Sendung wurde storniert.';

  @override
  String get bottomNavHomeLabel => 'Start';

  @override
  String get bottomNavOrdersLabel => 'Bestellungen';

  @override
  String get bottomNavPaymentsLabel => 'Zahlungen';

  @override
  String get bottomNavProfileLabel => 'Profil';

  @override
  String get homeCurrentLocationLabel => 'Aktueller Standort';

  @override
  String get homeCurrentLocationPlaceholder => 'Abholort festlegen';

  @override
  String get homeServiceRideTitle => 'Fahrt';

  @override
  String get homeServiceParcelsTitle => 'Pakete';

  @override
  String get homeServiceFoodTitle => 'Essen';

  @override
  String get homeServiceRideSubtitle => 'Fahrt in Minuten bekommen';

  @override
  String get homeServiceParcelsSubtitle => 'Pakete senden und verfolgen';

  @override
  String get homeServiceFoodSubtitle =>
      'Essen von nahegelegenen Restaurants bestellen';

  @override
  String get homeSearchPlaceholder => 'Wohin?';

  @override
  String get paymentsEntryTitle => 'Zahlungen';

  @override
  String get paymentsEntryStubBody =>
      'Die Zahlungsverwaltung wird in einem zukünftigen Update verfügbar sein.';

  @override
  String get paymentsTitle => 'Zahlungsmethoden';

  @override
  String get paymentsAddMethodCta => 'Neue Zahlungsmethode hinzufügen';

  @override
  String get paymentsEmptyTitle => 'Keine Zahlungsmethoden gespeichert';

  @override
  String get paymentsEmptyBody =>
      'Deine gespeicherten Karten und Zahlungsoptionen erscheinen hier.';

  @override
  String get paymentsMethodTypeCash => 'Barzahlung';

  @override
  String get paymentsMethodTypeCard => 'Karte';

  @override
  String get paymentsDefaultBadge => 'Standard';

  @override
  String get paymentsAddMethodComingSoon =>
      'Das Hinzufügen neuer Zahlungsmethoden ist bald verfügbar.';

  @override
  String paymentsCardExpiry(int month, int year) {
    return 'Gültig bis $month/$year';
  }

  @override
  String get paymentsMethodTypeApplePay => 'Apple Pay';

  @override
  String get paymentsMethodTypeGooglePay => 'Google Pay';

  @override
  String get paymentsMethodTypeDigitalWallet => 'Digitale Geldbörse';

  @override
  String get paymentsMethodTypeBankTransfer => 'Banküberweisung';

  @override
  String get paymentsMethodTypeCashOnDelivery => 'Zahlung bei Lieferung';

  @override
  String get profileEntryTitle => 'Profil';

  @override
  String get profileEntryStubBody =>
      'Profil- und Kontoeinstellungen werden in einem zukünftigen Update verfügbar sein.';

  @override
  String get rideStatusShortDraft => 'Entwurf';

  @override
  String get rideStatusShortQuoting => 'Preis wird ermittelt';

  @override
  String get rideStatusShortRequesting => 'Fahrt wird angefragt';

  @override
  String get rideStatusShortFindingDriver => 'Fahrer wird gesucht';

  @override
  String get rideStatusShortDriverAccepted => 'Fahrer akzeptiert';

  @override
  String get rideStatusShortDriverArrived => 'Fahrer angekommen';

  @override
  String get rideStatusShortInProgress => 'Unterwegs';

  @override
  String get rideStatusShortPayment => 'Zahlung läuft';

  @override
  String get rideStatusShortCompleted => 'Abgeschlossen';

  @override
  String get rideStatusShortCancelled => 'Storniert';

  @override
  String get rideStatusShortFailed => 'Fehlgeschlagen';

  @override
  String get homeActiveRideStatusPreparing => 'Deine Fahrt wird vorbereitet...';

  @override
  String get homeActiveRideStatusFindingDriver => 'Fahrer wird gesucht...';

  @override
  String get homeActiveRideStatusDriverAccepted => 'Fahrer ist unterwegs';

  @override
  String get homeActiveRideStatusDriverArrived => 'Fahrer ist angekommen';

  @override
  String get homeActiveRideStatusInProgress => 'Fahrt läuft';

  @override
  String get homeActiveRideStatusPayment => 'Zahlung wird abgeschlossen';

  @override
  String get homeActiveRideStatusCompleted => 'Fahrt abgeschlossen';

  @override
  String get homeActiveRideStatusCancelled => 'Fahrt storniert';

  @override
  String get homeActiveRideStatusFailed => 'Fahrt fehlgeschlagen';

  @override
  String get rideActiveTripTitle => 'Aktive Fahrt';

  @override
  String rideActiveTripFromLabel(String pickup) {
    return 'Von: $pickup';
  }

  @override
  String rideActiveTripToLabel(String dropoff) {
    return 'Nach: $dropoff';
  }

  @override
  String rideActiveTripIdLabel(String id) {
    return 'Fahrt-ID: $id';
  }

  @override
  String get rideActiveTripMapStub => 'Live-Kartenverfolgung (bald verfügbar)';

  @override
  String get rideActiveTripStubNote =>
      'Vollständiges Live-Tracking wird nach der Integration mit dem Mobilitätsdienst verfügbar sein.';

  @override
  String rideActiveTripStatusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String get rideActiveTripDriverSectionTitle => 'Fahrer & Fahrzeug';

  @override
  String get rideActiveTripDriverSectionStubBody =>
      'Details zu Fahrer und Fahrzeug werden nach der Integration mit dem Mobilitätsdienst verfügbar sein.';

  @override
  String get ordersHistoryEmptyAllTitle => 'Noch keine Bestellungen';

  @override
  String get ordersHistoryEmptyAllDescription =>
      'Ihre Fahrten, Pakete und Essensbestellungen werden hier angezeigt.';

  @override
  String get ordersHistoryEmptyRidesTitle => 'Noch keine Fahrten';

  @override
  String get ordersHistoryEmptyRidesDescription =>
      'Ihre abgeschlossenen Fahrten werden hier angezeigt.';

  @override
  String get ordersHistoryEmptyParcelsTitle => 'Noch keine Pakete';

  @override
  String get ordersHistoryEmptyParcelsDescription =>
      'Ihre Sendungen werden hier angezeigt.';

  @override
  String get ordersHistoryEmptyFoodTitle => 'Noch keine Essensbestellungen';

  @override
  String get ordersHistoryEmptyFoodDescription =>
      'Ihre Essenslieferungen werden hier angezeigt.';

  @override
  String get ordersServiceRideSemanticLabel => 'Fahrtbestellung';

  @override
  String get ordersServiceParcelSemanticLabel => 'Paketversand';

  @override
  String get ordersServiceFoodSemanticLabel => 'Essensbestellung';

  @override
  String get parcelsShipmentsTitle => 'Meine Sendungen';

  @override
  String get parcelsShipmentsNewShipmentTooltip => 'Neue Sendung';

  @override
  String get parcelsShipmentsEmptyTitle => 'Noch keine Sendungen';

  @override
  String get parcelsShipmentsEmptyDescription =>
      'Du hast noch keine Sendungen. Erstelle deine erste Sendung, um zu starten.';

  @override
  String get parcelsShipmentsEmptyCta => 'Erste Sendung erstellen';

  @override
  String get parcelsShipmentStatusCreated => 'Erstellt';

  @override
  String get parcelsShipmentStatusInTransit => 'Unterwegs';

  @override
  String get parcelsShipmentStatusDelivered => 'Zugestellt';

  @override
  String get parcelsShipmentStatusCancelled => 'Storniert';

  @override
  String get parcelsShipmentsErrorTitle => 'Etwas ist schiefgelaufen';

  @override
  String get parcelsCreateShipmentCta => 'Sendung erstellen';

  @override
  String get parcelsCreateShipmentSenderSectionTitle => 'Absender';

  @override
  String get parcelsCreateShipmentReceiverSectionTitle => 'Empfänger';

  @override
  String get parcelsCreateShipmentParcelDetailsSectionTitle => 'Paketdetails';

  @override
  String get parcelsCreateShipmentSenderNameLabel => 'Name des Absenders';

  @override
  String get parcelsCreateShipmentSenderPhoneLabel => 'Telefon des Absenders';

  @override
  String get parcelsCreateShipmentReceiverNameLabel => 'Name des Empfängers';

  @override
  String get parcelsCreateShipmentReceiverPhoneLabel =>
      'Telefon des Empfängers';

  @override
  String get parcelsCreateShipmentPickupAddressLabel => 'Abholadresse';

  @override
  String get parcelsCreateShipmentDropoffAddressLabel => 'Lieferadresse';

  @override
  String get parcelsCreateShipmentWeightLabel => 'Gewicht (kg)';

  @override
  String get parcelsCreateShipmentSizeLabel => 'Größe';

  @override
  String get parcelsCreateShipmentNotesLabel => 'Notizen';

  @override
  String get parcelsCreateShipmentServiceTypeLabel => 'Service-Typ';

  @override
  String get parcelsCreateShipmentServiceTypeExpress => 'Express';

  @override
  String get parcelsCreateShipmentServiceTypeStandard => 'Standard';

  @override
  String get parcelsCreateShipmentServiceTypeError =>
      'Bitte einen Service-Typ auswählen';

  @override
  String get parcelsCreateShipmentSuccessMessage =>
      'Sendung erfolgreich erstellt';

  @override
  String get commonErrorFieldRequired => 'Dieses Feld ist erforderlich';

  @override
  String get commonAddressesTitle => 'Adressen';

  @override
  String get parcelsShipmentDetailsContactsSectionTitle => 'Kontakte';

  @override
  String get parcelsShipmentDetailsDetailsSectionTitle => 'Paketdetails';

  @override
  String get parcelsShipmentDetailsServiceTypeLabel => 'Service-Typ';

  @override
  String get commonTotalLabel => 'Gesamt';

  @override
  String get homeHubRecentDestinationsTitle => 'Recent destinations';

  @override
  String get homeHubRecentDestinationsSeeAll => 'See all';
}

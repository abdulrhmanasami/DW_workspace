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
  String get rideActiveShareTripCta => 'Share trip';

  @override
  String get rideActiveCancelTripCta => 'Cancel ride';

  @override
  String get rideActiveContactDriverNotImplemented =>
      'Contact driver is not implemented yet.';

  @override
  String get rideActiveShareTripNotImplemented =>
      'Share trip is not implemented yet.';

  @override
  String get rideActiveCancelTripNotImplemented =>
      'Cancel ride is not implemented yet.';

  @override
  String get rideActiveCancelErrorGeneric =>
      'Could not cancel the ride. Please try again.';

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
  String rideActiveDestinationLabel(String destination) {
    return 'To $destination';
  }

  @override
  String get homeActiveRideViewTripCta => 'View trip';

  @override
  String get rideDestinationTitle => 'Where to?';

  @override
  String get rideDestinationPickupLabel => 'Pick-up';

  @override
  String get rideDestinationPickupCurrentLocation => 'Current location';

  @override
  String get rideDestinationRecentLocationsSection => 'Recent locations';

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
  String get parcelsDetailsContinueCta => 'Weiter zur Preisberechnung';

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
  String get parcelsListSectionTitle => 'Meine Sendungen';

  @override
  String get parcelsListEmptyTitle => 'Noch keine Sendungen';

  @override
  String get parcelsListEmptySubtitle =>
      'Wenn Sie eine Sendung erstellen, erscheint sie hier.';

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
  String get parcelsCreateShipmentTitle => 'Neue Sendung';

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
  String get parcelsShipmentDetailsTitle => 'Sendungsdetails';

  @override
  String parcelsShipmentDetailsCreatedAt(String date) {
    return 'Erstellt am $date';
  }

  @override
  String get parcelsShipmentDetailsRouteSectionTitle => 'Route';

  @override
  String get parcelsShipmentDetailsPickupLabel => 'Abholung';

  @override
  String get parcelsShipmentDetailsDropoffLabel => 'Zustellung';

  @override
  String get parcelsShipmentDetailsAddressSectionTitle => 'Adressen';

  @override
  String get parcelsShipmentDetailsSenderLabel => 'Von (Absender)';

  @override
  String get parcelsShipmentDetailsReceiverLabel => 'An (Empfänger)';

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
}

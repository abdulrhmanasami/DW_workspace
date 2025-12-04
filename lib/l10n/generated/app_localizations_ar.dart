// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Delivery Ways';

  @override
  String get authPhoneTitle => 'تسجيل الدخول';

  @override
  String get authPhoneSubtitle =>
      'أدخل رقم جوالك لتسجيل الدخول إلى Delivery Ways.';

  @override
  String get authPhoneFieldHint => '+9665xxxxxxxx';

  @override
  String get authPhoneContinueCta => 'متابعة';

  @override
  String get authOtpTitle => 'إدخال الرمز';

  @override
  String get authOtpSubtitle => 'قمنا بإرسال رمز تحقق إلى جوالك.';

  @override
  String get authOtpFieldHint => 'رمز التحقق';

  @override
  String get authOtpVerifyCta => 'تأكيد ومتابعة';

  @override
  String get accountSheetTitle => 'الحساب';

  @override
  String get accountSheetSignedOutSubtitle =>
      'أنت غير مسجل الدخول. سجّل دخولك لمزامنة الرحلات والتوصيل.';

  @override
  String get accountSheetSignInCta => 'تسجيل الدخول برقم الجوال';

  @override
  String get accountSheetSignedInTitle => 'تم تسجيل الدخول';

  @override
  String get accountSheetSignOutCta => 'تسجيل الخروج';

  @override
  String get accountSheetFooterText => 'المزيد من خيارات الحساب قريبًا.';

  @override
  String get initializing => 'جارٍ التهيئة...';

  @override
  String get back => 'العودة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get confirm => 'تأكيد';

  @override
  String get ok => 'موافق';

  @override
  String get close => 'إغلاق';

  @override
  String get error => 'خطأ';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get authPhoneLoginTitle => 'تسجيل الدخول';

  @override
  String get authPhoneLoginSubtitle =>
      'أدخل رقم جوالك لتسجيل الدخول أو إنشاء حساب جديد.';

  @override
  String get authPhoneFieldLabel => 'رقم الجوال';

  @override
  String get authPhoneContinueButton => 'متابعة';

  @override
  String get authPhoneRequiredError => 'يرجى إدخال رقم الجوال.';

  @override
  String get authPhoneInvalidFormatError => 'يرجى إدخال رقم جوال صحيح.';

  @override
  String get authPhoneSubmitError => 'تعذّر إرسال رمز التحقق. حاول مرة أخرى.';

  @override
  String get authOtpFieldLabel => 'رمز التحقق';

  @override
  String get authOtpConfirmButton => 'تأكيد';

  @override
  String get authOtpRequiredError => 'يرجى إدخال رمز التحقق.';

  @override
  String get authOtpInvalidFormatError => 'يرجى إدخال رمز مكون من 4-6 أرقام.';

  @override
  String get authOtpSubmitError => 'رمز التحقق غير صحيح أو منتهي الصلاحية.';

  @override
  String get authOtpResendButton => 'إعادة إرسال الرمز';

  @override
  String authOtpResendCountdown(int seconds) {
    return 'يمكنك إعادة إرسال الرمز بعد $seconds ثانية';
  }

  @override
  String get authBiometricButtonLabel => 'استخدام البصمة';

  @override
  String get authBiometricReason => 'قم بالمصادقة للمتابعة.';

  @override
  String get authBiometricUnlockError =>
      'تعذّر الفتح بالبصمة. يرجى طلب رمز جديد.';

  @override
  String authCooldownMessage(int seconds) {
    return 'يرجى الانتظار $seconds ثانية قبل المحاولة مجدداً.';
  }

  @override
  String get authCooldownReady => 'يمكنك إعادة الإرسال الآن.';

  @override
  String authAttemptsRemaining(int count) {
    return '$count محاولات متبقية';
  }

  @override
  String get authNoAttemptsRemaining => 'لا توجد محاولات متبقية.';

  @override
  String get auth2faTitle => 'التحقق الثنائي';

  @override
  String get auth2faSubtitle => 'مطلوب خطوة تحقق إضافية لأمانك.';

  @override
  String get auth2faSelectMethod => 'اختر طريقة التحقق';

  @override
  String get auth2faMethodSms => 'رسالة نصية (SMS)';

  @override
  String auth2faMethodSmsDescription(String destination) {
    return 'استلام رمز عبر SMS إلى $destination';
  }

  @override
  String get auth2faMethodTotp => 'تطبيق المصادقة';

  @override
  String get auth2faMethodTotpDescription => 'استخدم تطبيق المصادقة لتوليد رمز';

  @override
  String get auth2faMethodEmail => 'البريد الإلكتروني';

  @override
  String auth2faMethodEmailDescription(String destination) {
    return 'استلام رمز عبر البريد الإلكتروني إلى $destination';
  }

  @override
  String get auth2faMethodPush => 'إشعار فوري';

  @override
  String get auth2faMethodPushDescription =>
      'الموافقة على الطلب من جهازك المسجّل';

  @override
  String get auth2faEnterCode => 'أدخل رمز التحقق';

  @override
  String get auth2faCodeHint => 'أدخل الرمز المكون من 6 أرقام';

  @override
  String get auth2faVerifyButton => 'تأكيد';

  @override
  String get auth2faCancelButton => 'إلغاء';

  @override
  String get auth2faResendCode => 'إعادة إرسال الرمز';

  @override
  String get auth2faCodeExpired => 'انتهت صلاحية الرمز. اطلب رمزاً جديداً.';

  @override
  String get auth2faInvalidCode => 'رمز غير صحيح. حاول مرة أخرى.';

  @override
  String get auth2faAccountLocked => 'محاولات كثيرة. تم قفل الحساب مؤقتاً.';

  @override
  String auth2faLockoutMessage(int minutes) {
    return 'يرجى المحاولة بعد $minutes دقيقة.';
  }

  @override
  String get notificationsSettingsTitle => 'إعدادات الإشعارات';

  @override
  String get notificationsSettingsOrderStatusTitle => 'إشعارات حالة الطلب';

  @override
  String get notificationsSettingsOrderStatusSubtitle =>
      'استلام تحديثات مباشرة عن حالة طلباتك النشطة.';

  @override
  String get notificationsSettingsPromotionsTitle => 'العروض الترويجية';

  @override
  String get notificationsSettingsPromotionsSubtitle =>
      'استلام عروض وخصومات مخصصة لك.';

  @override
  String get notificationsSettingsSystemTitle => 'إشعارات النظام';

  @override
  String get notificationsSettingsSystemSubtitle =>
      'تنبيهات مهمة حول حسابك والنظام.';

  @override
  String get notificationsSettingsConsentRequired =>
      'يجب منح إذن الإشعارات لتفعيل هذه الإعدادات.';

  @override
  String get notificationsSettingsErrorGeneric =>
      'تعذّر تحميل إعدادات الإشعارات. حاول مرة أخرى.';

  @override
  String get notificationsSettingsErrorLoading =>
      'حدث خطأ في تحميل إعدادات الإشعارات';

  @override
  String get notificationsSettingsSystemSettingsButton => 'فتح إعدادات النظام';

  @override
  String get notificationsSettingsSystemSettingsPlaceholder =>
      'سيتم فتح إعدادات النظام قريباً';

  @override
  String get notificationsSettingsQuietHoursTitle => 'ساعات الهدوء';

  @override
  String get notificationsSettingsQuietHoursNotEnabled =>
      'لم يتم تفعيل وضع عدم الإزعاج';

  @override
  String get settingsSectionNotifications => 'إعدادات الإشعارات';

  @override
  String get notificationsInboxTitle => 'الإشعارات';

  @override
  String get notificationsInboxErrorGeneric =>
      'تعذّر تحميل الإشعارات. حاول مرة أخرى.';

  @override
  String get notificationsInboxRetryButtonLabel => 'إعادة المحاولة';

  @override
  String get notificationsInboxEmptyTitle => 'لا توجد إشعارات بعد';

  @override
  String get notificationsInboxEmptySubtitle =>
      'ستظهر هنا التنبيهات المهمة عن طلباتك والعروض.';

  @override
  String get notificationsInboxEmptyCtaBackToHomeLabel => 'العودة للرئيسية';

  @override
  String get notificationsInboxMarkAsReadTooltip => 'وضع كمقروء';

  @override
  String get notificationsInboxMarkAllAsReadTooltip => 'وضع الكل كمقروء';

  @override
  String get notificationsInboxClearAllTooltip => 'مسح الكل';

  @override
  String get notificationsInboxClearAllDialogTitle => 'مسح جميع الإشعارات';

  @override
  String get notificationsInboxClearAllDialogMessage =>
      'هل أنت متأكد من حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get notificationsInboxClearAllConfirm => 'مسح الكل';

  @override
  String get notificationsInboxTappedGeneric => 'تم فتح الإشعار';

  @override
  String get notificationsInboxTimeNow => 'الآن';

  @override
  String notificationsInboxTimeMinutes(int minutes) {
    return 'منذ $minutes دقيقة';
  }

  @override
  String notificationsInboxTimeHours(int hours) {
    return 'منذ $hours ساعة';
  }

  @override
  String notificationsInboxTimeDays(int days) {
    return 'منذ $days يوم';
  }

  @override
  String get privacyConsentTitle => 'الخصوصية والموافقة';

  @override
  String get privacyConsentHeadline => 'تحكم في خصوصيتك';

  @override
  String get privacyConsentDescription =>
      'اختر ما تريد مشاركته معنا لتحسين تجربتك';

  @override
  String get privacyConsentAnalyticsTitle => 'تحليلات الاستخدام';

  @override
  String get privacyConsentAnalyticsDescription =>
      'يساعدنا في فهم كيفية استخدام التطبيق لتحسين الأداء والميزات';

  @override
  String get privacyConsentCrashReportsTitle => 'تقارير الأعطال';

  @override
  String get privacyConsentCrashReportsDescription =>
      'يرسل تقارير تلقائية عند حدوث أعطال لمساعدتنا في إصلاح المشاكل';

  @override
  String get privacyConsentBackgroundLocationTitle => 'الموقع في الخلفية';

  @override
  String get privacyConsentBackgroundLocationDescription =>
      'يسمح بتتبع الموقع حتى عندما يكون التطبيق مغلقاً لتحسين خدمات التوصيل';

  @override
  String get privacyConsentSaveSuccess => 'تم حفظ إعدادات الخصوصية';

  @override
  String privacyConsentErrorPrefix(String message) {
    return 'خطأ: $message';
  }

  @override
  String get dsrExportTitle => 'تصدير البيانات';

  @override
  String get dsrExportHeadline => 'تصدير بياناتك الشخصية';

  @override
  String get dsrExportDescription =>
      'ستحصل على رابط آمن لتنزيل جميع بياناتك. الرابط صالح لمدة 7 أيام فقط.';

  @override
  String get dsrExportIncludePaymentsTitle => 'تضمين سجل المدفوعات';

  @override
  String get dsrExportIncludePaymentsDescription =>
      'قد يحتوي سجل المدفوعات على معلومات حساسة. تأكد من مراجعة الملف بعناية.';

  @override
  String get dsrExportStartButton => 'ابدأ التصدير';

  @override
  String get dsrExportRequestStatus => 'حالة الطلب';

  @override
  String dsrExportRequestDate(String date) {
    return 'تاريخ الطلب: $date';
  }

  @override
  String get dsrExportDownloadLink => 'رابط التنزيل';

  @override
  String dsrExportLinkExpires(String date) {
    return 'ينتهي في: $date';
  }

  @override
  String get dsrExportCopyLink => 'نسخ الرابط';

  @override
  String get dsrExportLinkCopied => 'تم نسخ الرابط';

  @override
  String get dsrExportPreparingFile => 'جارٍ تجهيز ملفك…';

  @override
  String get dsrExportSendingRequest => 'جارٍ إرسال طلب التصدير…';

  @override
  String get dsrExportRequestFailed => 'فشل في إرسال الطلب';

  @override
  String get dsrErasureTitle => 'حذف الحساب';

  @override
  String get dsrErasureHeadline => 'حذف حسابك نهائياً';

  @override
  String get dsrErasureDescription =>
      'هذا الإجراء لا رجعة فيه. سيتم حذف جميع بياناتك وبيانات حسابك.';

  @override
  String get dsrErasureRequestButton => 'طلب حذف الحساب';

  @override
  String get dsrErasureWarningTitle => 'تحذير مهم';

  @override
  String get dsrErasureWarningPoint1 => 'سيتم حذف جميع بياناتك الشخصية نهائياً';

  @override
  String get dsrErasureWarningPoint2 => 'لن تتمكن من استرجاع حسابك أو بياناتك';

  @override
  String get dsrErasureWarningPoint3 =>
      'سيتم إلغاء جميع الطلبات والحجوزات النشطة';

  @override
  String get dsrErasureWarningPoint4 => 'سيتم حذف سجل المدفوعات والمعاملات';

  @override
  String get dsrErasureWarningPoint5 => 'قد يستغرق تنفيذ الطلب عدة أيام';

  @override
  String get dsrErasureLegalNotice =>
      'حذف الحساب يخضع للائحة حماية البيانات العامة (GDPR). سنرسل لك تأكيداً قبل تنفيذ الحذف النهائي.';

  @override
  String get dsrErasureRequestStatus => 'حالة الطلب';

  @override
  String get dsrErasureStatusPending => 'في انتظار المراجعة';

  @override
  String get dsrErasureStatusInProgress => 'قيد المعالجة';

  @override
  String get dsrErasureStatusReady => 'جاهز للتأكيد';

  @override
  String get dsrErasureStatusCompleted => 'مكتمل';

  @override
  String get dsrErasureStatusFailed => 'فشل في المعالجة';

  @override
  String get dsrErasureStatusCanceled => 'ملغي';

  @override
  String get dsrErasureReviewingRequest => 'جارٍ مراجعة طلبك…';

  @override
  String get dsrErasureSendingRequest => 'جارٍ إرسال طلب الحذف…';

  @override
  String get dsrErasureRequestFailed => 'فشل في إرسال الطلب';

  @override
  String get dsrErasureNewRequest => 'طلب حذف جديد';

  @override
  String get dsrErasureConfirmTitle => 'تأكيد الحذف النهائي';

  @override
  String get dsrErasureConfirmMessage =>
      'هذا هو الخطوة الأخيرة. بعد التأكيد، سيتم حذف حسابك نهائياً خلال 30 يوماً ولن يمكن التراجع عن هذا القرار.';

  @override
  String get dsrErasureConfirmButton => 'تأكيد الحذف';

  @override
  String get legalPrivacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get legalPrivacyPolicyUnavailable =>
      'سياسة الخصوصية غير متاحة حالياً.';

  @override
  String get legalTermsOfServiceTitle => 'شروط الاستخدام';

  @override
  String get legalTermsOfServiceUnavailable =>
      'شروط الاستخدام غير متاحة حالياً.';

  @override
  String get legalAboutTitle => 'المعلومات القانونية';

  @override
  String get legalPrivacyButton => 'سياسة الخصوصية';

  @override
  String get legalTermsButton => 'شروط الاستخدام';

  @override
  String get legalOpenSourceLicenses => 'التراخيص المفتوحة المصدر';

  @override
  String get ordersTitle => 'الطلبات';

  @override
  String ordersOrderLabel(String orderId) {
    return 'الطلب: $orderId';
  }

  @override
  String get cartTitle => 'السلة';

  @override
  String cartItemsLabel(int count) {
    return 'العناصر: $count';
  }

  @override
  String get checkoutTitle => 'الدفع';

  @override
  String get paymentTitle => 'الدفع';

  @override
  String get paymentInitializing => 'جارٍ تهيئة نظام الدفع...';

  @override
  String get paymentDebugTitle => 'تصحيح المدفوعات';

  @override
  String paymentEnabled(String enabled) {
    return 'المدفوعات مفعلة: $enabled';
  }

  @override
  String paymentMissingKeys(String keys) {
    return 'مفاتيح الإعداد المفقودة: $keys';
  }

  @override
  String paymentGatewayStatus(String status) {
    return 'حالة البوابة: $status';
  }

  @override
  String paymentGateway(String type) {
    return 'البوابة: $type';
  }

  @override
  String paymentSheetStatus(String status) {
    return 'حالة الشاشة: $status';
  }

  @override
  String paymentSheet(String type) {
    return 'الشاشة: $type';
  }

  @override
  String get paymentApplePay => 'الدفع بـ Apple Pay';

  @override
  String get paymentGooglePay => 'الدفع بـ Google Pay';

  @override
  String get paymentDigitalWallet => 'الدفع بالمحفظة الرقمية';

  @override
  String get paymentCash => 'الدفع نقداً';

  @override
  String get trackingTitle => 'التتبع';

  @override
  String get trackingLocationTitle => 'تتبع الموقع';

  @override
  String get trackingCurrentLocation => 'موقعك الحالي';

  @override
  String get trackingTripRoute => 'مسار الرحلة';

  @override
  String get trackingRealtimeUnavailableTitle => 'التتبع اللحظي غير متاح';

  @override
  String get trackingRealtimeUnavailableBody =>
      'التتبّع اللحظي غير متاح حاليًا، سيتم تحديث حالة الطلب تلقائيًا.';

  @override
  String get trackingOrderStatus => 'حالة الطلب';

  @override
  String get trackingNoActiveTrip => 'لا توجد رحلة نشطة';

  @override
  String get mapTitle => 'الخريطة';

  @override
  String get mapSmokeTestTitle => 'اختبار الخرائط';

  @override
  String get mapTestLocation => 'موقع الاختبار';

  @override
  String get mobilityBgTestsTitle => 'اختبارات التنقل في الخلفية (المرحلة 3)';

  @override
  String get mobilityTestBackgroundTracking => 'اختبار التتبع في الخلفية';

  @override
  String get mobilityTestGeofence => 'اختبار السياج الجغرافي';

  @override
  String get mobilityTestTripRecording => 'اختبار تسجيل الرحلة';

  @override
  String get adminPanelTitle => 'لوحة التحكم';

  @override
  String get adminUserInfo => 'معلومات المستخدم';

  @override
  String adminUserLabel(String userId) {
    return 'المستخدم: $userId';
  }

  @override
  String adminRoleLabel(String role) {
    return 'الدور: $role';
  }

  @override
  String get adminUserManagement => 'إدارة المستخدمين';

  @override
  String get adminAnalyticsReports => 'التحليلات والتقارير';

  @override
  String get adminAnalyticsAccess => 'لديك صلاحية الوصول للتحليلات';

  @override
  String get adminSystemMonitoring => 'مراقبة النظام';

  @override
  String get adminRbacStats => 'إحصائيات RBAC';

  @override
  String adminRbacEnabled(String status) {
    return 'الحالة: $status';
  }

  @override
  String get adminRbacStatusEnabled => 'مفعّل';

  @override
  String get adminRbacStatusDisabled => 'معطّل';

  @override
  String adminCanaryPercentage(int percentage) {
    return 'نسبة الـ Canary: $percentage%';
  }

  @override
  String adminRolesCount(int count) {
    return 'عدد الأدوار: $count';
  }

  @override
  String adminTotalPermissions(int count) {
    return 'إجمالي الصلاحيات: $count';
  }

  @override
  String get trackingCheckingAvailability => 'جارٍ التحقق من توفر التتبع...';

  @override
  String get trackingLoadingRoute => 'جارٍ تحميل المسار...';

  @override
  String get ordersHistoryTitle => 'طلباتي';

  @override
  String get ordersHistoryEmptyTitle => 'لا توجد طلبات بعد';

  @override
  String get ordersHistoryEmptySubtitle =>
      'لا يوجد لديك أي طلبات حتى الآن. ابدأ بإنشاء شحنة جديدة.';

  @override
  String get ordersHistoryUnavailableTitle => 'الطلبات غير متاحة';

  @override
  String get ordersHistoryLoadError => 'تعذّر تحميل سجل الطلبات';

  @override
  String get ordersFilterAll => 'الكل';

  @override
  String get ordersFilterParcels => 'الطرود';

  @override
  String get ordersFilterRides => 'الرحلات';

  @override
  String get ordersSectionRidesTitle => 'الرحلات';

  @override
  String ordersRideItemTitleToDestination(String destination) {
    return 'رحلة إلى $destination';
  }

  @override
  String ordersRideItemTitleWithService(
    String serviceName,
    String destination,
  ) {
    return '$serviceName إلى $destination';
  }

  @override
  String ordersRideItemSubtitleWithOrigin(String origin, String date) {
    return 'من $origin · $date';
  }

  @override
  String get ordersRideStatusCompleted => 'مكتملة';

  @override
  String get ordersRideStatusCancelled => 'ملغاة';

  @override
  String get ordersRideStatusFailed => 'فشلت';

  @override
  String get paymentMethodsTitle => 'وسائل الدفع';

  @override
  String get paymentMethodsEmptyTitle => 'لا توجد وسائل دفع';

  @override
  String get paymentMethodsEmptySubtitle => 'أضف وسيلة دفع للبدء';

  @override
  String get paymentMethodsAddButton => 'إضافة وسيلة دفع';

  @override
  String get paymentMethodsLoadError => 'تعذّر تحميل وسائل الدفع';

  @override
  String get paymentMethodsSaving => 'جارٍ الحفظ...';

  @override
  String get authVerifying => 'جارٍ التحقق...';

  @override
  String get authSendingCode => 'جارٍ إرسال الرمز...';

  @override
  String get featureUnavailableTitle => 'الميزة غير متاحة';

  @override
  String get featureUnavailableGeneric =>
      'هذه الميزة غير متاحة حالياً. حاول مرة أخرى لاحقاً.';

  @override
  String get onbWelcomeTitle => 'أهلاً بك في ديليفري ويز';

  @override
  String get onbWelcomeBody =>
      'شريكك الموثوق للتوصيل. اطلب ما تحتاجه وتتبع توصيلتك بالوقت الفعلي.';

  @override
  String get onbAppIntroTitle => 'كيف يعمل';

  @override
  String get onbAppIntroBody =>
      'تصفح المنتجات، قدم طلبك، ونوصله لباب بيتك. بسيط وسريع.';

  @override
  String get onbOrderingTitle => 'طلب سهل';

  @override
  String get onbOrderingBody =>
      'اعثر على ما تحتاجه، أضفه للسلة، وادفع في ثوانٍ. خيارات دفع متعددة متوفرة حيث يُدعم ذلك.';

  @override
  String get onbTrackingTitle => 'تتبع طلبك';

  @override
  String get onbTrackingBody =>
      'تابع توصيلتك بالوقت الفعلي عندما يكون التتبع متاحاً في منطقتك. ستتلقى تحديثات في كل خطوة.';

  @override
  String get onbSecurityTitle => 'أمانك يهمنا';

  @override
  String get onbSecurityBody =>
      'بياناتك محمية بمعايير أمان عالمية. لن نشارك معلوماتك الشخصية أبداً بدون موافقتك.';

  @override
  String get onbNotificationsTitle => 'ابق على اطلاع';

  @override
  String get onbNotificationsBody =>
      'فعّل الإشعارات لتلقي تحديثات الطلبات وتنبيهات التوصيل والعروض الحصرية.';

  @override
  String get onbReadyTitle => 'أنت جاهز!';

  @override
  String get onbReadyBody =>
      'ابدأ الاستكشاف وقدم طلبك الأول. نحن هنا لمساعدتك متى احتجت.';

  @override
  String get onbRideTitle => 'احصل على توصيلة فوراً.';

  @override
  String get onbRideBody =>
      'اضغط، اركب، وصل. نقل سريع وموثوق وبأسعار مناسبة في متناول يدك.';

  @override
  String get onbParcelsTitle => 'وصّل أي شيء بسهولة.';

  @override
  String get onbParcelsBody =>
      'أرسل طرودك عبر المدينة أو عبر البلاد. تتبع كل خطوة في الرحلة.';

  @override
  String get onbFoodTitle => 'طعامك المفضل يصلك.';

  @override
  String get onbFoodBody =>
      'تشتهي شيئاً لذيذاً؟ اطلب من أفضل المطاعم واستمتع بتوصيل سريع لباب بيتك.';

  @override
  String get onbRiderWelcomeTitle => 'أهلاً بك أيها السائق!';

  @override
  String get onbRiderWelcomeBody =>
      'انضم لشبكة التوصيل وابدأ بالكسب. ساعات مرنة وأجر عادل.';

  @override
  String get onbRiderHowItWorksTitle => 'رحلتك تبدأ هنا';

  @override
  String get onbRiderHowItWorksBody =>
      'اقبل التوصيلات، توجه للاستلام، وصّل للعملاء. تتبع أرباحك في التطبيق.';

  @override
  String get onbRiderLocationTitle => 'تفعيل الموقع';

  @override
  String get onbRiderLocationBody =>
      'نستخدم موقعك لربطك بالتوصيلات القريبة وتوفير التنقل. يُشارك موقعك فقط أثناء التوصيلات النشطة.';

  @override
  String get onbRiderSecurityTitle => 'آمن ومحمي';

  @override
  String get onbRiderSecurityBody =>
      'أرباحك وبياناتك الشخصية محمية. المصادقة متعددة العوامل تحافظ على أمان حسابك.';

  @override
  String get onbRiderNotificationsTitle => 'لا تفوت أي توصيلة';

  @override
  String get onbRiderNotificationsBody =>
      'احصل على تنبيهات فورية لطلبات التوصيل الجديدة والتحديثات المهمة.';

  @override
  String get onbRiderReadyTitle => 'جاهز للتوصيل!';

  @override
  String get onbRiderReadyBody =>
      'أنت مُعدّ وجاهز للانطلاق. ابدأ بقبول التوصيلات الآن.';

  @override
  String get onbCtaGetStarted => 'ابدأ الآن';

  @override
  String get onbCtaNext => 'التالي';

  @override
  String get onbCtaSkip => 'تخطي';

  @override
  String get onbCtaEnableNotifications => 'تفعيل الإشعارات';

  @override
  String get onbCtaEnableLocation => 'تفعيل الموقع';

  @override
  String get onbCtaStartOrdering => 'ابدأ الطلب';

  @override
  String get onbCtaStartDelivering => 'ابدأ التوصيل';

  @override
  String get onbCtaMaybeLater => 'ربما لاحقاً';

  @override
  String get onbCtaDone => 'تم';

  @override
  String get onbCtaBack => 'رجوع';

  @override
  String get hintAuthPhoneTitle => 'تسجيل دخول آمن';

  @override
  String get hintAuthPhoneBody =>
      'سنرسل رمز تحقق لهذا الرقم. رقم هاتفك يساعدنا على حماية حسابك.';

  @override
  String get hintAuthOtpTitle => 'تحقق من رسائلك';

  @override
  String get hintAuthOtpBody =>
      'أدخل الرمز الذي أرسلناه لهاتفك. هذا يؤكد أنك أنت حقاً.';

  @override
  String get hintAuth2faTitle => 'حماية إضافية';

  @override
  String get hintAuth2faBody =>
      'المصادقة الثنائية تضيف طبقة أمان إضافية لحسابك.';

  @override
  String get hintAuthBiometricTitle => 'دخول سريع';

  @override
  String get hintAuthBiometricBody =>
      'استخدم بصمتك أو وجهك لتسجيل الدخول بسرعة مع الحفاظ على أمان حسابك.';

  @override
  String get hintPaymentsMethodsTitle => 'خيارات الدفع';

  @override
  String get hintPaymentsMethodsBody =>
      'أضف طريقة دفع لتسريع عملية الشراء. معلومات الدفع الخاصة بك مشفرة بشكل آمن.';

  @override
  String get hintPaymentsSecurityTitle => 'دفع آمن';

  @override
  String get hintPaymentsSecurityBody =>
      'تفاصيل بطاقتك مشفرة ولا تُخزن على خوادمنا أبداً. المدفوعات تُعالج من قبل مزودين موثوقين.';

  @override
  String get hintPaymentsLimitedTitle => 'خيارات دفع محدودة';

  @override
  String get hintPaymentsLimitedBody =>
      'بعض طرق الدفع قد لا تكون متوفرة في منطقتك. الدفع عند الاستلام متاح حيث يُدعم.';

  @override
  String get hintTrackingExplanationTitle => 'تتبع مباشر';

  @override
  String get hintTrackingExplanationBody =>
      'شاهد رحلة طلبك من الاستلام حتى التوصيل على الخريطة.';

  @override
  String get hintTrackingUnavailableTitle => 'التتبع غير متاح';

  @override
  String get hintTrackingUnavailableBody =>
      'التتبع بالوقت الفعلي غير متاح لهذا الطلب. ستتلقى تحديثات الحالة عبر الإشعارات.';

  @override
  String get hintTrackingRealtimeTitle => 'تحديثات بالوقت الفعلي';

  @override
  String get hintTrackingRealtimeBody =>
      'الخريطة تُحدّث تلقائياً مع تقدم توصيلتك.';

  @override
  String get hintNotificationsImportanceTitle => 'لماذا الإشعارات مهمة';

  @override
  String get hintNotificationsImportanceBody =>
      'احصل على تحديثات فورية حول حالة طلبك ووصول التوصيلة والعروض الخاصة.';

  @override
  String get hintNotificationsPermissionTitle => 'تفعيل الإشعارات';

  @override
  String get hintNotificationsPermissionBody =>
      'لتلقي تحديثات الطلبات وتنبيهات التوصيل، يرجى تفعيل الإشعارات.';

  @override
  String get hintNotificationsPermissionCta => 'فعّل الآن';

  @override
  String get hintOrdersFirstTitle => 'طلبك الأول';

  @override
  String get hintOrdersFirstBody => 'تهانينا على طلبك الأول! تتبع تقدمه هنا.';

  @override
  String get hintOrdersEmptyTitle => 'لا توجد طلبات بعد';

  @override
  String get hintOrdersEmptyBody =>
      'ابدأ بالتصفح وقدم طلبك الأول. سيظهر سجل طلباتك هنا.';

  @override
  String get hintOrdersEmptyCta => 'تصفح الآن';

  @override
  String get settingsReplayOnboarding => 'عرض مقدمة التطبيق';

  @override
  String get settingsReplayOnboardingDescription =>
      'شاهد دليل الترحيب مرة أخرى';

  @override
  String get rideBookingTitle => 'اطلب رحلة';

  @override
  String get rideBookingMapStubLabel => 'معاينة خريطة (وضع تجريبي لعرض الرحلة)';

  @override
  String get rideBookingSheetTitle => 'إلى أين تريد الذهاب؟';

  @override
  String get rideBookingSheetSubtitle =>
      'اختر نقطة الانطلاق والوجهة لعرض الخيارات والتسعير.';

  @override
  String get rideBookingPickupLabel => 'نقطة الانطلاق';

  @override
  String get rideBookingPickupCurrentLocation => 'موقعك الحالي';

  @override
  String get rideBookingDestinationLabel => 'الوجهة';

  @override
  String get rideBookingDestinationHint => 'إلى أين؟';

  @override
  String get rideBookingRecentTitle => 'أماكنك الأخيرة';

  @override
  String get rideBookingRecentHome => 'المنزل';

  @override
  String get rideBookingRecentHomeSubtitle => 'عنوان المنزل المحفوظ';

  @override
  String get rideBookingRecentWork => 'العمل';

  @override
  String get rideBookingRecentWorkSubtitle => 'عنوان العمل المحفوظ';

  @override
  String get rideBookingRecentAddNew => 'إضافة مكان جديد';

  @override
  String get rideBookingRecentAddNewSubtitle => 'احفظ وجهة متكررة جديدة';

  @override
  String get rideBookingSeeOptionsCta => 'عرض الخيارات';

  @override
  String get rideConfirmTitle => 'تأكيد الرحلة';

  @override
  String get rideConfirmMapStubLabel =>
      'معاينة المسار (وضع تجريبي – سيتم عرض السائق والوجهة لاحقًا).';

  @override
  String get rideConfirmSheetTitle => 'اختر نوع الرحلة';

  @override
  String get rideConfirmSheetSubtitle =>
      'اختر الخيار المناسب، راجع التسعير، ثم أكّد رحلتك.';

  @override
  String get rideConfirmOptionEconomyTitle => 'اقتصادي';

  @override
  String get rideConfirmOptionEconomySubtitle =>
      'رحلات يومية ميسورة التكلفة لما يصل إلى ٤ أشخاص.';

  @override
  String get rideConfirmOptionXlTitle => 'XL';

  @override
  String get rideConfirmOptionXlSubtitle =>
      'مساحة إضافية للمجموعات والأغراض الكبيرة.';

  @override
  String get rideConfirmOptionPremiumTitle => 'مميزة';

  @override
  String get rideConfirmOptionPremiumSubtitle =>
      'رحلات مريحة مع أفضل السائقين تقييمًا.';

  @override
  String rideConfirmOptionEtaFormat(String minutes) {
    return '$minutes دقيقة تقريبًا';
  }

  @override
  String rideConfirmOptionPriceApprox(String amount) {
    return '≈ $amount ريال';
  }

  @override
  String get rideConfirmPaymentLabel => 'طريقة الدفع';

  @override
  String get rideConfirmPaymentStubValue => 'فيزا •• 4242 (تجريبية)';

  @override
  String get rideConfirmPrimaryCta => 'اطلب الرحلة';

  @override
  String get rideConfirmRequestedStubMessage =>
      'طلب الرحلة هنا تجريبي – سيتم ربطه بالخلفية لاحقًا.';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileSectionSettingsTitle => 'الإعدادات';

  @override
  String get profileSectionPrivacyTitle => 'الخصوصية والبيانات';

  @override
  String get profileUserFallbackName => 'مستخدم';

  @override
  String get profileUserPhoneLabel => 'رقم الجوال';

  @override
  String get profileSettingsPersonalInfoTitle => 'المعلومات الشخصية';

  @override
  String get profileSettingsPersonalInfoSubtitle =>
      'إدارة اسمك وبياناتك الأساسية.';

  @override
  String get profileSettingsRidePrefsTitle => 'تفضيلات الرحلات';

  @override
  String get profileSettingsRidePrefsSubtitle => 'قريبًا.';

  @override
  String get profileSettingsNotificationsTitle => 'الإشعارات';

  @override
  String get profileSettingsNotificationsSubtitle =>
      'تحكم في التنبيهات والعروض.';

  @override
  String get profileSettingsHelpTitle => 'المساعدة والدعم';

  @override
  String get profileSettingsHelpSubtitle =>
      'احصل على مساعدة في رحلاتك وطلباتك.';

  @override
  String get profilePrivacyExportTitle => 'تصدير بياناتي';

  @override
  String get profilePrivacyExportSubtitle => 'اطلب نسخة من بياناتك الشخصية.';

  @override
  String get profilePrivacyErasureTitle => 'حذف بياناتي';

  @override
  String get profilePrivacyErasureSubtitle =>
      'اطلب حذف بياناتك الشخصية من النظام.';

  @override
  String get profileLogoutTitle => 'تسجيل الخروج';

  @override
  String get profileLogoutSubtitle => 'تسجيل الخروج من حسابك';

  @override
  String get profileLogoutDialogTitle => 'تأكيد تسجيل الخروج';

  @override
  String get profileLogoutDialogBody => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get profileLogoutDialogCancel => 'إلغاء';

  @override
  String get profileLogoutDialogConfirm => 'تسجيل الخروج';

  @override
  String get profileGuestName => 'مستخدم زائر';

  @override
  String get profileGuestPhonePlaceholder => 'أضف رقم جوالك';

  @override
  String get profileLogoutSnack => 'تسجيل الخروج غير مفعّل بالكامل بعد';

  @override
  String get ridePhaseDraftLabel => 'مسودة';

  @override
  String get ridePhaseQuotingLabel => 'جارٍ حساب السعر…';

  @override
  String get ridePhaseRequestingLabel => 'جارٍ إرسال الطلب…';

  @override
  String get ridePhaseFindingDriverLabel => 'جارٍ البحث عن سائق…';

  @override
  String get ridePhaseDriverAcceptedLabel => 'تم قبول السائق';

  @override
  String get ridePhaseDriverArrivedLabel => 'السائق وصل';

  @override
  String get ridePhaseInProgressLabel => 'الرحلة جارية';

  @override
  String get ridePhasePaymentLabel => 'إتمام الدفع';

  @override
  String get ridePhaseCompletedLabel => 'تم إنهاء الرحلة';

  @override
  String get ridePhaseCancelledLabel => 'تم إلغاء الرحلة';

  @override
  String get ridePhaseFailedLabel => 'فشل في الرحلة';

  @override
  String get rideErrorOptionsLoadFailed =>
      'تعذر تحميل خيارات الرحلة. حاول مرة أخرى.';

  @override
  String get rideErrorRetryCta => 'إعادة المحاولة';

  @override
  String get rideActiveNoTripTitle => 'لا توجد رحلة نشطة';

  @override
  String get rideActiveNoTripBody => 'لا توجد لديك رحلة جارية في الوقت الحالي.';

  @override
  String get rideActiveAppBarTitle => 'رحلتك';

  @override
  String rideActiveEtaFormat(String minutes) {
    return 'الوقت المتوقع للوصول ~ $minutes دقيقة';
  }

  @override
  String get rideActiveContactDriverCta => 'التواصل مع السائق';

  @override
  String get rideActiveShareTripCta => 'مشاركة حالة الرحلة';

  @override
  String get rideActiveCancelTripCta => 'إلغاء الرحلة';

  @override
  String get rideActiveShareTripCopied =>
      'تم نسخ حالة الرحلة. يمكنك لصقها في أي تطبيق.';

  @override
  String get rideActiveContactNoPhoneError =>
      'بيانات تواصل السائق غير متوفرة حالياً.';

  @override
  String get rideActiveShareGenericError =>
      'لا يمكن تجهيز حالة الرحلة الآن. يرجى المحاولة لاحقاً.';

  @override
  String rideActiveShareMessageTemplate(String destination, String link) {
    return 'أنا في رحلة مع Delivery Ways إلى $destination. يمكنك متابعة حالة الرحلة هنا: $link';
  }

  @override
  String get rideActiveCancelErrorGeneric =>
      'تعذر إلغاء الرحلة. يرجى المحاولة مرة أخرى.';

  @override
  String get rideCancelDialogTitle => 'هل تريد إلغاء الرحلة؟';

  @override
  String get rideCancelDialogMessage =>
      'إذا ألغيت الآن، سيتوقف السائق عن التوجه إلى موقعك.';

  @override
  String get rideCancelDialogKeepRideCta => 'الاستمرار في الرحلة';

  @override
  String get rideCancelDialogConfirmCta => 'إلغاء الرحلة';

  @override
  String get rideCancelSuccessSnackbar => 'تم إلغاء رحلتك.';

  @override
  String get rideCancelReasonByRider => 'تم الإلغاء من قِبل الراكب';

  @override
  String get rideActiveHeadlineFindingDriver => 'جارٍ البحث عن سائق…';

  @override
  String rideActiveHeadlineDriverEta(String minutes) {
    return 'السائق يبعد $minutes دقيقة';
  }

  @override
  String get rideActiveHeadlineDriverOnTheWay => 'السائق في الطريق إليك';

  @override
  String get rideActiveHeadlineDriverArrived => 'السائق وصل إلى موقعك';

  @override
  String get rideActiveHeadlineInProgress => 'الرحلة جارية الآن';

  @override
  String get rideActiveHeadlinePayment => 'جارٍ إتمام الدفع';

  @override
  String get rideActiveHeadlineCompleted => 'تم إنهاء الرحلة بنجاح';

  @override
  String get rideActiveHeadlineCancelled => 'تم إلغاء الرحلة';

  @override
  String get rideActiveHeadlineFailed => 'حدث خطأ في الرحلة';

  @override
  String get rideActiveHeadlinePreparing => 'جارٍ تجهيز رحلتك';

  @override
  String get rideActiveGoBackCta => 'العودة';

  @override
  String get rideActiveCancelledTitle => 'تم إلغاء الرحلة';

  @override
  String get rideActiveCancelledBody =>
      'تم إلغاء رحلتك. يمكنك طلب رحلة جديدة في أي وقت.';

  @override
  String get rideActiveFailedTitle => 'حدث خطأ ما';

  @override
  String get rideActiveFailedBody =>
      'تعذّر إكمال هذه الرحلة. يرجى المحاولة مرة أخرى بعد قليل.';

  @override
  String get rideActiveBackToHomeCta => 'الرجوع للرئيسية';

  @override
  String get rideActiveRequestNewRideCta => 'طلب رحلة جديدة';

  @override
  String rideActiveDestinationLabel(String destination) {
    return 'إلى $destination';
  }

  @override
  String rideActiveSummaryServiceAndPrice(String serviceName, String price) {
    return '$serviceName · $price';
  }

  @override
  String rideActivePayingWith(String method) {
    return 'الدفع عبر $method';
  }

  @override
  String get rideActivePriceNotAvailable => 'السعر غير متاح بعد';

  @override
  String homeActiveRidePriceAndPayment(String price, String paymentMethod) {
    return '$price · $paymentMethod';
  }

  @override
  String get rideDebugFsmTitle => 'أدوات تصحيح FSM';

  @override
  String rideDebugCurrentPhase(String phase) {
    return 'المرحلة الحالية: $phase';
  }

  @override
  String get rideDebugDriverFound => 'السائق قبل';

  @override
  String get rideDebugDriverArrived => 'السائق وصل';

  @override
  String get rideDebugStartTrip => 'بدء الرحلة';

  @override
  String get rideDebugCompleteTrip => 'إنهاء الرحلة';

  @override
  String get rideDebugConfirmPayment => 'تأكيد الدفع';

  @override
  String get rideStatusFindingDriver => 'جاري البحث عن سائق...';

  @override
  String get rideStatusDriverAccepted => 'السائق في الطريق';

  @override
  String get rideStatusDriverArrived => 'السائق وصل';

  @override
  String get rideStatusInProgress => 'الرحلة قيد التنفيذ';

  @override
  String get rideStatusPaymentPending => 'في انتظار الدفع';

  @override
  String get rideStatusCompleted => 'تم إنهاء الرحلة';

  @override
  String get rideStatusUnknown => 'جاري تجهيز رحلتك...';

  @override
  String get homeActiveRideViewTripCta => 'عرض الرحلة';

  @override
  String get homeActiveRideTitleGeneric => 'رحلة نشطة';

  @override
  String homeActiveRideEtaTitle(int minutes) {
    return 'يصل خلال $minutes دقيقة';
  }

  @override
  String homeActiveRideSubtitleToDestination(String destination) {
    return 'إلى $destination';
  }

  @override
  String get homeHubTitle => 'إلى أين تريد الذهاب؟';

  @override
  String get homeHubCurrentLocationLabel => 'موقعك الحالي';

  @override
  String get homeHubCurrentLocationLoading => 'جاري تحديد موقعك...';

  @override
  String get homeHubCurrentLocationUnavailable => 'لا يمكن تحديد موقعك';

  @override
  String get homeHubServiceRide => 'مشاوير';

  @override
  String get homeHubServiceParcels => 'طرود';

  @override
  String get homeHubServiceFood => 'طلبات الطعام';

  @override
  String get homeHubActiveRideTitle => 'رحلة قيد التنفيذ';

  @override
  String get homeHubActiveRideSubtitle => 'تابع رحلتك النشطة';

  @override
  String get homeHubParcelsComingSoonMessage =>
      'خدمة الطرود قادمة قريبًا إلى مدينتك.';

  @override
  String get homeHubFoodComingSoonMessage =>
      'خدمة طلبات الطعام قادمة قريبًا إلى مدينتك.';

  @override
  String get homeHubSearchPlaceholder => 'إلى أين؟';

  @override
  String get rideDestinationTitle => 'إلى أين؟';

  @override
  String get rideDestinationPickupLabel => 'نقطة الالتقاط';

  @override
  String get rideDestinationPickupCurrentLocation => 'الموقع الحالي';

  @override
  String get rideDestinationRecentLocationsSection => 'المواقع الأخيرة';

  @override
  String get rideLocationPickerTitle => 'اختيار موقع الرحلة';

  @override
  String get rideLocationPickerPickupLabel => 'مكان الانطلاق';

  @override
  String get rideLocationPickerDestinationLabel => 'وجهة الوصول';

  @override
  String get rideLocationPickerPickupPlaceholder => 'من أين نلتقطك؟';

  @override
  String get rideLocationPickerDestinationPlaceholder => 'إلى أين تتجه؟';

  @override
  String get rideLocationPickerMapHint =>
      'حرّك العلامة أو استخدم البحث لتحديد المواقع.';

  @override
  String get rideLocationPickerContinueCta => 'عرض الأسعار';

  @override
  String get rideTripConfirmationTitle => 'تأكيد الرحلة';

  @override
  String get rideTripConfirmationRequestRideCta => 'طلب الرحلة';

  @override
  String get rideTripConfirmationPaymentSectionTitle => 'الدفع';

  @override
  String get rideTripConfirmationPaymentMethodCash => 'نقدًا';

  @override
  String get rideTripSummaryTitle => 'ملخص الرحلة';

  @override
  String get rideTripSummaryCompletedTitle => 'تم إنهاء الرحلة';

  @override
  String get rideTripSummaryCompletedSubtitle =>
      'شكرًا لاستخدامك Delivery Ways';

  @override
  String get rideTripSummaryCancelledTitle => 'تم إلغاء الرحلة';

  @override
  String get rideTripSummaryCancelledSubtitle => 'تم إلغاء رحلتك';

  @override
  String get rideTripSummaryFailedTitle => 'فشلت الرحلة';

  @override
  String get rideTripSummaryFailedSubtitle => 'تعذّر إكمال هذه الرحلة';

  @override
  String get rideFailReasonNoDriverFound => 'لم يتم العثور على سائق';

  @override
  String get rideFailNoDriverFoundSnackbar =>
      'تعذّر العثور على سائق لهذه الرحلة.';

  @override
  String get rideFailNoDriverFoundCta => 'لا يوجد سائقون متاحون؟ حاول لاحقاً';

  @override
  String get rideTripSummaryRouteSectionTitle => 'المسار';

  @override
  String get rideTripSummaryFareSectionTitle => 'الأجرة';

  @override
  String get rideTripSummaryTotalLabel => 'الإجمالي';

  @override
  String get rideTripSummaryDriverSectionTitle => 'السائق';

  @override
  String get rideTripSummaryRatingLabel => 'قيّم السائق';

  @override
  String get rideTripSummaryDoneCta => 'إنهاء';

  @override
  String rideTripCompletionServiceLabel(String serviceName) {
    return 'رحلة $serviceName';
  }

  @override
  String get rideConfirmLoadingTitle => 'جاري جلب خيارات الرحلة...';

  @override
  String get rideConfirmLoadingSubtitle =>
      'يرجى الانتظار بينما نبحث عن أفضل الخيارات لك.';

  @override
  String get rideConfirmErrorTitle => 'تعذر تحميل خيارات الرحلة';

  @override
  String get rideConfirmErrorSubtitle =>
      'يرجى التحقق من الاتصال بالإنترنت ثم المحاولة مرة أخرى.';

  @override
  String get rideConfirmEmptyTitle => 'لا توجد رحلات متاحة';

  @override
  String get rideConfirmEmptySubtitle => 'يرجى المحاولة مرة أخرى بعد قليل.';

  @override
  String get rideConfirmRetryCta => 'إعادة المحاولة';

  @override
  String get rideConfirmRecommendedBadge => 'موصى به';

  @override
  String get rideQuoteErrorTitle => 'تعذّر تحميل خيارات الرحلة';

  @override
  String get rideQuoteErrorGeneric =>
      'يرجى التحقق من الاتصال بالإنترنت ثم المحاولة مرة أخرى.';

  @override
  String get rideQuoteErrorNoOptions =>
      'لا تتوفر خيارات رحلات لهذا المسار في الوقت الحالي.';

  @override
  String get ridePricingErrorGeneric =>
      'تعذّر تحميل أسعار الرحلة، حاول مرة أخرى.';

  @override
  String get rideQuoteRetryCta => 'إعادة المحاولة';

  @override
  String get rideQuoteEmptyTitle => 'لا توجد رحلات متاحة';

  @override
  String get rideQuoteEmptyDescription =>
      'يرجى المحاولة مرة أخرى خلال بضع دقائق.';

  @override
  String get rideConfirmFromLabel => 'من';

  @override
  String get rideConfirmToLabel => 'إلى';

  @override
  String get onboardingWelcomeTitle => 'مرحبًا في Delivery Ways';

  @override
  String get onboardingWelcomeSubtitle =>
      'كل الرحلات والطرود والتوصيل في مكان واحد.';

  @override
  String get onboardingWelcomeGetStartedCta => 'ابدأ الآن';

  @override
  String get onboardingPermissionsTitle => 'الصلاحيات المطلوبة';

  @override
  String get onboardingPermissionsLocation => 'الوصول إلى الموقع';

  @override
  String get onboardingPermissionsLocationSubtitle =>
      'نستخدم موقعك للعثور على أقرب السائقين.';

  @override
  String get onboardingPermissionsNotifications => 'الإشعارات';

  @override
  String get onboardingPermissionsNotificationsSubtitle =>
      'لإبقائك على اطلاع بحالة رحلاتك وطرودك.';

  @override
  String get onboardingPermissionsContinueCta => 'متابعة';

  @override
  String get onboardingPermissionsSkipCta => 'تخطي الآن';

  @override
  String get onboardingPreferencesTitle => 'تهيئة التفضيلات';

  @override
  String get onboardingPreferencesSubtitle =>
      'يمكنك تغيير هذه التفضيلات لاحقًا من الإعدادات.';

  @override
  String get onboardingPreferencesPrimaryServiceTitle =>
      'ما الخدمة التي تستخدمها أكثر؟';

  @override
  String get onboardingPreferencesServiceRides => 'الرحلات';

  @override
  String get onboardingPreferencesServiceRidesDesc =>
      'احصل على توصيلة من وإلى وجهتك';

  @override
  String get onboardingPreferencesServiceParcels => 'الطرود';

  @override
  String get onboardingPreferencesServiceParcelsDesc => 'أرسل واستلم الطرود';

  @override
  String get onboardingPreferencesServiceFood => 'الطعام';

  @override
  String get onboardingPreferencesServiceFoodDesc => 'اطلب من المطاعم';

  @override
  String get onboardingPreferencesDoneCta => 'ابدأ استخدام Delivery Ways';

  @override
  String get parcelsEntryTitle => 'الطرود';

  @override
  String get parcelsEntrySubtitle => 'اشحن وتابع طرودك من مكان واحد.';

  @override
  String get parcelsEntryCreateShipmentCta => 'إنشاء شحنة';

  @override
  String get parcelsEntryViewShipmentsCta => 'عرض الشحنات';

  @override
  String get parcelsEntryComingSoonMessage => 'مسارات الطرود قيد التطوير.';

  @override
  String get parcelsEntryFooterNote => 'إصدار Parcels MVP قيد التطوير النشط.';

  @override
  String get parcelsComingSoonMessage => 'خدمة الطرود قادمة قريبًا.';

  @override
  String get parcelsDestinationTitle => 'إنشاء شحنة';

  @override
  String get parcelsDestinationSubtitle =>
      'أدخل عنوان الاستلام وعنوان التسليم لشحنتك.';

  @override
  String get parcelsDestinationPickupLabel => 'عنوان الاستلام';

  @override
  String get parcelsDestinationPickupHint => 'أدخل عنوان الاستلام';

  @override
  String get parcelsDestinationDropoffLabel => 'عنوان التسليم';

  @override
  String get parcelsDestinationDropoffHint => 'أدخل عنوان التسليم';

  @override
  String get parcelsDestinationContinueCta => 'متابعة';

  @override
  String get parcelsDetailsTitle => 'تفاصيل الشحنة';

  @override
  String get parcelsDetailsSubtitle =>
      'أدخل تفاصيل الشحنة للحصول على تسعير أدق.';

  @override
  String get parcelsDetailsSizeLabel => 'الحجم';

  @override
  String get parcelsDetailsWeightLabel => 'الوزن';

  @override
  String get parcelsDetailsWeightHint => 'مثال: ٢٫٥ كجم';

  @override
  String get parcelsDetailsContentsLabel => 'ما الذي تريد إرساله؟';

  @override
  String get parcelsDetailsContentsHint => 'وصف مختصر لمحتوى الشحنة';

  @override
  String get parcelsDetailsFragileLabel => 'هذه الشحنة قابلة للكسر';

  @override
  String get parcelsDetailsContinueCta => 'مراجعة التسعيرة';

  @override
  String get parcelsDetailsErrorWeightRequired => 'يرجى إدخال وزن الطرد';

  @override
  String get parcelsDetailsErrorPositiveNumber => 'يرجى إدخال رقم صحيح موجب';

  @override
  String get parcelsDetailsErrorContentsRequired => 'يرجى وصف محتوى الشحنة';

  @override
  String get parcelsDetailsErrorSizeRequired => 'يرجى اختيار حجم الطرد';

  @override
  String get parcelsDetailsSectionParcelTitle => 'تفاصيل الطرد';

  @override
  String get parcelsQuoteTitle => 'تسعير الشحنة';

  @override
  String get parcelsQuoteSubtitle => 'اختر سرعة التوصيل والتكلفة المناسبة لك.';

  @override
  String get parcelsQuoteLoadingTitle => 'جاري جلب خيارات التسعير...';

  @override
  String get parcelsQuoteErrorTitle => 'تعذر تحميل خيارات التسعير';

  @override
  String get parcelsQuoteErrorSubtitle =>
      'يرجى التحقق من الاتصال بالإنترنت ثم المحاولة مرة أخرى.';

  @override
  String get parcelsQuoteEmptyTitle => 'لا توجد خيارات متاحة';

  @override
  String get parcelsQuoteEmptySubtitle =>
      'يرجى تعديل تفاصيل الشحنة ثم المحاولة مرة أخرى.';

  @override
  String get parcelsQuoteRetryCta => 'إعادة المحاولة';

  @override
  String get parcelsQuoteConfirmCta => 'تأكيد الشحنة';

  @override
  String get parcelsQuoteSummaryTitle => 'ملخص الشحنة';

  @override
  String get parcelsQuoteFromLabel => 'من';

  @override
  String get parcelsQuoteToLabel => 'إلى';

  @override
  String get parcelsQuoteWeightLabel => 'الوزن';

  @override
  String get parcelsQuoteSizeLabel => 'الحجم';

  @override
  String parcelsQuoteTotalLabel(String amount) {
    return 'الإجمالي: $amount';
  }

  @override
  String get parcelsQuoteBreakdownStubNote =>
      'هذا سعر تقديري. قد يتغيّر السعر النهائي بعد الربط مع خدمة التسعير الفعلية.';

  @override
  String get parcelsListTitle => 'شحناتك';

  @override
  String get parcelsListSectionTitle => 'شحناتي';

  @override
  String get parcelsListEmptyTitle => 'لا توجد شحنات حتى الآن';

  @override
  String get parcelsListEmptySubtitle => 'عند إنشاء شحنة جديدة ستظهر هنا.';

  @override
  String get parcelsListEmptyCta => 'أنشئ أول شحنة';

  @override
  String get parcelsListNewShipmentTooltip => 'شحنة جديدة';

  @override
  String parcelsListCreatedAtLabel(String date) {
    return 'تم الإنشاء في $date';
  }

  @override
  String get parcelsListUnknownDestinationLabel => 'وجهة غير معروفة';

  @override
  String get parcelsFilterAllLabel => 'الكل';

  @override
  String get parcelsFilterInProgressLabel => 'قيد التنفيذ';

  @override
  String get parcelsFilterDeliveredLabel => 'تم التسليم';

  @override
  String get parcelsFilterCancelledLabel => 'ملغاة';

  @override
  String get parcelsStatusScheduled => 'مجدولة';

  @override
  String get parcelsStatusPickupPending => 'في انتظار الاستلام';

  @override
  String get parcelsStatusPickedUp => 'تم الاستلام';

  @override
  String get parcelsStatusInTransit => 'في الطريق';

  @override
  String get parcelsStatusDelivered => 'تم التسليم';

  @override
  String get parcelsStatusCancelled => 'ملغاة';

  @override
  String get parcelsStatusFailed => 'فشل في التسليم';

  @override
  String get parcelsCreateShipmentTitle => 'إنشاء شحنة';

  @override
  String get parcelsCreateSenderSectionTitle => 'المرسل';

  @override
  String get parcelsCreateReceiverSectionTitle => 'المستلم';

  @override
  String get parcelsCreateDetailsSectionTitle => 'تفاصيل الشحنة';

  @override
  String get parcelsCreateServiceSectionTitle => 'نوع الخدمة';

  @override
  String get parcelsCreateSenderNameLabel => 'اسم المرسل';

  @override
  String get parcelsCreateSenderPhoneLabel => 'هاتف المرسل';

  @override
  String get parcelsCreateSenderAddressLabel => 'عنوان المرسل';

  @override
  String get parcelsCreateReceiverNameLabel => 'اسم المستلم';

  @override
  String get parcelsCreateReceiverPhoneLabel => 'هاتف المستلم';

  @override
  String get parcelsCreateReceiverAddressLabel => 'عنوان المستلم';

  @override
  String get parcelsCreateWeightLabel => 'الوزن (كجم)';

  @override
  String get parcelsCreateSizeLabel => 'الحجم';

  @override
  String get parcelsCreateNotesLabel => 'ملاحظات (اختياري)';

  @override
  String get parcelsCreateServiceExpress => 'سريع';

  @override
  String get parcelsCreateServiceStandard => 'عادي';

  @override
  String get parcelsCreateShipmentCtaGetEstimate => 'احصل على التقدير';

  @override
  String get parcelsCreateErrorRequired => 'هذا الحقل مطلوب';

  @override
  String get parcelsCreateErrorInvalidNumber => 'يرجى إدخال رقم صحيح';

  @override
  String get parcelsCreateErrorInvalidPhone => 'يرجى إدخال رقم هاتف صحيح';

  @override
  String get parcelsCreateWeightInvalidError => 'يرجى إدخال وزن صحيح.';

  @override
  String get parcelsCreateEstimateComingSoonSnackbar =>
      'تسعيرة الشحنة قيد التنفيذ وستتوفر قريباً.';

  @override
  String get parcelsCreateSizeSmallLabel => 'صغيرة';

  @override
  String get parcelsCreateSizeMediumLabel => 'متوسطة';

  @override
  String get parcelsCreateSizeLargeLabel => 'كبيرة';

  @override
  String get parcelsCreateSizeOversizeLabel => 'ضخمة';

  @override
  String get parcelsShipmentDetailsTitle => 'تفاصيل الشحنة';

  @override
  String parcelsShipmentDetailsCreatedAt(String date) {
    return 'أُنشئت في $date';
  }

  @override
  String get parcelsShipmentDetailsRouteSectionTitle => 'المسار';

  @override
  String get parcelsShipmentDetailsPickupLabel => 'عنوان الاستلام';

  @override
  String get parcelsShipmentDetailsDropoffLabel => 'عنوان التسليم';

  @override
  String get parcelsShipmentDetailsAddressSectionTitle => 'العناوين';

  @override
  String get parcelsShipmentDetailsSenderLabel => 'المرسل';

  @override
  String get parcelsShipmentDetailsReceiverLabel => 'المستلم';

  @override
  String get parcelsShipmentDetailsMetaSectionTitle => 'تفاصيل الطرد';

  @override
  String get parcelsShipmentDetailsWeightLabel => 'الوزن';

  @override
  String get parcelsShipmentDetailsSizeLabel => 'الحجم';

  @override
  String get parcelsShipmentDetailsNotesLabel => 'ملاحظات';

  @override
  String get parcelsShipmentDetailsNotAvailable => 'غير متوفر';

  @override
  String get parcelsShipmentDetailsSizeSmall => 'صغير';

  @override
  String get parcelsShipmentDetailsSizeMedium => 'متوسط';

  @override
  String get parcelsShipmentDetailsSizeLarge => 'كبير';

  @override
  String get parcelsShipmentDetailsSizeOversize => 'ضخم';

  @override
  String get parcelsDetailsPriceLabel => 'السعر';

  @override
  String get foodComingSoonAppBarTitle => 'توصيل الطعام';

  @override
  String get foodComingSoonTitle => 'خدمة توصيل الطعام قادمة قريباً';

  @override
  String get foodComingSoonSubtitle =>
      'نعمل حالياً على إطلاق خدمة توصيل الطعام في منطقتك. ترقّب التحديث القادم!';

  @override
  String get foodComingSoonPrimaryCta => 'العودة إلى الرئيسية';

  @override
  String get foodRestaurantsAppBarTitle => 'توصيل الطعام';

  @override
  String get foodRestaurantsSearchPlaceholder => 'ابحث عن مطاعم أو مطابخ';

  @override
  String get foodRestaurantsFilterAll => 'الكل';

  @override
  String get foodRestaurantsFilterBurgers => 'برجر';

  @override
  String get foodRestaurantsFilterItalian => 'إيطالي';

  @override
  String get foodRestaurantsEmptyTitle => 'لا توجد مطاعم مطابقة';

  @override
  String get foodRestaurantsEmptySubtitle =>
      'جرّب تغيير الفلاتر أو البحث عن نوع آخر من الأطعمة.';

  @override
  String get foodRestaurantMenuError =>
      'تعذّر تحميل قائمة الطعام. يرجى المحاولة مرة أخرى.';

  @override
  String foodCartSummaryCta(String itemCount, String totalPrice) {
    return '$itemCount عنصر · المجموع $totalPrice';
  }

  @override
  String foodCartCheckoutStub(String itemCount, String totalPrice) {
    return 'إتمام الطلب غير مفعّل بعد. عدد العناصر $itemCount، المجموع $totalPrice.';
  }

  @override
  String get ordersSectionParcelsTitle => 'الطرود';

  @override
  String get ordersSectionFoodTitle => 'الطعام';

  @override
  String get ordersFilterFood => 'الطعام';

  @override
  String get ordersFoodStatusPending => 'قيد المعالجة';

  @override
  String get ordersFoodStatusInPreparation => 'قيد التحضير';

  @override
  String get ordersFoodStatusOnTheWay => 'في الطريق';

  @override
  String get ordersFoodStatusDelivered => 'تم التسليم';

  @override
  String get ordersFoodStatusCancelled => 'ملغي';

  @override
  String ordersFoodCreatedAtLabel(String date) {
    return 'تم الطلب في $date';
  }

  @override
  String foodCartOrderCreatedSnackbar(String restaurant) {
    return 'تم إنشاء طلبك من $restaurant.';
  }

  @override
  String get homeFoodComingSoonLabel => 'قريباً';

  @override
  String get homeFoodComingSoonMessage =>
      'خدمة توصيل الطعام غير متاحة بعد في منطقتك.';

  @override
  String get homeFoodCardTitle => 'الطعام';

  @override
  String get homeFoodCardSubtitle => 'طعامك المفضل، إليك.';

  @override
  String get onboardingRideTitle => 'احصل على رحلة، فورًا.';

  @override
  String get onboardingRideBody =>
      'اضغط، اركب، ووصل. تنقل سريع، موثوق، وبسعر مناسب في متناول يدك.';

  @override
  String get onboardingParcelsTitle => 'أرسل أي شيء، بسهولة.';

  @override
  String get onboardingParcelsBody =>
      'من المستندات إلى الهدايا، أرسل وتتبع طرودك بسهولة وثقة.';

  @override
  String get onboardingFoodTitle => 'طعامك المفضل، إليك.';

  @override
  String get onboardingFoodBody =>
      'استكشف المطاعم القريبة واستمتع بتوصيل سريع حتى باب منزلك.';

  @override
  String get onboardingButtonContinue => 'استمر';

  @override
  String get onboardingButtonGetStarted => 'ابدأ الآن';

  @override
  String get homeRideCardTitle => 'رحلة';

  @override
  String get homeRideCardSubtitle => 'احصل على رحلة فوراً.';

  @override
  String get rideDestinationDestinationLabel => 'الوجهة';

  @override
  String get rideDestinationDestinationPlaceholder => 'إلى أين؟';

  @override
  String get rideDestinationRecentTitle => 'الوجهات الأخيرة';

  @override
  String get rideDestinationRecentHomeLabel => 'المنزل';

  @override
  String get rideDestinationRecentHomeSubtitle => 'عنوان المنزل المحفوظ';

  @override
  String get rideDestinationRecentWorkLabel => 'العمل';

  @override
  String get rideDestinationRecentWorkSubtitle => 'عنوان العمل المحفوظ';

  @override
  String get rideDestinationRecentLastLabel => 'آخر رحلة';

  @override
  String get rideDestinationRecentLastSubtitle => 'استخدم وجهة آخر رحلة';

  @override
  String get rideDestinationNextCta => 'التالي';

  @override
  String get rideDestinationComingSoonSnackbar =>
      'ملخص الرحلة قيد التنفيذ وسيتوفر قريباً.';

  @override
  String get rideSummaryReceiptTitle => 'الإيصال';

  @override
  String get rideSummaryReceiptFareLabel => 'أجرة الرحلة';

  @override
  String get rideSummaryReceiptFeesLabel => 'الرسوم';

  @override
  String get rideSummaryReceiptTotalLabel => 'الإجمالي';

  @override
  String get rideSummaryRatingTitle => 'قيّم السائق';

  @override
  String get rideSummaryRatingSubtitle =>
      'ملاحظاتك تساعدنا في الحفاظ على رحلات آمنة ومريحة.';

  @override
  String get rideSummaryCommentPlaceholder => 'أضف ملاحظة (اختياري)';

  @override
  String rideReceiptTripIdLabel(String id) {
    return 'رقم الرحلة: $id';
  }

  @override
  String rideReceiptCompletedAt(String date, String time) {
    return '$date في $time';
  }

  @override
  String get rideReceiptFromLabel => 'من';

  @override
  String get rideReceiptToLabel => 'إلى';

  @override
  String get rideReceiptFareSectionTitle => 'أجرة الرحلة';

  @override
  String get rideReceiptBaseFareLabel => 'الأجرة الأساسية';

  @override
  String get rideReceiptDistanceFareLabel => 'المسافة';

  @override
  String get rideReceiptTimeFareLabel => 'الوقت';

  @override
  String get rideReceiptFeesLabel => 'الرسوم والضرائب';

  @override
  String get rideReceiptTotalLabel => 'الإجمالي';

  @override
  String get rideReceiptDriverSectionTitle => 'السائق والمركبة';

  @override
  String get rideReceiptRateDriverTitle => 'قيّم تجربتك مع السائق';

  @override
  String get rideReceiptRateDriverSubtitle =>
      'ملاحظاتك تساعدنا على تحسين جودة الرحلات.';

  @override
  String get rideReceiptDoneCta => 'تم';

  @override
  String get rideDriverMockName => 'أحمد م.';

  @override
  String get rideDriverMockCarInfo => 'تويوتا كامري • ABC 1234';

  @override
  String get rideDriverMockRating => '4.9';

  @override
  String get rideSummaryEndTripDebugCta => 'إنهاء الرحلة';

  @override
  String get rideSummaryThankYouSnackbar => 'شكرًا لملاحظاتك.';

  @override
  String get homeActiveParcelTitleGeneric => 'شحنة نشطة';

  @override
  String homeActiveParcelSubtitleToDestination(String destination) {
    return 'إلى $destination';
  }

  @override
  String get homeActiveParcelViewShipmentCta => 'عرض الشحنة';

  @override
  String get homeActiveParcelStatusPreparing => 'جاري تجهيز شحنتك...';

  @override
  String get homeActiveParcelStatusScheduled => 'الاستلام مجدول';

  @override
  String get homeActiveParcelStatusPickupPending => 'في انتظار الاستلام';

  @override
  String get homeActiveParcelStatusPickedUp => 'تم الاستلام';

  @override
  String get homeActiveParcelStatusInTransit => 'قيد النقل';

  @override
  String get homeActiveParcelStatusDelivered => 'تم التسليم';

  @override
  String get homeActiveParcelStatusCancelled => 'تم إلغاء الشحنة';

  @override
  String get homeActiveParcelStatusFailed => 'فشل التسليم';

  @override
  String get parcelsActiveShipmentTitle => 'الشحنة النشطة';

  @override
  String get parcelsActiveShipmentNoActiveTitle => 'لا توجد شحنة نشطة';

  @override
  String get parcelsActiveShipmentNoActiveSubtitle =>
      'لا يوجد لديك شحنات نشطة حالياً.';

  @override
  String get parcelsActiveShipmentMapStub => 'تتبع الخريطة (قريباً)';

  @override
  String parcelsActiveShipmentStatusLabel(String status) {
    return 'الحالة: $status';
  }

  @override
  String parcelsActiveShipmentIdLabel(String id) {
    return 'رقم الشحنة: $id';
  }

  @override
  String get parcelsActiveShipmentStubNote =>
      'سيتوفر التتبع الكامل في تحديث قادم.';

  @override
  String get parcelsDetailsCancelShipmentCta => 'إلغاء الشحنة';

  @override
  String get parcelsCancelDialogTitle => 'هل تريد إلغاء هذه الشحنة؟';

  @override
  String get parcelsCancelDialogSubtitle =>
      'إذا قمت بالإلغاء الآن، سيتم إيقاف هذه الشحنة ولن تظهر كشحنة نشطة.';

  @override
  String get parcelsCancelDialogConfirmCta => 'نعم، إلغاء';

  @override
  String get parcelsCancelDialogDismissCta => 'الإبقاء على الشحنة';

  @override
  String get parcelsCancelSuccessMessage => 'تم إلغاء الشحنة بنجاح.';

  @override
  String get bottomNavHomeLabel => 'الرئيسية';

  @override
  String get bottomNavOrdersLabel => 'الطلبات';

  @override
  String get bottomNavPaymentsLabel => 'المدفوعات';

  @override
  String get bottomNavProfileLabel => 'الحساب';

  @override
  String get homeCurrentLocationLabel => 'الموقع الحالي';

  @override
  String get homeCurrentLocationPlaceholder => 'حدد موقع الانطلاق';

  @override
  String get homeServiceRideTitle => 'الرحلات';

  @override
  String get homeServiceParcelsTitle => 'الطرود';

  @override
  String get homeServiceFoodTitle => 'الطعام';

  @override
  String get homeServiceRideSubtitle => 'احصل على رحلة خلال دقائق';

  @override
  String get homeServiceParcelsSubtitle => 'أرسل وتابع طرودك';

  @override
  String get homeServiceFoodSubtitle => 'اطلب الطعام من المطاعم القريبة';

  @override
  String get homeSearchPlaceholder => 'إلى أين؟';

  @override
  String get paymentsEntryTitle => 'المدفوعات';

  @override
  String get paymentsEntryStubBody => 'إدارة المدفوعات ستتوفر في تحديث قادم.';

  @override
  String get paymentsTitle => 'طرق الدفع';

  @override
  String get paymentsAddMethodCta => 'إضافة طريقة دفع جديدة';

  @override
  String get paymentsEmptyTitle => 'لا توجد طرق دفع محفوظة';

  @override
  String get paymentsEmptyBody => 'ستظهر هنا بطاقاتك وطرق الدفع المحفوظة.';

  @override
  String get paymentsMethodTypeCash => 'نقدًا';

  @override
  String get paymentsMethodTypeCard => 'بطاقة';

  @override
  String get paymentsDefaultBadge => 'افتراضية';

  @override
  String get paymentsAddMethodComingSoon =>
      'إضافة طرق دفع جديدة ستكون متاحة قريبًا.';

  @override
  String paymentsCardExpiry(int month, int year) {
    return 'انتهاء الصلاحية $month/$year';
  }

  @override
  String get paymentsMethodTypeApplePay => 'أبل باي';

  @override
  String get paymentsMethodTypeGooglePay => 'غوغل باي';

  @override
  String get paymentsMethodTypeDigitalWallet => 'محفظة رقمية';

  @override
  String get paymentsMethodTypeBankTransfer => 'تحويل بنكي';

  @override
  String get paymentsMethodTypeCashOnDelivery => 'الدفع عند الاستلام';

  @override
  String get profileEntryTitle => 'الملف الشخصي';

  @override
  String get profileEntryStubBody =>
      'إعدادات الملف الشخصي والحساب ستتوفر في تحديث قادم.';

  @override
  String get rideStatusShortDraft => 'مسودة';

  @override
  String get rideStatusShortQuoting => 'جاري التسعير';

  @override
  String get rideStatusShortRequesting => 'جاري طلب الرحلة';

  @override
  String get rideStatusShortFindingDriver => 'جاري البحث عن سائق';

  @override
  String get rideStatusShortDriverAccepted => 'تم قبول السائق';

  @override
  String get rideStatusShortDriverArrived => 'وصل السائق';

  @override
  String get rideStatusShortInProgress => 'قيد التنفيذ';

  @override
  String get rideStatusShortPayment => 'جاري الدفع';

  @override
  String get rideStatusShortCompleted => 'مكتملة';

  @override
  String get rideStatusShortCancelled => 'ملغاة';

  @override
  String get rideStatusShortFailed => 'فشلت';

  @override
  String get homeActiveRideStatusPreparing => 'جاري تجهيز رحلتك...';

  @override
  String get homeActiveRideStatusFindingDriver => 'جاري البحث عن سائق...';

  @override
  String get homeActiveRideStatusDriverAccepted => 'السائق في الطريق إليك';

  @override
  String get homeActiveRideStatusDriverArrived => 'وصل السائق';

  @override
  String get homeActiveRideStatusInProgress => 'الرحلة جارية';

  @override
  String get homeActiveRideStatusPayment => 'جاري إتمام الدفع';

  @override
  String get homeActiveRideStatusCompleted => 'تم إنهاء الرحلة';

  @override
  String get homeActiveRideStatusCancelled => 'تم إلغاء الرحلة';

  @override
  String get homeActiveRideStatusFailed => 'فشلت الرحلة';

  @override
  String get rideActiveTripTitle => 'الرحلة النشطة';

  @override
  String rideActiveTripFromLabel(String pickup) {
    return 'من: $pickup';
  }

  @override
  String rideActiveTripToLabel(String dropoff) {
    return 'إلى: $dropoff';
  }

  @override
  String rideActiveTripIdLabel(String id) {
    return 'رقم الرحلة: $id';
  }

  @override
  String get rideActiveTripMapStub => 'تتبع الخريطة المباشر (قريبًا)';

  @override
  String get rideActiveTripStubNote =>
      'سيتم توفير تتبع مباشر كامل بعد الربط مع خدمة الرحلات الفعلية.';

  @override
  String rideActiveTripStatusLabel(String status) {
    return 'الحالة: $status';
  }

  @override
  String get rideActiveTripDriverSectionTitle => 'السائق والمركبة';

  @override
  String get rideActiveTripDriverSectionStubBody =>
      'تفاصيل السائق والمركبة ستظهر بعد الربط مع خدمة الرحلات الفعلية.';

  @override
  String get ordersHistoryEmptyAllTitle => 'لا توجد طلبات بعد';

  @override
  String get ordersHistoryEmptyAllDescription =>
      'ستظهر رحلاتك وطرودك وطلبات الطعام هنا.';

  @override
  String get ordersHistoryEmptyRidesTitle => 'لا توجد رحلات بعد';

  @override
  String get ordersHistoryEmptyRidesDescription => 'ستظهر رحلاتك المكتملة هنا.';

  @override
  String get ordersHistoryEmptyParcelsTitle => 'لا توجد طرود بعد';

  @override
  String get ordersHistoryEmptyParcelsDescription => 'ستظهر شحناتك هنا.';

  @override
  String get ordersHistoryEmptyFoodTitle => 'لا توجد طلبات طعام بعد';

  @override
  String get ordersHistoryEmptyFoodDescription => 'ستظهر طلبات الطعام هنا.';

  @override
  String get ordersServiceRideSemanticLabel => 'طلب رحلة';

  @override
  String get ordersServiceParcelSemanticLabel => 'شحنة طرد';

  @override
  String get ordersServiceFoodSemanticLabel => 'طلب طعام';

  @override
  String get parcelsShipmentsTitle => 'شحناتي';

  @override
  String get parcelsShipmentsNewShipmentTooltip => 'شحنة جديدة';

  @override
  String get parcelsShipmentsEmptyTitle => 'لا توجد شحنات بعد';

  @override
  String get parcelsShipmentsEmptyDescription =>
      'ليس لديك أي شحنات حتى الآن. أنشئ أول شحنة للبدء في إرسال الطرود.';

  @override
  String get parcelsShipmentsEmptyCta => 'إنشاء أول شحنة';

  @override
  String get parcelsShipmentStatusCreated => 'تم الإنشاء';

  @override
  String get parcelsShipmentStatusInTransit => 'قيد التوصيل';

  @override
  String get parcelsShipmentStatusDelivered => 'تم التوصيل';

  @override
  String get parcelsShipmentStatusCancelled => 'ملغاة';

  @override
  String get parcelsShipmentsErrorTitle => 'حدث خطأ ما';

  @override
  String get parcelsCreateShipmentCta => 'إنشاء شحنة';

  @override
  String get parcelsCreateShipmentSenderSectionTitle => 'بيانات المرسل';

  @override
  String get parcelsCreateShipmentReceiverSectionTitle => 'بيانات المستلم';

  @override
  String get parcelsCreateShipmentParcelDetailsSectionTitle => 'تفاصيل الشحنة';

  @override
  String get parcelsCreateShipmentSenderNameLabel => 'اسم المرسل';

  @override
  String get parcelsCreateShipmentSenderPhoneLabel => 'هاتف المرسل';

  @override
  String get parcelsCreateShipmentReceiverNameLabel => 'اسم المستلم';

  @override
  String get parcelsCreateShipmentReceiverPhoneLabel => 'هاتف المستلم';

  @override
  String get parcelsCreateShipmentPickupAddressLabel => 'عنوان الاستلام';

  @override
  String get parcelsCreateShipmentDropoffAddressLabel => 'عنوان التسليم';

  @override
  String get parcelsCreateShipmentWeightLabel => 'الوزن (كجم)';

  @override
  String get parcelsCreateShipmentSizeLabel => 'الحجم';

  @override
  String get parcelsCreateShipmentNotesLabel => 'ملاحظات';

  @override
  String get parcelsCreateShipmentServiceTypeLabel => 'نوع الخدمة';

  @override
  String get parcelsCreateShipmentServiceTypeExpress => 'سريعة';

  @override
  String get parcelsCreateShipmentServiceTypeStandard => 'عادية';

  @override
  String get parcelsCreateShipmentServiceTypeError => 'يرجى اختيار نوع الخدمة';

  @override
  String get parcelsCreateShipmentSuccessMessage => 'تم إنشاء الشحنة بنجاح';

  @override
  String get commonErrorFieldRequired => 'هذا الحقل مطلوب';

  @override
  String get commonAddressesTitle => 'العناوين';

  @override
  String get parcelsShipmentDetailsContactsSectionTitle => 'جهات الاتصال';

  @override
  String get parcelsShipmentDetailsDetailsSectionTitle => 'تفاصيل الشحنة';

  @override
  String get parcelsShipmentDetailsServiceTypeLabel => 'نوع الخدمة';

  @override
  String get commonTotalLabel => 'المجموع';

  @override
  String get homeHubRecentDestinationsTitle => 'الوجهات الأخيرة';

  @override
  String get homeHubRecentDestinationsSeeAll => 'عرض الكل';
}

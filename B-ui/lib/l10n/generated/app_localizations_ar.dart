// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get notificationsSettingsTitle => 'إعدادات الإشعارات';

  @override
  String get notificationsSettingsOrderStatusTitle => 'إشعارات حالة الطلب';

  @override
  String get notificationsSettingsOrderStatusSubtitle => 'استلام تحديثات مباشرة عن حالة طلباتك النشطة.';

  @override
  String get notificationsSettingsPromotionsTitle => 'العروض الترويجية';

  @override
  String get notificationsSettingsPromotionsSubtitle => 'استلام عروض وخصومات مخصصة لك.';

  @override
  String get notificationsSettingsSystemTitle => 'إشعارات النظام';

  @override
  String get notificationsSettingsSystemSubtitle => 'تنبيهات مهمة حول حسابك والنظام.';

  @override
  String get notificationsSettingsConsentRequired => 'لتفعيل الإشعارات، يجب تفعيل الموافقة على جمع البيانات الأساسية من إعدادات الخصوصية.';

  @override
  String get notificationsSettingsErrorGeneric => 'تعذّر تحميل إعدادات الإشعارات. حاول مرة أخرى.';

  @override
  String get notificationsSettingsSystemSettingsButton => 'فتح إعدادات النظام';

  @override
  String get notificationsSettingsSystemSettingsPlaceholder => 'سيتم فتح إعدادات إشعارات النظام (عنصر نائب)';

  @override
  String get notificationsSettingsTooltip => 'إعدادات الإشعارات';

  @override
  String get settingsSectionNotifications => 'إعدادات الإشعارات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get back => 'العودة';

  @override
  String get notificationsInboxTitle => 'الإشعارات';

  @override
  String get notificationsInboxErrorGeneric => 'تعذّر تحميل الإشعارات. حاول مرة أخرى.';

  @override
  String get notificationsInboxRetryButtonLabel => 'إعادة المحاولة';

  @override
  String get notificationsInboxEmptyTitle => 'لا توجد إشعارات بعد';

  @override
  String get notificationsInboxEmptySubtitle => 'ستظهر هنا التنبيهات المهمة عن طلباتك والعروض.';

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
  String get notificationsInboxClearAllDialogMessage => 'هل أنت متأكد من حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get notificationsInboxClearAllConfirm => 'مسح الكل';

  @override
  String get notificationsInboxTappedGeneric => 'تم فتح الإشعار';

  @override
  String get notificationsInboxTimeNow => 'الآن';

  @override
  String notificationsInboxTimeMinutes(Object minutes) {
    return 'منذ $minutes دقيقة';
  }

  @override
  String notificationsInboxTimeHours(Object hours) {
    return 'منذ $hours ساعة';
  }

  @override
  String notificationsInboxTimeDays(Object days) {
    return 'منذ $days يوم';
  }

  @override
  String get notificationsPromotionsTitle => 'العروض والإشعارات الترويجية';

  @override
  String get notificationsPromotionsEmptyTitle => 'لا توجد عروض حالياً';

  @override
  String get notificationsPromotionsEmptyDescription => 'ستظهر هنا العروض والحملات المخصّصة لك بمجرد توفرها.';

  @override
  String get notificationsPromotionsErrorTitle => 'تعذّر تحميل الإشعارات الترويجية';

  @override
  String get notificationsPromotionsErrorDescription => 'حدث خطأ أثناء تحميل الإشعارات الترويجية. يرجى المحاولة لاحقاً.';

  @override
  String get notificationsSystemTitle => 'إشعارات النظام';

  @override
  String get notificationsSystemEmptyTitle => 'لا توجد رسائل من النظام';

  @override
  String get notificationsSystemEmptyDescription => 'لا توجد حالياً رسائل أو تحديثات من النظام أو سياسات الخصوصية.';

  @override
  String get notificationsSystemErrorTitle => 'تعذّر تحميل إشعارات النظام';

  @override
  String get notificationsSystemErrorDescription => 'حدث خطأ أثناء تحميل إشعارات النظام. يرجى المحاولة لاحقاً.';

  @override
  String get notificationsQuietHoursTitle => 'ساعات الهدوء';

  @override
  String get notificationsQuietHoursDescription => 'سيتم إسكات الإشعارات خلال الفترة الزمنية التي تختارها.';

  @override
  String get notificationsQuietHoursInactive => 'وضع عدم الإزعاج غير مُفعّل حالياً.';

  @override
  String get notificationsQuietHoursEdit => 'تعيين ساعات الهدوء';

  @override
  String get notificationsQuietHoursEditActive => 'تعديل ساعات الهدوء';

  @override
  String get notificationsQuietHoursDisable => 'إيقاف ساعات الهدوء';

  @override
  String get notificationsQuietHoursInvalidRange => 'يرجى اختيار أوقات بداية ونهاية مختلفة.';

  @override
  String get notificationsQuietHoursSaveError => 'تعذّر تحديث ساعات الهدوء. حاول مرة أخرى.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get authPhoneLoginTitle => 'تسجيل الدخول';

  @override
  String get authPhoneLoginSubtitle => 'أدخل رقم جوالك لتسجيل الدخول أو إنشاء حساب جديد.';

  @override
  String get authPhoneFieldLabel => 'رقم الجوال';

  @override
  String get authPhoneFieldHint => '+9665xxxxxxxx';

  @override
  String get authPhoneContinueButton => 'متابعة';

  @override
  String get authPhoneRequiredError => 'يرجى إدخال رقم الجوال.';

  @override
  String get authPhoneInvalidFormatError => 'يرجى إدخال رقم جوال صحيح.';

  @override
  String get authPhoneSubmitError => 'تعذّر إرسال رمز التحقق. حاول مرة أخرى.';

  @override
  String get authOtpTitle => 'رمز التحقق';

  @override
  String authOtpSubtitle(Object phone) {
    return 'أرسلنا رمز تحقق إلى $phone';
  }

  @override
  String get authOtpFieldLabel => 'رمز التحقق';

  @override
  String get authOtpFieldHint => 'أدخل الرمز';

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
  String authOtpResendCountdown(Object seconds) {
    return 'يمكنك إعادة إرسال الرمز بعد $seconds ثانية';
  }
}

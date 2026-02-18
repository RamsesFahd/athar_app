// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get splashTitle => ' مرحبًا بك في أثر';

  @override
  String get splashSubtitle => 'عراقة الماضي.. برؤية حديثة';

  @override
  String get signInWelcome => ' مرحبًا بك في أثر';

  @override
  String get signInSubtitle => 'اكتشف التراث برؤية حديثة';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get continueButton => 'متابعة';

  @override
  String get orDivider => 'أو';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get signUpLink => 'انضم إلينا';

  @override
  String get continueAsGuest => 'تصفح كضيف';

  @override
  String get emailHint => 'example@mail.com';

  @override
  String get passwordHint => '••••••••';

  @override
  String get signUpTitle => 'انضم إلى أثر';

  @override
  String get signUpSubtitle => 'كن جزءاً من رحلتنا الثقافية';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get nameHint => 'أدخل اسمك';

  @override
  String get createAccountButton => 'إنشاء حساب';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get signInLink => 'تسجيل الدخول';

  @override
  String get resetPasswordTitle => 'استعادة كلمة المرور';

  @override
  String get resetPasswordSubtitle =>
      'أدخل بريدك المسجل لإرسال رابط استعادة كلمة المرور';

  @override
  String get sendLinkButton => 'إرسال الرابط';

  @override
  String get emailSentTitle => 'تم إرسال الرابط!';

  @override
  String get emailSentMessage => 'تفقد بريدك الإلكتروني واتبع التعليمات';

  @override
  String get backToSignInButton => 'العودة لتسجيل الدخول';

  @override
  String get backToSignUpButton => 'العودة لإنشاء حساب';

  @override
  String get verifyEmailTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get verifyEmailSubtitle => 'أدخل الرمز المرسل إلى بريدك';

  @override
  String get verifyEmailInfoText => 'تم إرسال رمز التحقق إلى:';

  @override
  String get verifyButton => 'تحقق';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendCodeInSeconds(int seconds) {
    return 'إعادة إرسال الرمز خلال $seconds ثانية';
  }

  @override
  String get errorEmailAlreadyInUse => 'هذا البريد الإلكتروني مستخدم بالفعل.';

  @override
  String get errorInvalidEmail => 'عنوان البريد الإلكتروني غير صحيح.';

  @override
  String get errorUserNotFound => 'لا يوجد مستخدم مسجل بهذا البريد.';

  @override
  String get errorWrongPassword => 'كلمة المرور خاطئة. حاول مرة أخرى.';

  @override
  String get errorWeakPassword => 'كلمة المرور ضعيفة جداً.';

  @override
  String get errorUnexpected => 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.';

  @override
  String get fillAllFieldsError => 'يرجى ملء جميع الحقول';

  @override
  String get passwordsDoNotMatchError =>
      'كلمتا المرور غير متطابقتين، يرجى المحاولة مرة أخرى.';

  @override
  String get guestUser => 'ضيف';

  @override
  String get errorEmailNotVerified =>
      'يرجى التحقق من بريدك الإلكتروني عبر الرابط المرسل إليك أولًا.';

  @override
  String get homeLabel => 'الرئيسية';

  @override
  String get mapLabel => 'الخريطة';

  @override
  String get assistantLabel => 'المساعد';

  @override
  String get calendarLabel => 'التقويم';

  @override
  String get profileLabel => 'الملف';

  @override
  String get accessibilityOptionsTitle => 'خيارات سهولة الوصول';

  @override
  String get accessibilityFontSize => 'حجم الخط';

  @override
  String get accessibilitySmall => 'صغير';

  @override
  String get accessibilityMedium => 'متوسط';

  @override
  String get accessibilityLarge => 'كبير';

  @override
  String get accessibilityLanguage => 'اللغة';

  @override
  String get accessibilityEnglish => 'الإنجليزية';

  @override
  String get accessibilityArabic => 'العربية';

  @override
  String get accessibilityContrast => 'التباين';

  @override
  String get accessibilityRegular => 'عادي';

  @override
  String get accessibilityHighContrast => 'تباين عالي';

  @override
  String get accessibilityTextReader => 'قارئ النصوص';

  @override
  String get accessibilityTextReaderHint =>
      'الاستماع إلى محتوى الصفحة بصوت عالٍ';

  @override
  String get profileEdit => 'تعديل';

  @override
  String get profileTabBooking => 'الحجوزات';

  @override
  String get profileTabSaved => 'المحفوظات';

  @override
  String get profileTabSettings => 'الإعدادات';

  @override
  String get profileUpcomingBooking => 'الحجوزات القادمة';

  @override
  String get profileWithLabel => 'مع';

  @override
  String get profileDetails => 'التفاصيل';

  @override
  String get profileEditEmail => 'تعديل البريد';

  @override
  String get profileEditPhone => 'إضافة/تعديل الجوال';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileNotifications => 'الإشعارات';

  @override
  String get profileContributeContent => 'المساهمة بالمحتوى';

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileClose => 'إغلاق';

  @override
  String get profileSave => 'حفظ';

  @override
  String get profileSubmit => 'إرسال';

  @override
  String get profileEditProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get profileChangePhoto => 'تغيير الصورة';

  @override
  String get profileNameLabel => 'الاسم';

  @override
  String get profileNameHint => 'اكتب اسمك';

  @override
  String get profileEditEmailTitle => 'تعديل البريد';

  @override
  String get profileNewEmailLabel => 'البريد الجديد';

  @override
  String get profileConfirmEmailLabel => 'تأكيد البريد';

  @override
  String get profileEmailHint => 'اكتب البريد الجديد';

  @override
  String get profileConfirmEmailHint => 'أعد كتابة البريد';

  @override
  String get profileEditPhoneTitle => 'إضافة/تعديل الجوال';

  @override
  String get profileNewPhoneLabel => 'رقم الجوال الجديد';

  @override
  String get profileConfirmPhoneLabel => 'تأكيد رقم الجوال';

  @override
  String get profilePhoneHint => 'اكتب رقم الجوال';

  @override
  String get profileConfirmPhoneHint => 'أعد كتابة الرقم';

  @override
  String get profileLanguageTitle => 'اللغة';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageArabic => 'العربية';

  @override
  String get profileSavedItemsTitle => 'العناصر المحفوظة';

  @override
  String get profileSettingsTitle => 'الإعدادات';

  @override
  String get profileAccountTitle => 'الحساب';

  @override
  String get profileBookingNotifications => 'إشعارات الحجوزات';

  @override
  String get profileEventReminders => 'تذكيرات الفعاليات';

  @override
  String get profileMarketingEmails => 'البريد التسويقي';
}

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
}

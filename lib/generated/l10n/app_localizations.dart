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
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en')
  ];

  /// Title shown on splash screen
  ///
  /// In en, this message translates to:
  /// **'Welcome To Athar'**
  String get splashTitle;

  /// Subtitle on splash screen
  ///
  /// In en, this message translates to:
  /// **'Timeless heritage, modern vision'**
  String get splashSubtitle;

  /// Welcome header on sign in screen
  ///
  /// In en, this message translates to:
  /// **'Welcome To Athar'**
  String get signInWelcome;

  /// Subtitle on sign in screen
  ///
  /// In en, this message translates to:
  /// **'Discover heritage with a modern vision'**
  String get signInSubtitle;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Checkbox text to remember user credentials
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// Link to reset forgotten password
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Button to proceed to next screen
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Divider text between different sign-in options
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// Text before sign up link
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// Link to create a new account
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpLink;

  /// Option to use the app without signing in
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// Hint text inside email field
  ///
  /// In en, this message translates to:
  /// **'example@mail.com'**
  String get emailHint;

  /// Hint text inside password field (bullets)
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// Title on sign up screen header
  ///
  /// In en, this message translates to:
  /// **'Join Athar'**
  String get signUpTitle;

  /// Subtitle on sign up screen
  ///
  /// In en, this message translates to:
  /// **'Be part of our cultural journey'**
  String get signUpSubtitle;

  /// Label for full name input field
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// Label for confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// Hint text inside full name field
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get nameHint;

  /// Button to register a new account
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// Text before sign in link on sign up screen
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Link to sign in screen
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInLink;

  /// Title on forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// Instruction text on forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email address to receive a password reset link'**
  String get resetPasswordSubtitle;

  /// Button to send password reset email
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get sendLinkButton;

  /// Title shown after reset email is sent
  ///
  /// In en, this message translates to:
  /// **'Email Sent!'**
  String get emailSentTitle;

  /// Message after reset email is sent
  ///
  /// In en, this message translates to:
  /// **'Check your email and follow the instructions'**
  String get emailSentMessage;

  /// Button to return to sign in screen
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignInButton;

  /// Button to return to sign up screen
  ///
  /// In en, this message translates to:
  /// **'Back to Sign Up'**
  String get backToSignUpButton;

  /// Title on verify email screen
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// Subtitle on verify email screen
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to your email'**
  String get verifyEmailSubtitle;

  /// Info text shown above the email on verify screen
  ///
  /// In en, this message translates to:
  /// **'We have sent a verification code to:'**
  String get verifyEmailInfoText;

  /// Verify button label
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// Resend code label
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendCodeInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds} seconds'**
  String resendCodeInSeconds(int seconds);

  /// No description provided for @errorEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get errorEmailAlreadyInUse;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is invalid.'**
  String get errorInvalidEmail;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email.'**
  String get errorUserNotFound;

  /// No description provided for @errorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get errorWrongPassword;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak.'**
  String get errorWeakPassword;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again later.'**
  String get errorUnexpected;

  /// No description provided for @fillAllFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFieldsError;

  /// No description provided for @passwordsDoNotMatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match. Please try again.'**
  String get passwordsDoNotMatchError;

  /// Default name for anonymous users
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestUser;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Please verify your email via the link sent to you.'**
  String get errorEmailNotVerified;

  /// Label for Home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// Label for Map tab
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapLabel;

  /// Label for Chatbot tab
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get assistantLabel;

  /// Label for Calendar tab
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarLabel;

  /// Label for Profile tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileLabel;

  /// No description provided for @accessibilityOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Accessibility Options'**
  String get accessibilityOptionsTitle;

  /// No description provided for @accessibilityFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get accessibilityFontSize;

  /// No description provided for @accessibilitySmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get accessibilitySmall;

  /// No description provided for @accessibilityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get accessibilityMedium;

  /// No description provided for @accessibilityLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get accessibilityLarge;

  /// No description provided for @accessibilityLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get accessibilityLanguage;

  /// No description provided for @accessibilityEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get accessibilityEnglish;

  /// No description provided for @accessibilityArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get accessibilityArabic;

  /// No description provided for @accessibilityContrast.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get accessibilityContrast;

  /// No description provided for @accessibilityRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get accessibilityRegular;

  /// No description provided for @accessibilityHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get accessibilityHighContrast;

  /// No description provided for @accessibilityTextReader.
  ///
  /// In en, this message translates to:
  /// **'Text Reader'**
  String get accessibilityTextReader;

  /// No description provided for @accessibilityTextReaderHint.
  ///
  /// In en, this message translates to:
  /// **'Listen to page content read aloud'**
  String get accessibilityTextReaderHint;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileEdit;

  /// No description provided for @profileTabBooking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get profileTabBooking;

  /// No description provided for @profileTabSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get profileTabSaved;

  /// No description provided for @profileTabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileTabSettings;

  /// No description provided for @profileUpcomingBooking.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Booking'**
  String get profileUpcomingBooking;

  /// No description provided for @profileWithLabel.
  ///
  /// In en, this message translates to:
  /// **'With'**
  String get profileWithLabel;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get profileDetails;

  /// No description provided for @profileEditEmail.
  ///
  /// In en, this message translates to:
  /// **'Edit Email'**
  String get profileEditEmail;

  /// No description provided for @profileEditPhone.
  ///
  /// In en, this message translates to:
  /// **'Add / Edit Phone'**
  String get profileEditPhone;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileContributeContent.
  ///
  /// In en, this message translates to:
  /// **'Contribute Content'**
  String get profileContributeContent;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get profileClose;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get profileSubmit;

  /// No description provided for @profileEditProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfileTitle;

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileChangePhoto;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameLabel;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get profileNameHint;

  /// No description provided for @profileEditEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Email'**
  String get profileEditEmailTitle;

  /// No description provided for @profileNewEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'New Email'**
  String get profileNewEmailLabel;

  /// No description provided for @profileConfirmEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Email'**
  String get profileConfirmEmailLabel;

  /// No description provided for @profileEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new email'**
  String get profileEmailHint;

  /// No description provided for @profileConfirmEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter email'**
  String get profileConfirmEmailHint;

  /// No description provided for @profileEditPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Add / Edit Phone'**
  String get profileEditPhoneTitle;

  /// No description provided for @profileNewPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'New Phone'**
  String get profileNewPhoneLabel;

  /// No description provided for @profileConfirmPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Phone'**
  String get profileConfirmPhoneLabel;

  /// No description provided for @profilePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new phone'**
  String get profilePhoneHint;

  /// No description provided for @profileConfirmPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter phone'**
  String get profileConfirmPhoneHint;

  /// No description provided for @profileLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageTitle;

  /// No description provided for @profileLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEnglish;

  /// No description provided for @profileLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get profileLanguageArabic;

  /// No description provided for @profileSavedItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Items'**
  String get profileSavedItemsTitle;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsTitle;

  /// No description provided for @profileAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccountTitle;

  /// No description provided for @profileBookingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Booking Notifications'**
  String get profileBookingNotifications;

  /// No description provided for @profileEventReminders.
  ///
  /// In en, this message translates to:
  /// **'Event Reminders'**
  String get profileEventReminders;

  /// No description provided for @profileMarketingEmails.
  ///
  /// In en, this message translates to:
  /// **'Marketing Emails'**
  String get profileMarketingEmails;

  /// No description provided for @culturalArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Cultural Archive'**
  String get culturalArchiveTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for heritage, places...'**
  String get searchHint;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @servingLabel.
  ///
  /// In en, this message translates to:
  /// **'Serving'**
  String get servingLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @cat_food.
  ///
  /// In en, this message translates to:
  /// **'Traditional Food'**
  String get cat_food;

  /// No description provided for @cat_craft.
  ///
  /// In en, this message translates to:
  /// **'Handicraft'**
  String get cat_craft;

  /// No description provided for @cat_music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get cat_music;

  /// No description provided for @cat_dance.
  ///
  /// In en, this message translates to:
  /// **'Dance'**
  String get cat_dance;

  /// No description provided for @cat_architecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get cat_architecture;

  /// No description provided for @cat_clothing.
  ///
  /// In en, this message translates to:
  /// **'Traditional Clothing'**
  String get cat_clothing;

  /// No description provided for @reg_qassim.
  ///
  /// In en, this message translates to:
  /// **'Qassim Region'**
  String get reg_qassim;

  /// No description provided for @reg_riyadh.
  ///
  /// In en, this message translates to:
  /// **'Riyadh'**
  String get reg_riyadh;

  /// No description provided for @reg_makkah.
  ///
  /// In en, this message translates to:
  /// **'Makkah'**
  String get reg_makkah;

  /// No description provided for @reg_medina.
  ///
  /// In en, this message translates to:
  /// **'Medina'**
  String get reg_medina;

  /// No description provided for @reg_eastern.
  ///
  /// In en, this message translates to:
  /// **'Eastern Province'**
  String get reg_eastern;

  /// No description provided for @reg_asir.
  ///
  /// In en, this message translates to:
  /// **'Asir'**
  String get reg_asir;

  /// No description provided for @coffeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Traditional Saudi Coffee'**
  String get coffeeTitle;

  /// No description provided for @coffeeDesc.
  ///
  /// In en, this message translates to:
  /// **'Saudi coffee is a traditional beverage prepared with lightly roasted coffee beans mixed with cardamom and saffron.'**
  String get coffeeDesc;

  /// No description provided for @saduTitle.
  ///
  /// In en, this message translates to:
  /// **'Traditional Sadu Weaving'**
  String get saduTitle;

  /// No description provided for @saduDesc.
  ///
  /// In en, this message translates to:
  /// **'Sadu is a traditional Bedouin weaving craft, handmade to express desert cultural identity.'**
  String get saduDesc;

  /// No description provided for @kleijaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qassim Kleija'**
  String get kleijaTitle;

  /// No description provided for @kleijaDesc.
  ///
  /// In en, this message translates to:
  /// **'Kleija is a traditional Saudi pastry made from spiced dough filled with a sweet mixture of dates and cardamom.'**
  String get kleijaDesc;

  /// No description provided for @servingDesc.
  ///
  /// In en, this message translates to:
  /// **'Usually served with Saudi coffee, representing a symbol of hospitality.'**
  String get servingDesc;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

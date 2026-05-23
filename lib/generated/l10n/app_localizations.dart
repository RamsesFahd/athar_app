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
  /// **'We have sent a verification link to your email.'**
  String get verifyEmailSubtitle;

  /// Info text shown above the email on verify screen
  ///
  /// In en, this message translates to:
  /// **'We have sent a verification link to:'**
  String get verifyEmailInfoText;

  /// Verify button label
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// Resend link label
  ///
  /// In en, this message translates to:
  /// **'Resend Link'**
  String get resendCode;

  /// No description provided for @resendCodeInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend link in {seconds} seconds'**
  String resendCodeInSeconds(int seconds);

  /// No description provided for @signUpAsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sign up to Athar as:'**
  String get signUpAsLabel;

  /// No description provided for @touristRole.
  ///
  /// In en, this message translates to:
  /// **'Tourist'**
  String get touristRole;

  /// No description provided for @tutorRole.
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get tutorRole;

  /// No description provided for @errorEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get errorEmailAlreadyInUse;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is invalid.'**
  String get errorInvalidEmail;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find an account with that email.'**
  String get errorUserNotFound;

  /// No description provided for @errorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get errorWrongPassword;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Use a stronger password to continue.'**
  String get errorWeakPassword;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnexpected;

  /// No description provided for @fillAllFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFieldsError;

  /// No description provided for @emptyLoginFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password to continue.'**
  String get emptyLoginFieldsError;

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
  /// **'Verify your email using the link we sent.'**
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

  /// Label for Trip Management tab
  ///
  /// In en, this message translates to:
  /// **'Trips'**
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

  /// No description provided for @welcomeToAthar.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Athar'**
  String get welcomeToAthar;

  /// No description provided for @startYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your journey now in discovering and documenting our cultural treasures and leave your own mark.'**
  String get startYourJourney;

  /// No description provided for @joinUsNow.
  ///
  /// In en, this message translates to:
  /// **'Join Us Now'**
  String get joinUsNow;

  /// No description provided for @leaveYourCulturalImpact.
  ///
  /// In en, this message translates to:
  /// **'Leave your cultural impact'**
  String get leaveYourCulturalImpact;

  /// No description provided for @contributionTeaserDescription.
  ///
  /// In en, this message translates to:
  /// **'Share photos and information with us, and collect points to reach the top contributors list.'**
  String get contributionTeaserDescription;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @contributions.
  ///
  /// In en, this message translates to:
  /// **'Contributions'**
  String get contributions;

  /// No description provided for @myInterests.
  ///
  /// In en, this message translates to:
  /// **'My Interests'**
  String get myInterests;

  /// No description provided for @manageContributions.
  ///
  /// In en, this message translates to:
  /// **'Manage Contributions'**
  String get manageContributions;

  /// No description provided for @editPicture.
  ///
  /// In en, this message translates to:
  /// **'Edit Picture'**
  String get editPicture;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileEdit;

  /// No description provided for @profileTabBooking.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
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
  /// **'Upcoming Bookings'**
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

  /// No description provided for @settingsSupportLegal.
  ///
  /// In en, this message translates to:
  /// **'Support & Legal'**
  String get settingsSupportLegal;

  /// No description provided for @settingsContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get settingsContactUs;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsAboutAthar.
  ///
  /// In en, this message translates to:
  /// **'About Athar'**
  String get settingsAboutAthar;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @tutorVerificationPendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Your verification request is currently under review'**
  String get tutorVerificationPendingStatus;

  /// No description provided for @tutorVerificationRequiredStatus.
  ///
  /// In en, this message translates to:
  /// **'Account not verified! Please add your license number'**
  String get tutorVerificationRequiredStatus;

  /// No description provided for @tutorLicenseNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'License number'**
  String get tutorLicenseNumberTitle;

  /// No description provided for @tutorCompleteVerificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your license number to verify your account'**
  String get tutorCompleteVerificationSubtitle;

  /// No description provided for @tutorLicenseNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'License No: {number}'**
  String tutorLicenseNumberLabel(String number);

  /// No description provided for @statusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statusVerified;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get statusUnverified;

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

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

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

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Dive into Saudi Heritage'**
  String get homeHeroTitle;

  /// No description provided for @homeYouMayLikeTitle.
  ///
  /// In en, this message translates to:
  /// **'You May Like'**
  String get homeYouMayLikeTitle;

  /// No description provided for @homeExploreHeritageTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Saudi Heritage'**
  String get homeExploreHeritageTitle;

  /// No description provided for @homeQuickAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get homeQuickAccessTitle;

  /// No description provided for @seeAllLabel.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAllLabel;

  /// No description provided for @quickCalendar.
  ///
  /// In en, this message translates to:
  /// **'View Event Calendar'**
  String get quickCalendar;

  /// No description provided for @quickMap.
  ///
  /// In en, this message translates to:
  /// **'Open Interactive Map'**
  String get quickMap;

  /// No description provided for @quickAchievements.
  ///
  /// In en, this message translates to:
  /// **'My Cultural Achievements'**
  String get quickAchievements;

  /// No description provided for @quickGuides.
  ///
  /// In en, this message translates to:
  /// **'Find a Tour Guide'**
  String get quickGuides;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @historicalChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Historical Figures Chat'**
  String get historicalChatTitle;

  /// No description provided for @historicalChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a figure to discover history with'**
  String get historicalChatSubtitle;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask the historical figure...'**
  String get chatInputHint;

  /// No description provided for @khwarizmi.
  ///
  /// In en, this message translates to:
  /// **'Al-Khwarizmi'**
  String get khwarizmi;

  /// No description provided for @khwarizmiRole.
  ///
  /// In en, this message translates to:
  /// **'Founder of Algebra'**
  String get khwarizmiRole;

  /// No description provided for @khwarizmiEra.
  ///
  /// In en, this message translates to:
  /// **'9th Century AD'**
  String get khwarizmiEra;

  /// No description provided for @ibnSina.
  ///
  /// In en, this message translates to:
  /// **'Ibn Sina'**
  String get ibnSina;

  /// No description provided for @ibnSinaRole.
  ///
  /// In en, this message translates to:
  /// **'Father of Modern Medicine'**
  String get ibnSinaRole;

  /// No description provided for @ibnSinaEra.
  ///
  /// In en, this message translates to:
  /// **'11th Century'**
  String get ibnSinaEra;

  /// No description provided for @ibnHaytham.
  ///
  /// In en, this message translates to:
  /// **'Ibn al-Haytham'**
  String get ibnHaytham;

  /// No description provided for @ibnHaythamRole.
  ///
  /// In en, this message translates to:
  /// **'Founder of Optics'**
  String get ibnHaythamRole;

  /// No description provided for @ibnHaythamEra.
  ///
  /// In en, this message translates to:
  /// **'10th Century AD'**
  String get ibnHaythamEra;

  /// No description provided for @firnas.
  ///
  /// In en, this message translates to:
  /// **'Abbas ibn Firnas'**
  String get firnas;

  /// No description provided for @firnasRole.
  ///
  /// In en, this message translates to:
  /// **'Pioneer of Flight'**
  String get firnasRole;

  /// No description provided for @firnasEra.
  ///
  /// In en, this message translates to:
  /// **'9th Century AD'**
  String get firnasEra;

  /// No description provided for @rawiNewChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get rawiNewChat;

  /// No description provided for @rawiSearchHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Search your previous chats'**
  String get rawiSearchHistoryHint;

  /// No description provided for @rawiEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Rawi\'s council is waiting for your stories...\nChoose a region and start your first journey'**
  String get rawiEmptyState;

  /// No description provided for @rawiNoMatchingChats.
  ///
  /// In en, this message translates to:
  /// **'No chats matched your search'**
  String get rawiNoMatchingChats;

  /// No description provided for @rawiOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get rawiOpenChat;

  /// No description provided for @rawiDeleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get rawiDeleteChat;

  /// No description provided for @rawiDeleteAllChats.
  ///
  /// In en, this message translates to:
  /// **'Delete all chats'**
  String get rawiDeleteAllChats;

  /// No description provided for @rawiDeleteChatConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this chat?'**
  String get rawiDeleteChatConfirmTitle;

  /// No description provided for @rawiDeleteChatConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This chat and all its messages will be permanently deleted.'**
  String get rawiDeleteChatConfirmBody;

  /// No description provided for @rawiDeleteAllChatsConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all chats?'**
  String get rawiDeleteAllChatsConfirmTitle;

  /// No description provided for @rawiDeleteAllChatsConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All chats and their messages will be permanently deleted.'**
  String get rawiDeleteAllChatsConfirmBody;

  /// No description provided for @rawiDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get rawiDelete;

  /// No description provided for @rawiCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get rawiCancel;

  /// No description provided for @rawiRenameChat.
  ///
  /// In en, this message translates to:
  /// **'Rename chat'**
  String get rawiRenameChat;

  /// No description provided for @rawiRenameChatDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename chat'**
  String get rawiRenameChatDialogTitle;

  /// No description provided for @rawiRenameChatHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a new title'**
  String get rawiRenameChatHint;

  /// No description provided for @rawiRenameChatSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get rawiRenameChatSave;

  /// No description provided for @rawiChatRenamedToast.
  ///
  /// In en, this message translates to:
  /// **'Chat title updated'**
  String get rawiChatRenamedToast;

  /// No description provided for @rawiChatDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Chat deleted'**
  String get rawiChatDeletedToast;

  /// No description provided for @rawiAllChatsDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'All chats deleted'**
  String get rawiAllChatsDeletedToast;

  /// No description provided for @rawiNoChatsToDelete.
  ///
  /// In en, this message translates to:
  /// **'There are no chats to delete'**
  String get rawiNoChatsToDelete;

  /// No description provided for @rawiStoryStartChat.
  ///
  /// In en, this message translates to:
  /// **'Start chatting with Rawi'**
  String get rawiStoryStartChat;

  /// No description provided for @rawiUntitledArabic.
  ///
  /// In en, this message translates to:
  /// **'New Story'**
  String get rawiUntitledArabic;

  /// No description provided for @rawiUntitledEnglish.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get rawiUntitledEnglish;

  /// No description provided for @rawiMicTooltip.
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get rawiMicTooltip;

  /// No description provided for @rawiMicListening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get rawiMicListening;

  /// No description provided for @rawiMicPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Turn on microphone access in Settings to use voice input.'**
  String get rawiMicPermissionDenied;

  /// No description provided for @rawiMicError.
  ///
  /// In en, this message translates to:
  /// **'Voice input couldn’t start. Please try again.'**
  String get rawiMicError;

  /// No description provided for @rawiSuggestedItems.
  ///
  /// In en, this message translates to:
  /// **'Rawi\'s Suggestions'**
  String get rawiSuggestedItems;

  /// No description provided for @all_trips.
  ///
  /// In en, this message translates to:
  /// **'Explore Trips'**
  String get all_trips;

  /// No description provided for @search_trips_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for a trip...'**
  String get search_trips_hint;

  /// No description provided for @price_low_first.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get price_low_first;

  /// No description provided for @price_high_first.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get price_high_first;

  /// No description provided for @trips_in.
  ///
  /// In en, this message translates to:
  /// **'Trips in {region}'**
  String trips_in(String region);

  /// No description provided for @about_trip.
  ///
  /// In en, this message translates to:
  /// **'About the trip:'**
  String get about_trip;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Organizing Company'**
  String get company;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @book_now.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get book_now;

  /// No description provided for @booking_details.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get booking_details;

  /// No description provided for @people_count.
  ///
  /// In en, this message translates to:
  /// **'Number of People'**
  String get people_count;

  /// No description provided for @adults.
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get adults;

  /// No description provided for @children.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get children;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @select_time.
  ///
  /// In en, this message translates to:
  /// **'Select Trip Time'**
  String get select_time;

  /// No description provided for @continue_btn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_btn;

  /// No description provided for @complete_data.
  ///
  /// In en, this message translates to:
  /// **'Please complete the data'**
  String get complete_data;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @choose_guide.
  ///
  /// In en, this message translates to:
  /// **'Choose a Tour Guide'**
  String get choose_guide;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages:'**
  String get languages;

  /// No description provided for @available_days.
  ///
  /// In en, this message translates to:
  /// **'Available Days:'**
  String get available_days;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills:'**
  String get skills;

  /// No description provided for @booking_summary.
  ///
  /// In en, this message translates to:
  /// **'Booking Summary'**
  String get booking_summary;

  /// No description provided for @total_price.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get total_price;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get currency;

  /// No description provided for @payment_note.
  ///
  /// In en, this message translates to:
  /// **'Note: Payment is not processed through the app; you will coordinate with the guide directly.'**
  String get payment_note;

  /// No description provided for @complete_booking.
  ///
  /// In en, this message translates to:
  /// **'Complete Booking'**
  String get complete_booking;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @trip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get trip;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @guide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guide;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @select_this_guide.
  ///
  /// In en, this message translates to:
  /// **'Select this guide'**
  String get select_this_guide;

  /// No description provided for @guides.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get guides;

  /// No description provided for @add_new_trip.
  ///
  /// In en, this message translates to:
  /// **'Add New Trip'**
  String get add_new_trip;

  /// No description provided for @add_trip_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Submit a trip for admin approval'**
  String get add_trip_subtitle;

  /// No description provided for @booking_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get booking_status_pending;

  /// No description provided for @booking_status_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get booking_status_accepted;

  /// No description provided for @booking_status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get booking_status_rejected;

  /// No description provided for @booking_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get booking_status_completed;

  /// No description provided for @accept_booking.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept_booking;

  /// No description provided for @reject_booking.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject_booking;

  /// No description provided for @view_details.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get view_details;

  /// No description provided for @adult_price.
  ///
  /// In en, this message translates to:
  /// **'Adult Price (SAR)'**
  String get adult_price;

  /// No description provided for @child_price.
  ///
  /// In en, this message translates to:
  /// **'Child Price (SAR, 0 = free)'**
  String get child_price;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @accessibility_wheelchair.
  ///
  /// In en, this message translates to:
  /// **'Wheelchair Accessible'**
  String get accessibility_wheelchair;

  /// No description provided for @accessibility_family.
  ///
  /// In en, this message translates to:
  /// **'Family / Child Friendly'**
  String get accessibility_family;

  /// No description provided for @guide_info_autofilled.
  ///
  /// In en, this message translates to:
  /// **'Guide Info (auto-filled from your profile)'**
  String get guide_info_autofilled;

  /// No description provided for @description_template_hint.
  ///
  /// In en, this message translates to:
  /// **'Use the template below — fill in each bullet point.'**
  String get description_template_hint;

  /// No description provided for @tour_operator.
  ///
  /// In en, this message translates to:
  /// **'Tour Operator'**
  String get tour_operator;

  /// No description provided for @filterAndSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter and Sort Results'**
  String get filterAndSortTitle;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHighToLow;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @showResults.
  ///
  /// In en, this message translates to:
  /// **'Show Results'**
  String get showResults;

  /// No description provided for @currencySAR.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get currencySAR;

  /// No description provided for @min_price.
  ///
  /// In en, this message translates to:
  /// **'Min Price'**
  String get min_price;

  /// No description provided for @max_price.
  ///
  /// In en, this message translates to:
  /// **'Max Price'**
  String get max_price;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @myCulturalAchievements.
  ///
  /// In en, this message translates to:
  /// **'My Cultural Achievements'**
  String get myCulturalAchievements;

  /// No description provided for @communityMember.
  ///
  /// In en, this message translates to:
  /// **'Community Member'**
  String get communityMember;

  /// No description provided for @culturalImpactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preserving Saudi heritage through meaningful cultural contributions.'**
  String get culturalImpactSubtitle;

  /// No description provided for @culturalContributorLevel.
  ///
  /// In en, this message translates to:
  /// **'Cultural Contributor'**
  String get culturalContributorLevel;

  /// No description provided for @heritagePreserverLevel.
  ///
  /// In en, this message translates to:
  /// **'Heritage Preserver'**
  String get heritagePreserverLevel;

  /// No description provided for @featuredBadgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Featured Badge'**
  String get featuredBadgeTitle;

  /// No description provided for @communityVoiceBadge.
  ///
  /// In en, this message translates to:
  /// **'Community Voice'**
  String get communityVoiceBadge;

  /// No description provided for @communityVoiceBadgeDescription.
  ///
  /// In en, this message translates to:
  /// **'Awarded to members with strong and consistent cultural participation.'**
  String get communityVoiceBadgeDescription;

  /// No description provided for @allBadges.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allBadges;

  /// No description provided for @earnedBadges.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earnedBadges;

  /// No description provided for @inProgressBadges.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressBadges;

  /// No description provided for @firstStepBadge.
  ///
  /// In en, this message translates to:
  /// **'First Step'**
  String get firstStepBadge;

  /// No description provided for @firstStepBadgeDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlocked after your first approved contribution.'**
  String get firstStepBadgeDescription;

  /// No description provided for @activeContributorBadge.
  ///
  /// In en, this message translates to:
  /// **'Active Contributor'**
  String get activeContributorBadge;

  /// No description provided for @activeContributorBadgeDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlocked after submitting multiple approved contributions.'**
  String get activeContributorBadgeDescription;

  /// No description provided for @storyKeeperBadge.
  ///
  /// In en, this message translates to:
  /// **'Story Keeper'**
  String get storyKeeperBadge;

  /// No description provided for @storyKeeperBadgeDescription.
  ///
  /// In en, this message translates to:
  /// **'Share more stories to unlock this badge.'**
  String get storyKeeperBadgeDescription;

  /// No description provided for @traditionGuardianBadge.
  ///
  /// In en, this message translates to:
  /// **'Tradition Guardian'**
  String get traditionGuardianBadge;

  /// No description provided for @traditionGuardianBadgeDescription.
  ///
  /// In en, this message translates to:
  /// **'Contribute more traditions from different regions.'**
  String get traditionGuardianBadgeDescription;

  /// No description provided for @visualArchivistBadge.
  ///
  /// In en, this message translates to:
  /// **'Visual Archivist'**
  String get visualArchivistBadge;

  /// No description provided for @visualArchivistBadgeDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload more visual content to unlock this achievement.'**
  String get visualArchivistBadgeDescription;

  /// No description provided for @unlockedLabel.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlockedLabel;

  /// No description provided for @storyKeeperProgress.
  ///
  /// In en, this message translates to:
  /// **'2 of 3 stories'**
  String get storyKeeperProgress;

  /// No description provided for @traditionGuardianProgress.
  ///
  /// In en, this message translates to:
  /// **'1 of 3 traditions'**
  String get traditionGuardianProgress;

  /// No description provided for @visualArchivistProgress.
  ///
  /// In en, this message translates to:
  /// **'3 of 5 uploads'**
  String get visualArchivistProgress;

  /// No description provided for @pointsValue.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String pointsValue(Object points);

  /// No description provided for @pointsToReachNextLevel.
  ///
  /// In en, this message translates to:
  /// **'{points} pts to reach {level}'**
  String pointsToReachNextLevel(Object points, Object level);

  /// No description provided for @addContributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Contribution'**
  String get addContributionTitle;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter contribution title'**
  String get titleHint;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your contribution'**
  String get descriptionHint;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @categoryStory.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get categoryStory;

  /// No description provided for @categoryTradition.
  ///
  /// In en, this message translates to:
  /// **'Tradition'**
  String get categoryTradition;

  /// No description provided for @categoryEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get categoryEvent;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @cityRiyadh.
  ///
  /// In en, this message translates to:
  /// **'Riyadh'**
  String get cityRiyadh;

  /// No description provided for @cityJeddah.
  ///
  /// In en, this message translates to:
  /// **'Jeddah'**
  String get cityJeddah;

  /// No description provided for @cityMakkah.
  ///
  /// In en, this message translates to:
  /// **'Makkah'**
  String get cityMakkah;

  /// No description provided for @cityMadinah.
  ///
  /// In en, this message translates to:
  /// **'Madinah'**
  String get cityMadinah;

  /// No description provided for @selectCityError.
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get selectCityError;

  /// No description provided for @mediaLabel.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get mediaLabel;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get addVideo;

  /// No description provided for @mediaRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'You must add at least one photo or one video'**
  String get mediaRequiredHint;

  /// No description provided for @mediaRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Media is required'**
  String get mediaRequiredError;

  /// No description provided for @submitContribution.
  ///
  /// In en, this message translates to:
  /// **'Submit Contribution'**
  String get submitContribution;

  /// No description provided for @submissionSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Submitted successfully for review'**
  String get submissionSuccessMessage;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @addContributionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us preserve Saudi heritage by sharing what you know!'**
  String get addContributionSubtitle;

  /// No description provided for @categoryTraditionalFood.
  ///
  /// In en, this message translates to:
  /// **'Traditional Food'**
  String get categoryTraditionalFood;

  /// No description provided for @categoryCulturalTradition.
  ///
  /// In en, this message translates to:
  /// **'Cultural Tradition'**
  String get categoryCulturalTradition;

  /// No description provided for @categoryTraditionalGame.
  ///
  /// In en, this message translates to:
  /// **'Traditional Game'**
  String get categoryTraditionalGame;

  /// No description provided for @categoryTraditionalCraft.
  ///
  /// In en, this message translates to:
  /// **'Traditional Craft'**
  String get categoryTraditionalCraft;

  /// No description provided for @categoryHistoricalStory.
  ///
  /// In en, this message translates to:
  /// **'Historical Story'**
  String get categoryHistoricalStory;

  /// No description provided for @contentReviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Content will be reviewed before publishing'**
  String get contentReviewNotice;

  /// Title of the privacy policy screen
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// Text before the privacy policy link in signup
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get privacyPolicyAgreePrefix;

  /// Clickable privacy policy link text in signup
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLinkText;

  /// Error shown if user tries to sign up without accepting policy
  ///
  /// In en, this message translates to:
  /// **'Please accept the Privacy Policy to continue'**
  String get privacyPolicyMustAccept;

  /// No description provided for @privacyPolicyIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get privacyPolicyIntroTitle;

  /// No description provided for @privacyPolicyIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Athar is committed to protecting your privacy. This policy explains how we collect, use, and safeguard your personal information.'**
  String get privacyPolicyIntroBody;

  /// No description provided for @privacyPolicyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Data We Collect'**
  String get privacyPolicyDataTitle;

  /// No description provided for @privacyPolicyDataBody.
  ///
  /// In en, this message translates to:
  /// **'We collect your name, email address, account role, accessibility preferences, and the timestamp of your privacy policy consent.'**
  String get privacyPolicyDataBody;

  /// No description provided for @privacyPolicyUseTitle.
  ///
  /// In en, this message translates to:
  /// **'How We Use Your Data'**
  String get privacyPolicyUseTitle;

  /// No description provided for @privacyPolicyUseBody.
  ///
  /// In en, this message translates to:
  /// **'Your data is used to provide core app features, personalise your experience, and comply with legal obligations.'**
  String get privacyPolicyUseBody;

  /// No description provided for @privacyPolicySharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Sharing'**
  String get privacyPolicySharingTitle;

  /// No description provided for @privacyPolicySharingBody.
  ///
  /// In en, this message translates to:
  /// **'We do not sell your personal data. We may share it with trusted service providers (e.g. Firebase) solely to operate the app.'**
  String get privacyPolicySharingBody;

  /// No description provided for @privacyPolicyRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get privacyPolicyRightsTitle;

  /// No description provided for @privacyPolicyRightsBody.
  ///
  /// In en, this message translates to:
  /// **'You may request access to, correction of, or deletion of your personal data at any time by contacting us.'**
  String get privacyPolicyRightsBody;

  /// No description provided for @privacyPolicyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get privacyPolicyContactTitle;

  /// No description provided for @privacyPolicyContactBody.
  ///
  /// In en, this message translates to:
  /// **'For privacy-related enquiries please email: privacy@athar-app.com'**
  String get privacyPolicyContactBody;

  /// No description provided for @bookingPendingForGuide.
  ///
  /// In en, this message translates to:
  /// **'New request — action required'**
  String get bookingPendingForGuide;

  /// No description provided for @bookingPendingForTourist.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Guide\'s approval'**
  String get bookingPendingForTourist;

  /// No description provided for @bookingApproved.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get bookingApproved;

  /// No description provided for @bookingRejectedByGuide.
  ///
  /// In en, this message translates to:
  /// **'You rejected this'**
  String get bookingRejectedByGuide;

  /// No description provided for @bookingRejectedForTourist.
  ///
  /// In en, this message translates to:
  /// **'Rejected by Guide'**
  String get bookingRejectedForTourist;

  /// No description provided for @bookingCancelledByTourist.
  ///
  /// In en, this message translates to:
  /// **'Tourist cancelled before your approval'**
  String get bookingCancelledByTourist;

  /// No description provided for @bookingCancelledByMe.
  ///
  /// In en, this message translates to:
  /// **'Cancelled before approval'**
  String get bookingCancelledByMe;

  /// No description provided for @bookingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookingCompleted;

  /// No description provided for @guideContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Guide Contact'**
  String get guideContactInfo;

  /// No description provided for @touristContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Tourist Contact'**
  String get touristContactInfo;

  /// No description provided for @rateYourGuide.
  ///
  /// In en, this message translates to:
  /// **'Rate your Guide'**
  String get rateYourGuide;

  /// No description provided for @completeProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeProfileTitle;

  /// No description provided for @phoneRequiredForGuide.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile first — phone number is required to publish trips'**
  String get phoneRequiredForGuide;

  /// No description provided for @phoneRequiredForTourist.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile first — phone number is required to book a trip'**
  String get phoneRequiredForTourist;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @guideTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Guide Type'**
  String get guideTypeLabel;

  /// No description provided for @guideTypeIndependent.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get guideTypeIndependent;

  /// No description provided for @guideTypeCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get guideTypeCompany;

  /// No description provided for @myTrips.
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get myTrips;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @privacyDisclaimerTouristTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Disclaimer'**
  String get privacyDisclaimerTouristTitle;

  /// No description provided for @privacyDisclaimerTouristBody.
  ///
  /// In en, this message translates to:
  /// **'We care about your data privacy and confidentiality.'**
  String get privacyDisclaimerTouristBody;

  /// No description provided for @privacyDisclaimerGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Guide Privacy Disclaimer'**
  String get privacyDisclaimerGuideTitle;

  /// No description provided for @privacyDisclaimerGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Your data and documents are stored and protected with the highest standards.'**
  String get privacyDisclaimerGuideBody;

  /// No description provided for @credVerifTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Verification'**
  String get credVerifTitle;

  /// No description provided for @credVerifIndividualLicence.
  ///
  /// In en, this message translates to:
  /// **'Freelance License'**
  String get credVerifIndividualLicence;

  /// No description provided for @credVerifCompanyDetails.
  ///
  /// In en, this message translates to:
  /// **'Company Details'**
  String get credVerifCompanyDetails;

  /// No description provided for @credVerifLicenceNumber.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get credVerifLicenceNumber;

  /// No description provided for @credVerifLicenceExpiry.
  ///
  /// In en, this message translates to:
  /// **'License Expiry Date'**
  String get credVerifLicenceExpiry;

  /// No description provided for @credVerifCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get credVerifCompanyName;

  /// No description provided for @credVerifCommercialReg.
  ///
  /// In en, this message translates to:
  /// **'Commercial Registration Number'**
  String get credVerifCommercialReg;

  /// No description provided for @credVerifCommercialRegExpiry.
  ///
  /// In en, this message translates to:
  /// **'CR Expiry Date'**
  String get credVerifCommercialRegExpiry;

  /// No description provided for @credVerifTourismLicenceSection.
  ///
  /// In en, this message translates to:
  /// **'Tour Guide License'**
  String get credVerifTourismLicenceSection;

  /// No description provided for @credVerifTourismLicenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Tour Guide License Number'**
  String get credVerifTourismLicenceNumber;

  /// No description provided for @credVerifTourismLicenceExpiry.
  ///
  /// In en, this message translates to:
  /// **'Tour Guide License Expiry'**
  String get credVerifTourismLicenceExpiry;

  /// No description provided for @credVerifPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick Date'**
  String get credVerifPickDate;

  /// No description provided for @credVerifRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get credVerifRequired;

  /// No description provided for @credVerifPickLicenceExpiry.
  ///
  /// In en, this message translates to:
  /// **'Pick license expiry date'**
  String get credVerifPickLicenceExpiry;

  /// No description provided for @credVerifPickAllExpiry.
  ///
  /// In en, this message translates to:
  /// **'Please specify all expiry dates'**
  String get credVerifPickAllExpiry;

  /// No description provided for @credVerifSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit for Verification'**
  String get credVerifSubmit;

  /// No description provided for @credVerifReviewNote.
  ///
  /// In en, this message translates to:
  /// **'Your documents will be reviewed by the administration'**
  String get credVerifReviewNote;

  /// No description provided for @credVerifSuccess.
  ///
  /// In en, this message translates to:
  /// **'Documents submitted successfully'**
  String get credVerifSuccess;

  /// No description provided for @credVerifRejectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents Rejected'**
  String get credVerifRejectionTitle;

  /// No description provided for @credVerifPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents Under Review'**
  String get credVerifPendingTitle;

  /// No description provided for @credVerifPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Your documents are currently under review, we will notify you once done.'**
  String get credVerifPendingBody;

  /// No description provided for @credVerifVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get credVerifVerifiedTitle;

  /// No description provided for @credVerifVerifiedBody.
  ///
  /// In en, this message translates to:
  /// **'Your documents have been verified and approved successfully.'**
  String get credVerifVerifiedBody;

  /// No description provided for @credVerifPhoneRequiredFirst.
  ///
  /// In en, this message translates to:
  /// **'Please verify your phone number before submitting credentials'**
  String get credVerifPhoneRequiredFirst;

  /// No description provided for @credVerifPhoneNotVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Not Verified'**
  String get credVerifPhoneNotVerifiedTitle;

  /// No description provided for @credVerifPhoneNotVerifiedBody.
  ///
  /// In en, this message translates to:
  /// **'You must verify your phone number first. Go back to your profile and verify your phone.'**
  String get credVerifPhoneNotVerifiedBody;

  /// No description provided for @tripEligibilityProfileIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile (bio & languages) to add trips'**
  String get tripEligibilityProfileIncomplete;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get goBack;

  /// No description provided for @selectTutorTypeError.
  ///
  /// In en, this message translates to:
  /// **'Please select an account type (individual or company)'**
  String get selectTutorTypeError;

  /// No description provided for @phoneDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneDialogTitle;

  /// No description provided for @otpDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get otpDialogTitle;

  /// No description provided for @phoneSmsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A verification code will be sent to you via SMS'**
  String get phoneSmsSubtitle;

  /// No description provided for @phoneInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get phoneInvalidError;

  /// No description provided for @phoneVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Phone number verified successfully'**
  String get phoneVerifiedSuccess;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to\n{phone}'**
  String otpSentTo(String phone);

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} seconds'**
  String otpResendIn(int seconds);

  /// No description provided for @otpResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get otpResendCode;

  /// No description provided for @otpSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get otpSendCode;

  /// No description provided for @contactUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsTitle;

  /// No description provided for @contactUsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'d love to hear your suggestions or feedback to improve Athar.'**
  String get contactUsSubtitle;

  /// No description provided for @contactUsEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactUsEmailTitle;

  /// No description provided for @contactUsLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get contactUsLocationTitle;

  /// No description provided for @contactUsSaudiArabia.
  ///
  /// In en, this message translates to:
  /// **'Saudi Arabia'**
  String get contactUsSaudiArabia;

  /// No description provided for @contactUsSupportType.
  ///
  /// In en, this message translates to:
  /// **'Support Type'**
  String get contactUsSupportType;

  /// No description provided for @contactUsReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get contactUsReportIssue;

  /// No description provided for @contactUsSuggestFeature.
  ///
  /// In en, this message translates to:
  /// **'Suggest Feature'**
  String get contactUsSuggestFeature;

  /// No description provided for @contactUsGuideSupport.
  ///
  /// In en, this message translates to:
  /// **'Guide Support'**
  String get contactUsGuideSupport;

  /// No description provided for @contactUsContributions.
  ///
  /// In en, this message translates to:
  /// **'Contributions'**
  String get contactUsContributions;

  /// No description provided for @contactUsSendMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a Message'**
  String get contactUsSendMessageTitle;

  /// No description provided for @contactUsSendMessageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write your message and we will review it as soon as possible.'**
  String get contactUsSendMessageSubtitle;

  /// No description provided for @contactUsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get contactUsNameHint;

  /// No description provided for @contactUsEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Your Email'**
  String get contactUsEmailHint;

  /// No description provided for @contactUsMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write your message here...'**
  String get contactUsMessageHint;

  /// No description provided for @contactUsMessageSent.
  ///
  /// In en, this message translates to:
  /// **'Your message has been sent successfully'**
  String get contactUsMessageSent;

  /// No description provided for @contactUsSendMessageButton.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get contactUsSendMessageButton;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in'**
  String get notificationsSignInRequired;

  /// No description provided for @notificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your notifications. Please try again.'**
  String get notificationsLoadError;

  /// No description provided for @notificationsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyState;

  /// No description provided for @notificationsDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get notificationsDeleteAll;

  /// No description provided for @notificationsDeleteAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all notifications?'**
  String get notificationsDeleteAllConfirm;

  /// No description provided for @notificationContributionApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Contribution Approved'**
  String get notificationContributionApprovedTitle;

  /// No description provided for @notificationContributionRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Contribution Rejected'**
  String get notificationContributionRejectedTitle;

  /// No description provided for @notificationContributionSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'New Contribution Awaiting Review'**
  String get notificationContributionSubmittedTitle;

  /// No description provided for @notificationTripSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'New Trip Awaiting Review'**
  String get notificationTripSubmittedTitle;

  /// No description provided for @notificationTripApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Approved'**
  String get notificationTripApprovedTitle;

  /// No description provided for @notificationTripRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Rejected'**
  String get notificationTripRejectedTitle;

  /// No description provided for @notificationBookingNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Booking'**
  String get notificationBookingNewTitle;

  /// No description provided for @notificationBookingApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Approved'**
  String get notificationBookingApprovedTitle;

  /// No description provided for @notificationBookingCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Cancelled'**
  String get notificationBookingCancelledTitle;

  /// No description provided for @notificationBookingAutoCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Auto-Completed'**
  String get notificationBookingAutoCompletedTitle;

  /// No description provided for @notificationGuideVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Verified'**
  String get notificationGuideVerifiedTitle;

  /// No description provided for @notificationGuideRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Rejected'**
  String get notificationGuideRejectedTitle;

  /// No description provided for @notificationPointsAwardedTitle.
  ///
  /// In en, this message translates to:
  /// **'Bonus Points Awarded'**
  String get notificationPointsAwardedTitle;

  /// No description provided for @notificationDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'New Notification'**
  String get notificationDefaultTitle;

  /// No description provided for @notificationContributionApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Your contribution has been approved.'**
  String get notificationContributionApprovedBody;

  /// No description provided for @notificationContributionRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your contribution was rejected. Please review the reason.'**
  String get notificationContributionRejectedBody;

  /// No description provided for @notificationContributionSubmittedBody.
  ///
  /// In en, this message translates to:
  /// **'A tourist submitted a contribution for review.'**
  String get notificationContributionSubmittedBody;

  /// No description provided for @notificationTripSubmittedBody.
  ///
  /// In en, this message translates to:
  /// **'A guide submitted a new trip for review.'**
  String get notificationTripSubmittedBody;

  /// No description provided for @notificationTripApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Your trip is now open for bookings.'**
  String get notificationTripApprovedBody;

  /// No description provided for @notificationTripRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your trip was rejected.'**
  String get notificationTripRejectedBody;

  /// No description provided for @notificationBookingNewBody.
  ///
  /// In en, this message translates to:
  /// **'A tourist has booked your trip.'**
  String get notificationBookingNewBody;

  /// No description provided for @notificationBookingApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Your booking has been approved.'**
  String get notificationBookingApprovedBody;

  /// No description provided for @notificationBookingCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'Your booking has been cancelled.'**
  String get notificationBookingCancelledBody;

  /// No description provided for @notificationBookingAutoCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'Your trip was auto-completed 24 hours after the scheduled end time. Contact support if there is an issue.'**
  String get notificationBookingAutoCompletedBody;

  /// No description provided for @notificationGuideVerifiedBody.
  ///
  /// In en, this message translates to:
  /// **'Your guide account has been verified.'**
  String get notificationGuideVerifiedBody;

  /// No description provided for @notificationGuideRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your guide verification request has been rejected.'**
  String get notificationGuideRejectedBody;

  /// No description provided for @notificationPointsAwardedBody.
  ///
  /// In en, this message translates to:
  /// **'Bonus points have been added to your account.'**
  String get notificationPointsAwardedBody;

  /// No description provided for @notificationDefaultBody.
  ///
  /// In en, this message translates to:
  /// **'You have a new notification.'**
  String get notificationDefaultBody;

  /// No description provided for @commonErrorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'{message, select, _ {Something went wrong. Please try again.} other {Something went wrong. Please try again.}}'**
  String commonErrorWithMessage(String message);

  /// No description provided for @commonFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get commonFree;

  /// No description provided for @commonPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get commonPaid;

  /// No description provided for @commonLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get commonLinkCopied;

  /// No description provided for @commonNoTitle.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get commonNoTitle;

  /// No description provided for @commonNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get commonNoDescription;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @timeAmMarker.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get timeAmMarker;

  /// No description provided for @timePmMarker.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get timePmMarker;

  /// No description provided for @homeAttractionsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Attractions'**
  String get homeAttractionsSectionTitle;

  /// No description provided for @homeTripsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get homeTripsSectionTitle;

  /// No description provided for @homeEventsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get homeEventsSectionTitle;

  /// No description provided for @homeHeroFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Saudi Heritage'**
  String get homeHeroFallbackTitle;

  /// No description provided for @homeHeroEventBadge.
  ///
  /// In en, this message translates to:
  /// **'The Countdown Begins'**
  String get homeHeroEventBadge;

  /// No description provided for @homeHeroEventSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A cultural moment is almost here'**
  String get homeHeroEventSubtitle;

  /// No description provided for @homeHeroEventCta.
  ///
  /// In en, this message translates to:
  /// **'Get Ready'**
  String get homeHeroEventCta;

  /// No description provided for @homeHeroAttractionCta.
  ///
  /// In en, this message translates to:
  /// **'Explore Landmark'**
  String get homeHeroAttractionCta;

  /// No description provided for @homeHeroCommunityCta.
  ///
  /// In en, this message translates to:
  /// **'Share Athar'**
  String get homeHeroCommunityCta;

  /// No description provided for @homeHeroArchiveCta.
  ///
  /// In en, this message translates to:
  /// **'Open Archive'**
  String get homeHeroArchiveCta;

  /// No description provided for @homeHeroTripBadge.
  ///
  /// In en, this message translates to:
  /// **'Balloon Experience'**
  String get homeHeroTripBadge;

  /// No description provided for @homeHeroTripSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rise above a landscape made for memory'**
  String get homeHeroTripSubtitle;

  /// No description provided for @homeHeroTripCta.
  ///
  /// In en, this message translates to:
  /// **'Book Experience'**
  String get homeHeroTripCta;

  /// No description provided for @homeHeroDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get homeHeroDaysLabel;

  /// No description provided for @homeHeroHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get homeHeroHoursLabel;

  /// No description provided for @attractionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Attractions'**
  String get attractionsTitle;

  /// No description provided for @attractionsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search attractions...'**
  String get attractionsSearchHint;

  /// No description provided for @attractionsNoAvailable.
  ///
  /// In en, this message translates to:
  /// **'No attractions available'**
  String get attractionsNoAvailable;

  /// No description provided for @attractionsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get attractionsNoResults;

  /// No description provided for @attractionHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get attractionHours;

  /// No description provided for @attractionAlwaysOpen.
  ///
  /// In en, this message translates to:
  /// **'Always Open'**
  String get attractionAlwaysOpen;

  /// No description provided for @attractionEntryFee.
  ///
  /// In en, this message translates to:
  /// **'Entry Fee'**
  String get attractionEntryFee;

  /// No description provided for @attractionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get attractionAbout;

  /// No description provided for @attractionTicketLink.
  ///
  /// In en, this message translates to:
  /// **'Get tickets here'**
  String get attractionTicketLink;

  /// No description provided for @attractionGetDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get attractionGetDirections;

  /// No description provided for @mapSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search landmarks or events...'**
  String get mapSearchHint;

  /// No description provided for @mapLandmarks.
  ///
  /// In en, this message translates to:
  /// **'Landmarks'**
  String get mapLandmarks;

  /// No description provided for @mapAttractions.
  ///
  /// In en, this message translates to:
  /// **'Attractions'**
  String get mapAttractions;

  /// No description provided for @mapEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get mapEvents;

  /// No description provided for @mapNearMe.
  ///
  /// In en, this message translates to:
  /// **'Near Me'**
  String get mapNearMe;

  /// No description provided for @mapMyLocationTooltip.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get mapMyLocationTooltip;

  /// No description provided for @mapShareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get mapShareTooltip;

  /// No description provided for @mapAboutEvent.
  ///
  /// In en, this message translates to:
  /// **'About the Event'**
  String get mapAboutEvent;

  /// No description provided for @mapAboutAttraction.
  ///
  /// In en, this message translates to:
  /// **'About the Attraction'**
  String get mapAboutAttraction;

  /// No description provided for @mapAboutLandmark.
  ///
  /// In en, this message translates to:
  /// **'About the Landmark'**
  String get mapAboutLandmark;

  /// No description provided for @mapBookTicket.
  ///
  /// In en, this message translates to:
  /// **'Book Ticket'**
  String get mapBookTicket;

  /// No description provided for @mapSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get mapSource;

  /// No description provided for @mapDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get mapDirections;

  /// No description provided for @mapNoResultsInArea.
  ///
  /// In en, this message translates to:
  /// **'No results in this area'**
  String get mapNoResultsInArea;

  /// No description provided for @mapAttractionLabel.
  ///
  /// In en, this message translates to:
  /// **'Attraction'**
  String get mapAttractionLabel;

  /// No description provided for @mapLandmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get mapLandmarkLabel;

  /// No description provided for @mapLocationPermissionSettings.
  ///
  /// In en, this message translates to:
  /// **'Turn on location access in Settings to use your current location.'**
  String get mapLocationPermissionSettings;

  /// No description provided for @mapLoadDataError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load the map. Check your connection and try again.'**
  String get mapLoadDataError;

  /// No description provided for @contributionAuthError.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to add a contribution.'**
  String get contributionAuthError;

  /// No description provided for @contributionUserUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your profile. Please try again.'**
  String get contributionUserUnavailable;

  /// No description provided for @contributionErrorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'{message, select, _ {We couldn’t submit your contribution. Please try again.} other {We couldn’t submit your contribution. Please try again.}}'**
  String contributionErrorWithMessage(String message);

  /// No description provided for @contributionGoToProfile.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile'**
  String get contributionGoToProfile;

  /// No description provided for @contributionTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Contribution Type'**
  String get contributionTypeLabel;

  /// No description provided for @contributionTitleExampleHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Al-Khatwa Dance - Asir'**
  String get contributionTitleExampleHint;

  /// No description provided for @contributionDescriptionExampleHint.
  ///
  /// In en, this message translates to:
  /// **'Write a clear description: what is it, where is it used, and why is it important?'**
  String get contributionDescriptionExampleHint;

  /// No description provided for @contributionSelectRegionHint.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get contributionSelectRegionHint;

  /// No description provided for @contributionSelectRegionFirstHint.
  ///
  /// In en, this message translates to:
  /// **'Select region first'**
  String get contributionSelectRegionFirstHint;

  /// No description provided for @contributionFileSelected.
  ///
  /// In en, this message translates to:
  /// **'File selected'**
  String get contributionFileSelected;

  /// No description provided for @contributionRejectionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Submission Details'**
  String get contributionRejectionDetailsTitle;

  /// No description provided for @contributionSubmittedContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Submitted Content'**
  String get contributionSubmittedContentTitle;

  /// No description provided for @contributionSubmissionInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Submission Info'**
  String get contributionSubmissionInfoTitle;

  /// No description provided for @contributionSubmittedDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get contributionSubmittedDateLabel;

  /// No description provided for @contributionSubmitNew.
  ///
  /// In en, this message translates to:
  /// **'Submit New Contribution'**
  String get contributionSubmitNew;

  /// No description provided for @contributionRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get contributionRejectionReason;

  /// No description provided for @contributionAchievementsSection.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get contributionAchievementsSection;

  /// No description provided for @contributionMyContributionsSection.
  ///
  /// In en, this message translates to:
  /// **'My Contributions'**
  String get contributionMyContributionsSection;

  /// No description provided for @contributionPhoneVerificationRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Verification Required'**
  String get contributionPhoneVerificationRequiredTitle;

  /// No description provided for @contributionPhoneVerificationRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'You must verify your phone number before adding a contribution. Go to your profile to complete verification.'**
  String get contributionPhoneVerificationRequiredBody;

  /// No description provided for @contributionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get contributionCompleted;

  /// No description provided for @contributionContributorLevel.
  ///
  /// In en, this message translates to:
  /// **'Contributor Level'**
  String get contributionContributorLevel;

  /// No description provided for @contributionActiveContributor.
  ///
  /// In en, this message translates to:
  /// **'Active Contributor'**
  String get contributionActiveContributor;

  /// No description provided for @contributionPointsUnit.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get contributionPointsUnit;

  /// No description provided for @contributionLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get contributionLikes;

  /// No description provided for @contributionShares.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get contributionShares;

  /// No description provided for @contributionQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get contributionQuality;

  /// No description provided for @contributionTopContributions.
  ///
  /// In en, this message translates to:
  /// **'Top contributions'**
  String get contributionTopContributions;

  /// No description provided for @contributionNoAchievements.
  ///
  /// In en, this message translates to:
  /// **'No achievements yet'**
  String get contributionNoAchievements;

  /// No description provided for @contributionNoContributions.
  ///
  /// In en, this message translates to:
  /// **'No contributions yet'**
  String get contributionNoContributions;

  /// No description provided for @contributionArchiveLinkMissing.
  ///
  /// In en, this message translates to:
  /// **'This contribution has no archive link'**
  String get contributionArchiveLinkMissing;

  /// No description provided for @contributionArchiveItemNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find that archive item.'**
  String get contributionArchiveItemNotFound;

  /// No description provided for @contributionPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get contributionPublished;

  /// No description provided for @contributionPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get contributionPending;

  /// No description provided for @contributionRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get contributionRejected;

  /// No description provided for @contributionWaitingForReview.
  ///
  /// In en, this message translates to:
  /// **'Waiting for admin review'**
  String get contributionWaitingForReview;

  /// No description provided for @contributionRejectedDefault.
  ///
  /// In en, this message translates to:
  /// **'Contribution was rejected'**
  String get contributionRejectedDefault;

  /// No description provided for @bookingAdultsAgeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'12+ years'**
  String get bookingAdultsAgeSubtitle;

  /// No description provided for @bookingChildrenAgeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Under 12 years'**
  String get bookingChildrenAgeSubtitle;

  /// No description provided for @bookingDateTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get bookingDateTimeTitle;

  /// No description provided for @bookingSelectDateError.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get bookingSelectDateError;

  /// No description provided for @bookingConfirmedMessage.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed!'**
  String get bookingConfirmedMessage;

  /// No description provided for @bookingChildFreeLine.
  ///
  /// In en, this message translates to:
  /// **'{count} Child (Free)'**
  String bookingChildFreeLine(int count);

  /// No description provided for @bookingChildPriceLine.
  ///
  /// In en, this message translates to:
  /// **'{count} Child x {price}'**
  String bookingChildPriceLine(int count, String price);

  /// No description provided for @bookingAdultPriceLine.
  ///
  /// In en, this message translates to:
  /// **'{count} Adults x {price}'**
  String bookingAdultPriceLine(int count, String price);

  /// No description provided for @bookingPeopleSummary.
  ///
  /// In en, this message translates to:
  /// **'{adults} Adults, {children} Children'**
  String bookingPeopleSummary(int adults, int children);

  /// No description provided for @bookingViewPendingGuide.
  ///
  /// In en, this message translates to:
  /// **'You have a new booking request that needs your review.'**
  String get bookingViewPendingGuide;

  /// No description provided for @bookingViewPendingTourist.
  ///
  /// In en, this message translates to:
  /// **'Your booking is currently under review. You will be notified once the status changes.'**
  String get bookingViewPendingTourist;

  /// No description provided for @bookingViewApprovedGuide.
  ///
  /// In en, this message translates to:
  /// **'You confirmed this booking. Contact the tourist using their details below.'**
  String get bookingViewApprovedGuide;

  /// No description provided for @bookingViewApprovedTourist.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed. You can contact the Guide using their details below.'**
  String get bookingViewApprovedTourist;

  /// No description provided for @bookingViewRejectedGuide.
  ///
  /// In en, this message translates to:
  /// **'You rejected this request.'**
  String get bookingViewRejectedGuide;

  /// No description provided for @bookingViewRejectedTourist.
  ///
  /// In en, this message translates to:
  /// **'Sorry, this booking was rejected. You can try another date or a different trip.'**
  String get bookingViewRejectedTourist;

  /// No description provided for @bookingViewCancelledGuide.
  ///
  /// In en, this message translates to:
  /// **'The tourist cancelled this request before your approval.'**
  String get bookingViewCancelledGuide;

  /// No description provided for @bookingViewCancelledTourist.
  ///
  /// In en, this message translates to:
  /// **'This booking has been cancelled.'**
  String get bookingViewCancelledTourist;

  /// No description provided for @bookingViewCompleted.
  ///
  /// In en, this message translates to:
  /// **'This trip has been completed successfully.'**
  String get bookingViewCompleted;

  /// No description provided for @bookingCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking?'**
  String get bookingCancelTitle;

  /// No description provided for @cancelBookingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking?'**
  String get cancelBookingConfirmation;

  /// No description provided for @bookingCancelNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get bookingCancelNo;

  /// No description provided for @bookingCancelYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get bookingCancelYes;

  /// No description provided for @bookingCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get bookingCancelButton;

  /// No description provided for @bookingTripDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get bookingTripDetailsTitle;

  /// No description provided for @bookingPriceSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Price Summary'**
  String get bookingPriceSummaryTitle;

  /// No description provided for @bookingTouristLabel.
  ///
  /// In en, this message translates to:
  /// **'Tourist'**
  String get bookingTouristLabel;

  /// No description provided for @bookingGuideLabel.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get bookingGuideLabel;

  /// No description provided for @bookingAvailableSoon.
  ///
  /// In en, this message translates to:
  /// **'Available soon'**
  String get bookingAvailableSoon;

  /// No description provided for @bookingPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get bookingPhoneLabel;

  /// No description provided for @bookingShownAfterConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Shown after confirmation'**
  String get bookingShownAfterConfirmation;

  /// No description provided for @tripDayAlreadyBookedError.
  ///
  /// In en, this message translates to:
  /// **'That date is already booked for this trip. Choose another date.'**
  String get tripDayAlreadyBookedError;

  /// No description provided for @tripTypeShared.
  ///
  /// In en, this message translates to:
  /// **'Shared Trip'**
  String get tripTypeShared;

  /// No description provided for @tripTypePrivate.
  ///
  /// In en, this message translates to:
  /// **'Private Trip'**
  String get tripTypePrivate;

  /// No description provided for @tripFullyBooked.
  ///
  /// In en, this message translates to:
  /// **'Fully Booked'**
  String get tripFullyBooked;

  /// No description provided for @addTripTypeSection.
  ///
  /// In en, this message translates to:
  /// **'Trip Type'**
  String get addTripTypeSection;

  /// No description provided for @addTripTypeShared.
  ///
  /// In en, this message translates to:
  /// **'Shared (multiple tourists)'**
  String get addTripTypeShared;

  /// No description provided for @addTripTypePrivate.
  ///
  /// In en, this message translates to:
  /// **'Private (one booking only)'**
  String get addTripTypePrivate;

  /// No description provided for @tripAdultsPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get tripAdultsPriceLabel;

  /// No description provided for @tripChildrenPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get tripChildrenPriceLabel;

  /// No description provided for @tripGuideUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No guide info available'**
  String get tripGuideUnavailable;

  /// No description provided for @tripReviewsCount.
  ///
  /// In en, this message translates to:
  /// **'({count} reviews)'**
  String tripReviewsCount(int count);

  /// No description provided for @tripCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get tripCardDetails;

  /// No description provided for @tripCardViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get tripCardViewDetails;

  /// No description provided for @tripAccessibilityWheelchairShort.
  ///
  /// In en, this message translates to:
  /// **'Accessible'**
  String get tripAccessibilityWheelchairShort;

  /// No description provided for @tripAccessibilityFamilyShort.
  ///
  /// In en, this message translates to:
  /// **'Family Friendly'**
  String get tripAccessibilityFamilyShort;

  /// No description provided for @tripManagementGuidesOnly.
  ///
  /// In en, this message translates to:
  /// **'This feature is for guides only'**
  String get tripManagementGuidesOnly;

  /// No description provided for @tripManagementVerifyPhoneFirst.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number first to add trips'**
  String get tripManagementVerifyPhoneFirst;

  /// No description provided for @tripManagementCompleteVerificationFirst.
  ///
  /// In en, this message translates to:
  /// **'Complete verification first to add trips'**
  String get tripManagementCompleteVerificationFirst;

  /// No description provided for @tripManagementCompleteProfileFirst.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile (bio & languages) to add trips'**
  String get tripManagementCompleteProfileFirst;

  /// No description provided for @tripStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get tripStatusApproved;

  /// No description provided for @tripStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get tripStatusRejected;

  /// No description provided for @tripStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get tripStatusPending;

  /// No description provided for @tripDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Trip'**
  String get tripDeleteTitle;

  /// No description provided for @tripDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?\nThis action cannot be undone.'**
  String tripDeleteConfirm(String title);

  /// No description provided for @tripDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Trip deleted successfully'**
  String get tripDeletedSuccess;

  /// No description provided for @tripAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Trip'**
  String get tripAddButton;

  /// No description provided for @tripNoTripsYet.
  ///
  /// In en, this message translates to:
  /// **'No trips yet'**
  String get tripNoTripsYet;

  /// No description provided for @tripTapToAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first trip'**
  String get tripTapToAddFirst;

  /// No description provided for @tripNoBookingsYet.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get tripNoBookingsYet;

  /// No description provided for @tripEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get tripEdit;

  /// No description provided for @tripDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tripDelete;

  /// No description provided for @addTripImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please add a trip image'**
  String get addTripImageRequired;

  /// No description provided for @addTripDailyTimesRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select the daily tour start and end time'**
  String get addTripDailyTimesRequired;

  /// No description provided for @addTripAvailabilityDatesRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select trip availability dates'**
  String get addTripAvailabilityDatesRequired;

  /// No description provided for @addTripUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Trip updated! It will be reviewed again by admin.'**
  String get addTripUpdatedSuccess;

  /// No description provided for @addTripSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Trip submitted! It will appear in the marketplace after admin approval.'**
  String get addTripSubmittedSuccess;

  /// No description provided for @addTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Trip'**
  String get addTripTitle;

  /// No description provided for @addTripAccountUnverifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account not verified'**
  String get addTripAccountUnverifiedTitle;

  /// No description provided for @addTripAccountUnverifiedBody.
  ///
  /// In en, this message translates to:
  /// **'You must verify your account before adding trips.\nComplete credential verification from your profile.'**
  String get addTripAccountUnverifiedBody;

  /// No description provided for @addTripEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Trip'**
  String get addTripEditTitle;

  /// No description provided for @addTripNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Trip'**
  String get addTripNewTitle;

  /// No description provided for @addTripAvailabilityPeriod.
  ///
  /// In en, this message translates to:
  /// **'Trip Availability Period'**
  String get addTripAvailabilityPeriod;

  /// No description provided for @addTripStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get addTripStartTime;

  /// No description provided for @addTripEndTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get addTripEndTime;

  /// No description provided for @addTripCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get addTripCity;

  /// No description provided for @addTripCredentialExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'License expired'**
  String get addTripCredentialExpiredTitle;

  /// No description provided for @addTripCredentialExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'You cannot add trips with an expired license.\nRenew your license and verify again to continue.'**
  String get addTripCredentialExpiredBody;

  /// No description provided for @addTripLicenseExpiringSoonWarning.
  ///
  /// In en, this message translates to:
  /// **'Your license will expire soon. Please renew it before the expiry date.'**
  String get addTripLicenseExpiringSoonWarning;

  /// No description provided for @addTripTimingDurationSection.
  ///
  /// In en, this message translates to:
  /// **'Timing and Duration'**
  String get addTripTimingDurationSection;

  /// No description provided for @addTripTitleSection.
  ///
  /// In en, this message translates to:
  /// **'Trip Title'**
  String get addTripTitleSection;

  /// No description provided for @addTripShortDescriptionSection.
  ///
  /// In en, this message translates to:
  /// **'Short Description'**
  String get addTripShortDescriptionSection;

  /// No description provided for @addTripDetailedDescriptionSection.
  ///
  /// In en, this message translates to:
  /// **'Detailed Description'**
  String get addTripDetailedDescriptionSection;

  /// No description provided for @addTripLocationSection.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get addTripLocationSection;

  /// No description provided for @addTripPricingCapacitySection.
  ///
  /// In en, this message translates to:
  /// **'Pricing and Capacity'**
  String get addTripPricingCapacitySection;

  /// No description provided for @addTripTripLanguagesSection.
  ///
  /// In en, this message translates to:
  /// **'Available Tour Languages'**
  String get addTripTripLanguagesSection;

  /// No description provided for @addTripImagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a trip image'**
  String get addTripImagePrompt;

  /// No description provided for @addTripChangeImage.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get addTripChangeImage;

  /// No description provided for @addTripPickAvailabilityPeriod.
  ///
  /// In en, this message translates to:
  /// **'Choose availability period'**
  String get addTripPickAvailabilityPeriod;

  /// No description provided for @addTripDailyStartEndHint.
  ///
  /// In en, this message translates to:
  /// **'Daily tour start and end time'**
  String get addTripDailyStartEndHint;

  /// No description provided for @addTripMultiDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-day trip'**
  String get addTripMultiDayTitle;

  /// No description provided for @addTripMultiDaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'One booking extends over more than one consecutive day, such as camping trips.'**
  String get addTripMultiDaySubtitle;

  /// No description provided for @addTripDurationDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of trip days'**
  String get addTripDurationDaysLabel;

  /// No description provided for @addTripDurationDaysMinError.
  ///
  /// In en, this message translates to:
  /// **'The number must be 2 or more'**
  String get addTripDurationDaysMinError;

  /// No description provided for @addTripTitleArLabel.
  ///
  /// In en, this message translates to:
  /// **'Title in Arabic'**
  String get addTripTitleArLabel;

  /// No description provided for @addTripTitleEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Title in English'**
  String get addTripTitleEnLabel;

  /// No description provided for @addTripShortDescArLabel.
  ///
  /// In en, this message translates to:
  /// **'Short description in Arabic'**
  String get addTripShortDescArLabel;

  /// No description provided for @addTripShortDescEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Short description in English'**
  String get addTripShortDescEnLabel;

  /// No description provided for @addTripDescArLabel.
  ///
  /// In en, this message translates to:
  /// **'Description in Arabic'**
  String get addTripDescArLabel;

  /// No description provided for @addTripDescEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Full description in English'**
  String get addTripDescEnLabel;

  /// No description provided for @addTripDescTemplateAr.
  ///
  /// In en, this message translates to:
  /// **'## ما تشمله الجولة\n- \n\n## الجدول الزمني\n- \n\n## ما يجب إحضاره\n- '**
  String get addTripDescTemplateAr;

  /// No description provided for @addTripDescTemplateEn.
  ///
  /// In en, this message translates to:
  /// **'## What\'s Included\n- \n\n## Schedule\n- \n\n## What to Bring\n- '**
  String get addTripDescTemplateEn;

  /// No description provided for @addTripCityRequired.
  ///
  /// In en, this message translates to:
  /// **'Please choose a city'**
  String get addTripCityRequired;

  /// No description provided for @addTripAdultPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Adult price'**
  String get addTripAdultPriceLabel;

  /// No description provided for @addTripAllowsChildren.
  ///
  /// In en, this message translates to:
  /// **'Children allowed'**
  String get addTripAllowsChildren;

  /// No description provided for @addTripChildPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Child price (0 = free)'**
  String get addTripChildPriceLabel;

  /// No description provided for @addTripChildrenCapacityNote.
  ///
  /// In en, this message translates to:
  /// **'Note: 2 children count as 1 adult seat in capacity calculation.'**
  String get addTripChildrenCapacityNote;

  /// No description provided for @addTripMaxCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Maximum capacity (adults count)'**
  String get addTripMaxCapacityLabel;

  /// No description provided for @addTripValidNumberError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get addTripValidNumberError;

  /// No description provided for @addTripValidIntegerError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid whole number'**
  String get addTripValidIntegerError;

  /// No description provided for @addTripRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get addTripRequiredField;

  /// No description provided for @addTripSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get addTripSaveChanges;

  /// No description provided for @addTripSubmitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for Review'**
  String get addTripSubmitForReview;

  /// No description provided for @addTripGuideName.
  ///
  /// In en, this message translates to:
  /// **'Guide: {name}'**
  String addTripGuideName(String name);

  /// No description provided for @addTripLicenseValue.
  ///
  /// In en, this message translates to:
  /// **'License: {value}'**
  String addTripLicenseValue(String value);

  /// No description provided for @addTripCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company: {name}'**
  String addTripCompanyName(String name);

  /// No description provided for @addTripTourismLicenseValue.
  ///
  /// In en, this message translates to:
  /// **'Tourism license: {value}'**
  String addTripTourismLicenseValue(String value);

  /// No description provided for @addTripBackToProfile.
  ///
  /// In en, this message translates to:
  /// **'Back to profile'**
  String get addTripBackToProfile;

  /// No description provided for @bookingRejectedExploreMore.
  ///
  /// In en, this message translates to:
  /// **'You can go back and explore other trips or choose a different date.'**
  String get bookingRejectedExploreMore;

  /// No description provided for @tripManagementTouristHint.
  ///
  /// In en, this message translates to:
  /// **'View and manage your bookings from the Bookings tab in your profile'**
  String get tripManagementTouristHint;

  /// No description provided for @rawiImageQuestion.
  ///
  /// In en, this message translates to:
  /// **'Rawi, what does this image represent?'**
  String get rawiImageQuestion;

  /// No description provided for @rawiGeneralCouncil.
  ///
  /// In en, this message translates to:
  /// **'Rawi General Council'**
  String get rawiGeneralCouncil;

  /// No description provided for @rawiStoryAboutRegion.
  ///
  /// In en, this message translates to:
  /// **'Story about {region}'**
  String rawiStoryAboutRegion(String region);

  /// No description provided for @rawiWelcomeGeneral.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Rawi\'s Council.. Which region would you like to explore today?'**
  String get rawiWelcomeGeneral;

  /// No description provided for @rawiPickRegionStart.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Rawi\'s Council.. Pick a region to start:'**
  String get rawiPickRegionStart;

  /// No description provided for @rawiAskHint.
  ///
  /// In en, this message translates to:
  /// **'Ask Rawi...'**
  String get rawiAskHint;

  /// No description provided for @rawiTyping.
  ///
  /// In en, this message translates to:
  /// **'Rawi is typing...'**
  String get rawiTyping;

  /// No description provided for @rawiAttachmentFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get rawiAttachmentFile;

  /// No description provided for @rawiAttachmentCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get rawiAttachmentCamera;

  /// No description provided for @rawiAttachmentImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get rawiAttachmentImage;

  /// No description provided for @rawiGeneralCouncilTitle.
  ///
  /// In en, this message translates to:
  /// **'General Council'**
  String get rawiGeneralCouncilTitle;

  /// No description provided for @rawiUserLabel.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get rawiUserLabel;

  /// No description provided for @rawiBotLabel.
  ///
  /// In en, this message translates to:
  /// **'Rawi'**
  String get rawiBotLabel;

  /// No description provided for @rawiHistoryHeader.
  ///
  /// In en, this message translates to:
  /// **'Previous Conversation History:'**
  String get rawiHistoryHeader;

  /// No description provided for @rawiGeneralSystemInstruction.
  ///
  /// In en, this message translates to:
  /// **'You are Rawi, a general Saudi cultural assistant. Reply in the user\'s language and be friendly.'**
  String get rawiGeneralSystemInstruction;

  /// No description provided for @adminUsersTab.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsersTab;

  /// No description provided for @adminGuidesTab.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get adminGuidesTab;

  /// No description provided for @adminTripsTab.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get adminTripsTab;

  /// No description provided for @adminSearchUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get adminSearchUsersHint;

  /// No description provided for @adminNoUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get adminNoUsersFound;

  /// No description provided for @adminNoResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String adminNoResultsFor(String query);

  /// No description provided for @adminNoGuidesForStatus.
  ///
  /// In en, this message translates to:
  /// **'No {status} guides'**
  String adminNoGuidesForStatus(String status);

  /// No description provided for @adminStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminStatusPending;

  /// No description provided for @adminStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get adminStatusApproved;

  /// No description provided for @adminStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get adminStatusRejected;

  /// No description provided for @adminStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get adminStatusExpired;

  /// No description provided for @adminRoleTutor.
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get adminRoleTutor;

  /// No description provided for @adminRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminRoleAdmin;

  /// No description provided for @adminRoleTourist.
  ///
  /// In en, this message translates to:
  /// **'Tourist'**
  String get adminRoleTourist;

  /// No description provided for @adminGuideTypeIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get adminGuideTypeIndividual;

  /// No description provided for @adminGuideTypeCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get adminGuideTypeCompany;

  /// No description provided for @adminNoBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get adminNoBookings;

  /// No description provided for @adminBookingPeopleSummary.
  ///
  /// In en, this message translates to:
  /// **'{adults} adults, {children} children'**
  String adminBookingPeopleSummary(int adults, int children);

  /// No description provided for @adminTouristId.
  ///
  /// In en, this message translates to:
  /// **'Tourist: {id}'**
  String adminTouristId(String id);

  /// No description provided for @adminTutorId.
  ///
  /// In en, this message translates to:
  /// **'Tutor: {id}'**
  String adminTutorId(String id);

  /// No description provided for @adminNoTripsPending.
  ///
  /// In en, this message translates to:
  /// **'No trips pending approval'**
  String get adminNoTripsPending;

  /// No description provided for @adminGuideLabel.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get adminGuideLabel;

  /// No description provided for @adminCompanyLabel.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get adminCompanyLabel;

  /// No description provided for @adminPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get adminPriceLabel;

  /// No description provided for @adminLicenseLabel.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get adminLicenseLabel;

  /// No description provided for @adminTutorIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Tutor ID'**
  String get adminTutorIdLabel;

  /// No description provided for @adminTripRejected.
  ///
  /// In en, this message translates to:
  /// **'Trip rejected'**
  String get adminTripRejected;

  /// No description provided for @adminTripApproved.
  ///
  /// In en, this message translates to:
  /// **'Trip approved'**
  String get adminTripApproved;

  /// No description provided for @adminReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminReject;

  /// No description provided for @adminApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminApprove;

  /// No description provided for @adminEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminEdit;

  /// No description provided for @adminDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminDelete;

  /// No description provided for @adminCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminCancel;

  /// No description provided for @adminAddAttraction.
  ///
  /// In en, this message translates to:
  /// **'Add Attraction'**
  String get adminAddAttraction;

  /// No description provided for @adminEditAttraction.
  ///
  /// In en, this message translates to:
  /// **'Edit Attraction'**
  String get adminEditAttraction;

  /// No description provided for @adminNoAttractions.
  ///
  /// In en, this message translates to:
  /// **'No attractions yet. Tap + to add one.'**
  String get adminNoAttractions;

  /// No description provided for @adminNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No events yet. Tap + to add one.'**
  String get adminNoEvents;

  /// No description provided for @adminDeleteAttraction.
  ///
  /// In en, this message translates to:
  /// **'Delete Attraction'**
  String get adminDeleteAttraction;

  /// No description provided for @adminDeleteAttractionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String adminDeleteAttractionConfirm(String name);

  /// No description provided for @adminAttractionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Attraction deleted'**
  String get adminAttractionDeleted;

  /// No description provided for @adminAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get adminAddItem;

  /// No description provided for @adminEditArchiveItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Archive Item'**
  String get adminEditArchiveItem;

  /// No description provided for @adminAddArchiveItem.
  ///
  /// In en, this message translates to:
  /// **'Add Archive Item'**
  String get adminAddArchiveItem;

  /// No description provided for @adminUpdateItem.
  ///
  /// In en, this message translates to:
  /// **'Update Item'**
  String get adminUpdateItem;

  /// No description provided for @adminAddToArchive.
  ///
  /// In en, this message translates to:
  /// **'Add to Archive'**
  String get adminAddToArchive;

  /// No description provided for @adminItemUpdated.
  ///
  /// In en, this message translates to:
  /// **'Item updated successfully'**
  String get adminItemUpdated;

  /// No description provided for @adminCulturalItemAdded.
  ///
  /// In en, this message translates to:
  /// **'Cultural item added successfully'**
  String get adminCulturalItemAdded;

  /// No description provided for @adminMapCoordinatesOptional.
  ///
  /// In en, this message translates to:
  /// **'Map Coordinates (optional)'**
  String get adminMapCoordinatesOptional;

  /// No description provided for @adminLatitudeExample.
  ///
  /// In en, this message translates to:
  /// **'Latitude (e.g. 24.68)'**
  String get adminLatitudeExample;

  /// No description provided for @adminLongitudeExample.
  ///
  /// In en, this message translates to:
  /// **'Longitude (e.g. 46.72)'**
  String get adminLongitudeExample;

  /// No description provided for @adminNoCulturalItems.
  ///
  /// In en, this message translates to:
  /// **'No cultural items yet'**
  String get adminNoCulturalItems;

  /// No description provided for @adminDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get adminDeleteItem;

  /// No description provided for @adminDeleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String adminDeleteItemConfirm(String name);

  /// No description provided for @adminItemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get adminItemDeleted;

  /// No description provided for @adminByContributor.
  ///
  /// In en, this message translates to:
  /// **'By: {name}'**
  String adminByContributor(String name);

  /// No description provided for @adminSelectRegion.
  ///
  /// In en, this message translates to:
  /// **'Please select a region'**
  String get adminSelectRegion;

  /// No description provided for @adminSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get adminSelectCity;

  /// No description provided for @adminSelectMainImage.
  ///
  /// In en, this message translates to:
  /// **'Please select a main image'**
  String get adminSelectMainImage;

  /// No description provided for @adminCoordinatesRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter coordinates (lat & lng)'**
  String get adminCoordinatesRequired;

  /// No description provided for @adminAttractionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Attraction updated!'**
  String get adminAttractionUpdated;

  /// No description provided for @adminAttractionAdded.
  ///
  /// In en, this message translates to:
  /// **'Attraction added! AI tagging will run shortly.'**
  String get adminAttractionAdded;

  /// No description provided for @adminMainImage.
  ///
  /// In en, this message translates to:
  /// **'Main Image *'**
  String get adminMainImage;

  /// No description provided for @adminNameDescription.
  ///
  /// In en, this message translates to:
  /// **'Name & Description'**
  String get adminNameDescription;

  /// No description provided for @adminClassification.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get adminClassification;

  /// No description provided for @adminNameArabic.
  ///
  /// In en, this message translates to:
  /// **'Name (Arabic)'**
  String get adminNameArabic;

  /// No description provided for @adminNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get adminNameEnglish;

  /// No description provided for @adminNameArabicHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the Arabic name'**
  String get adminNameArabicHint;

  /// No description provided for @adminNameEnglishHint.
  ///
  /// In en, this message translates to:
  /// **'Enter attraction name in English'**
  String get adminNameEnglishHint;

  /// No description provided for @adminDescriptionArabic.
  ///
  /// In en, this message translates to:
  /// **'Description (Arabic)'**
  String get adminDescriptionArabic;

  /// No description provided for @adminDescriptionEnglish.
  ///
  /// In en, this message translates to:
  /// **'Description (English)'**
  String get adminDescriptionEnglish;

  /// No description provided for @adminDescriptionArabicHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the Arabic description'**
  String get adminDescriptionArabicHint;

  /// No description provided for @adminDescriptionEnglishHint.
  ///
  /// In en, this message translates to:
  /// **'Enter description in English'**
  String get adminDescriptionEnglishHint;

  /// No description provided for @adminLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get adminLocation;

  /// No description provided for @adminCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get adminCategory;

  /// No description provided for @adminRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get adminRegion;

  /// No description provided for @adminCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get adminCity;

  /// No description provided for @adminSelectRegionFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a region first'**
  String get adminSelectRegionFirst;

  /// No description provided for @adminAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get adminAddress;

  /// No description provided for @adminAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Full address'**
  String get adminAddressHint;

  /// No description provided for @adminMapCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Map Coordinates'**
  String get adminMapCoordinates;

  /// No description provided for @adminLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get adminLatitude;

  /// No description provided for @adminLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get adminLongitude;

  /// No description provided for @adminHoursFees.
  ///
  /// In en, this message translates to:
  /// **'Hours & Fees'**
  String get adminHoursFees;

  /// No description provided for @adminAlwaysOpen.
  ///
  /// In en, this message translates to:
  /// **'Always Open (24/7)'**
  String get adminAlwaysOpen;

  /// No description provided for @adminOpeningHoursArabic.
  ///
  /// In en, this message translates to:
  /// **'Opening Hours (Arabic)'**
  String get adminOpeningHoursArabic;

  /// No description provided for @adminOpeningHoursEnglish.
  ///
  /// In en, this message translates to:
  /// **'Opening Hours (English)'**
  String get adminOpeningHoursEnglish;

  /// No description provided for @adminOpeningHoursArabicHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 9 AM - 10 PM'**
  String get adminOpeningHoursArabicHint;

  /// No description provided for @adminOpeningHoursEnglishHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 9 AM - 10 PM'**
  String get adminOpeningHoursEnglishHint;

  /// No description provided for @adminEntryFee.
  ///
  /// In en, this message translates to:
  /// **'Entry Fee'**
  String get adminEntryFee;

  /// No description provided for @adminEntryFeeSar.
  ///
  /// In en, this message translates to:
  /// **'Entry Fee (SAR) - 0 means free'**
  String get adminEntryFeeSar;

  /// No description provided for @adminFreeFeeHint.
  ///
  /// In en, this message translates to:
  /// **'0 = Free'**
  String get adminFreeFeeHint;

  /// No description provided for @adminValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get adminValidNumber;

  /// No description provided for @adminGalleryImages.
  ///
  /// In en, this message translates to:
  /// **'Gallery Images'**
  String get adminGalleryImages;

  /// No description provided for @adminNoGalleryImages.
  ///
  /// In en, this message translates to:
  /// **'No gallery images added yet.'**
  String get adminNoGalleryImages;

  /// No description provided for @adminMaxGalleryImages.
  ///
  /// In en, this message translates to:
  /// **'Maximum 8 images reached.'**
  String get adminMaxGalleryImages;

  /// No description provided for @adminVideoOptional.
  ///
  /// In en, this message translates to:
  /// **'Video (Optional)'**
  String get adminVideoOptional;

  /// No description provided for @adminOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get adminOptional;

  /// No description provided for @adminTicketBookingUrl.
  ///
  /// In en, this message translates to:
  /// **'Ticket Booking URL'**
  String get adminTicketBookingUrl;

  /// No description provided for @adminUpdateAttraction.
  ///
  /// In en, this message translates to:
  /// **'Update Attraction'**
  String get adminUpdateAttraction;

  /// No description provided for @adminTapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get adminTapToChange;

  /// No description provided for @adminTapPickMainImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick main image'**
  String get adminTapPickMainImage;

  /// No description provided for @adminVideoSaved.
  ///
  /// In en, this message translates to:
  /// **'Video saved'**
  String get adminVideoSaved;

  /// No description provided for @adminTapPickVideo.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick a video'**
  String get adminTapPickVideo;

  /// No description provided for @adminAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get adminAdd;

  /// No description provided for @adminImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get adminImage;

  /// No description provided for @adminEventAdded.
  ///
  /// In en, this message translates to:
  /// **'Event added successfully'**
  String get adminEventAdded;

  /// No description provided for @adminSelectEventDate.
  ///
  /// In en, this message translates to:
  /// **'Please select an event date'**
  String get adminSelectEventDate;

  /// No description provided for @adminPickImage.
  ///
  /// In en, this message translates to:
  /// **'Please pick an image'**
  String get adminPickImage;

  /// No description provided for @adminEventCoordinatesRequired.
  ///
  /// In en, this message translates to:
  /// **'Latitude and longitude are required for events'**
  String get adminEventCoordinatesRequired;

  /// No description provided for @adminImageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t upload the image. Please try again.'**
  String get adminImageUploadFailed;

  /// No description provided for @adminTitleArabic.
  ///
  /// In en, this message translates to:
  /// **'Title (Arabic)'**
  String get adminTitleArabic;

  /// No description provided for @adminTitleEnglish.
  ///
  /// In en, this message translates to:
  /// **'Title (English)'**
  String get adminTitleEnglish;

  /// No description provided for @adminTitleArabicHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Arabic title'**
  String get adminTitleArabicHint;

  /// No description provided for @adminTitleEnglishHint.
  ///
  /// In en, this message translates to:
  /// **'Enter English title'**
  String get adminTitleEnglishHint;

  /// No description provided for @adminEventDate.
  ///
  /// In en, this message translates to:
  /// **'Event Date'**
  String get adminEventDate;

  /// No description provided for @adminSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get adminSelectDate;

  /// No description provided for @adminEndDateOptional.
  ///
  /// In en, this message translates to:
  /// **'End Date (optional)'**
  String get adminEndDateOptional;

  /// No description provided for @adminSelectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select end date (leave empty for single-day)'**
  String get adminSelectEndDate;

  /// No description provided for @adminTimeArabic.
  ///
  /// In en, this message translates to:
  /// **'Time (Arabic)'**
  String get adminTimeArabic;

  /// No description provided for @adminTimeEnglish.
  ///
  /// In en, this message translates to:
  /// **'Time (English)'**
  String get adminTimeEnglish;

  /// No description provided for @adminEventType.
  ///
  /// In en, this message translates to:
  /// **'Event Type'**
  String get adminEventType;

  /// No description provided for @adminAdmission.
  ///
  /// In en, this message translates to:
  /// **'Admission'**
  String get adminAdmission;

  /// No description provided for @adminFreeEntry.
  ///
  /// In en, this message translates to:
  /// **'Free Entry'**
  String get adminFreeEntry;

  /// No description provided for @adminPaidEntry.
  ///
  /// In en, this message translates to:
  /// **'Paid Entry'**
  String get adminPaidEntry;

  /// No description provided for @adminTicketUrl.
  ///
  /// In en, this message translates to:
  /// **'Ticket URL'**
  String get adminTicketUrl;

  /// No description provided for @adminAddEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get adminAddEvent;

  /// No description provided for @adminMigrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Content Migration'**
  String get adminMigrationTitle;

  /// No description provided for @adminMigrateAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Migrate All Content'**
  String get adminMigrateAllTitle;

  /// No description provided for @adminMigrateAllBody.
  ///
  /// In en, this message translates to:
  /// **'This will classify all attractions, trips, events, and cultural items using Gemini AI. Takes 3-7 minutes. Make sure you have a stable internet connection. Continue?'**
  String get adminMigrateAllBody;

  /// No description provided for @adminRunMigration.
  ///
  /// In en, this message translates to:
  /// **'Run Migration'**
  String get adminRunMigration;

  /// No description provided for @adminMigrationHeading.
  ///
  /// In en, this message translates to:
  /// **'AI Content Classification'**
  String get adminMigrationHeading;

  /// No description provided for @adminMigrationDescription.
  ///
  /// In en, this message translates to:
  /// **'Generates interestIds and embedding vectors for all attractions, trips, events, and cultural items.'**
  String get adminMigrationDescription;

  /// No description provided for @adminMigratingProgress.
  ///
  /// In en, this message translates to:
  /// **'Migrating... (3-7 minutes)'**
  String get adminMigratingProgress;

  /// No description provided for @adminEmbeddingProgress.
  ///
  /// In en, this message translates to:
  /// **'Generating embeddings...'**
  String get adminEmbeddingProgress;

  /// No description provided for @adminGenerateMissingEmbeddings.
  ///
  /// In en, this message translates to:
  /// **'Generate missing embeddings'**
  String get adminGenerateMissingEmbeddings;

  /// No description provided for @adminMigrationComplete.
  ///
  /// In en, this message translates to:
  /// **'Migration Complete'**
  String get adminMigrationComplete;

  /// No description provided for @adminMigrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Migration couldn’t be completed.'**
  String get adminMigrationFailed;

  /// No description provided for @adminOperationComplete.
  ///
  /// In en, this message translates to:
  /// **'Operation complete'**
  String get adminOperationComplete;

  /// No description provided for @adminEmbeddingStatsLine.
  ///
  /// In en, this message translates to:
  /// **'{collection}: processed {processed} | skipped {skipped} | failed {failed}'**
  String adminEmbeddingStatsLine(
      String collection, String processed, String skipped, String failed);

  /// No description provided for @adminDocumentShapes.
  ///
  /// In en, this message translates to:
  /// **'Document Shapes'**
  String get adminDocumentShapes;

  /// No description provided for @adminInspectDataShape.
  ///
  /// In en, this message translates to:
  /// **'Inspect data shape'**
  String get adminInspectDataShape;

  /// No description provided for @adminTranslationFailed.
  ///
  /// In en, this message translates to:
  /// **'{message, select, _ {We couldn’t translate this content. Please try again.} other {We couldn’t translate this content. Please try again.}}'**
  String adminTranslationFailed(String message);

  /// No description provided for @adminApproveContribution.
  ///
  /// In en, this message translates to:
  /// **'Approve Contribution'**
  String get adminApproveContribution;

  /// No description provided for @adminApproveContributionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Approve \"{title}\" by {name}?\n\nThis will award {points} points to the tourist.'**
  String adminApproveContributionConfirm(String title, String name, int points);

  /// No description provided for @adminFillEnglishBeforeApprove.
  ///
  /// In en, this message translates to:
  /// **'Please fill English title and description before approving.'**
  String get adminFillEnglishBeforeApprove;

  /// No description provided for @adminFillArabicBeforeApprove.
  ///
  /// In en, this message translates to:
  /// **'Please fill Arabic title and description before approving.'**
  String get adminFillArabicBeforeApprove;

  /// No description provided for @adminContributionApproved.
  ///
  /// In en, this message translates to:
  /// **'Contribution approved successfully'**
  String get adminContributionApproved;

  /// No description provided for @adminRejectContribution.
  ///
  /// In en, this message translates to:
  /// **'Reject Contribution'**
  String get adminRejectContribution;

  /// No description provided for @adminRejectContributionHelp.
  ///
  /// In en, this message translates to:
  /// **'Provide a reason so the tourist knows what to improve.'**
  String get adminRejectContributionHelp;

  /// No description provided for @adminRejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Image quality is too low, please resubmit with a clearer photo.'**
  String get adminRejectReasonHint;

  /// No description provided for @adminPleaseEnterReason.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason.'**
  String get adminPleaseEnterReason;

  /// No description provided for @adminContributionRejected.
  ///
  /// In en, this message translates to:
  /// **'Contribution rejected'**
  String get adminContributionRejected;

  /// No description provided for @adminReviewContribution.
  ///
  /// In en, this message translates to:
  /// **'Review Contribution'**
  String get adminReviewContribution;

  /// No description provided for @adminVideoContribution.
  ///
  /// In en, this message translates to:
  /// **'Video Contribution'**
  String get adminVideoContribution;

  /// No description provided for @adminTourist.
  ///
  /// In en, this message translates to:
  /// **'Tourist'**
  String get adminTourist;

  /// No description provided for @adminName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminName;

  /// No description provided for @adminEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminEmail;

  /// No description provided for @adminSubmissionDetails.
  ///
  /// In en, this message translates to:
  /// **'Submission Details'**
  String get adminSubmissionDetails;

  /// No description provided for @adminSubmittedIn.
  ///
  /// In en, this message translates to:
  /// **'Submitted in'**
  String get adminSubmittedIn;

  /// No description provided for @adminDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get adminDate;

  /// No description provided for @adminRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason'**
  String get adminRejectionReason;

  /// No description provided for @adminArabicByTourist.
  ///
  /// In en, this message translates to:
  /// **'Arabic (by tourist)'**
  String get adminArabicByTourist;

  /// No description provided for @adminEnglishByTourist.
  ///
  /// In en, this message translates to:
  /// **'English (by tourist)'**
  String get adminEnglishByTourist;

  /// No description provided for @adminEnglishAdminFills.
  ///
  /// In en, this message translates to:
  /// **'English (admin fills)'**
  String get adminEnglishAdminFills;

  /// No description provided for @adminArabicAdminFills.
  ///
  /// In en, this message translates to:
  /// **'Arabic (admin fills)'**
  String get adminArabicAdminFills;

  /// No description provided for @adminTranslating.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get adminTranslating;

  /// No description provided for @adminAutoTranslate.
  ///
  /// In en, this message translates to:
  /// **'Auto-translate with AI'**
  String get adminAutoTranslate;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get adminTitle;

  /// No description provided for @adminDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get adminDescription;

  /// No description provided for @adminVerifyGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Guide'**
  String get adminVerifyGuideTitle;

  /// No description provided for @adminVerifyGuideConfirm.
  ///
  /// In en, this message translates to:
  /// **'Verify \"{name}\"?\nThey can add trips until their license expires.'**
  String adminVerifyGuideConfirm(String name);

  /// No description provided for @adminVerifyGuide.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get adminVerifyGuide;

  /// No description provided for @adminGuideVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Guide verified successfully'**
  String get adminGuideVerifiedSuccess;

  /// No description provided for @adminRejectRequest.
  ///
  /// In en, this message translates to:
  /// **'Reject request'**
  String get adminRejectRequest;

  /// No description provided for @adminRejectRequestHelp.
  ///
  /// In en, this message translates to:
  /// **'This will be shown to the guide so they know what needs correction.'**
  String get adminRejectRequestHelp;

  /// No description provided for @adminRejectRequestHint.
  ///
  /// In en, this message translates to:
  /// **'Example: The license expiry date is incorrect'**
  String get adminRejectRequestHint;

  /// No description provided for @adminRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected'**
  String get adminRequestRejected;

  /// No description provided for @adminReviewVerification.
  ///
  /// In en, this message translates to:
  /// **'Review Verification'**
  String get adminReviewVerification;

  /// No description provided for @adminLicenseData.
  ///
  /// In en, this message translates to:
  /// **'License Data'**
  String get adminLicenseData;

  /// No description provided for @adminCompanyData.
  ///
  /// In en, this message translates to:
  /// **'Company Data'**
  String get adminCompanyData;

  /// No description provided for @adminLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get adminLicenseNumber;

  /// No description provided for @adminLicenseExpiry.
  ///
  /// In en, this message translates to:
  /// **'License Expiry Date'**
  String get adminLicenseExpiry;

  /// No description provided for @adminCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get adminCompanyName;

  /// No description provided for @adminCommercialRegistration.
  ///
  /// In en, this message translates to:
  /// **'Commercial Registration No.'**
  String get adminCommercialRegistration;

  /// No description provided for @adminCommercialRegistrationExpiry.
  ///
  /// In en, this message translates to:
  /// **'Commercial Registration Expiry'**
  String get adminCommercialRegistrationExpiry;

  /// No description provided for @adminTourismActivityLicense.
  ///
  /// In en, this message translates to:
  /// **'Tourism Activity License'**
  String get adminTourismActivityLicense;

  /// No description provided for @adminTourismLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'Tourism License No.'**
  String get adminTourismLicenseNumber;

  /// No description provided for @adminTourismLicenseExpiry.
  ///
  /// In en, this message translates to:
  /// **'Tourism License Expiry'**
  String get adminTourismLicenseExpiry;

  /// No description provided for @adminExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get adminExpiringSoon;

  /// No description provided for @adminRejectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Rejection Details'**
  String get adminRejectionDetails;

  /// No description provided for @adminVerificationDetails.
  ///
  /// In en, this message translates to:
  /// **'Verification Details'**
  String get adminVerificationDetails;

  /// No description provided for @adminBy.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get adminBy;

  /// No description provided for @adminVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get adminVerify;

  /// No description provided for @adminRevokeVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke Verification'**
  String get adminRevokeVerificationTitle;

  /// No description provided for @adminRevokeVerificationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Revoke verification for \"{name}\"? They will need to resubmit documents.'**
  String adminRevokeVerificationConfirm(String name);

  /// No description provided for @adminRevokeVerification.
  ///
  /// In en, this message translates to:
  /// **'Revoke Verification'**
  String get adminRevokeVerification;

  /// No description provided for @adminVerificationRevoked.
  ///
  /// In en, this message translates to:
  /// **'Verification revoked'**
  String get adminVerificationRevoked;

  /// No description provided for @adminVerificationRevokedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification revoked successfully'**
  String get adminVerificationRevokedSuccess;
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

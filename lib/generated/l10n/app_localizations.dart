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
  /// **'Please allow microphone access in settings'**
  String get rawiMicPermissionDenied;

  /// No description provided for @rawiMicError.
  ///
  /// In en, this message translates to:
  /// **'Could not start voice recognition'**
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

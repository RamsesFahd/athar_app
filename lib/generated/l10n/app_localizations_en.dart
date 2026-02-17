// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get splashTitle => 'Welcome To Athar';

  @override
  String get splashSubtitle => 'Timeless heritage, modern vision';

  @override
  String get signInWelcome => 'Welcome To Athar';

  @override
  String get signInSubtitle => 'Discover heritage with a modern vision';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get continueButton => 'Continue';

  @override
  String get orDivider => 'OR';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUpLink => 'Sign Up';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get emailHint => 'example@mail.com';

  @override
  String get passwordHint => '••••••••';

  @override
  String get signUpTitle => 'Join Athar';

  @override
  String get signUpSubtitle => 'Be part of our cultural journey';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get nameHint => 'Enter your name';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signInLink => 'Sign In';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordSubtitle =>
      'Enter your registered email address to receive a password reset link';

  @override
  String get sendLinkButton => 'Send Link';

  @override
  String get emailSentTitle => 'Email Sent!';

  @override
  String get emailSentMessage => 'Check your email and follow the instructions';

  @override
  String get backToSignInButton => 'Back to Sign In';

  @override
  String get backToSignUpButton => 'Back to Sign Up';

  @override
  String get verifyEmailTitle => 'Verify Your Email';

  @override
  String get verifyEmailSubtitle => 'Enter the code sent to your email';

  @override
  String get verifyEmailInfoText => 'We have sent a verification code to:';

  @override
  String get verifyButton => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendCodeInSeconds(int seconds) {
    return 'Resend code in $seconds seconds';
  }

  @override
  String get errorEmailAlreadyInUse => 'This email is already in use.';

  @override
  String get errorInvalidEmail => 'The email address is invalid.';

  @override
  String get errorUserNotFound => 'No user found with this email.';

  @override
  String get errorWrongPassword => 'Incorrect password. Please try again.';

  @override
  String get errorWeakPassword => 'The password is too weak.';

  @override
  String get errorUnexpected =>
      'An unexpected error occurred. Please try again later.';

  @override
  String get fillAllFieldsError => 'Please fill in all fields';

  @override
  String get passwordsDoNotMatchError =>
      'Passwords do not match. Please try again.';

  @override
  String get guestUser => 'Guest';

  @override
  String get errorEmailNotVerified =>
      'Please verify your email via the link sent to you.';

  @override
  String get homeLabel => 'Home';

  @override
  String get mapLabel => 'Map';

  @override
  String get assistantLabel => 'AI Chat';

  @override
  String get calendarLabel => 'Calendar';

  @override
  String get profileLabel => 'Profile';
}

// App navigation routes
import 'package:flutter/material.dart';
import 'package:athar_app/features/auth/screens/signin_screen.dart';
import 'package:athar_app/features/auth/screens/signup_screen.dart';
import 'package:athar_app/features/auth/screens/forgot_password_screen.dart';
import 'package:athar_app/features/auth/screens/splash_screen.dart';
import 'package:athar_app/features/auth/screens/verify_email_screen.dart';
import 'package:athar_app/core/widgets/navigation_container.dart';

class AppRoutes {
  static const String splash = '/';
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String verifyEmail = '/verify-email';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      signIn: (context) => const SignInScreen(),
      signUp: (context) => const SignUpScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      verifyEmail: (context) => const VerifyEmailScreen(),
      home: (context) => const NavigationContainer(),
    };
  }
}

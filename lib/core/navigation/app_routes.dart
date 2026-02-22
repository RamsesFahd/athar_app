// App navigation routes
import 'package:athar_app/core/widgets/navigation_container.dart';
import 'package:athar_app/features/cultural_archive/screens/cultural_archive.dart';
import 'package:flutter/material.dart';
import 'package:athar_app/features/auth/screens/signin_screen.dart';
import 'package:athar_app/features/auth/screens/signup_screen.dart';
import 'package:athar_app/features/auth/screens/forgot_password_screen.dart';
import 'package:athar_app/features/auth/screens/splash_screen.dart';
import 'package:athar_app/features/auth/screens/verify_email_screen.dart';
import 'package:athar_app/features/cultural_archive/widgets/cultural_item_details.dart';
import 'package:athar_app/core/models/user/cultural/cultural_item_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String verifyEmail = '/verify-email';
  static const String culturalArchive = '/cultural-archive';
  static const String culturalDetails = '/cultural-details';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      signIn: (context) => const SignInScreen(),
      signUp: (context) => const SignUpScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      verifyEmail: (context) => const VerifyEmailScreen(),

      // ✨ the main navigation container that holds the bottom navigation and the main screens of the app, we will navigate to this screen after successful login or if the user is already logged in when opening the app
      home: (context) => const NavigationContainer(),

      culturalArchive: (context) => const CulturalArchive(),

      culturalDetails: (context) {
        final CulturalItemModel item =
            ModalRoute.of(context)!.settings.arguments as CulturalItemModel;
        return CulturalItemDetails(item: item);
      },
    };
  }
}

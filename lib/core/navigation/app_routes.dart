// App navigation routes
import 'package:athar_app/core/widgets/navigation_container.dart';
import 'package:athar_app/features/admin/screens/admin_navigation_container.dart';
import 'package:athar_app/features/cultural_archive/screens/cultural_archive.dart';
import 'package:flutter/material.dart';
import 'package:athar_app/features/auth/screens/signin_screen.dart';
import 'package:athar_app/features/auth/screens/signup_screen.dart';
import 'package:athar_app/features/auth/screens/forgot_password_screen.dart';
import 'package:athar_app/features/auth/screens/splash_screen.dart';
import 'package:athar_app/features/auth/screens/verify_email_screen.dart';
import 'package:athar_app/features/auth/screens/privacy_policy_screen.dart';
import 'package:athar_app/features/cultural_archive/widgets/cultural_item_details.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/features/historical_chat/screens/rawi_landing_screen.dart';
import 'package:athar_app/features/auth/screens/google_role_selection_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String admin = '/admin';
  static const String verifyEmail = '/verify-email';
  static const String googleRoleSelection = '/google-role-selection';
  static const String culturalArchive = '/cultural-archive';
  static const String culturalDetails = '/cultural-details';
  static const String historicalChat = '/historical-chat';
  static const String privacyPolicy = '/privacy-policy';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      signIn: (context) => const SignInScreen(),
      signUp: (context) => const SignUpScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      verifyEmail: (context) => const VerifyEmailScreen(),
      googleRoleSelection: (context) => const GoogleRoleSelectionScreen(),
      privacyPolicy: (context) => const PrivacyPolicyScreen(),

      home: (context) => const NavigationContainer(),
      admin: (context) => const AdminNavigationContainer(),

      culturalArchive: (context) => const CulturalArchive(),

      historicalChat: (context) => const RawiLandingScreen(),

      culturalDetails: (context) {
        final CulturalItemModel item =
            ModalRoute.of(context)!.settings.arguments as CulturalItemModel;
        return CulturalItemDetails(item: item);
      },
    };
  }
}
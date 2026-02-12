// App navigation routes
import 'package:flutter/material.dart';

import '../../features/auth/screens/signin_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/splash_screen.dart';

class AppRoutes {
  // 2. تعريف أسماء المسارات
  static const String splash = '/';           // السبلاتش هي نقطة البداية
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      signIn: (context) => const SignInScreen(),
      signUp: (context) => const SignUpScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      // home: (context) => const HomeScreen(), 
    };
  }
}
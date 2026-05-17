import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/navigation/app_routes.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/auth_notifier.dart';
import 'package:athar_app/core/models/user/user_model.dart';

// We used a ConsumerStatefulWidget to manage the timer and navigation logic while still being able to access the authentication state if needed in the future.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final results = await Future.wait([
      ref.read(authNotifierProvider.future),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    if (!mounted) return;

    final user = results[0];

    if (user != null) {
        if (user is AdminModel) {
          Navigator.pushReplacementNamed(context, AppRoutes.admin);
        } else if (!user.emailVerified && user.role != UserRole.guest) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.verifyEmail,
            arguments: user.email,
          );
        } else {
          final tourist = user is TouristModel ? user : null;
          final hasInterests = tourist?.culturalInterests?.isNotEmpty ?? false;
          if (tourist != null && !hasInterests) {
            Navigator.pushReplacementNamed(context, AppRoutes.userPreferences);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep authNotifierProvider alive while splash is visible so it is never
    // auto-disposed before NavigationContainer reads it on navigation.
    ref.watch(authNotifierProvider);

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.08),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/athar_logo_white.png',
                  width: 280,
                ),
                const SizedBox(height: 25),
                Text(
                  l10n.splashTitle,
                  //
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.splashSubtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: (theme.textTheme.bodyLarge?.fontSize ?? 16) + 6,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      const Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(2, 2))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

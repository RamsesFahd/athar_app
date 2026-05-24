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
    // We wait only for auth to resolve, then route immediately. The previous
    // 500ms minimum-display delay was purely cosmetic and added dead time to
    // every launch — removed so the splash disappears the moment auth is ready.
    final user = await ref.read(authNotifierProvider.future);

    if (!mounted) return;

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
        final hasInterests = tourist?.culturalInterests.isNotEmpty ?? false;
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
    // Note: AuthNotifier is annotated @Riverpod(keepAlive: true), so it is never
    // auto-disposed — no need to watch it here just to keep it alive. The splash
    // is a static image + logo; it renders instantly without waiting on any data.
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
              // Decode the background at screen resolution rather than full
              // source size — faster decode, lower memory, no visible quality
              // loss for a full-bleed background.
              cacheWidth: (screenWidth * devicePixelRatio).round(),
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
                  // Logo is shown at 280 logical px — decode it at that size.
                  cacheWidth: (280 * devicePixelRatio).round(),
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

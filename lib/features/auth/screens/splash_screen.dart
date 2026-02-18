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

    // wait for 3 seconds before navigating to the next screen then check the authentication state
    Future.delayed(const Duration(seconds: 3), () async {
      // Ensure the widget is still mounted before navigating
      if (!mounted) return;

      // Check the authentication state using Riverpod
      final user = await ref.read(authNotifierProvider.future);

      if (!mounted)
        return; // Check again if the widget is still mounted before navigating

      if (user != null) {
        if (!user.emailVerified && user.role != UserRole.guest) {
          Navigator.pushReplacementNamed(
            context, 
            AppRoutes.verifyEmail, 
            arguments: user.email,
          );
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.signIn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context); // for using localization
    final theme = Theme.of(context); // الوصول للثيم الموحد

    return Scaffold(
      // استخدام اللون الأسود كخلفية احتياطية أثناء تحميل الصورة
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. الخلفية: صورة رجال ألمع (تغطي كامل الشاشة)
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png', // امتداد .jpg مطابق لملفك
              fit: BoxFit.cover,
            ),
          ),

          // 2. طبقة تظليل (Overlay): تدرج أسود لضمان بروز النصوص والشعار
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // 3. المحتوى المركزي: الشعار والنصوص
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // شعار أثر المرفوع
                Image.asset(
                  'assets/images/athar_logo_white.png',
                  width: 280, // حجم مناسب لعرض الشعار بوضوح
                ),
                const SizedBox(height: 25),
                Text(
                  l10n.splashTitle,
                  // استخدام displayLarge من الثيم لضمان الخط الرسمي مع تعديل اللون للأبيض فقط
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.splashSubtitle,
                  // استخدام bodyLarge من الثيم لضمان الخط الرسمي
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    // تم استبدال الحجم الثابت 22 بحجم متناسب مع الثيم (BaseFontSize + 6) ليكون مرناً
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

          // 4. مؤشر التحميل في الأسفل (تحريك انسيابي مثل الفيديو)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 160,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

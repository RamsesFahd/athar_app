import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/navigation/app_routes.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // الانتقال التلقائي لصفحة تسجيل الدخول بعد 4 ثوانٍ
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.signIn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context); // for using localization 
    return Scaffold(
      // استخدام اللون الأسود كخلفية احتياطية أثناء تحميل الصورة
      backgroundColor: Colors.black, 
      body: Stack(
        children: [
          // 1. الخلفية: صورة رجال ألمع (تغطي كامل الشاشة)
          Positioned.fill(
            child: Image.asset(
              'assets/images/image.png', // امتداد .jpg مطابق لملفك
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.splashSubtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2))
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
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
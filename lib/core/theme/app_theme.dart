import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme(AppSettings settings) {
    
    // 1. تحديد حجم الخط الأساسي
    double baseFontSize;
    switch (settings.fontSize) {
      case AppFontSize.small: baseFontSize = 14.0; break;
      case AppFontSize.medium: baseFontSize = 16.0; break;
      case AppFontSize.large: baseFontSize = 20.0; break;
    }

    // 2. تحديد الألوان (عادي أو تباين عالي)
    final Color primaryColor = settings.highContrast ? Colors.black : AppColors.primary;
    final Color surfaceColor = settings.highContrast ? Colors.white : AppColors.sand50;

    // 3. تجهيز أسماء الخطوط لدمجها
    // ملاحظة: Playfair لا يدعم العربي، لذا سيترك المهمة لـ IBM Plex تلقائياً
    final String? englishFont = GoogleFonts.playfairDisplay().fontFamily;
    final List<String> fallbackArabicFont = [GoogleFonts.ibmPlexSansArabic().fontFamily!];

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surfaceColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: AppColors.secondary,
        surface: surfaceColor,
        onPrimary: Colors.white,
      ),
      
      textTheme: TextTheme(
        // العناوين الكبيرة
        displayLarge: TextStyle(
          fontFamily: englishFont,
          fontFamilyFallback: fallbackArabicFont,
          fontSize: baseFontSize + 16, 
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        // العناوين الفرعية
        titleLarge: TextStyle(
          fontFamily: englishFont,
          fontFamilyFallback: fallbackArabicFont,
          fontSize: baseFontSize + 4,
          fontWeight: FontWeight.w600,
        ),
        // النصوص الأساسية
        bodyLarge: TextStyle(
          fontFamily: englishFont,
          fontFamilyFallback: fallbackArabicFont,
          fontSize: baseFontSize,
          color: AppColors.sage900,
        ),
        // النصوص الصغيرة
        bodyMedium: TextStyle(
          fontFamily: englishFont,
          fontFamilyFallback: fallbackArabicFont,
          fontSize: baseFontSize - 2,
          color: AppColors.sage800,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          // نطبق نفس المنطق داخل الأزرار
          textStyle: TextStyle(
            fontFamily: englishFont,
            fontFamilyFallback: fallbackArabicFont,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
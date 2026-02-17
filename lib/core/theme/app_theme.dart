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
    final bool isHighContrast = settings.highContrast;
    
    // ✨ في التباين العالي، نجبر النصوص والأزرار على ألوان شديدة الوضوح (أسود/أبيض)
    final Color primaryColor = isHighContrast ? Colors.black : AppColors.primary;
    final Color surfaceColor = isHighContrast ? Colors.white : AppColors.sand50;
    final Color textColorPrimary = isHighContrast ? Colors.black : AppColors.sage900;
    final Color textColorSecondary = isHighContrast ? Colors.black87 : AppColors.sage800;

    // 3. الخطوط
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
        displayLarge: TextStyle(
          fontFamily: englishFont,
          fontFamilyFallback: fallbackArabicFont,
          fontSize: baseFontSize + 16, 
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        titleLarge: TextStyle(
          fontFamily: englishFont,
          fontFamilyFallback: fallbackArabicFont,
          fontSize: baseFontSize + 4,
          fontWeight: FontWeight.w600,
          color: textColorPrimary, // ✨ تم ربطه بالتباين
        ),
        bodyLarge: TextStyle(
          fontFamily: englishFont,
          fontFamilyFallback: fallbackArabicFont,
          fontSize: baseFontSize,
          color: textColorPrimary, // ✨ تم ربطه بالتباين
        ),
        bodyMedium: TextStyle(
          fontFamily: englishFont,
          fontFamilyFallback: fallbackArabicFont,
          fontSize: baseFontSize - 2,
          color: textColorSecondary, // ✨ تم ربطه بالتباين
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // ✨ يتغير للأسود في التباين العالي
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            // ✨ إضافة حدود واضحة للزر في وضع التباين العالي
            side: isHighContrast ? const BorderSide(color: Colors.black, width: 2) : BorderSide.none,
          ),
          textStyle: TextStyle(
            fontFamily: englishFont,
            fontFamilyFallback: fallbackArabicFont,
            fontWeight: FontWeight.bold,
            fontSize: baseFontSize, // ✨ ربط حجم خط الزر بالإعدادات أيضاً
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme(AppSettings settings) {
    
    // 1. Dynamic font size based on user settings
    double baseFontSize;
    switch (settings.fontSize) {
      case AppFontSize.small: baseFontSize = 14.0; break;
      case AppFontSize.medium: baseFontSize = 16.0; break;
      case AppFontSize.large: baseFontSize = 20.0; break;
    }

    // 2. Determine if high contrast mode is enabled and adjust colors accordingly
    final bool isHighContrast = settings.highContrast;
    
    // ✨ in high contrast mode, we switch to a more stark color palette to enhance readability
    final Color primaryColor = isHighContrast ? Colors.black : AppColors.primary;
    final Color backgroundColor = isHighContrast ? Colors.white : AppColors.background;
    final Color surfaceColor = isHighContrast ? Colors.white : AppColors.sand50;
    final Color textColorPrimary = isHighContrast ? Colors.black : AppColors.sage900;
    final Color textColorSecondary = isHighContrast ? Colors.black87 : AppColors.sage800;

    // 3. Using Google Fonts with proper fallbacks for Arabic and English text
    final String? englishFont = GoogleFonts.playfairDisplay().fontFamily;
    final List<String> fallbackArabicFont = [GoogleFonts.ibmPlexSansArabic().fontFamily!];

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: AppColors.secondary,
        surface: surfaceColor,
        onPrimary: Colors.white,
        tertiary: AppColors.henna500,
        onSurfaceVariant: AppColors.sage50,
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
          color: textColorPrimary, // ✨ linked for high contrast mode
        ),
        bodyLarge: TextStyle(
          fontFamily: englishFont,
          fontFamilyFallback: fallbackArabicFont,
          fontSize: baseFontSize,
          color: textColorPrimary, // ✨ linked for high contrast mode
        ),
        bodyMedium: TextStyle(
          fontFamily: englishFont,
          fontFamilyFallback: fallbackArabicFont,
          fontSize: baseFontSize - 2,
          color: textColorSecondary, // ✨ linked for high contrast mode
        ),
        bodySmall: TextStyle(
          fontFamily: englishFont,
          fontFamilyFallback: fallbackArabicFont,
          fontSize: baseFontSize - 4,
          color: textColorSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: englishFont,
          fontFamilyFallback: fallbackArabicFont,
          fontSize: baseFontSize - 6,
          fontWeight: FontWeight.w500,
          color: textColorSecondary, // ✨ linked for high contrast mode
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // ✨ linked for high contrast mode
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            // ✨ adding a border in high contrast mode
            side: isHighContrast ? const BorderSide(color: Colors.black, width: 2) : BorderSide.none,
          ),
          textStyle: TextStyle(
            fontFamily: englishFont,
            fontFamilyFallback: fallbackArabicFont,
            fontWeight: FontWeight.bold,
            fontSize: baseFontSize, // ✨ linked for dynamic font size
          ),
        ),
      ),
    );
  }
}
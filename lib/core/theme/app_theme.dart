import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';
import 'app_colors.dart';

@immutable
class AtharThemeExtension extends ThemeExtension<AtharThemeExtension> {
  final bool highContrast;

  const AtharThemeExtension({required this.highContrast});

  @override
  AtharThemeExtension copyWith({bool? highContrast}) {
    return AtharThemeExtension(
      highContrast: highContrast ?? this.highContrast,
    );
  }

  @override
  AtharThemeExtension lerp(
      covariant ThemeExtension<AtharThemeExtension>? other, double t) {
    if (other is! AtharThemeExtension) return this;
    return AtharThemeExtension(
      highContrast: t < 0.5 ? highContrast : other.highContrast,
    );
  }
}

extension AtharThemeDataX on ThemeData {
  bool get isHighContrast =>
      extension<AtharThemeExtension>()?.highContrast ?? false;

  Color get semanticSuccess =>
      isHighContrast ? colorScheme.primary : Colors.green;

  Color get semanticWarning =>
      isHighContrast ? colorScheme.primary : Colors.orange;
}

class AppTheme {
  static ThemeData getTheme(AppSettings settings) {
    // 1. Dynamic font size based on user settings
    double baseFontSize;
    switch (settings.fontSize) {
      case AppFontSize.small:
        baseFontSize = 14.0;
        break;
      case AppFontSize.medium:
        baseFontSize = 16.0;
        break;
      case AppFontSize.large:
        baseFontSize = 20.0;
        break;
    }

    // 2. Determine if high contrast mode is enabled and adjust colors accordingly
    final bool isHighContrast = settings.highContrast;

    // ✨ in high contrast mode, we switch to a more stark color palette to enhance readability
    final Color primaryColor =
        isHighContrast ? Colors.black : AppColors.primary;
    final Color secondaryColor =
        isHighContrast ? Colors.black : AppColors.secondary;
    final Color tertiaryColor =
        isHighContrast ? Colors.black : AppColors.henna500;
    final Color errorColor = isHighContrast ? Colors.black : AppColors.error;
    final Color backgroundColor =
        isHighContrast ? Colors.white : AppColors.background;
    final Color surfaceColor = isHighContrast ? Colors.white : AppColors.sand50;
    final Color textColorPrimary =
        isHighContrast ? Colors.black : AppColors.sage900;
    final Color textColorSecondary =
        isHighContrast ? Colors.black87 : AppColors.sage800;
    final Color outlineColor = isHighContrast ? Colors.black : AppColors.sage50;
    final Color inputBorderColor =
        isHighContrast ? Colors.black : AppColors.sage50;
    final Color inputFocusedBorderColor =
        isHighContrast ? Colors.black : AppColors.primary;

    // 3. Using Google Fonts with proper fallbacks for Arabic and English text
    final String? englishFont = GoogleFonts.playfairDisplay().fontFamily;
    final List<String> fallbackArabicFont = [
      'ThmanyahSerifDisplay',
    ];

    return ThemeData(
      useMaterial3: true,
      extensions: <ThemeExtension<dynamic>>[
        AtharThemeExtension(highContrast: isHighContrast),
      ],
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        surface: surfaceColor,
        onPrimary: Colors.white,
        error: errorColor,
        onError: Colors.white,
        outline: outlineColor,
        outlineVariant: outlineColor,
        // ✨ text color on cards/surfaces, linked for high contrast mode
        onSurface: textColorPrimary,

        tertiary: tertiaryColor,
        onTertiary: Colors.white,

        // ✨ secondary text color linked for high contrast mode
        onSurfaceVariant: textColorSecondary,
      ),

      // ✨ default card styling linked for high contrast mode
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: isHighContrast ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isHighContrast ? Colors.black : AppColors.sage50,
            width: isHighContrast ? 2 : 1,
          ),
        ),
      ),

// ✨ default icon color linked for high contrast mode
      iconTheme: IconThemeData(
        color: isHighContrast ? Colors.black : AppColors.primary,
      ),

// ✨ bottom navigation colors linked for high contrast mode
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: isHighContrast ? Colors.black : AppColors.primary,
        unselectedItemColor:
            isHighContrast ? Colors.black87 : AppColors.sage800,
        selectedLabelStyle: TextStyle(
          fontSize: baseFontSize - 4,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: baseFontSize - 4,
          fontWeight: FontWeight.w600,
        ),
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
          fontSize: baseFontSize + 8,
          fontWeight: FontWeight.w800,
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

      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: textColorSecondary,
        ),
        labelStyle: TextStyle(
          color: textColorSecondary,
        ),
        floatingLabelStyle: TextStyle(
          color: primaryColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: inputBorderColor,
            width: isHighContrast ? 2 : 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: inputBorderColor,
            width: isHighContrast ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: inputFocusedBorderColor,
            width: 2,
          ),
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
            side: isHighContrast
                ? const BorderSide(color: Colors.black, width: 2)
                : BorderSide.none,
          ),
          textStyle: TextStyle(
            fontFamily: englishFont,
            fontFamilyFallback: fallbackArabicFont,
            fontWeight: FontWeight.bold,
            fontSize: baseFontSize, // ✨ linked for dynamic font size
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        contentTextStyle: TextStyle(
          fontFamily: englishFont,
          fontFamilyFallback: fallbackArabicFont,
          fontSize: baseFontSize - 2,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// أنواع أحجام الخطوط
enum AppFontSize { small, medium, large }

class AppSettings {
  final AppFontSize fontSize;
  final Locale locale;
  final bool highContrast;

  AppSettings({required this.fontSize, required this.locale, this.highContrast = false});

  AppSettings copyWith({AppFontSize? fontSize, Locale? locale, bool? highContrast}) {
    return AppSettings(
      fontSize: fontSize ?? this.fontSize,
      locale: locale ?? this.locale,
      highContrast: highContrast ?? this.highContrast,
    );
  }
}

// الـ Provider الذي سنستخدمه في كل التطبيق
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings(fontSize: AppFontSize.medium, locale: const Locale('ar')));

  void setFontSize(AppFontSize size) => state = state.copyWith(fontSize: size);
  void setLocale(Locale locale) => state = state.copyWith(locale: locale);
  void toggleContrast() => state = state.copyWith(highContrast: !state.highContrast);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) => SettingsNotifier());
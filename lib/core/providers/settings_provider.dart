import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppFontSize { small, medium, large }

// 1. AppSettings class to hold all the settings in one place
class AppSettings {
  final AppFontSize fontSize;
  final Locale locale;
  final bool highContrast;
  final bool isTtsEnabled;

  AppSettings({
    required this.fontSize, 
    required this.locale, 
    this.highContrast = false,
    this.isTtsEnabled = false,
  });

  AppSettings copyWith({
    AppFontSize? fontSize, 
    Locale? locale, 
    bool? highContrast,
    bool? isTtsEnabled,
  }) {
    return AppSettings(
      fontSize: fontSize ?? this.fontSize,
      locale: locale ?? this.locale,
      highContrast: highContrast ?? this.highContrast,
      isTtsEnabled: isTtsEnabled ?? this.isTtsEnabled,
    );
  }
}

// 2. Notifier class to manage the state of the settings
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings(fontSize: AppFontSize.medium, locale: const Locale('ar')));

  void setFontSize(AppFontSize size) => state = state.copyWith(fontSize: size);
  void setLocale(Locale locale) => state = state.copyWith(locale: locale);
  void toggleContrast() => state = state.copyWith(highContrast: !state.highContrast);
  void toggleTts() => state = state.copyWith(isTtsEnabled: !state.isTtsEnabled);
}

// 3.defining the provider that will be used to access the settings state and notifier throughout the app
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
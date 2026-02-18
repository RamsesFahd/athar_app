import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/theme/app_theme.dart';
import 'package:athar_app/core/providers/settings_provider.dart';

// استيراد نظام المسارات
import 'package:athar_app/core/navigation/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: AtharApp(),
    ),
  );
}

class AtharApp extends ConsumerWidget {
  const AtharApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Athar App',

      // تطبيق ثيم الفريق بناءً على الإعدادات
      theme: AppTheme.getTheme(settings),
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      initialRoute: AppRoutes.splash,

      routes: AppRoutes.getRoutes(),
    );
  }
}

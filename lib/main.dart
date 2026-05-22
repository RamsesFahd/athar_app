import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // <-- 1. إضافة استدعاء حزمة App Check

import 'firebase_options.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/theme/app_theme.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:athar_app/core/navigation/app_routes.dart';
import 'package:athar_app/core/services/notification_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cap in-memory image cache: 100 decoded images, max 100 MB.
  PaintingBinding.instance.imageCache.maximumSize = 100;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20;

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // navigatorKey must be set before runApp so NotificationService can navigate.
  NotificationService.navigatorKey = navigatorKey;

  runApp(
    const ProviderScope(
      child: AtharApp(),
    ),
  );

  // Everything below runs after the first frame is painted.
  // AppCheck, auth settings, and notifications don't block UI rendering.
  // AppCheck will be ready long before the first Firestore call (after splash).
  FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
  );

  if (kDebugMode) {
    FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
  }

  NotificationService.instance.init();
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

      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.splash,

      routes: AppRoutes.getRoutes(),
    );
  }
}
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

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

  // ── Essential, blocking init only ──────────────────────────────────────────
  // These two must complete before the app can run at all.
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore offline persistence so reads after the first launch come
  // from the local cache (near-instant) instead of the network. On mobile this
  // is on by default, but setting it explicitly guarantees it and unlocks the
  // unlimited cache size — this is what makes the splash + home reads fast on
  // repeat launches.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // navigatorKey is set synchronously (cheap) so NotificationService can
  // navigate as soon as a notification is tapped — even before init() finishes.
  NotificationService.navigatorKey = navigatorKey;

  // ── Run the app immediately ──────────────────────────────────────────────
  // We no longer await App Check or NotificationService.init() here. Blocking
  // on them was the main cause of the long black screen at startup.
  runApp(
    const ProviderScope(
      child: AtharApp(),
    ),
  );

  // ── Secondary services init in the background ────────────────────────────
  // App Check + push notifications finish initializing after the first frame
  // is already on screen. The user sees the splash instantly; these complete
  // a fraction of a second later, well before any Firestore write is attempted.
  unawaited(_initSecondaryServices());
}

/// Initializes non-blocking services after the UI is already visible.
///
/// IMPORTANT: If App Check enforcement is ON in the Firebase console, Firestore
/// reads will wait for a valid App Check token. In that case the very first
/// read on the splash may still wait briefly for activation to finish. For the
/// demo, ensure App Check enforcement is in monitor (not enforce) mode, or that
/// the debug provider token is registered, so reads are never blocked.
Future<void> _initSecondaryServices() async {
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    );

    if (kDebugMode) {
      await FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: true,
      );
    }

    await NotificationService.instance.init();
  } catch (e) {
    // Never let a background-service failure crash startup. Log and move on.
    debugPrint('[main] Secondary service init failed: $e');
  }
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
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// استيراد ملفات المشروع (تأكدي من صحة المسارات في مجلدك)
import 'firebase_options.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart'; 
import 'package:athar_app/core/theme/app_theme.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/features/auth/screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تغليف التطبيق بـ ProviderScope لتفعيل Riverpod
  runApp(
    const ProviderScope(
      child: AtharApp(),
    ),
  );
}

class AtharApp extends ConsumerWidget { // حولناه لـ ConsumerWidget ليدعم Riverpod
  const AtharApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مراقبة الإعدادات (اللغة، الخط، التباين) من الـ Provider
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Athar App',
      
      // ربط الثيم الديناميكي بالإعدادات
      theme: AppTheme.getTheme(settings), 
      
      // إعدادات اللغة من الـ Provider بدلاً من الحالة المحلية
      locale: settings.locale, 
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      
      //home: const AtharHomePage(), 
      home: const SignUpScreen(),
    );
  }
}

class AtharHomePage extends ConsumerWidget {
  const AtharHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // الوصول للإعدادات والمتحكم بها
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appName), // تأكدي من وجودها في arb
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              // تبديل اللغة عبر الـ Provider
              if (settings.locale.languageCode == 'ar') {
                settingsNotifier.setLocale(const Locale('en'));
              } else {
                settingsNotifier.setLocale(const Locale('ar'));
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          AppLocalizations.of(context).welcome, // تأكدي من وجودها في arb
          style: Theme.of(context).textTheme.bodyLarge, // يستخدم حجم الخط من الثيم
        ),
      ),
    );
  }
}
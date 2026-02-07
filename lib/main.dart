import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AtharApp());
}

// حولناه إلى StatefulWidget عشان نقدر نغير الحالة (اللغة)
class AtharApp extends StatefulWidget {
  const AtharApp({super.key});

  @override
  State<AtharApp> createState() => _AtharAppState();
}

class _AtharAppState extends State<AtharApp> {
  // متغير لتخزين اللغة الحالية (تبدأ بالعربي)
  Locale _locale = const Locale('ar');

  // دالة لتغيير اللغة
  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Athar App',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      
      // نستخدم المتغير هنا بدلاً من القيمة الثابتة
      locale: _locale, 

      home: AtharHomePage(
        currentLocale: _locale,
        onLocaleChange: setLocale, // نمرر الدالة للشاشة الرئيسية
      ), 
    );
  }
}

class AtharHomePage extends StatelessWidget {
  final Locale currentLocale;
  final Function(Locale) onLocaleChange;

  const AtharHomePage({
    super.key, 
    required this.currentLocale, 
    required this.onLocaleChange,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appName),
        actions: [
          // زر لتغيير اللغة
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              // إذا كانت عربي حولها إنجليزي، والعكس
              if (currentLocale.languageCode == 'ar') {
                onLocaleChange(const Locale('en'));
              } else {
                onLocaleChange(const Locale('ar'));
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.welcome, // تأكدي أن welcome موجود في ملفات الـ arb
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/navigation/app_routes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    
    // مراقبة حالة المستخدم الحالية
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Athar Home (Test Mode)'),
        actions: [
          // زر تسجيل الخروج للتجربة
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              // بعد تسجيل الخروج، السبلاش أو صفحة الدخول راح تتولى التوجيه
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.signIn);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: authState.when(
          // 1. حالة وجود بيانات المستخدم
          data: (user) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              Text(
                '${l10n.signInWelcome}, ${user?.fullName ?? "User"}!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text('Email: ${user?.email ?? "No Email"}'),
              const SizedBox(height: 40),
              const Text(
                'هذه الصفحة "مؤقتة" لتجربة تسجيل الدخول.\n الحين تقدرين تبدأين تصميم الواجهة الحقيقية لأثر!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          // 2. حالة التحميل
          loading: () => const CircularProgressIndicator(),
          // 3. حالة الخطأ
          error: (err, stack) => Text('Error: $err'),
        ),
      ),
    );
  }
}
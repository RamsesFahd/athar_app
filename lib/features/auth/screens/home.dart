import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/navigation/app_routes.dart';
import 'package:athar_app/core/widgets/header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Center(
        child: authState.when(
          data: (user) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              Text(
                '${l10n.signInWelcome}, ${user?.fullName ?? "User"}!',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text('Email: ${user?.email ?? "No Email"}'),
              const SizedBox(height: 40),
              // زر تسجيل الخروج خليته هنا في النص عشان الهيدر صار نظيف باللوقو
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.signIn);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF1A4D32),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'محتوى الصفحة سيتم تصميمه لاحقاً...\n الهيدر والفوتر الآن جاهزان! ✅',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
      ),
    );
  }
}

import 'package:athar_app/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/navigation/app_routes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!; 
    final authState = ref.watch(authNotifierProvider);
    
    // ✨ calling the color scheme once to use it in multiple places
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: authState.when(
          data: (user) {
            final welcomeText = '${l10n.signInWelcome}, ${user?.fullName ?? "User"}!';
            final emailText = 'Email: ${user?.email ?? "No Email"}';
            final infoText = 'محتوى الصفحة سيتم تصميمه لاحقاً. الهيدر والفوتر الآن جاهزان!';
            final fullTextToRead = '$welcomeText. $emailText. $infoText';

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration, size: 80, color: Colors.amber),
                const SizedBox(height: 20),
                
                // زر الاستماع للمحتوى
                IconButton(
                  // ✨ 2. ربطنا لون الأيقونة بالثيم بدل اللون الأخضر الثابت
                  icon: Icon(Icons.volume_up, color: colorScheme.primary, size: 32),
                  tooltip: 'الاستماع للمحتوى',
                  onPressed: () {
                    ref.read(ttsServiceProvider).speak(fullTextToRead);
                  },
                ),
                const SizedBox(height: 8),

                Text(
                  welcomeText,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(emailText),
                const SizedBox(height: 40),
                
                // زر تسجيل الخروج
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(ttsServiceProvider).stop(); 
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.signIn);
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                  style: ElevatedButton.styleFrom(
                    // ✨ 3. ربطنا خلفية الزر بالثيم بدل اللون الثابت
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary, // النص بيكون أبيض دايماً
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'محتوى الصفحة سيتم تصميمه لاحقاً...\n الهيدر والفوتر الآن جاهزان! ✅',
                  textAlign: TextAlign.center,
                  // ✨ 4. ربطنا لون النص الرمادي بالثيم عشان يتأثر بالتباين
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../widgets/custom_button.dart';
import '../logic/auth_notifier.dart';
import '../../../core/models/user_model.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../widgets/auth_utils.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _emailController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 50;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // إرسال الرابط تلقائياً عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).sendVerificationLink();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      final email = args.trim();
      if (email.isNotEmpty && _emailController.text.isEmpty) {
        _emailController.text = email;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 50);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);

    // مراقبة الحالة للانتقال للهوم
    ref.listen<AsyncValue<UserModel?>>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                // استخدام ملف الأدوات المشترك لترجمة الخطأ
                content: Text(AuthUtils.translateError(error.toString(), l10n)),
                backgroundColor: Colors.red),
          );
        },
        data: (user) {
          if (user != null) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleBackToLogin(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة كبيرة معبرة
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.email_outlined,
                    size: 100, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 40),

              // العنوان بخط الثيم الرسمي
              Text(
                l10n.verifyEmailTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize:
                      (theme.textTheme.displayLarge?.fontSize ?? 32) * 0.9,
                ),
              ),
              const SizedBox(height: 16),

              // رسالة الشرح والإيميل
              Text(
                l10n.verifyEmailSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    height: 1.5),
              ),
              const SizedBox(height: 10),
              Text(
                _emailController.text,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: theme.textTheme.bodyLarge?.fontSize,
                ),
              ),
              const SizedBox(height: 48),

              // الزر الرئيسي للتحقق
              AtharButton(
                label: l10n.verifyButton,
                isLoading: authState.isLoading,
                onPressed: () => ref
                    .read(authNotifierProvider.notifier)
                    .checkEmailVerificationStatus(),
              ),

              const SizedBox(height: 20),

              // زر إعادة الإرسال
              _buildResendButton(l10n, authState.isLoading),

              const SizedBox(height: 40),

              // زر العودة لتسجيل الدخول (بشكل بسيط)
              TextButton(
                onPressed: () => _handleBackToLogin(),
                child: Text(
                  l10n.backToSignInButton,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton(AppLocalizations l10n, bool isLoading) {
    final theme = Theme.of(context);
    final canResend = _secondsLeft == 0;
    return canResend
        ? TextButton(
            onPressed: isLoading
                ? null
                : () {
                    ref
                        .read(authNotifierProvider.notifier)
                        .sendVerificationLink();
                    _startTimer();
                  },
            child: Text(l10n.resendCode,
                style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontSize: theme.textTheme.bodyLarge?.fontSize)),
          )
        : Text(
            l10n.resendCodeInSeconds(_secondsLeft),
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5)),
          );
  }

  void _handleBackToLogin() {
    // يفضل تسجيل الخروج قبل العودة لضمان نظافة الحالة
    ref.read(authNotifierProvider.notifier).logout();
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.signIn, (route) => false);
  }
}

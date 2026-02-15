import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../logic/auth_notifier.dart';
import '../../../core/models/user_model.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

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
    final authState = ref.watch(authNotifierProvider);

    // مراقبة الحالة للانتقال للهوم
    ref.listen<AsyncValue<UserModel?>>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_translateError(error.toString(), l10n)), backgroundColor: Colors.red),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
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
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.email_outlined, size: 100, color: AppColors.primary),
              ),
              const SizedBox(height: 40),
              
              // العنوان بخط Playfair
              Text(
                l10n.verifyEmailTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Playfair Display',
                ),
              ),
              const SizedBox(height: 16),
              
              // رسالة الشرح والإيميل
              Text(
                l10n.verifyEmailSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 10),
              Text(
                _emailController.text,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 48),

              // الزر الرئيسي للتحقق
              AtharButton(
                label: l10n.verifyButton,
                isLoading: authState.isLoading,
                onPressed: () => ref.read(authNotifierProvider.notifier).checkEmailVerificationStatus(),
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
                  style: TextStyle(color: Colors.grey[600], decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton(AppLocalizations l10n, bool isLoading) {
    final canResend = _secondsLeft == 0;
    return canResend
        ? TextButton(
            onPressed: isLoading ? null : () {
              ref.read(authNotifierProvider.notifier).sendVerificationLink();
              _startTimer();
            },
            child: Text(l10n.resendCode, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          )
        : Text(
            l10n.resendCodeInSeconds(_secondsLeft),
            style: TextStyle(color: Colors.grey[400]),
          );
  }

  void _handleBackToLogin() {
    // يفضل تسجيل الخروج قبل العودة لضمان نظافة الحالة
    ref.read(authNotifierProvider.notifier).logout();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (route) => false);
  }

  String _translateError(String errorKey, AppLocalizations l10n) {
    switch (errorKey) {
      case 'errorEmailNotVerified': return l10n.errorEmailNotVerified;
      default: return l10n.errorUnexpected;
    }
  }
}
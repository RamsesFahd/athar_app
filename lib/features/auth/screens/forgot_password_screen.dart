import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart'; 
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/auth_notifier.dart';
import '../../../core/models/user_model.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context); // for using localization

    // Listen to auth state changes to show error messages or update the UI when the user logs in successfully
    ref.listen<AsyncValue<UserModel?>>(authNotifierProvider, (previous, next) {
    next.whenOrNull(
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_translateError(error.toString(), l10n)),
            backgroundColor: Colors.red,
          ),
        );
      },
      data: (_) {
        // if the previous state was loading, it means the form was submitted and we can show the success state
        if (previous is AsyncLoading) {
          setState(() => _isSubmitted = true);
        }
      },
    );
  });

  final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // تأكدي أن الرجوع لليمن واليسار لا يقلب الأيقونة
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _isSubmitted ? _buildSuccessState(l10n) : _buildFormState(l10n, authState.isLoading),
        ),
    );
  }

  Widget _buildFormState(AppLocalizations l10n, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          l10n.forgotPassword,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827), 
            fontFamily: 'Playfair Display', 
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.resetPasswordSubtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        Text(
          l10n.emailLabel,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: l10n.emailHint,
            prefixIcon: const Icon(Icons.mail_outline, size: 20),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // استخدام الزر المشترك
        AtharButton(
          label: l10n.sendLinkButton,
          isLoading: isLoading, 
          onPressed: () {
            final email = _emailController.text.trim();
            if (email.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.fillAllFieldsError)),
              );
              return;
            }
            // call the reset password method from the auth notifier
            ref.read(authNotifierProvider.notifier).resetPassword(email:  email);
          },
        ),
      ],
    );
  }

  Widget _buildSuccessState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: AppColors.primary, size: 80),
          const SizedBox(height: 24),
          Text(
            l10n.emailSentTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.emailSentMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 40),
          
          // استخدام الزر المشترك بنوع Outline
          AtharButton(
            label: l10n.backToSignInButton,
            variant: ButtonVariant.outline,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  String _translateError(String errorKey, AppLocalizations l10n) {
    switch (errorKey) {
      case 'errorEmailAlreadyInUse': return l10n.errorEmailAlreadyInUse;
      case 'errorInvalidEmail': return l10n.errorInvalidEmail;
      case 'errorUserNotFound': return l10n.errorUserNotFound;
      case 'errorWrongPassword': return l10n.errorWrongPassword;
      case 'errorWeakPassword': return l10n.errorWeakPassword;
      default: return l10n.errorUnexpected;
    }
  }
}
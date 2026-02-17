import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/models/user_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/auth_utils.dart';
import '../logic/auth_notifier.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
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
    final l10n = AppLocalizations.of(context); 

    ref.listen<AsyncValue<UserModel?>>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AuthUtils.translateError(error.toString(), l10n)),
              backgroundColor: Colors.red,
            ),
          );
        },
        data: (_) {
          if (previous is AsyncLoading) {
            setState(() => _isSubmitted = true);
          }
        },
      );
    });

    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent, // ليظهر لون خلفية Scaffold
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: _isSubmitted
            ? _buildSuccessState(l10n)
            : _buildFormState(l10n, authState.isLoading),
      ),
    );
  }

  Widget _buildFormState(AppLocalizations l10n, bool isLoading) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          l10n.forgotPassword,
          style: theme.textTheme.displayLarge, 
        ),
        const SizedBox(height: 12),
        Text(
          l10n.resetPasswordSubtitle,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 48),
        Text(
          l10n.emailLabel,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: theme.textTheme.bodyLarge?.fontSize, // يتبع الحجم الأساسي للثيم
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: l10n.emailHint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            prefixIcon: Icon(Icons.mail_outline, size: 20, color: theme.colorScheme.primary),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
        const SizedBox(height: 32),

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
            ref.read(authNotifierProvider.notifier).resetPassword(email: email);
          },
        ),
      ],
    );
  }

  Widget _buildSuccessState(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 80),
          const SizedBox(height: 24),
          Text(
            l10n.emailSentTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: (theme.textTheme.displayLarge?.fontSize ?? 32) * 0.8, // نسبة وتناسب مع حجم الثيم
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.emailSentMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),

          AtharButton(
            label: l10n.backToSignInButton,
            variant: ButtonVariant.outline,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
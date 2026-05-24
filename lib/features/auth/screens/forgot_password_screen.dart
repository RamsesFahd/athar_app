import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: _isSubmitted
            ? _buildSuccessState(l10n)
            : _buildFormState(l10n, _isLoading),
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
            fontSize: theme.textTheme.bodyLarge?.fontSize,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: l10n.emailHint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            prefixIcon: Icon(Icons.mail_outline,
                size: 20, color: theme.colorScheme.primary),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.35),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        AtharButton(
          label: l10n.sendLinkButton,
          isLoading: isLoading,
          onPressed: () async {
            final email = _emailController.text.trim();
            if (email.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.fillAllFieldsError)),
              );
              return;
            }
            final errorColor = Theme.of(context).colorScheme.error;
            setState(() => _isLoading = true);
            final success = await ref
                .read(authNotifierProvider.notifier)
                .resetPassword(email: email);
            if (!mounted) return;
            setState(() => _isLoading = false);
            if (success) {
              setState(() => _isSubmitted = true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AuthUtils.translateError('errorUnexpected', l10n)),
                backgroundColor: errorColor,
              ));
            }
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
              fontSize: (theme.textTheme.displayLarge?.fontSize ?? 32) * 0.8,
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

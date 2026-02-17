import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/models/user_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/auth_utils.dart';
import '../logic/auth_notifier.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // listening to auth state changes to show error messages or navigate to home screen on successful login
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
        data: (user) {
          if (user != null) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.verifyEmail,
              arguments: _email.text,
            );
          }
        },
      );
    });

    // checking for loading state
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomHeader(
            title: l10n.signUpTitle,
            subtitle: l10n.signUpSubtitle,
            imagePath: 'assets/images/signup_header.png',
          ),
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 35, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FullName lable
                    Text(l10n.fullNameLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: theme.textTheme.bodyLarge?.fontSize,
                        )),
                    const SizedBox(height: 8),
                    _buildTextField(_fullName, l10n.nameHint, false),
                    const SizedBox(height: 18),

                    // Email label
                    Text(l10n.emailLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: theme.textTheme.bodyLarge?.fontSize)),
                    const SizedBox(height: 8),
                    _buildTextField(_email, l10n.emailHint, false),
                    const SizedBox(height: 18),

                    // Password label
                    Text(l10n.passwordLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: theme.textTheme.bodyLarge?.fontSize)),
                    const SizedBox(height: 8),
                    _buildTextField(_password, l10n.passwordHint, true),
                    const SizedBox(height: 18),

                    // Confirm Password label
                    Text(l10n.confirmPasswordLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: theme.textTheme.bodyLarge?.fontSize)),
                    const SizedBox(height: 8),
                    _buildTextField(_confirmPassword, l10n.passwordHint, true, isConfirm: true),

                    // Sign up button
                    const SizedBox(height: 20),
                    AtharButton(
                      label: l10n.createAccountButton,
                      isLoading:
                          authState.isLoading, // pass loading state to button
                      onPressed: () {
                        final email = _email.text.trim();
                        final pass = _password.text;
                        final confirm = _confirmPassword.text;
                        final name = _fullName.text.trim();

                        // Basic validation before calling sign up method
                        if (name.isEmpty || email.isEmpty || pass.isEmpty) {
                          // you show a snackbar or dialog to inform the user to fill all fields
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.fillAllFieldsError),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        if (pass != confirm) {
                          // you show a snackbar or dialog to inform the user that passwords do not match
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.passwordsDoNotMatchError),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        // call sign up method from auth notifier
                        ref.read(authNotifierProvider.notifier).signUp(
                              email: email,
                              password: pass,
                              fullName: name,
                            );
                      },
                    ),

                    const SizedBox(height: 25),
                    AuthUtils.buildDivider(l10n),
                    const SizedBox(height: 25),
                    _buildSocialButtons(),
                    const SizedBox(height: 25),
                    _buildFooterLinks(l10n, authState.isLoading),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField( TextEditingController controller, String hint, bool isPassword, { bool isConfirm = false,}) {

    final theme = Theme.of(context);
    final hide = isConfirm ? _hideConfirmPassword : _hidePassword;

    return TextField(
      controller: controller,
      obscureText: isPassword ? hide : false,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
      // استخدمتو عشان تعديل مربع الايميل 
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintText: hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
             //  يثبت مساحة الأيقونة عشان ما يأثر على ارتفاع الحقل
      suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  hide ? Icons.visibility_off : Icons.visibility,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () => setState(() {
                  if (isConfirm) {
                    _hideConfirmPassword = !_hideConfirmPassword;
                  } else {
                    _hidePassword = !_hidePassword;
                  }
                }),
              )
            : null,
      ),
    );
  }

  
  Widget _buildSocialButtons() {
    final theme = Theme.of(context);
    return Row(children: [
      _socialBtn(Icons.apple, theme.colorScheme.onSurface, theme.colorScheme.surface),
      const SizedBox(width: 12),
      _socialBtn(null, theme.colorScheme.surface, theme.colorScheme.onSurface, isGoogle: true),
    ]);
  }

  Widget _socialBtn(IconData? icon, Color bg, Color fg,
      {bool isGoogle = false}) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: isGoogle
              ? Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                  height: 22,
                )
              : Icon(icon, color: fg, size: 24),
        ),
      ),
    );
  }

  
  Widget _buildFooterLinks(AppLocalizations l10n, bool isLoading) {
    final theme = Theme.of(context);
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(l10n.alreadyHaveAccount, style: theme.textTheme.bodyMedium),
        TextButton(
          onPressed: isLoading
              ? null
              : () => Navigator.pushNamed(context, AppRoutes.signIn),
          child: Text(
            l10n.signInLink,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ]),
      TextButton(
        onPressed: isLoading
            ? null
            : () => ref.read(authNotifierProvider.notifier).guestLogin(),
        child: Text(
          l10n.continueAsGuest,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold),
      ),
      ),
    ]);
}
}
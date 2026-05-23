import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/navigation/app_routes.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/auth/widgets/custom_header.dart';
import 'package:athar_app/features/auth/widgets/custom_button.dart';
import 'package:athar_app/features/auth/widgets/auth_utils.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  // 1. Managing the selected role state (tourist or tutor)
  UserRole _selectedRole = UserRole.tourist;
  TutorType? _selectedTutorType;
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isSignUpLoading = false;

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _privacyPolicyAccepted = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
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

    // 2. Listening to auth state changes to show error messages or navigate to home screen on successful registration
    ref.listen<AsyncValue<UserModel?>>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          if (error.toString() == 'needsRoleSelection') {
            Navigator.pushReplacementNamed(
                context, AppRoutes.googleRoleSelection);
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AuthUtils.translateError(error.toString(), l10n)),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        },
        data: (user) {
          if (user != null) {
            TextInput.finishAutofillContext();
            if (user is AdminModel) {
              Navigator.pushReplacementNamed(context, AppRoutes.admin);
              return;
            }
            if (!user.emailVerified && user.role != UserRole.guest) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.verifyEmail,
                arguments: _email.text,
              );
            } else {
              final tourist = user is TouristModel ? user : null;
              final hasInterests =
                  tourist?.culturalInterests.isNotEmpty ?? false;
              if (tourist != null && !hasInterests) {
                Navigator.pushReplacementNamed(
                    context, AppRoutes.userPreferences);
              } else {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              }
            }
          }
        },
      );
    });

    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                child: AutofillGroup(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- اختيار الدور ---
                    _buildSectionLabel(l10n.signUpAsLabel, theme),
                    const SizedBox(height: 12),
                    _buildRoleSelector(theme, l10n),
                    const SizedBox(height: 25),
                    // يظهر فقط إذا كان المستخدم اختار "مرشد"
                    if (_selectedRole == UserRole.tutor) ...[
                      _buildSectionLabel(l10n.guideTypeLabel, theme),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _tutorTypeOption(TutorType.individual,
                              l10n.guideTypeIndependent, theme),
                          const SizedBox(width: 12),
                          _tutorTypeOption(
                              TutorType.company, l10n.guideTypeCompany, theme),
                        ],
                      ),
                      const SizedBox(height: 25),
                    ],
                    // --- حقول البيانات ---
                    _buildSectionLabel(l10n.fullNameLabel, theme),
                    _buildTextField(_fullName, l10n.nameHint, false,
                        autofillHints: const [AutofillHints.name]),
                    const SizedBox(height: 18),

                    _buildSectionLabel(l10n.emailLabel, theme),
                    _buildTextField(_email, l10n.emailHint, false,
                        autofillHints: const [AutofillHints.email]),
                    const SizedBox(height: 18),

                    _buildSectionLabel(l10n.passwordLabel, theme),
                    _buildTextField(_password, l10n.passwordHint, true,
                        autofillHints: const [AutofillHints.newPassword]),
                    const SizedBox(height: 18),

                    _buildSectionLabel(l10n.confirmPasswordLabel, theme),
                    _buildTextField(_confirmPassword, l10n.passwordHint, true,
                        isConfirm: true,
                        autofillHints: const [AutofillHints.newPassword]),

                    const SizedBox(height: 20),

                    // Privacy Policy consent checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _privacyPolicyAccepted,
                          activeColor: theme.colorScheme.primary,
                          onChanged: (v) => setState(
                              () => _privacyPolicyAccepted = v ?? false),
                        ),
                        Text(
                          l10n.privacyPolicyAgreePrefix,
                          style: theme.textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.privacyPolicy),
                          child: Text(
                            l10n.privacyPolicyLinkText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // register button
                    AtharButton(
                      label: l10n.createAccountButton,
                      isLoading: _isSignUpLoading,
                      onPressed: authState.isLoading || !_privacyPolicyAccepted
                          ? null
                          : () {
                              _handleSignUp(l10n);
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
          ),
        ],
      ),
    );
  }

  // UI for role selection between tourist and tutor with visual feedback on selection
  Widget _buildRoleSelector(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        _roleCard(
            UserRole.tourist, l10n.touristRole, Icons.explore_outlined, theme),
        const SizedBox(width: 12),
        _roleCard(UserRole.tutor, l10n.tutorRole,
            Icons.account_balance_outlined, theme),
      ],
    );
  }

  Widget _roleCard(
      UserRole role, String label, IconData icon, ThemeData theme) {
    final bool isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.35),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8)
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignUp(AppLocalizations l10n) async {
    final name = _fullName.text.trim();
    final email = _email.text.trim();
    final pass = _password.text;
    final confirm = _confirmPassword.text;

    if (!_privacyPolicyAccepted) {
      _showError(l10n.privacyPolicyMustAccept);
      return;
    }
    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      _showError(l10n.fillAllFieldsError);
      return;
    }
    if (_selectedRole == UserRole.tutor && _selectedTutorType == null) {
      _showError(l10n.selectTutorTypeError);
      return;
    }
    if (pass != confirm) {
      _showError(l10n.passwordsDoNotMatchError);
      return;
    }
    setState(() =>
        _isSignUpLoading = true); // Show loading state on the sign-up button
    // triggering the sign-up process in the auth notifier with the selected role
    await ref.read(authNotifierProvider.notifier).signUp(
          email: email,
          password: pass,
          fullName: name,
          role: _selectedRole,
          tutorType: _selectedTutorType,
        );
    if (mounted) {
      setState(() => _isSignUpLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSectionLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, bool isPassword,
      {bool isConfirm = false, List<String>? autofillHints}) {
    final theme = Theme.of(context);
    final bool hide = isConfirm ? _hideConfirmPassword : _hidePassword;

    return TextField(
      controller: controller,
      obscureText: isPassword ? hide : false,
      autofillHints: autofillHints,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintText: hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
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
    final authState = ref.watch(authNotifierProvider);
    return Row(children: [
      _socialBtn(
          Icons.apple, theme.colorScheme.onSurface, theme.colorScheme.surface),
      const SizedBox(width: 12),
      _socialBtn(
        null,
        theme.colorScheme.surface,
        theme.colorScheme.onSurface,
        isGoogle: true,
        onTap: authState.isLoading
            ? null
            : () async {
                setState(() => _isGoogleLoading = true);
                await ref
                    .read(authNotifierProvider.notifier)
                    .signInWithGoogle();
                if (mounted) setState(() => _isGoogleLoading = false);
              },
      ),
    ]);
  }

  Widget _socialBtn(IconData? icon, Color bg, Color fg,
      {bool isGoogle = false, VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
            ),
          ),
          child: Center(
            child: isGoogle
                ? _isGoogleLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : SvgPicture.asset(
                        'assets/icons/google_logo.svg',
                        height: 22,
                        width: 22,
                      )
                : Icon(icon, color: fg, size: 24),
          ),
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ]);
  }

  Widget _tutorTypeOption(TutorType type, String label, ThemeData theme) {
    final isSelected = _selectedTutorType == type;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isSelected ? theme.colorScheme.primary : Colors.transparent,
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
          foregroundColor:
              isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
        ),
        onPressed: () => setState(() => _selectedTutorType = type),
        child: Text(label, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
// استيراد ملف الموديل الأساسي للوصول للأدوار
import '../../../core/models/user/user_model.dart'; 
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
  // 1. إدارة حالة الدور المختار (سائح بشكل افتراضي)
  UserRole _selectedRole = UserRole.tourist; 

  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

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

    // مراقبة حالة المصادقة للتوجيه بعد النجاح
    ref.listen<AsyncValue<UserModel?>>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AuthUtils.translateError(error.toString(), l10n)),
              backgroundColor: AppColors.error, // استخدام لون الخطأ من الثيم
            ),
          );
        },
        data: (user) {
          if (user != null) {
            //  التعديل: فحص التفعيل فور التسجيل
            if (!user.emailVerified && user.role != UserRole.guest) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.verifyEmail,
                arguments: _email.text, // تمرير الإيميل للشاشة التالية
              );
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          }
        },
      );
    });

    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      // التعديل: استخدام لون الخلفية من الثيم ليدعم التباين العالي
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
                color: theme.colorScheme.surface, // التزام بلون السطح
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
                    // --- اختيار الدور ---
                    _buildSectionLabel("سجل في أثر كـ:", theme),
                    const SizedBox(height: 12),
                    _buildRoleSelector(theme),
                    const SizedBox(height: 25),

                    // --- حقول البيانات ---
                    _buildSectionLabel(l10n.fullNameLabel, theme),
                    _buildTextField(_fullName, l10n.nameHint, false),
                    const SizedBox(height: 18),

                    _buildSectionLabel(l10n.emailLabel, theme),
                    _buildTextField(_email, l10n.emailHint, false),
                    const SizedBox(height: 18),

                    _buildSectionLabel(l10n.passwordLabel, theme),
                    _buildTextField(_password, l10n.passwordHint, true),
                    const SizedBox(height: 18),

                    _buildSectionLabel(l10n.confirmPasswordLabel, theme),
                    _buildTextField(_confirmPassword, l10n.passwordHint, true, isConfirm: true),

                    const SizedBox(height: 30),

                    // زر التسجيل مع تمرير الدور المختار
                    AtharButton(
                      label: l10n.createAccountButton,
                      isLoading: authState.isLoading,
                      onPressed: () => _handleSignUp(l10n),
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

  // ودجت اختيار الدور (سائح أو مرشد)
  Widget _buildRoleSelector(ThemeData theme) {
    return Row(
      children: [
        _roleCard(UserRole.tourist, "سائح", Icons.explore_outlined, theme),
        const SizedBox(width: 12),
        _roleCard(UserRole.tutor, "مرشد (Tutor)", Icons.account_balance_outlined, theme),
      ],
    );
  }

  Widget _roleCard(UserRole role, String label, IconData icon, ThemeData theme) {
    final bool isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: isSelected ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.2), blurRadius: 8)] : null,
          ),
          child: Column(
            children: [
              Icon(
                icon, 
                color: isSelected ? Colors.white : theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignUp(AppLocalizations l10n) {
    final name = _fullName.text.trim();
    final email = _email.text.trim();
    final pass = _password.text;
    final confirm = _confirmPassword.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      _showError(l10n.fillAllFieldsError);
      return;
    }

    if (pass != confirm) {
      _showError(l10n.passwordsDoNotMatchError);
      return;
    }

    // استدعاء المنطق مع تمرير الدور المختار
    ref.read(authNotifierProvider.notifier).signUp(
      email: email,
      password: pass,
      fullName: name,
      role: _selectedRole, 
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSectionLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: theme.textTheme.bodyLarge?.fontSize,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isPassword, {bool isConfirm = false}) {
    final theme = Theme.of(context);
    final bool hide = isConfirm ? _hideConfirmPassword : _hidePassword;

    return TextField(
      controller: controller,
      obscureText: isPassword ? hide : false,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintText: hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
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
    return Row(children: [
      _socialBtn(Icons.apple, theme.colorScheme.onSurface, theme.colorScheme.surface),
      const SizedBox(width: 12),
      _socialBtn(null, theme.colorScheme.surface, theme.colorScheme.onSurface, isGoogle: true),
    ]);
  }

  Widget _socialBtn(IconData? icon, Color bg, Color fg, {bool isGoogle = false}) {
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
          onPressed: isLoading ? null : () => Navigator.pushNamed(context, AppRoutes.signIn),
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
        onPressed: isLoading ? null : () => ref.read(authNotifierProvider.notifier).guestLogin(),
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
}
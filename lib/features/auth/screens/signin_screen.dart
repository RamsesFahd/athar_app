import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../widgets/custom_header.dart';
import '../../../core/widgets/custom_button.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../logic/auth_notifier.dart';
import '../../../core/models/user_model.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context); 

    // listening to auth state changes to show error messages or navigate to home screen on successful login
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
        data: (user) {
          if (user != null) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
      );
    });

    // checking the auth state to show loading indicator on the sign in button when the sign in process is ongoing
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomHeader(
            title: l10n.signInWelcome, 
            subtitle: l10n.signInSubtitle,
            imagePath: 'assets/images/signin_header.png',
          ),
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 35, 24, 20),
                //deleted the directionality widget to fix the text direction issue in the text fields
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email label
                      Text(l10n.emailLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _buildTextField(_email, l10n.emailHint, false),
                      const SizedBox(height: 18),
                      // Password label
                      Text(l10n.passwordLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _buildTextField(_password, l10n.passwordHint, true),
                      const SizedBox(height: 10),
                      // Remember me checkbox
                      _buildRememberMeRow(l10n),
                      const SizedBox(height: 20),
                      // Sign in button
                      AtharButton(
                        label: l10n.continueButton,
                        isLoading: authState.isLoading, // pass loading state to button
                      // disable the button when loading to prevent multiple taps (New)
                        onPressed: () {
                          ref.read(authNotifierProvider.notifier).signIn(
                            email: _email.text.trim(),
                            password: _password.text.trim(),
                          );
                        },
                      ),
                      const SizedBox(height: 25),
                      _buildDivider(l10n),
                      const SizedBox(height: 25),
                      _buildSocialButtons(),
                      const SizedBox(height: 25),
                      _buildFooterLinks(l10n,authState.isLoading),
                    ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _hidePassword : false,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _hidePassword = !_hidePassword),
        ) : null,
      ),
    );
  }

  Widget _buildRememberMeRow(AppLocalizations l10n) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _rememberMe,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _rememberMe = v!),
                ),
              ),
              const SizedBox(width: 8),
              Text(l10n.rememberMe),
            ],
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
            child: Text(l10n.forgotPassword),
          ),
        ],
    );
  }

  Widget _buildDivider(AppLocalizations l10n) {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(l10n.orDivider, style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold)),
      ),
      const Expanded(child: Divider()),
    ]);
  }

  Widget _buildSocialButtons() {
    return Row(children: [
      _socialBtn(Icons.apple, Colors.black, Colors.white),
      const SizedBox(width: 12),
      _socialBtn(null, Colors.white, Colors.black, isGoogle: true),
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
              ? Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png', height: 22)
              : Icon(icon, color: fg, size: 24),
        ),
      ),
    );
  }

  Widget _buildFooterLinks(AppLocalizations l10n, bool isLoading) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(l10n.noAccount),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.signUp),
          child: Text(l10n.signUpLink, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ]),
      TextButton(
        onPressed: isLoading 
      ? null 
      : () => ref.read(authNotifierProvider.notifier).guestLogin(), // تحتاجين إضافة الميثود في النوتيفاير
  child: Text(
    l10n.continueAsGuest, 
    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)
  ),
      ),
    ]);
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
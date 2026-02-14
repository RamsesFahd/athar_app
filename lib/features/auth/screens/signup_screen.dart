import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../widgets/custom_header.dart';
import '../../../core/widgets/custom_button.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomHeader(
            title: l10n.signUpTitle,
            subtitle: l10n.signUpSubtitle,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.fullNameLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildTextField(_fullName, l10n.nameHint, false),

                    const SizedBox(height: 18),
                    Text(l10n.emailLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildTextField(_email, l10n.emailHint, false),

                    const SizedBox(height: 18),
                    Text(l10n.passwordLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildPasswordField(_password, l10n.passwordHint, isConfirm: false),

                    const SizedBox(height: 18),
                    Text(l10n.confirmPasswordLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildPasswordField(_confirmPassword, l10n.passwordHint, isConfirm: true),

                    const SizedBox(height: 20),
                    AtharButton(
                      label: l10n.continueButton,
                      onPressed: () {
                        final email = _email.text.trim();
                        final pass = _password.text;
                        final confirm = _confirmPassword.text;

                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter your email')),
                          );
                          return;
                        }

                        if (pass.isEmpty || confirm.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter your password')),
                          );
                          return;
                        }

                        if (pass != confirm) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Passwords do not match')),
                          );
                          return;
                        }
                        
                          Navigator.pushNamed(
                            context,
                            AppRoutes.verifyEmail,
                            arguments: email, // <-- string 
                          );
                        },
                      ),
                        

                    const SizedBox(height: 25),
                    _buildDivider(l10n),
                    const SizedBox(height: 25),
                    _buildSocialButtons(),
                    const SizedBox(height: 25),
                    _buildFooterLinks(l10n),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint, {required bool isConfirm}) {
    final hide = isConfirm ? _hideConfirmPassword : _hidePassword;

    return TextField(
      controller: controller,
      obscureText: hide,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              if (isConfirm) {
                _hideConfirmPassword = !_hideConfirmPassword;
              } else {
                _hidePassword = !_hidePassword;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildDivider(AppLocalizations l10n) {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          l10n.orDivider,
          style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
        ),
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
              ? Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                  height: 22,
                )
              : Icon(icon, color: fg, size: 24),
        ),
      ),
    );
  }

  Widget _buildFooterLinks(AppLocalizations l10n) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(l10n.alreadyHaveAccount),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.signIn),
          child: Text(
            l10n.signInLink,
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      TextButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
        child: Text(
          l10n.continueAsGuest,
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
      ),
    ]);
  }
}
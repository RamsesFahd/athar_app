import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/custom_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CustomHeader(
            title: 'Welcome To Athar',
            subtitle: 'Discover heritage with a modern vision',
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
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _buildTextField(_email, 'example@mail.com', false),
                      const SizedBox(height: 18),
                      const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _buildTextField(_password, '••••••••', true),
                      const SizedBox(height: 10),
                      _buildRememberMeRow(),
                      const SizedBox(height: 20),
                      AtharButton(
                        label: 'Continue',
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
                      ),
                      const SizedBox(height: 25),
                      _buildDivider(),
                      const SizedBox(height: 25),
                      _buildSocialButtons(),
                      const SizedBox(height: 25),
                      _buildFooterLinks(),
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

  Widget _buildRememberMeRow() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
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
              const Text('Remember Me'),
            ],
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
            child: const Text('Forgot Password?'),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text("OR", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold)),
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

  Widget _buildFooterLinks() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.signUp),
          child: Text('Sign Up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ]),
      TextButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
        child: Text('Continue as Guest', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      ),
    ]);
  }
}
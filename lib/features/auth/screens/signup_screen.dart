/*import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  
  Color get _fieldBg => AppColors.background; 
  Color get _border => AppColors.sand900.withAlpha(28); 
  Color get _textMuted => AppColors.sage900.withAlpha(150);
  Color get _hint => AppColors.sage900.withAlpha(100);
  Color get _iconMuted => AppColors.sage900.withAlpha(120);

  InputDecoration _dec(
    BuildContext context, {
    required String label,
    required String hint,
    Widget? suffix,
  }) {
    final text = Theme.of(context).textTheme;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 1.4),
      ),
      labelStyle: text.bodyMedium?.copyWith(
        color: _textMuted,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: text.bodyMedium?.copyWith(color: _hint),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return  Directionality(
    textDirection: TextDirection.ltr,
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    )
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ===== Header =====
                    SizedBox(
                      height: 170,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/signup_header.jpg',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withAlpha(150),
                                  Colors.black.withAlpha(90),
                                  Colors.black.withAlpha(150),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Join Athar',
                                  style: text.displayLarge?.copyWith(
                                    color: Colors.white,
                                    height: 1.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Be part of our cultural journey',
                                  style: text.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ===== Form =====
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _fullName,
                            decoration: _dec(
                              context,
                              label: 'Full Name',
                              hint: 'Enter your name',
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _dec(
                              context,
                              label: 'Email Address',
                              hint: 'example@mail.com',
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Password (عين)
                          TextField(
                            controller: _password,
                            obscureText: _hidePassword,
                            decoration: _dec(
                              context,
                              label: 'Password',
                              hint: '••••••••',
                              suffix: IconButton(
                                onPressed: () =>
                                    setState(() => _hidePassword = !_hidePassword),
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _iconMuted,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Confirm Password (عين)
                          TextField(
                            controller: _confirm,
                            obscureText: _hideConfirm,
                            decoration: _dec(
                              context,
                              label: 'Confirm Password',
                              hint: '••••••••',
                              suffix: IconButton(
                                onPressed: () =>
                                    setState(() => _hideConfirm = !_hideConfirm),
                                icon: Icon(
                                  _hideConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _iconMuted,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Create Account button
                          SizedBox(
                            height: 52,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Create Account',
                                    style: text.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'OR',
                            style: text.bodyMedium?.copyWith(
                              color: _textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Social buttons
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      side: BorderSide.none,
                                    ),
                                    onPressed: () {},
                                    child: const Icon(Icons.apple),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      side: BorderSide(color: _border),
                                    ),
                                    onPressed: () {},
                                    child: const Text(
                                      'G',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: text.bodyMedium?.copyWith(color: _textMuted),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Sign In',
                                  style: text.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );

  }
}*/

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'signin_screen.dart';
import '../profile_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Color get _fieldBg => AppColors.background;
  Color get _border => AppColors.sand900.withAlpha(28);
  Color get _textMuted => AppColors.sage900.withAlpha(150);
  Color get _hint => AppColors.sage900.withAlpha(100);
  Color get _iconMuted => AppColors.sage900.withAlpha(120);

  InputDecoration _dec(
    BuildContext context, {
    required String hint,
    Widget? suffix,
  }) {
    final text = Theme.of(context).textTheme;

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 1.4),
      ),
      hintStyle: text.bodyMedium?.copyWith(color: _hint),
      suffixIcon: suffix,
    );
  }

  Widget _field({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
  }) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: text.bodyMedium?.copyWith(
            color: _textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: _dec(
            context,
            hint: hint,
            suffix: suffix,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(18),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ===== Header =====
                      SizedBox(
                        height: 170,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/signup_header.jpg',
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withAlpha(150),
                                    Colors.black.withAlpha(90),
                                    Colors.black.withAlpha(150),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Join Athar',
                                    style: text.displayLarge?.copyWith(
                                      color: Colors.white,
                                      height: 1.0,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Be part of our cultural journey',
                                    style: text.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ===== Form =====
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _field(
                              context: context,
                              label: 'Full Name',
                              hint: 'Enter your name',
                              controller: _fullName,
                            ),
                            const SizedBox(height: 12),

                            _field(
                              context: context,
                              label: 'Email Address',
                              hint: 'example@mail.com',
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),

                            _field(
                              context: context,
                              label: 'Password',
                              hint: '••••••••',
                              controller: _password,
                              obscureText: _hidePassword,
                              suffix: IconButton(
                                onPressed: () => setState(
                                    () => _hidePassword = !_hidePassword),
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _iconMuted,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            _field(
                              context: context,
                              label: 'Confirm Password',
                              hint: '••••••••',
                              controller: _confirm,
                              obscureText: _hideConfirm,
                              suffix: IconButton(
                                onPressed: () => setState(
                                    () => _hideConfirm = !_hideConfirm),
                                icon: Icon(
                                  _hideConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _iconMuted,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Create Account button
                            SizedBox(
                              height: 52,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ProfileScreen(),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Create Account',
                                      style: text.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'OR',
                              style: text.bodyMedium?.copyWith(
                                color: _textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Social buttons
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        side: BorderSide.none,
                                      ),
                                      onPressed: () {},
                                      child: const Icon(Icons.apple),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        side: BorderSide(color: _border),
                                      ),
                                      onPressed: () {},
                                      child: const Text(
                                        'G',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: text.bodyMedium
                                      ?.copyWith(color: _textMuted),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                       MaterialPageRoute(
                                        builder: (_) => const SignInScreen(),
                                         ),
                                         );
                                         },
                                  child: Text(
                                    'Sign In',
                                    style: text.bodyMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../widgets/custom_header.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());

  Timer? _timer;
  int _secondsLeft = 50;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Read email passed from Sign In as a String
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String) {
      final email = args.trim();
      if (email.isNotEmpty && _emailController.text.isEmpty) {
        _emailController.text = email;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // Starts/Restarts the resend countdown timer
  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 50);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  // Builds the whole screen layout
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomHeader(
            title: l10n.verifyEmailTitle,
            subtitle: l10n.verifyEmailSubtitle,
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 35, 24, 20),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildEmailInfo(l10n),
                              const SizedBox(height: 18),
                              _buildOtpInputs(),
                              const SizedBox(height: 18),
                              _buildVerifyButton(l10n),
                              const SizedBox(height: 12),
                              _buildResendRow(l10n),
                              const SizedBox(height: 18),
                              _buildBackButton(l10n),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Shows the email info text
  Widget _buildEmailInfo(AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.verifyEmailInfoText,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 6),
        Text(
          _emailController.text.isEmpty ? '—' : _emailController.text,
          style: const TextStyle(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  // Builds OTP boxes without overflow (Wrap instead of Row)
  Widget _buildOtpInputs() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: List.generate(6, (i) => _buildOtpBox(i)),
    );
  }

  // Builds a single OTP input box
  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 46,
      height: 54,
      child: TextField(
        controller: _otpControllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (v) => _handleOtpTyping(index, v),
      ),
    );
  }

  // Moves focus between OTP boxes automatically
  void _handleOtpTyping(int index, String value) {
    if (value.isNotEmpty) {
      if (index < _otpControllers.length - 1) {
        FocusScope.of(context).nextFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
    } else {
      if (index > 0) {
        FocusScope.of(context).previousFocus();
      }
    }
  }

  // Main verify button (front-end only for now)
  Widget _buildVerifyButton(AppLocalizations l10n) {
    return AtharButton(
      label: l10n.verifyButton,
      onPressed: () {
        // Front-end only: later you will connect it to backend
        Navigator.pushNamed(context, AppRoutes.home);
      },
    );
  }

  // Resend logic + countdown UI
  Widget _buildResendRow(AppLocalizations l10n) {
    final canResend = _secondsLeft == 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!canResend)
          Text(
            l10n.resendCodeInSeconds(_secondsLeft),
            style: TextStyle(color: Colors.grey[600]),
          ),
        if (canResend)
          TextButton(
            onPressed: () {
              // Front-end only: later you will trigger resend API
              _startTimer();
            },
            child: Text(
              l10n.resendCode,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  // Back to Sign Up button (outline style)
  Widget _buildBackButton(AppLocalizations l10n) {
    return AtharButton(
      label: l10n.backToSignUpButton,
      variant: ButtonVariant.outline,
      onPressed: () => Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.signUp,
        (route) => false,
      ),
    );
  }
}

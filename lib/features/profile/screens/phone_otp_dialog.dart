import 'dart:async';

import 'package:athar_app/features/profile/logic/profile_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Two-step dialog: (1) enter phone → (2) enter 6-digit OTP.
class PhoneOtpDialog extends ConsumerStatefulWidget {
  final String? currentPhone;
  const PhoneOtpDialog({super.key, this.currentPhone});

  @override
  ConsumerState<PhoneOtpDialog> createState() => _PhoneOtpDialogState();
}

class _PhoneOtpDialogState extends ConsumerState<PhoneOtpDialog> {
  // ── step tracking ────────────────────────────────────────────────────────
  bool _otpStep = false;
  String _phoneNumber = '';

  // ── phone step ───────────────────────────────────────────────────────────
  final _phoneController = TextEditingController();
  String? _phoneError;

  // ── OTP step ─────────────────────────────────────────────────────────────
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  int _countdown = 60;
  Timer? _timer;

  // ── lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    if (widget.currentPhone != null) {
      _phoneController.text = widget.currentPhone!.replaceFirst('+966', '');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) { c.dispose(); }
    for (final f in _otpFocusNodes) { f.dispose(); }
    _timer?.cancel();
    super.dispose();
  }

  // ── helpers ───────────────────────────────────────────────────────────────
  String get _fullPhone => '+966${_phoneController.text.trim()}';

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  void _clearOtp() {
    for (final c in _otpControllers) { c.clear(); }
    _otpFocusNodes.first.requestFocus();
  }

  // ── actions ───────────────────────────────────────────────────────────────
  void _sendOtp({bool isResend = false}) {
    final l10n = AppLocalizations.of(context);
    final raw = _phoneController.text.trim();
    if (raw.length < 9) {
      setState(() => _phoneError = l10n.phoneInvalidError);
      return;
    }
    setState(() => _phoneError = null);
    _phoneNumber = _fullPhone;

    ref.read(profileNotifierProvider.notifier).sendPhoneOtp(
      phoneNumber: _phoneNumber,
      onCodeSent: () {
        if (!mounted) return;
        setState(() => _otpStep = true);
        _startCountdown();
        if (isResend) _clearOtp();
      },
      onError: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_otp.length < 6) return;
    await ref.read(profileNotifierProvider.notifier).verifyPhoneOtp(
      smsCode: _otp,
      phoneNumber: _phoneNumber,
    );

    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final state = ref.read(profileNotifierProvider);
    if (state is AsyncData) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.phoneVerifiedSuccess)),
      );
    } else if (state is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString().replaceFirst('Exception: ', ''))),
      );
      _clearOtp();
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.colorScheme.primary == Colors.black;
    final isLoading =
        ref.watch(profileNotifierProvider) is AsyncLoading;

    return PopScope(
      canPop: !isLoading,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _otpStep ? AppLocalizations.of(context).otpDialogTitle : AppLocalizations.of(context).phoneDialogTitle,
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: _otpStep
              ? _buildOtpStep(theme, isLoading, isHighContrast)
              : _buildPhoneStep(theme, isLoading, isHighContrast),
        ),
        actions: _otpStep
            ? _otpActions(theme, isLoading)
            : _phoneActions(theme, isLoading),
      ),
    );
  }

  // ── phone step UI ─────────────────────────────────────────────────────────
  Widget _buildPhoneStep(ThemeData theme, bool isLoading, bool isHighContrast,) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.phoneSmsSubtitle,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: isHighContrast
    ? theme.colorScheme.onSurface
    : theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          enabled: !isLoading,
          decoration: InputDecoration(
            prefixText: '+966  ',
            hintText: '5xxxxxxxx',
            errorText: _phoneError,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _sendOtp(),
        ),
      ],
    );
  }

  List<Widget> _phoneActions(ThemeData theme, bool isLoading) {
    final l10n = AppLocalizations.of(context);
    return [
      TextButton(
        onPressed: isLoading ? null : () => Navigator.of(context).pop(),
        child: Text(l10n.cancel),
      ),
      FilledButton(
        onPressed: isLoading ? null : _sendOtp,
        child: isLoading
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(l10n.otpSendCode),
      ),
    ];
  }

  // ── OTP step UI ───────────────────────────────────────────────────────────
  Widget _buildOtpStep(ThemeData theme, bool isLoading, bool isHighContrast,) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.otpSentTo(_phoneNumber),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: isHighContrast
    ? theme.colorScheme.onSurface
    : theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 20),
        _buildOtpBoxes(theme, isLoading),
        const SizedBox(height: 16),
        _buildResendRow(theme, isLoading),
      ],
    );
  }

  Widget _buildOtpBoxes(ThemeData theme, bool isLoading) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (i) {
          return SizedBox(
            width: 42,
            height: 52,
            child: TextField(
              controller: _otpControllers[i],
              focusNode: _otpFocusNodes[i],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              enabled: !isLoading,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (val) {
                if (val.isNotEmpty) {
                  if (i < 5) {
                    _otpFocusNodes[i + 1].requestFocus();
                  } else {
                    _otpFocusNodes[i].unfocus();
                    _verifyOtp();
                  }
                } else if (val.isEmpty && i > 0) {
                  _otpFocusNodes[i - 1].requestFocus();
                }
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildResendRow(ThemeData theme, bool isLoading) {
    final l10n = AppLocalizations.of(context);
    if (_countdown > 0) {
      return Text(
        l10n.otpResendIn(_countdown),
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      );
    }
    return TextButton(
      onPressed: isLoading ? null : () => _sendOtp(isResend: true),
      child: Text(l10n.otpResendCode),
    );
  }

  List<Widget> _otpActions(ThemeData theme, bool isLoading) {
    final l10n = AppLocalizations.of(context);
    return [
      TextButton(
        onPressed: isLoading
            ? null
            : () => setState(() {
                  _otpStep = false;
                  _timer?.cancel();
                }),
        child: Text(l10n.goBack),
      ),
      FilledButton(
        onPressed: isLoading ? null : _verifyOtp,
        child: isLoading
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(l10n.verifyButton),
      ),
    ];
  }
}
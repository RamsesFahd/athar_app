import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/models/user/user_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/auth_utils.dart';
import '../logic/auth_notifier.dart';

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
  bool _isLoginLoading = false;
  bool _isGoogleLoading = false;

  static const _kRememberMeKey = 'remember_me';
  static const _kSavedEmailKey = 'saved_email';

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_kRememberMeKey) ?? false;
    final savedEmail = prefs.getString(_kSavedEmailKey) ?? '';
    if (mounted && remember && savedEmail.isNotEmpty) {
      setState(() {
        _rememberMe = true;
        _email.text = savedEmail;
      });
    }
  }

  Future<void> _persistRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool(_kRememberMeKey, true);
      await prefs.setString(_kSavedEmailKey, _email.text.trim());
    } else {
      await prefs.remove(_kRememberMeKey);
      await prefs.remove(_kSavedEmailKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // listening to auth state changes to show error messages or navigate to home screen on successful login
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
            _persistRememberMe();
            TextInput.finishAutofillContext();
            if (user is AdminModel) {
              Navigator.pushReplacementNamed(context, AppRoutes.admin);
              return;
            }
            // redirecting to email verification screen if the user's email is not verified
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

    // checking the auth state to show loading indicator on the sign in button when the sign in process is ongoing
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
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
                      Text(l10n.emailLabel,
                          style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: theme.textTheme.bodyLarge?.fontSize)),
                      const SizedBox(height: 8),
                      _buildTextField(_email, l10n.emailHint, false,
                          autofillHints: const [AutofillHints.email]),
                      const SizedBox(height: 18),
                      Text(l10n.passwordLabel,
                          style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: theme.textTheme.bodyLarge?.fontSize)),
                      const SizedBox(height: 8),
                      _buildTextField(_password, l10n.passwordHint, true,
                          autofillHints: const [AutofillHints.password]),
                      const SizedBox(height: 10),
                      _buildRememberMeRow(l10n),
                      const SizedBox(height: 20),
                      AtharButton(
                        label: l10n.continueButton,
                        isLoading: _isLoginLoading,
                        onPressed: authState.isLoading
                            ? null
                            : () async {
                                final email = _email.text.trim();
                                final password = _password.text.trim();
                                if (email.isEmpty || password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.emptyLoginFieldsError),
                                    ),
                                  );
                                  return;
                                }
                                setState(() => _isLoginLoading = true);
                                await ref
                                    .read(authNotifierProvider.notifier)
                                    .signIn(
                                      email: email,
                                      password: password,
                                    );
                                if (mounted)
                                  setState(() => _isLoginLoading = false);
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

  Widget _buildTextField(
      TextEditingController controller, String hint, bool isPassword,
      {List<String>? autofillHints}) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      obscureText: isPassword ? _hidePassword : false,
      autofillHints: autofillHints,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
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
            )),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.35),
            )),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: theme.colorScheme.primary),
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
              )
            : null,
      ),
    );
  }

  Widget _buildRememberMeRow(AppLocalizations l10n) {
    final theme = Theme.of(context);
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
                activeColor: theme.colorScheme.primary,
                onChanged: (v) => setState(() => _rememberMe = v!),
              ),
            ),
            const SizedBox(width: 8),
            Text(l10n.rememberMe, style: theme.textTheme.bodyMedium),
          ],
        ),
        TextButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.forgotPassword),
          child: Text(l10n.forgotPassword,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    return Row(children: [
      _socialBtn(
          Icons.apple, theme.colorScheme.onSurface, theme.colorScheme.surface),
      const SizedBox(width: 12),
      _socialBtn(null, theme.colorScheme.surface, theme.colorScheme.onSurface,
          isGoogle: true,
          onTap: authState.isLoading
              ? null
              : () async {
                  setState(() => _isGoogleLoading = true);
                  await ref
                      .read(authNotifierProvider.notifier)
                      .signInWithGoogle();
                  if (mounted) setState(() => _isGoogleLoading = false);
                }),
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
                    : CachedNetworkImage(
                        imageUrl:
                            'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png',
                        height: 28,
                        placeholder: (_, __) => const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.g_mobiledata, size: 28),
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
        Text(l10n.noAccount, style: theme.textTheme.bodyMedium),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.signUp),
          child: Text(l10n.signUpLink,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold)),
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
}

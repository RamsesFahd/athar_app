import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/navigation/app_routes.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/auth/widgets/custom_button.dart';
import 'package:athar_app/features/auth/widgets/custom_header.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class GoogleRoleSelectionScreen extends ConsumerStatefulWidget {
  const GoogleRoleSelectionScreen({super.key});

  @override
  ConsumerState<GoogleRoleSelectionScreen> createState() =>
      _GoogleRoleSelectionScreenState();
}

class _GoogleRoleSelectionScreenState
    extends ConsumerState<GoogleRoleSelectionScreen> {
  UserRole _selectedRole = UserRole.tourist;
  TutorType? _selectedTutorType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authNotifierProvider);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    ref.listen<AsyncValue<UserModel?>>(authNotifierProvider, (_, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isAr
                  ? 'تعذّر إكمال تسجيل الدخول. يرجى المحاولة مرة أخرى.'
                  : 'We couldn’t finish signing you in. Please try again.'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        },
        data: (user) {
          if (user != null) {
            final tourist = user is TouristModel ? user : null;
            final hasInterests = tourist?.culturalInterests.isNotEmpty ?? false;
            if (tourist != null &&
                tourist.role != UserRole.guest &&
                !hasInterests) {
              Navigator.pushReplacementNamed(context, AppRoutes.userPreferences);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          }
        },
      );
    });

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: l10n.welcomeToAthar,
            subtitle: isAr ? 'اختر نوع حسابك للمتابعة' : 'Choose your account type',
            storagePath: 'static/auth/signup_header.png',
            centerText: true,
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
                    Text(l10n.signUpAsLabel, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _buildRoleSelector(theme, l10n),
                    if (_selectedRole == UserRole.tutor) ...[
                      const SizedBox(height: 20),
                      Text(l10n.guideTypeLabel, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _tutorTypeOption(TutorType.individual, l10n.guideTypeIndependent, theme),
                          const SizedBox(width: 12),
                          _tutorTypeOption(TutorType.company, l10n.guideTypeCompany, theme),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),
                    AtharButton(
                      label: l10n.continueButton,
                      isLoading: authState.isLoading,
                      onPressed: authState.isLoading ? null : () => _handleConfirm(l10n, isAr),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        _roleCard(UserRole.tourist, l10n.touristRole, Icons.explore_outlined, theme),
        const SizedBox(width: 12),
        _roleCard(UserRole.tutor, l10n.tutorRole, Icons.account_balance_outlined, theme),
      ],
    );
  }

  Widget _roleCard(UserRole role, String label, IconData icon, ThemeData theme) {
    final isSelected = _selectedRole == role;
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
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: 2,
            ),
            boxShadow: isSelected
                ? [BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                  )]
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
                : theme.colorScheme.outlineVariant,
          ),
          foregroundColor:
              isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
        ),
        onPressed: () => setState(() => _selectedTutorType = type),
        child: Text(label, style: theme.textTheme.bodyMedium),
      ),
    );
  }

  void _handleConfirm(AppLocalizations l10n, bool isAr) {
    if (_selectedRole == UserRole.tutor && _selectedTutorType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? 'يرجى اختيار نوع الحساب' : 'Please select an account type'),
        ),
      );
      return;
    }
    ref.read(authNotifierProvider.notifier).createGoogleUser(
      role: _selectedRole,
      tutorType: _selectedTutorType,
    );
  }
}

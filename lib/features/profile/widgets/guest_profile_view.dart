// guest_profile_view.dart
import 'package:flutter/material.dart';
import 'package:athar_app/features/profile/widgets/settings_tile.dart';
import 'package:athar_app/core/navigation/app_routes.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class GuestProfileView extends StatelessWidget {
  const GuestProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // 1. قسم الترحيب واللوجو
              _buildHeroSection(theme, l10n),
              const SizedBox(height: 32),

              // 2. زر الانضمام
              _buildJoinButton(context, theme, l10n),
              const SizedBox(height: 40),

              // 3. بطاقة تشويق المساهمة (Gamification)
              _buildContributionTeaser(theme, l10n),
              const SizedBox(height: 40),

              // 4. قسم المساعدة والدعم
              _buildSupportGroup(context, theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        Image.asset(
          'assets/images/athar_logo_illustration.png',
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),
        Text(
         l10n.welcomeToAthar,
  textAlign: TextAlign.center,
  style: theme.textTheme.displayLarge?.copyWith(
    color: theme.colorScheme.primary,
    fontWeight: FontWeight.bold,
  ),
),
        const SizedBox(height: 12),
        Text(
          l10n.startYourJourney,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildJoinButton(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.signUp), //
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          l10n.joinUsNow,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildContributionTeaser(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.stars_rounded, color: theme.colorScheme.primary, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.leaveYourCulturalImpact,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.contributionTeaserDescription,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportGroup(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Text(
            l10n.settingsSupportLegal,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              SettingsTile(
                //
                title: l10n.settingsContactUs,
                leadingIcon: Icons.support_agent_rounded,
                 onTap: () => Navigator.pushNamed(context, AppRoutes.contactUs),
              ),
              SettingsTile(
                title: l10n.settingsAboutAthar,
                leadingIcon: Icons.info_outline_rounded,
                 onTap: () => Navigator.pushNamed(context, AppRoutes.aboutAthar),
              ),
              SettingsTile(
                title: l10n.settingsPrivacyPolicy,
                leadingIcon: Icons.privacy_tip_outlined,
                onTap: () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

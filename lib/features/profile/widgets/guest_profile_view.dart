// guest_profile_view.dart
import 'package:flutter/material.dart';
import 'package:athar_app/features/profile/widgets/settings_tile.dart';
import 'package:athar_app/core/navigation/app_routes.dart';

class GuestProfileView extends StatelessWidget {
  const GuestProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // 1. قسم الترحيب واللوجو
              _buildHeroSection(theme),
              const SizedBox(height: 32),

              // 2. زر الانضمام
              _buildJoinButton(context, theme),
              const SizedBox(height: 40),

              // 3. بطاقة تشويق المساهمة (Gamification)
              _buildContributionTeaser(theme),
              const SizedBox(height: 40),

              // 4. قسم المساعدة والدعم
              _buildSupportGroup(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    return Column(
      children: [
        Image.asset(
          'assets/images/athar_logo_illustration.png',
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),
        Text(
          "أهلاً بك في أثر",
          style: theme.textTheme.displayMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "ابدأ رحلتك الآن في اكتشاف وتوثيق كنوزنا الثقافية واترك بصمتك الخاصة",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildJoinButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.signUp), //
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          "انضم إلينا الآن",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildContributionTeaser(ThemeData theme) {
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
                const Text(
                  "اترك أثرك الثقافي",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "شاركنا بصور ومعلومات واجمع النقاط لتصل إلى قائمة كبار المساهمين",
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportGroup(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Text(
            "المساعدة والقانونية",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                title: "تواصل معنا",
                leadingIcon: Icons.support_agent_rounded,
                onTap: () {},
              ),
              SettingsTile(
                title: "عن أثر",
                leadingIcon: Icons.info_outline_rounded,
                onTap: () {},
              ),
              SettingsTile(
                title: "سياسة الخصوصية",
                leadingIcon: Icons.privacy_tip_outlined,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

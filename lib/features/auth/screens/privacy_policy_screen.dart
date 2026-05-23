import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(
          l10n.privacyPolicyTitle,
          style: theme.textTheme.titleLarge
              ?.copyWith(color: theme.colorScheme.onPrimary),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: l10n.privacyPolicyIntroTitle,
              body: l10n.privacyPolicyIntroBody,
            ),
            _buildSection(
              context,
              title: l10n.privacyPolicyDataTitle,
              body: l10n.privacyPolicyDataBody,
            ),
            _buildSection(
              context,
              title: l10n.privacyPolicyUseTitle,
              body: l10n.privacyPolicyUseBody,
            ),
            _buildSection(
              context,
              title: l10n.privacyPolicySharingTitle,
              body: l10n.privacyPolicySharingBody,
            ),
            _buildSection(
              context,
              title: l10n.privacyPolicyRightsTitle,
              body: l10n.privacyPolicyRightsBody,
            ),
            _buildSection(
              context,
              title: l10n.privacyPolicyContactTitle,
              body: l10n.privacyPolicyContactBody,
            ),
            _buildSection(
              context,
              title: l10n.privacyDisclaimerTouristTitle,
              body: l10n.privacyDisclaimerTouristBody,
            ),
            _buildSection(
              context,
              title: l10n.privacyDisclaimerGuideTitle,
              body: l10n.privacyDisclaimerGuideBody,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String body,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        if (!isLast) ...[
          const SizedBox(height: 20),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

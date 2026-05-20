import 'package:flutter/material.dart';
import 'package:athar_app/core/constants/region_city_constants.dart';
import 'package:athar_app/core/models/contribution/contribution_model.dart';
import 'package:athar_app/features/contributions/screens/add_contribution_screen.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ContributionRejectionDetailScreen extends StatelessWidget {
  final ContributionModel contribution;

  const ContributionRejectionDetailScreen(
      {super.key, required this.contribution});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final c = contribution;

    final regionEn = regionLabel(c.regionId, isArabic: false);
    final regionAr = regionLabel(c.regionId, isArabic: true);
    final cityEn = cityLabel(c.cityId, isArabic: false);
    final cityAr = cityLabel(c.cityId, isArabic: true);
    final date = DateFormat('MMM d, yyyy').format(c.createdAt);

    final sourceTitle = c.submissionLanguage == 'ar' ? c.titleAr : c.titleEn;
    final sourceDesc =
        c.submissionLanguage == 'ar' ? c.descriptionAr : c.descriptionEn;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contributionRejectionDetailsTitle),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        children: [
          // Media preview
          _buildMediaPreview(theme, c),
          const SizedBox(height: 16),

          // Rejection reason — prominent
          _buildRejectionCard(theme, l10n, isAr, c.rejectionReason),
          const SizedBox(height: 16),

          // Submitted content
          _buildInfoCard(
            theme,
            title: l10n.contributionSubmittedContentTitle,
            children: [
              _InfoRow(
                icon: Icons.title,
                label: l10n.titleLabel,
                value: sourceTitle.isNotEmpty
                    ? sourceTitle
                    : l10n.commonNoTitle,
              ),
              _InfoRow(
                icon: Icons.notes_rounded,
                label: l10n.descriptionLabel,
                value: sourceDesc.isNotEmpty
                    ? sourceDesc
                    : l10n.commonNoDescription,
                maxLines: 6,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Submission details
          _buildInfoCard(
            theme,
            title: l10n.contributionSubmissionInfoTitle,
            children: [
              _InfoRow(
                icon: Icons.category_outlined,
                label: l10n.categoryLabel,
                value: c.category.replaceAll('_', ' '),
              ),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: l10n.locationLabel,
                value: isAr ? regionAr : regionEn,
              ),
              _InfoRow(
                icon: Icons.location_city_outlined,
                label: l10n.cityLabel,
                value: isAr ? cityAr : cityEn,
              ),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: l10n.contributionSubmittedDateLabel,
                value: date,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddContributionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: Text(
                l10n.contributionSubmitNew,
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(ThemeData theme, ContributionModel c) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: c.mediaType == 'image' && c.mediaUrl.isNotEmpty
          ? Image.network(
              c.mediaUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _mediaPlaceholder(theme),
            )
          : _mediaPlaceholder(theme, isVideo: c.mediaType == 'video'),
    );
  }

  Widget _mediaPlaceholder(ThemeData theme, {bool isVideo = false}) {
    return Container(
      height: 220,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isVideo ? Icons.videocam_rounded : Icons.image_not_supported_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            isVideo ? 'Video Submission' : 'Image unavailable',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionCard(
    ThemeData theme, AppLocalizations l10n, bool isAr, String? rejectionReason) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cancel_outlined,
              color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.contributionRejectionReason,
                  style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  rejectionReason ??
                      (isAr
                          ? 'لم يُذكر سبب محدد'
                          : 'No specific reason provided'),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        border:
            Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int maxLines;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style:
                  theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

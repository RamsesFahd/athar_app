import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:athar_app/core/models/contribution/contribution_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/core/constants/region_city_constants.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';
import 'package:athar_app/features/admin/screens/contribution_review_detail_screen.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

final _contributionsStreamProvider =
    StreamProvider.autoDispose<List<ContributionModel>>((ref) {
  return ref.watch(adminRepositoryProvider).getContributions();
});

class ContributionsReviewScreen extends ConsumerStatefulWidget {
  const ContributionsReviewScreen({super.key});

  @override
  ConsumerState<ContributionsReviewScreen> createState() =>
      _ContributionsReviewScreenState();
}

class _ContributionsReviewScreenState
    extends ConsumerState<ContributionsReviewScreen> {
  ContributionStatus? _filter = ContributionStatus.pending;

  static const Map<String, IconData> _categoryIcons = {
    'traditional_food': Icons.restaurant_rounded,
    'handicraft': Icons.handyman_rounded,
    'dance': Icons.theater_comedy_rounded,
    'architecture': Icons.account_balance_rounded,
    'music': Icons.music_note_rounded,
    'traditional_clothing': Icons.checkroom_rounded,
  };

  static const Map<String, String> _categoryLabels = {
    'traditional_food': 'Traditional Food',
    'handicraft': 'Handicraft',
    'dance': 'Dance',
    'architecture': 'Architecture',
    'music': 'Music',
    'traditional_clothing': 'Traditional Clothing',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final contributionsAsync = ref.watch(_contributionsStreamProvider);

    return Column(
      children: [
        _buildFilterRow(theme),
        Expanded(
          child: contributionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text(l10n.commonErrorWithMessage(''))),
            data: (all) {
              final filtered = _filter == null
                  ? all
                  : all
                      .where((c) => c.status == _filter)
                      .toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text(
                        'No ${_filter?.name ?? ''} contributions',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) =>
                    _ContributionCard(
                  contribution: filtered[index],
                  categoryIcons: _categoryIcons,
                  categoryLabels: _categoryLabels,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContributionReviewDetailScreen(
                        contribution: filtered[index],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow(ThemeData theme) {
    final filters = [
      (label: 'قيد المراجعة', value: ContributionStatus.pending),
      (label: 'مقبول', value: ContributionStatus.approved),
      (label: 'مرفوض', value: ContributionStatus.rejected),
      (label: 'الكل', value: null),
    ];

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = _filter == f.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  f.label,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => setState(() => _filter = f.value),
                selectedColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                checkmarkColor: AppColors.primary,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.withValues(alpha: 0.35),
                ),
                showCheckmark: true,
                pressElevation: 0,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ContributionCard extends StatelessWidget {
  final ContributionModel contribution;
  final Map<String, IconData> categoryIcons;
  final Map<String, String> categoryLabels;
  final VoidCallback onTap;

  const _ContributionCard({
    required this.contribution,
    required this.categoryIcons,
    required this.categoryLabels,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = contribution;
    final icon = categoryIcons[c.category] ?? Icons.category_outlined;
    final label = categoryLabels[c.category] ?? c.category;
    final region = regionLabel(c.regionId, isArabic: false);
    final city = cityLabel(c.cityId, isArabic: false);
    final date = DateFormat('MMM d, yyyy').format(c.createdAt);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.displayTitle.isNotEmpty
                                ? c.displayTitle
                                : 'No title',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(status: c.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$label · $region, $city',
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          c.mediaType == 'video'
                              ? Icons.videocam_outlined
                              : Icons.image_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          c.mediaType == 'video' ? 'Video' : 'Image',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const Spacer(),
                        Text(
                          c.touristName,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ContributionStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ContributionStatus.pending => ('Pending', Colors.orange),
      ContributionStatus.approved => ('Approved', Colors.green),
      ContributionStatus.rejected => ('Rejected', Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

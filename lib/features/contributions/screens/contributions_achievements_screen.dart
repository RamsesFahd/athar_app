import 'package:athar_app/core/constants/region_city_constants.dart';
import 'package:athar_app/core/models/contribution/contribution_model.dart';
import 'package:athar_app/core/models/contribution/user_reward_model.dart';
import 'package:athar_app/features/contributions/logic/contribution_repository.dart';
import 'package:athar_app/features/contributions/screens/add_contribution_screen.dart';
import 'package:athar_app/features/contributions/screens/contribution_rejection_detail_screen.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_repository.dart';
import 'package:athar_app/features/cultural_archive/widgets/cultural_item_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/contributions/widgets/badge_card.dart';
import 'package:athar_app/features/profile/widgets/tourist_profile.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

// Stream provider family — keyed by touristId
final _touristContributionsProvider = StreamProvider.autoDispose
    .family<List<ContributionModel>, String>((ref, touristId) {
  return ref
      .watch(contributionRepositoryProvider)
      .getTouristContributions(touristId);
});

class ContributionsAchievementsScreen extends ConsumerStatefulWidget {
  const ContributionsAchievementsScreen({super.key});

  @override
  ConsumerState<ContributionsAchievementsScreen> createState() =>
      _ContributionsAchievementsScreenState();
}

class _ContributionsAchievementsScreenState
    extends ConsumerState<ContributionsAchievementsScreen> {
  final Set<String> _celebratingRewardIds = {};

  static const double _pageHorizontalPadding = 16;

  // Thresholds: [0, 250, 500, 750, 1000] → maps to 5 levels
  static const List<int> _levelThresholds = [0, 250, 500, 750, 1000];

  static String _levelName(int pts, AppLocalizations l10n, bool isArabic) {
    if (pts >= 1000) return isArabic ? 'سفير التراث' : 'Heritage Ambassador';
    if (pts >= 750) return l10n.heritagePreserverLevel;
    if (pts >= 500) return l10n.culturalContributorLevel;
    if (pts >= 250) return l10n.contributionActiveContributor;
    return l10n.communityMember;
  }

  static String _nextLevelName(int pts, AppLocalizations l10n, bool isArabic) {
    if (pts >= 750) return isArabic ? 'سفير التراث' : 'Heritage Ambassador';
    if (pts >= 500) return l10n.heritagePreserverLevel;
    if (pts >= 250) return l10n.culturalContributorLevel;
    return l10n.contributionActiveContributor;
  }

  // Category display labels & icons
  static const Map<String, String> _categoryLabelsAr = {
    'traditional_food': 'أكل شعبي',
    'handicraft': 'حرف يدوية',
    'dance': 'رقص',
    'architecture': 'عمارة',
    'music': 'موسيقى',
    'traditional_clothing': 'لبس تقليدي',
  };

  static const Map<String, String> _categoryLabelsEn = {
    'traditional_food': 'Traditional Food',
    'handicraft': 'Handicraft',
    'dance': 'Dance',
    'architecture': 'Architecture',
    'music': 'Music',
    'traditional_clothing': 'Traditional Clothing',
  };

  static const Map<String, IconData> _categoryIcons = {
    'traditional_food': Icons.restaurant_rounded,
    'handicraft': Icons.handyman_rounded,
    'dance': Icons.theater_comedy_rounded,
    'architecture': Icons.account_balance_rounded,
    'music': Icons.music_note_rounded,
    'traditional_clothing': Icons.checkroom_rounded,
  };

  static const Map<String, Color> _categoryColors = {
    'traditional_food': Color(0xFFFF9800),
    'handicraft': Color(0xFF795548),
    'dance': Color(0xFF9C27B0),
    'architecture': Color(0xFF607D8B),
    'music': Color(0xFF2196F3),
    'traditional_clothing': Color(0xFFE91E63),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (user) {
        if (user == null || user.role == UserRole.guest) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 44,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n.contributionGuestAccessMessage,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final tourist = user as TouristModel;

        // Watch a live stream of the tourist's Firestore document so
        // points/contributionsCount update in real time after admin approval.
        final liveTouristAsync = ref.watch(touristStreamProvider(tourist.uId));
        final liveTourist = liveTouristAsync.valueOrNull ?? tourist;
        final uncelebratedRewardsAsync =
            ref.watch(uncelebratedRewardsProvider(tourist.uId));
        uncelebratedRewardsAsync.whenData((rewards) {
          if (rewards.isEmpty) return;
          final reward = rewards.first;
          if (_celebratingRewardIds.contains(reward.id)) return;
          _celebratingRewardIds.add(reward.id);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showRewardUnlockedDialog(context, tourist.uId, reward, l10n);
          });
        });

        // Watch the live contributions stream for this tourist
        final contributionsAsync =
            ref.watch(_touristContributionsProvider(tourist.uId));

        return contributionsAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            body: Center(child: Text(l10n.commonErrorWithMessage(''))),
          ),
          data: (contributions) {
            final repo = ref.read(contributionRepositoryProvider);
            final stats = repo.computeStats(contributions);
            final achievements = repo.computeAchievements(contributions);
            final badges = _buildBadges(achievements, isArabic, theme, l10n);

            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (!tourist.phoneVerified) {
                    _showPhoneGuardDialog(context, isArabic);
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddContributionScreen(),
                    ),
                  );
                },
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                child: const Icon(Icons.add_rounded),
              ),
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        _pageHorizontalPadding,
                        12,
                        _pageHorizontalPadding,
                        24,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            TouristHeader(
                              user: liveTourist,
                              showEmail: false,
                              isContributionPage: true,
                            ),
                            const SizedBox(height: 16),
                            _buildRewardBanner(theme, isArabic),
                            const SizedBox(height: 16),
                            _buildLevelCard(
                              theme,
                              isArabic,
                              l10n: l10n,
                              currentPoints: stats.totalPoints,
                            ),
                            const SizedBox(height: 18),
                            _buildStatsRow(
                              theme,
                              isArabic,
                              l10n: l10n,
                              contributionsCount: stats.contributionsCount,
                              totalFavorites: stats.totalLikes,
                              totalShares: stats.totalShares,
                              qualityBonusCount: stats.qualityBonusCount,
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle(
                              theme,
                              l10n.contributionAchievementsSection,
                            ),
                            const SizedBox(height: 12),
                            badges.isEmpty
                                ? _buildBadgesEmptyMessage(theme, l10n)
                                : _buildAchievementsRow(badges),
                            const SizedBox(height: 24),
                            _buildSectionTitle(
                              theme,
                              l10n.contributionMyContributionsSection,
                            ),
                            const SizedBox(height: 12),
                            if (contributions.isEmpty)
                              _buildContributionsEmptyMessage(theme, l10n)
                            else
                              ...contributions.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildContributionCard(
                                      context, ref, theme, item, isArabic),
                                ),
                              ),
                            const SizedBox(height: 90),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text(l10n.commonErrorWithMessage(''))),
      ),
    );
  }

  Future<void> _showRewardUnlockedDialog(
    BuildContext context,
    String touristId,
    UserRewardModel reward,
    AppLocalizations l10n,
  ) async {
    if (!mounted) return;
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    final rewardTitle = isArabic ? reward.titleAr : reward.titleEn;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(l10n.rewardUnlockedTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.card_giftcard_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              if (rewardTitle.isNotEmpty) ...[
                Text(
                  rewardTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                l10n.rewardUnlockedMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              if (reward.type == 'free_trip') ...[
                const SizedBox(height: 10),
                Text(
                  l10n.freeTripRewardUnlockedMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonOk),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    await ref
        .read(contributionRepositoryProvider)
        .markRewardCelebrated(touristId, reward.id);
  }

  void _showPhoneGuardDialog(BuildContext context, bool isArabic) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.contributionPhoneVerificationRequiredTitle),
        content: Text(l10n.contributionPhoneVerificationRequiredBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonOk),
          ),
        ],
      ),
    );
  }

  // Converts AchievementData → _BadgeUiModel for the UI
  List<_BadgeUiModel> _buildBadges(
    List<AchievementData> achievements,
    bool isArabic,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final defs = [
      (
        id: 'first_contribution',
        titleAr: 'أول إثراء',
        titleEn: 'First Enrichment',
        icon: Icons.flag_rounded,
        color: theme.colorScheme.primary,
      ),
      (
        id: 'narrator',
        titleAr: 'الراوي',
        titleEn: 'Narrator',
        icon: Icons.auto_stories_rounded,
        color: theme.colorScheme.tertiary,
      ),
      (
        id: 'explorer',
        titleAr: 'المستكشف',
        titleEn: 'Explorer',
        icon: Icons.explore_outlined,
        color: theme.colorScheme.secondary,
      ),
      (
        id: 'loved',
        titleAr: 'المحبوب',
        titleEn: 'Loved',
        icon: Icons.favorite_border_rounded,
        color: theme.colorScheme.error,
      ),
      (
        id: 'heritage_ambassador',
        titleAr: 'سفير التراث',
        titleEn: 'Heritage Ambassador',
        icon: Icons.workspace_premium_outlined,
        color: theme.colorScheme.tertiary,
      ),
    ];

    return defs.map((def) {
      final data = achievements.firstWhere(
        (a) => a.id == def.id,
        orElse: () =>
            AchievementData(id: def.id, isEarned: false, current: 0, target: 1),
      );
      final progressLabel = data.isEarned
          ? l10n.contributionCompleted
          : '${data.current}/${data.target}';

      return _BadgeUiModel(
        title: isArabic ? def.titleAr : def.titleEn,
        description: '',
        icon: def.icon,
        isEarned: data.isEarned,
        progressLabel: progressLabel,
        color: def.color,
      );
    }).toList();
  }

  Widget _buildRewardBanner(ThemeData theme, bool isArabic) {
    final accent = theme.colorScheme.tertiary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(Icons.card_giftcard_rounded,
                color: theme.colorScheme.onPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isArabic
                  ? 'جائزة سفير التراث: خصم حصري على حجز رحلتك القادمة عند وصولك إلى 1000 نقطة'
                  : 'Heritage Ambassador Reward: Exclusive discount on your next booking when you reach 1000 points',
              style: theme.textTheme.bodySmall
                  ?.copyWith(height: 1.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(
    ThemeData theme,
    bool isArabic, {
    required AppLocalizations l10n,
    required int currentPoints,
  }) {
    // Find current level index
    int levelIndex = 0;
    for (int i = _levelThresholds.length - 1; i >= 0; i--) {
      if (currentPoints >= _levelThresholds[i]) {
        levelIndex = i;
        break;
      }
    }
    final isMaxLevel = levelIndex == _levelThresholds.length - 1;
    final currentThreshold = _levelThresholds[levelIndex];
    final nextThreshold =
        isMaxLevel ? _levelThresholds.last : _levelThresholds[levelIndex + 1];

    final rangeSize = nextThreshold - currentThreshold;
    final progressValue = isMaxLevel
        ? 1.0
        : (rangeSize == 0 ? 1.0 : (currentPoints - currentThreshold) / rangeSize);
    final remainingPoints = isMaxLevel ? 0 : nextThreshold - currentPoints;

    final currentLevelName = _levelName(currentPoints, l10n, isArabic);
    final nextLevelName = _nextLevelName(currentPoints, l10n, isArabic);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.contributionContributorLevel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentLevelName,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$currentPoints',
                style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900, fontSize: 30, height: 1),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  l10n.contributionPointsUnit,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 9,
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.12),
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '$currentThreshold',
                style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.78)),
              ),
              const Spacer(),
              Text(
                '$nextThreshold',
                style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.78)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isMaxLevel
                ? (isArabic ? 'وصلت للمستوى الأعلى!' : 'Maximum level reached!')
                : l10n.pointsToReachNextLevel(remainingPoints, nextLevelName),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    ThemeData theme,
    bool isArabic, {
    required AppLocalizations l10n,
    required int contributionsCount,
    required int totalFavorites,
    required int totalShares,
    required int qualityBonusCount,
  }) {
    final stats = [
      _StatItem(
          value: '$contributionsCount',
          label: l10n.contributions,
          icon: Icons.edit_note_rounded),
      _StatItem(
          value: '$totalFavorites',
          label: l10n.contributionLikes,
          icon: Icons.favorite_rounded),
      _StatItem(
          value: '$totalShares',
          label: l10n.contributionShares,
          icon: Icons.share_outlined),
      _StatItem(
          value: '$qualityBonusCount',
          label: l10n.contributionQuality,
          icon: Icons.stars_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(stats.length, (index) {
          final stat = stats[index];
          return SizedBox(
            width: 86,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                  end: index == stats.length - 1 ? 0 : 8),
              child: _buildInlineStat(theme, stat),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInlineStat(ThemeData theme, _StatItem stat) {
    final isLike = stat.icon == Icons.favorite_rounded;
    final isShare = stat.icon == Icons.share_outlined;
    final isBonus = stat.icon == Icons.stars_rounded;

    final Color accentColor = isLike
        ? Colors.red
        : isShare
            ? theme.colorScheme.primary
            : isBonus
                ? theme.colorScheme.tertiary
                : theme.colorScheme.primary.withValues(alpha: 0.85);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(stat.icon, size: 20, color: accentColor),
        const SizedBox(height: 6),
        Text(stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(stat.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.78),
            )),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(title,
        style:
            theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800));
  }

  Widget _buildBadgesEmptyMessage(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
      ),
      child: Text(
        l10n.contributionNoAchievements,
        style:
            theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildContributionsEmptyMessage(
      ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
      ),
      child: Text(
        l10n.contributionNoContributions,
        style:
            theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAchievementsRow(List<_BadgeUiModel> badges) {
    return SizedBox(
      height: 156,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 2),
        itemCount: badges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final badge = badges[index];
          return SizedBox(
            width: 138,
            child: BadgeCard(
              title: badge.title,
              description: badge.description,
              progressLabel: badge.progressLabel,
              icon: badge.icon,
              isEarned: badge.isEarned,
              color: badge.color,
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleContributionTap(
    BuildContext context,
    WidgetRef ref,
    ContributionModel item,
    bool isArabic,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (item.status == ContributionStatus.rejected) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ContributionRejectionDetailScreen(contribution: item),
        ),
      );
      return;
    }

    if (item.status == ContributionStatus.approved) {
      final archiveId = item.archiveItemId;
      if (archiveId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.contributionArchiveLinkMissing),
          ),
        );
        return;
      }
      final culturalItem = await ref
          .read(culturalRepositoryProvider)
          .fetchItemDetails(archiveId);
      if (!context.mounted) return;
      if (culturalItem == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.contributionArchiveItemNotFound),
          ),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CulturalItemDetails(item: culturalItem),
        ),
      );
    }
  }

  Widget _buildContributionCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ContributionModel item,
    bool isArabic,
  ) {
    final l10n = AppLocalizations.of(context);
    // Map approved → published label
    final (statusBg, statusColor, statusLabel) = switch (item.status) {
      ContributionStatus.approved => (
          theme.colorScheme.primary.withValues(alpha: 0.10),
          theme.colorScheme.primary,
          l10n.contributionPublished,
        ),
      ContributionStatus.pending => (
          theme.colorScheme.tertiary.withValues(alpha: 0.12),
          theme.colorScheme.tertiary,
          l10n.contributionPending,
        ),
      ContributionStatus.rejected => (
          theme.colorScheme.error.withValues(alpha: 0.10),
          theme.colorScheme.error,
          l10n.contributionRejected,
        ),
    };

    final categoryLabel = isArabic
        ? (_categoryLabelsAr[item.category] ?? item.category)
        : (_categoryLabelsEn[item.category] ?? item.category);
    final cityDisplay = cityLabel(item.cityId, isArabic: isArabic);
    final icon = _categoryIcons[item.category] ?? Icons.category_outlined;
    final previewColor =
        (_categoryColors[item.category] ?? theme.colorScheme.primary)
            .withValues(alpha: 0.12);

    final helperText = switch (item.status) {
      ContributionStatus.pending => l10n.contributionWaitingForReview,
      ContributionStatus.rejected =>
        item.rejectionReason ?? l10n.contributionRejectedDefault,
      ContributionStatus.approved => '',
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _handleContributionTap(context, ref, item, isArabic),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: item.status == ContributionStatus.approved &&
                        item.mediaType == 'image' &&
                        item.mediaUrl.isNotEmpty
                    ? Image.network(
                        item.mediaUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildCategoryPreview(previewColor, icon, theme),
                      )
                    : _buildCategoryPreview(previewColor, icon, theme),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.displayTitle.isNotEmpty
                                  ? item.displayTitle
                                  : l10n.commonNoTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              statusLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$categoryLabel • $cityDisplay',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.75),
                        ),
                      ),
                      if (item.status != ContributionStatus.approved)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            helperText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      const Spacer(),
                      if (item.status == ContributionStatus.approved)
                        Row(
                          children: [
                            _buildMeta(
                                theme, Icons.favorite_rounded, '${item.likes}'),
                            const SizedBox(width: 14),
                            _buildMeta(
                                theme, Icons.share_outlined, '${item.shares}'),
                            const SizedBox(width: 14),
                            _buildMeta(
                                theme, Icons.stars_rounded, '+${item.points}'),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPreview(Color color, IconData icon, ThemeData theme) {
    return Container(
      width: 90,
      height: 90,
      color: color,
      child: Icon(icon, color: theme.colorScheme.primary, size: 28),
    );
  }

  Widget _buildMeta(ThemeData theme, IconData icon, String value) {
    final iconColor = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.72);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(value,
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _BadgeUiModel {
  final String title;
  final String description;
  final IconData icon;
  final bool isEarned;
  final String progressLabel;
  final Color? color;

  const _BadgeUiModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.isEarned,
    required this.progressLabel,
    this.color,
  });
}

class _StatItem {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });
}

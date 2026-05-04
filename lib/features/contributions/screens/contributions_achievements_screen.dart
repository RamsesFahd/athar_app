import 'package:athar_app/core/constants/region_city_constants.dart';
import 'package:athar_app/core/models/contribution/contribution_model.dart';
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

// Stream provider family — keyed by touristId
final _touristContributionsProvider = StreamProvider.autoDispose
    .family<List<ContributionModel>, String>((ref, touristId) {
  return ref.watch(contributionRepositoryProvider).getTouristContributions(touristId);
});

class ContributionsAchievementsScreen extends ConsumerWidget {
  const ContributionsAchievementsScreen({super.key});

  static const double _pageHorizontalPadding = 16;
  static const int _nextLevelPoints = 500;

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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (user) {
        if (user == null || user.role == UserRole.guest) {
          return const Scaffold(
            body: Center(child: Text('User not available')),
          );
        }

        final tourist = user as TouristModel;

        // Watch a live stream of the tourist's Firestore document so
        // points/contributionsCount update in real time after admin approval.
        final liveTouristAsync =
            ref.watch(touristStreamProvider(tourist.uId));
        final liveTourist =
            liveTouristAsync.valueOrNull ?? tourist;

        // Watch the live contributions stream for this tourist
        final contributionsAsync =
            ref.watch(_touristContributionsProvider(tourist.uId));

        return contributionsAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            body: Center(child: Text('Error: $e')),
          ),
          data: (contributions) {
            final repo = ref.read(contributionRepositoryProvider);
            final stats = repo.computeStats(contributions);
            final achievements = repo.computeAchievements(contributions);
            final badges = _buildBadges(achievements, isArabic, theme);

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
                              currentPoints: stats.totalPoints,
                              maxPoints: _nextLevelPoints,
                            ),
                            const SizedBox(height: 18),

                            _buildStatsRow(
                              theme,
                              isArabic,
                              contributionsCount: stats.contributionsCount,
                              totalFavorites: stats.totalLikes,
                              totalShares: stats.totalShares,
                              qualityBonusCount: stats.qualityBonusCount,
                            ),
                            const SizedBox(height: 24),

                            _buildSectionTitle(
                              theme,
                              isArabic ? 'الإنجازات' : 'Achievements',
                            ),
                            const SizedBox(height: 12),

                            badges.isEmpty
                                ? _buildBadgesEmptyMessage(theme, isArabic)
                                : _buildAchievementsRow(badges),

                            const SizedBox(height: 24),

                            _buildSectionTitle(
                              theme,
                              isArabic ? 'مساهماتي' : 'My Contributions',
                            ),
                            const SizedBox(height: 12),

                            if (contributions.isEmpty)
                              _buildContributionsEmptyMessage(theme, isArabic)
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
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showPhoneGuardDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic
            ? 'التحقق من الجوال مطلوب'
            : 'Phone Verification Required'),
        content: Text(isArabic
            ? 'يجب التحقق من رقم جوالك أولاً لإضافة مساهمة. توجّه إلى الملف الشخصي لإكمال التحقق.'
            : 'You must verify your phone number before adding a contribution. Go to your profile to complete verification.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? 'حسناً' : 'OK'),
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
  ) {
    final defs = [
      (
        id: 'first_contribution',
        titleAr: 'أول مساهمة',
        titleEn: 'First Contribution',
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
        orElse: () => AchievementData(
            id: def.id, isEarned: false, current: 0, target: 1),
      );
      final progressLabel = data.isEarned
          ? (isArabic ? 'مكتمل' : 'Completed')
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
    required int currentPoints,
    required int maxPoints,
  }) {
    final safeCurrentPoints = currentPoints.clamp(0, maxPoints);
    final progressValue =
        maxPoints == 0 ? 0.0 : safeCurrentPoints / maxPoints;
    final remainingPoints =
        (maxPoints - safeCurrentPoints).clamp(0, maxPoints);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border:
            Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
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
            isArabic ? 'مستوى المساهم' : 'Contributor Level',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            isArabic ? 'مساهم نشط' : 'Active Contributor',
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$safeCurrentPoints',
                style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900, fontSize: 30, height: 1),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  isArabic ? 'نقطة' : 'pts',
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
              Text('0',
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.78))),
              const Spacer(),
              Text('$maxPoints',
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.78))),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isArabic
                ? 'متبقي $remainingPoints نقطة للوصول للمستوى القادم'
                : '$remainingPoints points left to the next level',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodySmall?.color
                  ?.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    ThemeData theme,
    bool isArabic, {
    required int contributionsCount,
    required int totalFavorites,
    required int totalShares,
    required int qualityBonusCount,
  }) {
    final stats = [
      _StatItem(
          value: '$contributionsCount',
          label: isArabic ? 'مساهمات' : 'Contributions',
          icon: Icons.edit_note_rounded),
      _StatItem(
          value: '$totalFavorites',
          label: isArabic ? 'إعجابات' : 'Likes',
          icon: Icons.favorite_rounded),
      _StatItem(
          value: '$totalShares',
          label: isArabic ? 'مشاركات' : 'Shares',
          icon: Icons.share_outlined),
      _StatItem(
          value: '$qualityBonusCount',
          label: isArabic ? 'جودة عالية' : 'Quality',
          subtitle: isArabic ? 'مساهمات متميزة' : 'Top contributions',
          icon: Icons.stars_rounded),
    ];

    return Row(
      children: List.generate(stats.length, (index) {
        final stat = stats[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
                end: index == stats.length - 1 ? 0 : 8),
            child: _buildInlineStat(theme, stat),
          ),
        );
      }),
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
              color: theme.textTheme.bodySmall?.color
                  ?.withValues(alpha: 0.78),
            )),
        if (stat.subtitle != null) ...[
          const SizedBox(height: 2),
          Text(stat.subtitle!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: theme.textTheme.bodySmall?.color
                    ?.withValues(alpha: 0.5),
              )),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(title,
        style: theme.textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w800));
  }

  Widget _buildBadgesEmptyMessage(ThemeData theme, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
      ),
      child: Text(
        isArabic ? 'لا توجد إنجازات بعد' : 'No achievements yet',
        style:
            theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildContributionsEmptyMessage(ThemeData theme, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
      ),
      child: Text(
        isArabic ? 'لا توجد مساهمات بعد' : 'No contributions yet',
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
    if (item.status == ContributionStatus.rejected) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ContributionRejectionDetailScreen(contribution: item),
        ),
      );
      return;
    }

    if (item.status == ContributionStatus.approved) {
      final archiveId = item.archiveItemId;
      if (archiveId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic
                ? 'هذه المساهمة لا تحتوي على رابط للأرشيف'
                : 'This contribution has no archive link yet'),
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
            content: Text(isArabic
                ? 'تعذّر العثور على العنصر في الأرشيف'
                : 'Archive item not found'),
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
    // Map approved → published label
    final (statusBg, statusColor, statusLabel) = switch (item.status) {
      ContributionStatus.approved => (
          theme.colorScheme.primary.withValues(alpha: 0.10),
          theme.colorScheme.primary,
          isArabic ? 'منشور' : 'Published',
        ),
      ContributionStatus.pending => (
          theme.colorScheme.tertiary.withValues(alpha: 0.12),
          theme.colorScheme.tertiary,
          isArabic ? 'قيد المراجعة' : 'Pending',
        ),
      ContributionStatus.rejected => (
          theme.colorScheme.error.withValues(alpha: 0.10),
          theme.colorScheme.error,
          isArabic ? 'مرفوض' : 'Rejected',
        ),
    };

    final categoryLabel = isArabic
        ? (_categoryLabelsAr[item.category] ?? item.category)
        : (_categoryLabelsEn[item.category] ?? item.category);
    final cityDisplay = cityLabel(item.cityId, isArabic: isArabic);
    final icon =
        _categoryIcons[item.category] ?? Icons.category_outlined;
    final previewColor =
        (_categoryColors[item.category] ?? theme.colorScheme.primary)
            .withValues(alpha: 0.12);

    final helperText = switch (item.status) {
      ContributionStatus.pending =>
        isArabic ? 'بانتظار مراجعة المشرف' : 'Waiting for admin review',
      ContributionStatus.rejected =>
        item.rejectionReason ??
            (isArabic ? 'تم رفض المساهمة' : 'Contribution was rejected'),
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
            border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.08)),
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
                        errorBuilder: (_, __, ___) => _buildCategoryPreview(
                            previewColor, icon, theme),
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
                                  : (isArabic ? 'بلا عنوان' : 'No title'),
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
                            _buildMeta(theme, Icons.favorite_rounded,
                                '${item.likes}'),
                            const SizedBox(width: 14),
                            _buildMeta(theme, Icons.share_outlined,
                                '${item.shares}'),
                            const SizedBox(width: 14),
                            _buildMeta(theme, Icons.stars_rounded,
                                '+${item.points}'),
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

  Widget _buildCategoryPreview(
      Color color, IconData icon, ThemeData theme) {
    return Container(
      width: 90,
      height: 90,
      color: color,
      child: Icon(icon, color: theme.colorScheme.primary, size: 28),
    );
  }

  Widget _buildMeta(ThemeData theme, IconData icon, String value) {
    final iconColor =
        theme.textTheme.bodySmall?.color?.withValues(alpha: 0.72);
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
  final String? subtitle;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    this.subtitle,
  });
}

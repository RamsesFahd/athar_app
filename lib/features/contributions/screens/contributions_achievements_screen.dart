import 'package:athar_app/features/contributions/screens/add_contribution_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/contributions/widgets/badge_card.dart';
import 'package:athar_app/features/profile/widgets/tourist_profile.dart';

class ContributionsAchievementsScreen extends ConsumerWidget {
  const ContributionsAchievementsScreen({super.key});

  static const double _pageHorizontalPadding = 16;

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

        const contributionsCount = 5;
        const totalFavorites = 34;
        const totalShares = 12;
        const qualityBonusCount = 3;
        const totalPoints = 270;
        const nextLevelPoints = 500;

       final badges = _buildMockBadges(isArabic, theme);
        final contributions = _buildMockContributions(isArabic);

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
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
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  surfaceTintColor: Colors.transparent,
                  centerTitle: true,
                  title: Text(
                    isArabic
                        ? 'مساهماتي وإنجازاتي'
                        : 'My Contributions & Achievements',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
                        user: user as TouristModel, 
                       showEmail: false, 
                       isContributionPage: true,          
                         ),
                       const SizedBox(height: 16),

                        _buildRewardBanner(theme, isArabic),
                        const SizedBox(height: 16),

                        _buildLevelCard(
                          theme,
                          isArabic,
                          currentPoints: totalPoints,
                          maxPoints: nextLevelPoints,
                        ),
                        const SizedBox(height: 18),

                        _buildStatsRow(
                          theme,
                          isArabic,
                          contributionsCount: contributionsCount,
                          totalFavorites: totalFavorites,
                          totalShares: totalShares,
                          qualityBonusCount: qualityBonusCount,
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

                        ...contributions.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildContributionCard(context, theme, item),
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
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
Widget _buildProfileNameHeader(
  BuildContext context,
  String fullName,
  bool isArabic,
) {
  final theme = Theme.of(context);

  return Text(
    fullName,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
    ),
  );
}
  Widget _buildRewardBanner(ThemeData theme, bool isArabic) {
    final accent = theme.colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
        ),
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
            child: Icon(
              Icons.card_giftcard_rounded,
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isArabic
                  ? 'جائزة سفير التراث: خصم حصري على حجز رحلتك القادمة عند وصولك إلى 1000 نقطة'
                  : 'Heritage Ambassador Reward: Exclusive discount on your next booking when you reach 1000 points',
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
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
    final progressValue = maxPoints == 0 ? 0.0 : safeCurrentPoints / maxPoints;
    final remainingPoints = (maxPoints - safeCurrentPoints).clamp(0, maxPoints);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.08),
        ),
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
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isArabic ? 'مساهم نشط' : 'Active Contributor',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$safeCurrentPoints',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  isArabic ? 'نقطة' : 'pts',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color:
                        theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
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
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '0',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.78),
                ),
              ),
              const Spacer(),
              Text(
                '$maxPoints',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isArabic
                ? 'متبقي $remainingPoints نقطة للوصول للمستوى القادم'
                : '$remainingPoints points left to the next level',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  theme.textTheme.bodySmall?.color?.withValues(alpha: 0.82),
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
        icon: Icons.edit_note_rounded,
      ),
      _StatItem(
        value: '$totalFavorites',
        label: isArabic ? 'إعجابات' : 'Likes',
        icon: Icons.favorite_rounded,
      ),
      _StatItem(
        value: '$totalShares',
        label: isArabic ? 'مشاركات' : 'Shares',
        icon: Icons.share_outlined,
      ),
      _StatItem(
        value: '$qualityBonusCount',
        label: isArabic ? 'بونص' : 'Bonus',
        icon: Icons.stars_rounded,
      ),
    ];

    return Row(
      children: List.generate(stats.length, (index) {
        final stat = stats[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: index == stats.length - 1 ? 0 : 8,
            ),
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
        Icon(
          stat.icon,
          size: 20,
          color: accentColor,
        ),
        const SizedBox(height: 6),
        Text(
          stat.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          stat.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.78),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildBadgesEmptyMessage(ThemeData theme, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        isArabic ? 'لا توجد إنجازات بعد' : 'No achievements yet',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
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

  Widget _buildContributionCard(
    BuildContext context,
    ThemeData theme,
    _ContributionItem item,
  ) {
    final statusBg = switch (item.status) {
      ContributionStatus.published =>
        theme.colorScheme.primary.withValues(alpha: 0.10),
      ContributionStatus.pending =>
        theme.colorScheme.tertiary.withValues(alpha: 0.12),
      ContributionStatus.rejected =>
        theme.colorScheme.error.withValues(alpha: 0.10),
    };

    final statusColor = switch (item.status) {
      ContributionStatus.published => theme.colorScheme.primary,
      ContributionStatus.pending => theme.colorScheme.tertiary,
      ContributionStatus.rejected => theme.colorScheme.error,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.08),
            ),
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
                child: Container(
                  width: 90,
                  height: 90,
                  color: item.previewColor,
                  child: Icon(
                    item.icon,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
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
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item.statusLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item.category} • ${item.city}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.75),
                        ),
                      ),
                      
                      if (item.status != ContributionStatus.published)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        item.helperText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                      const Spacer(),
                      if (item.status == ContributionStatus.published)
                        Row(
                          children: [
                            _buildMeta(
                              theme,
                              Icons.favorite_rounded,
                              '${item.favorites}',
                            ),
                            const SizedBox(width: 14),
                            _buildMeta(
                              theme,
                              Icons.share_outlined,
                              '${item.shares}',
                            ),
                            const SizedBox(width: 14),
                            _buildMeta(
                              theme,
                              Icons.stars_rounded,
                              '+${item.points}',
                            ),
                          ],
                        )
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

  Widget _buildMeta(
    ThemeData theme,
    IconData icon,
    String value,
  ) {
    final iconColor =
        theme.textTheme.bodySmall?.color?.withValues(alpha: 0.72);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  List<_BadgeUiModel> _buildMockBadges(bool isArabic, ThemeData theme) {
    return [
  _BadgeUiModel(
    title: isArabic ? 'أول مساهمة' : 'First Contribution',
    description: '',
    icon: Icons.flag_rounded,
    isEarned: true,
    progressLabel: '',
    color: theme.colorScheme.primary,
  ),
  _BadgeUiModel(
    title: isArabic ? 'الراوي' : 'Narrator',
    description: '',
    icon: Icons.auto_stories_rounded,
    isEarned: false,
    progressLabel: '5/10',
    color: theme.colorScheme.tertiary,
  ),
  _BadgeUiModel(
    title: isArabic ? 'المستكشف' : 'Explorer',
    description: '',
    icon: Icons.explore_outlined,
    isEarned: false,
    progressLabel: '2/3',
    color: theme.colorScheme.secondary,
  ),
  _BadgeUiModel(
    title: isArabic ? 'المحبوب' : 'Loved',
    description: '',
    icon: Icons.favorite_border_rounded,
    isEarned: false,
    progressLabel: '34/50',
    color: theme.colorScheme.error,
  ),
  _BadgeUiModel(
    title: isArabic ? 'سفير التراث' : 'Heritage Ambassador',
    description: '',
    icon: Icons.workspace_premium_outlined,
    isEarned: false,
    progressLabel: '?',
    color: theme.colorScheme.tertiary.withValues(alpha: 0.8),
  ),
];
  }

  List<_ContributionItem> _buildMockContributions(bool isArabic) {
    return [
      _ContributionItem(
        title: isArabic ? 'مراسم القهوة في نجران' : 'Najran Coffee Rituals',
        category: isArabic ? 'تقاليد وعادات' : 'Traditions',
        city: isArabic ? 'نجران' : 'Najran',
        status: ContributionStatus.published,
        statusLabel: isArabic ? 'منشور' : 'Published',
        favorites: 18,
        shares: 7,
        points: 75,
        helperText: '',
        icon: Icons.local_cafe_rounded,
        previewColor: Colors.orange.withValues(alpha: 0.12),
      ),
      _ContributionItem(
        title: isArabic ? 'رقصة المزمار الحجازية' : 'Hijazi Al-Mizmar Dance',
        category: isArabic ? 'فنون أدائية' : 'Performance Art',
        city: isArabic ? 'الحجاز' : 'Hijaz',
        status: ContributionStatus.published,
        statusLabel: isArabic ? 'منشور' : 'Published',
        favorites: 12,
        shares: 4,
        points: 80,
        helperText: '',
        icon: Icons.music_note_rounded,
        previewColor: Colors.purple.withValues(alpha: 0.12),
      ),
      _ContributionItem(
        title: isArabic ? 'طريقة عمل الجريش' : 'How to Make Jareesh',
        category: isArabic ? 'أطعمة تقليدية' : 'Traditional Food',
        city: isArabic ? 'القصيم' : 'Qassim',
        status: ContributionStatus.pending,
        statusLabel: isArabic ? 'قيد المراجعة' : 'Pending',
        favorites: 0,
        shares: 0,
        points: 0,
        helperText: isArabic ? 'بانتظار مراجعة المشرف' : 'Waiting for review',
        icon: Icons.restaurant_rounded,
        previewColor: Colors.amber.withValues(alpha: 0.12),
      ),
      _ContributionItem(
        title: isArabic ? 'زخارف نوافذ جدة القديمة' : 'Old Jeddah Window Patterns',
        category: isArabic ? 'فنون بصرية' : 'Visual Arts',
        city: isArabic ? 'جدة' : 'Jeddah',
        status: ContributionStatus.rejected,
        statusLabel: isArabic ? 'مرفوض' : 'Rejected',
        favorites: 0,
        shares: 0,
        points: 0,
        helperText:
            isArabic ? 'الصورة تحتاج جودة أوضح' : 'Image needs better quality',
        icon: Icons.photo_camera_back_rounded,
        previewColor: Colors.red.withValues(alpha: 0.10),
      ),
    ];
  }
  }
class _BadgeUiModel {
  final String title;
  final String description;
  final IconData icon;
  final bool isEarned;
  final String progressLabel;
  final Color? color; // ✨ جديد

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

enum ContributionStatus { published, pending, rejected }

class _ContributionItem {
  final String title;
  final String category;
  final String city;
  final ContributionStatus status;
  final String statusLabel;
  final int favorites;
  final int shares;
  final int points;
  final String helperText;
  final IconData icon;
  final Color previewColor;

  const _ContributionItem({
    required this.title,
    required this.category,
    required this.city,
    required this.status,
    required this.statusLabel,
    required this.favorites,
    required this.shares,
    required this.points,
    required this.helperText,
    required this.icon,
    required this.previewColor,
  });
}
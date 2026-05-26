import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:athar_app/core/models/user/user_model.dart'; //
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TouristHeader extends ConsumerWidget {
  final TouristModel user;
  final bool showEmail; 
  final bool isContributionPage;
  const TouristHeader({
    super.key, 
    required this.user, 
    this.showEmail = true, 
    this.isContributionPage = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. الصورة مع أيقونة التعديل الصغيرة)
              _buildAvatarWithEditIcon(theme, l10n, ref),
              const SizedBox(width: 16),
              // 2. الاسم والإيميل
              _buildUserBasicInfo(theme),
            ],
          ),
          const SizedBox(height: 20),
          // 3. قسم النقاط والمساهمات (للسائح فقط)
          _buildStatsSection(theme, l10n),
        ],
      ),
    );
  }

//
Widget _buildAvatarWithEditIcon(ThemeData theme, AppLocalizations l10n, WidgetRef ref) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
          backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
              ? CachedNetworkImageProvider(user.profileImage!)
              : null,
          child: user.profileImage == null || user.profileImage!.isEmpty
              ? Icon(Icons.person, size: 40, color: theme.colorScheme.primary)
              : null,
        ),
        // هنا التعديل: نختار وش نعرض في الزاوية
        Positioned(
          bottom: 0,
          right: 0,
          child: isContributionPage 
            ? _buildBadgeIcon(theme) // لو في المساهمات يطلع الوسم
            : _buildCameraIcon(theme, ref), // لو في البروفايل تطلع الكاميرا
        ),
      ],
    );
  }

  // --- ميثود أيقونة الكاميرا ---
  Widget _buildCameraIcon(ThemeData theme, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(authNotifierProvider.notifier).updateProfilePicture(),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
      ),
    );
  }

  // --- ميثود أيقونة الوسم (Badge) ---
  Widget _buildBadgeIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
       color: theme.colorScheme.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(
        Icons.verified_rounded, 
        size: 14, 
        color: Colors.white
      ),
    );
  }

  Widget _buildUserBasicInfo(ThemeData theme) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(user.fullName, style: theme.textTheme.titleLarge),
        if (showEmail) // إذا كان true بيطلع، إذا false بيختفي
          Text(user.email, style: theme.textTheme.bodyMedium),
      ],
    ),
  );
}

  Widget _buildStatsSection(ThemeData theme, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem(theme, Icons.stars_rounded, "${user.points}", l10n.points),
        Container(
            width: 1,
            height: 20,
            color: theme.dividerColor.withValues(alpha: 0.2)),
        _statItem(theme, Icons.auto_awesome_mosaic_rounded,
            "${user.contributionsCount}", l10n.contributionPageTitle),
      ],
    );
  }

  Widget _statItem(ThemeData theme, IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

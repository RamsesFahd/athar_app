// tutor_profile.dart
import 'package:flutter/material.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';

class TutorHeader extends ConsumerWidget {
  final TutorModel user;

  const TutorHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // 1. تنبيه إكمال البيانات (يظهر فقط إذا لم يكن موثقاً)
        if (user.verificationStatus != 'verified')
          Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _buildVerificationAlert(theme, l10n),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)), // حواف دائرية لأسفل الهيدر
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatarWithEditIcon(theme, ref),
                  const SizedBox(width: 16),
                  _buildTutorMainInfo(theme, l10n, ref),
                ],
              ),
              if (user.bio != null) ...[
                const SizedBox(height: 12),
                _buildBioSection(theme),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ويدجت التنبيه العلوي للمرشد
  Widget _buildVerificationAlert(ThemeData theme, AppLocalizations l10n) {
  bool isPending = user.verificationStatus == 'pending';
  final Color statusColor = isPending ? theme.colorScheme.tertiary : theme.colorScheme.error;

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: statusColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: statusColor.withValues(alpha: 0.2)),
    ),
    child: Row(
      children: [
        Icon(isPending ? Icons.hourglass_top_rounded : Icons.info_outline_rounded, 
            color: statusColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            isPending ? l10n.tutorVerificationPendingStatus : l10n.tutorVerificationRequiredStatus,
            style: theme.textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
  }

  Widget _buildTutorMainInfo(ThemeData theme, AppLocalizations l10n, WidgetRef ref) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(user.fullName, style: theme.textTheme.titleLarge),
              const SizedBox(width: 8),
              _buildStatusBadge(theme), // تاق الحالة الملون
            ],
          ),
          Text(user.email, style: theme.textTheme.bodyMedium),
          
          // DONT DELETE - سيتم تفعيل عرض رقم الرخصة في المستقبل
          // if (user.licenceNumber != null) ...[
          // Text(
          //   l10n.tutorLicenseNumberLabel(user.licenceNumber!),
          //   style: TextStyle(
          //     fontSize: 11,
          //     fontWeight: FontWeight.normal,
          //     color: theme.colorScheme.onSurface,
          //   ),
          // ),
        ],
    ),
  );
}

  Widget _buildStatusBadge(ThemeData theme) {
    Color color;
    IconData icon;

    if (user.verificationStatus == 'verified') {
      color = theme.colorScheme.primary;
      icon = Icons.verified;
    } else if (user.verificationStatus == 'pending') {
      color = theme.colorScheme.tertiary;
      icon = Icons.history;
    } else {
      color = theme.disabledColor;
      icon = Icons.error_outline;
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildAvatarWithEditIcon(ThemeData theme, WidgetRef  ref) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
          backgroundImage: user.profileImage != null ? NetworkImage(user.profileImage!) : null,
          child: user.profileImage == null ? Icon(Icons.person, size: 40, color: theme.colorScheme.primary) : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              print("📸 تم الضغط على زر الكاميرا!"); 
              ref.read(authNotifierProvider.notifier).updateProfilePicture();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTutorMetaDetails(ThemeData theme, AppLocalizations l10n) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(user.fullName, style: theme.textTheme.titleLarge), //
              const SizedBox(width: 8),
              if (user.verificationStatus == 'verified')
                Icon(Icons.verified_rounded,
                    color: theme.colorScheme.primary, size: 18),
            ],
          ),
          Text(user.email, style: theme.textTheme.bodyMedium), //
          if (user.licenceNumber != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.tutorLicenseNumberLabel(user.licenceNumber!), // عرض رقم الرخصة
              style: theme.textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBioSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        user.bio!, // عرض نص البايو
        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

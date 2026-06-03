import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TouristHeader extends ConsumerStatefulWidget {
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
  ConsumerState<TouristHeader> createState() => _TouristHeaderState();
}

class _TouristHeaderState extends ConsumerState<TouristHeader> {
  bool _isUploadingPicture = false;

  Future<void> _handlePictureUpload() async {
    setState(() => _isUploadingPicture = true);
    await ref.read(authNotifierProvider.notifier).updateProfilePicture();
    if (mounted) setState(() => _isUploadingPicture = false);
  }

  @override
  Widget build(BuildContext context) {
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
              _buildAvatarWithEditIcon(theme),
              const SizedBox(width: 16),
              _buildUserBasicInfo(theme),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatsSection(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildAvatarWithEditIcon(ThemeData theme) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
          backgroundImage:
              widget.user.profileImage != null &&
                      widget.user.profileImage!.isNotEmpty
                  ? CachedNetworkImageProvider(widget.user.profileImage!)
                  : null,
          child: widget.user.profileImage == null ||
                  widget.user.profileImage!.isEmpty
              ? Icon(Icons.person, size: 40, color: theme.colorScheme.primary)
              : null,
        ),
        // Overlay during upload so the user knows the picture is being saved.
        if (_isUploadingPicture)
          const Positioned.fill(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.black45,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: widget.isContributionPage
              ? _buildBadgeIcon(theme)
              : _buildCameraIcon(theme),
        ),
      ],
    );
  }

  Widget _buildCameraIcon(ThemeData theme) {
    return GestureDetector(
      onTap: _isUploadingPicture ? null : _handlePictureUpload,
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

  Widget _buildBadgeIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
    );
  }

  Widget _buildUserBasicInfo(ThemeData theme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.user.fullName, style: theme.textTheme.titleLarge),
          if (widget.showEmail)
            Text(widget.user.email, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem(theme, Icons.stars_rounded, '${widget.user.points}',
            l10n.points),
        Container(
            width: 1,
            height: 20,
            color: theme.dividerColor.withValues(alpha: 0.2)),
        _statItem(theme, Icons.auto_awesome_mosaic_rounded,
            '${widget.user.contributionsCount}', l10n.contributionPageTitle),
      ],
    );
  }

  Widget _statItem(
      ThemeData theme, IconData icon, String value, String label) {
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

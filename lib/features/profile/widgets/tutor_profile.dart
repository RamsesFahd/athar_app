import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';

class TutorHeader extends ConsumerStatefulWidget {
  final TutorModel user;

  const TutorHeader({super.key, required this.user});

  @override
  ConsumerState<TutorHeader> createState() => _TutorHeaderState();
}

class _TutorHeaderState extends ConsumerState<TutorHeader> {
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

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(30)),
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
                  _buildAvatarWithEditIcon(theme),
                  const SizedBox(width: 16),
                  _buildTutorMainInfo(theme, l10n),
                ],
              ),
              if (widget.user.bio != null &&
                  widget.user.bio!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildBioSection(theme),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTutorMainInfo(ThemeData theme, AppLocalizations l10n) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(widget.user.fullName, style: theme.textTheme.titleLarge),
              const SizedBox(width: 8),
              _buildStatusBadge(theme),
            ],
          ),
          Text(widget.user.email, style: theme.textTheme.bodyMedium),
          if (widget.user.rating != null && widget.user.rating! > 0) ...[
            const SizedBox(height: 6),
            _buildRatingRow(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingRow(ThemeData theme) {
    final rating = widget.user.rating ?? 0.0;
    final count = widget.user.reviewsCount ?? 0;
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;

    return Row(
      children: [
        ...List.generate(5, (i) {
          IconData icon;
          if (i < fullStars) {
            icon = Icons.star_rounded;
          } else if (i == fullStars && hasHalf) {
            icon = Icons.star_half_rounded;
          } else {
            icon = Icons.star_outline_rounded;
          }
          return Icon(icon, size: 16, color: Colors.amber.shade600);
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 2),
          Text(
            '($count)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    final Color color;
    final IconData icon;

    if (widget.user.verificationStatus == VerificationStatus.verified) {
      color = theme.colorScheme.primary;
      icon = Icons.verified;
    } else if (widget.user.verificationStatus == VerificationStatus.pending) {
      color = theme.colorScheme.tertiary;
      icon = Icons.history;
    } else {
      color = theme.disabledColor;
      icon = Icons.error_outline;
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildAvatarWithEditIcon(ThemeData theme) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
          backgroundImage: widget.user.profileImage != null
              ? CachedNetworkImageProvider(widget.user.profileImage!)
              : null,
          child: widget.user.profileImage == null
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
          child: GestureDetector(
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
          ),
        ),
      ],
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
        widget.user.bio!,
        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

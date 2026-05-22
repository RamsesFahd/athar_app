import 'package:flutter/material.dart';
import 'package:athar_app/core/models/notification/app_notification_model.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class NotificationCard extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isHighContrast = theme.colorScheme.primary == Colors.black;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final title = isAr
        ? (notification.titleAr.isNotEmpty
            ? notification.titleAr
            : _fallbackTitle(notification.type, l10n))
        : (notification.titleEn.isNotEmpty
            ? notification.titleEn
            : _fallbackTitle(notification.type, l10n));

    final body = isAr
        ? (notification.bodyAr.isNotEmpty
            ? notification.bodyAr
            : _fallbackBody(notification.type, l10n))
        : (notification.bodyEn.isNotEmpty
            ? notification.bodyEn
            : _fallbackBody(notification.type, l10n));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isHighContrast
                  ? Colors.black
                  : notification.isRead
                      ? theme.dividerColor.withValues(alpha: 0.08)
                      : theme.colorScheme.primary.withValues(alpha: 0.18),
              width: isHighContrast ? 2 : 1,
            ),
            boxShadow: isHighContrast
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHighContrast
                      ? Colors.white
                      : theme.colorScheme.primary.withValues(alpha: 0.12),
                  border: isHighContrast
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
                child: Icon(
                  notification.isRead
                      ? Icons.notifications_none_rounded
                      : Icons.notifications_active_rounded,
                  color: theme.colorScheme.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: isHighContrast
                            ? theme.colorScheme.onSurface
                            : theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead) ...[
                const SizedBox(width: 10),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _fallbackTitle(String type, AppLocalizations l10n) {
    switch (type) {
      case 'contribution_approved':
        return l10n.notificationContributionApprovedTitle;
      case 'contribution_rejected':
        return l10n.notificationContributionRejectedTitle;
      case 'contribution_submitted':
        return l10n.notificationContributionSubmittedTitle;
      case 'trip_submitted':
        return l10n.notificationTripSubmittedTitle;
      case 'trip_approved':
        return l10n.notificationTripApprovedTitle;
      case 'trip_rejected':
        return l10n.notificationTripRejectedTitle;
      case 'booking_new':
        return l10n.notificationBookingNewTitle;
      case 'booking_approved':
        return l10n.notificationBookingApprovedTitle;
      case 'booking_cancelled':
        return l10n.notificationBookingCancelledTitle;
      case 'booking_reminder':
        return l10n.notificationDefaultTitle;
      case 'booking_auto_completed':
        return l10n.notificationBookingAutoCompletedTitle;
      case 'guide_verified':
        return l10n.notificationGuideVerifiedTitle;
      case 'guide_rejected':
        return l10n.notificationGuideRejectedTitle;
      case 'points_awarded':
        return l10n.notificationPointsAwardedTitle;
      default:
        return l10n.notificationDefaultTitle;
    }
  }

  String _fallbackBody(String type, AppLocalizations l10n) {
    switch (type) {
      case 'contribution_approved':
        return l10n.notificationContributionApprovedBody;
      case 'contribution_rejected':
        return l10n.notificationContributionRejectedBody;
      case 'contribution_submitted':
        return l10n.notificationContributionSubmittedBody;
      case 'trip_submitted':
        return l10n.notificationTripSubmittedBody;
      case 'trip_approved':
        return l10n.notificationTripApprovedBody;
      case 'trip_rejected':
        return l10n.notificationTripRejectedBody;
      case 'booking_new':
        return l10n.notificationBookingNewBody;
      case 'booking_approved':
        return l10n.notificationBookingApprovedBody;
      case 'booking_cancelled':
        return l10n.notificationBookingCancelledBody;
      case 'booking_reminder':
        return l10n.notificationDefaultBody;
      case 'booking_auto_completed':
        return l10n.notificationBookingAutoCompletedBody;
      case 'guide_verified':
        return l10n.notificationGuideVerifiedBody;
      case 'guide_rejected':
        return l10n.notificationGuideRejectedBody;
      case 'points_awarded':
        return l10n.notificationPointsAwardedBody;
      default:
        return l10n.notificationDefaultBody;
    }
  }
}

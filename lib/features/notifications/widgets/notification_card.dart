import 'package:flutter/material.dart';
import 'package:athar_app/core/models/notification/app_notification_model.dart';

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

    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final title = _title(notification.type, isAr);

    final body = notification.body.isNotEmpty
        ? notification.body
        : _body(notification.type, isAr);

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
              color: notification.isRead
                  ? theme.dividerColor.withValues(alpha: 0.08)
                  : theme.colorScheme.primary.withValues(alpha: 0.18),
            ),
            boxShadow: [
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
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
                        color: theme.textTheme.bodyMedium?.color
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

  String _title(String type, bool isAr) {
    switch (type) {
      case 'contribution_approved':
        return isAr ? 'تم قبول المساهمة' : 'Contribution Approved';

      case 'contribution_rejected':
        return isAr ? 'تم رفض المساهمة' : 'Contribution Rejected';

      case 'booking_approved':
        return isAr ? 'تم قبول الحجز' : 'Booking Approved';

      case 'booking_cancelled':
        return isAr ? 'تم إلغاء الحجز' : 'Booking Cancelled';

      default:
        return isAr ? 'تنبيه جديد' : 'New Notification';
    }
  }

  String _body(String type, bool isAr) {
    switch (type) {
      case 'contribution_approved':
        return isAr
            ? 'تم قبول مساهمتك بنجاح.'
            : 'Your contribution has been approved successfully.';

      case 'contribution_rejected':
        return isAr
            ? 'تم رفض مساهمتك. يرجى مراجعة السبب.'
            : 'Your contribution was rejected. Please review the reason.';

      case 'booking_approved':
        return isAr
            ? 'تم قبول حجزك بنجاح.'
            : 'Your booking has been approved successfully.';

      case 'booking_cancelled':
        return isAr ? 'تم إلغاء حجزك.' : 'Your booking has been cancelled.';

      default:
        return isAr ? 'لديك تنبيه جديد.' : 'You have a new notification.';
    }
  }
}
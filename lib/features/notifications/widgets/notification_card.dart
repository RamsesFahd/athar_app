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
    final isHighContrast = theme.colorScheme.primary == Colors.black;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final title = isAr
        ? (notification.titleAr.isNotEmpty
            ? notification.titleAr
            : _fallbackTitle(notification.type, true))
        : (notification.titleEn.isNotEmpty
            ? notification.titleEn
            : _fallbackTitle(notification.type, false));

    final body = isAr
        ? (notification.bodyAr.isNotEmpty
            ? notification.bodyAr
            : _fallbackBody(notification.type, true))
        : (notification.bodyEn.isNotEmpty
            ? notification.bodyEn
            : _fallbackBody(notification.type, false));

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

  String _fallbackTitle(String type, bool isAr) {
    switch (type) {
      case 'contribution_approved':
        return isAr ? 'تم قبول المساهمة' : 'Contribution Approved';
      case 'contribution_rejected':
        return isAr ? 'تم رفض المساهمة' : 'Contribution Rejected';
      case 'contribution_submitted':
        return isAr ? 'مساهمة جديدة بانتظار المراجعة' : 'New Contribution Awaiting Review';
      case 'trip_submitted':
        return isAr ? 'رحلة جديدة بانتظار المراجعة' : 'New Trip Awaiting Review';
      case 'trip_approved':
        return isAr ? 'تم قبول رحلتك' : 'Trip Approved';
      case 'trip_rejected':
        return isAr ? 'تم رفض رحلتك' : 'Trip Rejected';
      case 'booking_new':
        return isAr ? 'حجز جديد' : 'New Booking';
      case 'booking_approved':
        return isAr ? 'تم قبول الحجز' : 'Booking Approved';
      case 'booking_cancelled':
        return isAr ? 'تم إلغاء الحجز' : 'Booking Cancelled';
      case 'guide_verified':
        return isAr ? 'تم توثيق حسابك' : 'Account Verified';
      case 'points_awarded':
        return isAr ? 'نقاط إضافية' : 'Bonus Points Awarded';
      default:
        return isAr ? 'تنبيه جديد' : 'New Notification';
    }
  }

  String _fallbackBody(String type, bool isAr) {
    switch (type) {
      case 'contribution_approved':
        return isAr
            ? 'تم قبول مساهمتك بنجاح.'
            : 'Your contribution has been approved.';
      case 'contribution_rejected':
        return isAr
            ? 'تم رفض مساهمتك. يرجى مراجعة السبب.'
            : 'Your contribution was rejected.';
      case 'contribution_submitted':
        return isAr
            ? 'قدّم سائح مساهمة جديدة تحتاج للمراجعة.'
            : 'A tourist submitted a contribution for review.';
      case 'trip_submitted':
        return isAr
            ? 'قام مرشد بتقديم رحلة جديدة.'
            : 'A guide submitted a new trip for review.';
      case 'trip_approved':
        return isAr
            ? 'تهانينا! رحلتك متاحة الآن للحجز.'
            : 'Congratulations! Your trip is now open for bookings.';
      case 'trip_rejected':
        return isAr ? 'تم رفض رحلتك.' : 'Your trip was rejected.';
      case 'booking_new':
        return isAr
            ? 'لديك حجز جديد من سائح.'
            : 'A tourist has booked your trip.';
      case 'booking_approved':
        return isAr
            ? 'تم قبول حجزك بنجاح.'
            : 'Your booking has been approved.';
      case 'booking_cancelled':
        return isAr ? 'تم إلغاء حجزك.' : 'Your booking has been cancelled.';
      case 'guide_verified':
        return isAr
            ? 'تهانينا! تم توثيق حسابك كمرشد معتمد.'
            : 'Your guide account has been verified.';
      case 'points_awarded':
        return isAr
            ? 'تم منحك نقاطاً إضافية.'
            : 'Bonus points have been added to your account.';
      default:
        return isAr ? 'لديك تنبيه جديد.' : 'You have a new notification.';
    }
  }
}

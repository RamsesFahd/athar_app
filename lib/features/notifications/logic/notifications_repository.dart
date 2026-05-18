import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:athar_app/core/models/notification/app_notification_model.dart';

part 'notifications_repository.g.dart';

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository();
}

@riverpod
Stream<List<AppNotificationModel>> userNotifications(
  Ref ref,
  String userId,
) {
  return ref.watch(notificationsRepositoryProvider).getNotifications(userId);
}

@riverpod
Stream<int> unreadNotificationCount(Ref ref, String userId) {
  return ref
      .watch(notificationsRepositoryProvider)
      .getUnreadCount(userId);
}

// ── Bilingual copy for each notification type ──────────────────────────────

Map<String, Map<String, String>> _titles = {
  'contribution_approved': {'ar': 'تم قبول المساهمة', 'en': 'Contribution Approved'},
  'contribution_rejected': {'ar': 'تم رفض المساهمة', 'en': 'Contribution Rejected'},
  'contribution_submitted': {'ar': 'مساهمة جديدة بانتظار المراجعة', 'en': 'New Contribution Awaiting Review'},
  'trip_submitted':        {'ar': 'رحلة جديدة بانتظار المراجعة', 'en': 'New Trip Awaiting Review'},
  'trip_approved':         {'ar': 'تم قبول رحلتك', 'en': 'Trip Approved'},
  'trip_rejected':         {'ar': 'تم رفض رحلتك', 'en': 'Trip Rejected'},
  'booking_new':           {'ar': 'حجز جديد', 'en': 'New Booking'},
  'booking_approved':      {'ar': 'تم قبول الحجز', 'en': 'Booking Approved'},
  'booking_cancelled':     {'ar': 'تم إلغاء الحجز', 'en': 'Booking Cancelled'},
  'guide_verified':        {'ar': 'تم توثيق حسابك', 'en': 'Account Verified'},
  'points_awarded':        {'ar': 'نقاط إضافية', 'en': 'Bonus Points Awarded'},
};

Map<String, Map<String, String>> _bodies = {
  'contribution_approved': {'ar': 'تم قبول مساهمتك بنجاح وإضافة النقاط لحسابك.', 'en': 'Your contribution was approved and points have been added.'},
  'contribution_rejected': {'ar': 'تم رفض مساهمتك. يرجى مراجعة السبب.', 'en': 'Your contribution was rejected. Please review the reason.'},
  'contribution_submitted': {'ar': 'قدّم سائح مساهمة جديدة تحتاج للمراجعة.', 'en': 'A tourist submitted a new contribution for review.'},
  'trip_submitted':        {'ar': 'قام مرشد بتقديم رحلة جديدة تحتاج للمراجعة.', 'en': 'A guide submitted a new trip for review.'},
  'trip_approved':         {'ar': 'تهانينا! تم قبول رحلتك وأصبحت متاحة للحجز.', 'en': 'Congratulations! Your trip is approved and open for bookings.'},
  'trip_rejected':         {'ar': 'تم رفض رحلتك. يرجى مراجعة التفاصيل.', 'en': 'Your trip was rejected. Please review the details.'},
  'booking_new':           {'ar': 'لديك حجز جديد من سائح. تحقق من التفاصيل.', 'en': 'A tourist booked your trip. Review the details.'},
  'booking_approved':      {'ar': 'تم قبول حجزك بنجاح. استعد لرحلتك!', 'en': 'Your booking is confirmed. Get ready for your trip!'},
  'booking_cancelled':     {'ar': 'تم إلغاء حجزك.', 'en': 'Your booking has been cancelled.'},
  'guide_verified':        {'ar': 'تهانينا! تم توثيق حسابك كمرشد سياحي معتمد.', 'en': 'Congratulations! Your guide account has been verified.'},
  'points_awarded':        {'ar': 'تم منحك نقاطاً إضافية من الإدارة.', 'en': 'The admin has awarded you bonus points.'},
};

class NotificationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addNotification({
    required String userId,
    required String type,
    String? bodyOverrideAr,
    String? bodyOverrideEn,
  }) async {
    final doc = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc();

    await doc.set({
      'type': type,
      'title': _titles[type] ?? {'ar': 'تنبيه', 'en': 'Notification'},
      'body': bodyOverrideAr != null
          ? {'ar': bodyOverrideAr, 'en': bodyOverrideEn ?? bodyOverrideAr}
          : _bodies[type] ?? {'ar': '', 'en': ''},
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Stream<List<AppNotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AppNotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.size);
  }
}

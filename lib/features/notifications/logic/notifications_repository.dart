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

const Map<String, String> _emptyLocalizedCopy = {'ar': '', 'en': ''};

class NotificationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addNotification({
    required String userId,
    required String type,
    String? bodyOverrideAr,
    String? bodyOverrideEn,
    // Deterministic ID prevents duplicate writes from Cloud Functions and
    // client code firing for the same event.
    String? notificationId,
  }) async {
    final collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
    final doc = notificationId != null
        ? collection.doc(notificationId)
        : collection.doc();

    await doc.set({
      'type': type,
      'title': _emptyLocalizedCopy,
      'body': bodyOverrideAr != null
          ? {'ar': bodyOverrideAr, 'en': bodyOverrideEn ?? bodyOverrideAr}
          : _emptyLocalizedCopy,
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
    // Firestore batches cap at 500 writes — chunk to stay within the limit.
    const chunkSize = 500;
    for (var i = 0; i < snap.docs.length; i += chunkSize) {
      final chunk = snap.docs.skip(i).take(chunkSize);
      final batch = _firestore.batch();
      for (final doc in chunk) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    }
  }

  Stream<List<AppNotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AppNotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteAllNotifications(String userId) async {
    final snap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .get();
    const chunkSize = 500;
    for (var i = 0; i < snap.docs.length; i += chunkSize) {
      final chunk = snap.docs.skip(i).take(chunkSize);
      final batch = _firestore.batch();
      for (final doc in chunk) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> deleteNotification(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  Stream<int> getUnreadCount(String userId) {
    // Bounded to 999 so the snapshot never transfers thousands of documents
    // just to derive a badge count. The Firestore Flutter SDK has no native
    // aggregate-count stream, so we cap the documents instead.
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .limit(999)
        .snapshots()
        .map((snap) => snap.size);
  }
}

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
  return ref
      .watch(notificationsRepositoryProvider)
      .getNotifications(userId);
}

class NotificationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  Future<void> addNotification({
  required String userId,
  required String type,
  String? body,
}) async {
  final doc = _firestore
      .collection('users')
      .doc(userId)
      .collection('notifications')
      .doc();

  await doc.set({
    'type': type,
    'body': body,
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
      .update({
    'isRead': true,
  });
}

  Stream<List<AppNotificationModel>> getNotifications(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => AppNotificationModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }
}
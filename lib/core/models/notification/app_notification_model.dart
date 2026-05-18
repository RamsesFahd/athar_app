import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationModel {
  final String id;
  final String type;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final bool isRead;
  final DateTime createdAt;

  AppNotificationModel({
    required this.id,
    required this.type,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotificationModel.fromMap(Map<String, dynamic> map, String id) {
    final titleMap = map['title'];
    final bodyMap = map['body'];

    return AppNotificationModel(
      id: id,
      type: map['type'] ?? '',
      titleAr: (titleMap is Map ? titleMap['ar'] : null) ?? '',
      titleEn: (titleMap is Map ? titleMap['en'] : null) ?? '',
      bodyAr: (bodyMap is Map ? bodyMap['ar'] : null) ??
          (bodyMap is String ? bodyMap : ''),
      bodyEn: (bodyMap is Map ? bodyMap['en'] : null) ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

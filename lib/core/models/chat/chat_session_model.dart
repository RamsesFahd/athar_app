import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSessionModel {
  final String sessionId;
  final String regionId;
  final String titleAr;
  final String titleEn;
  final String title;
  final DateTime lastMessageTime;

  ChatSessionModel({
    required this.sessionId,
    required this.regionId,
    required this.titleAr,
    required this.titleEn,
    this.title = '',
    required this.lastMessageTime,
  });

  String localizedTitle(String languageCode) {
    final legacy = title.trim();
    final legacyHasArabic = _containsArabic(legacy);

    if (languageCode == 'ar') {
      if (titleAr.isNotEmpty) {
        return titleAr;
      }
      return legacyHasArabic ? legacy : '';
    }

    if (titleEn.isNotEmpty) {
      return titleEn;
    }
    return (!legacyHasArabic && legacy.isNotEmpty) ? legacy : '';
  }

  static bool _containsArabic(String value) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return arabicRegex.hasMatch(value);
  }

  // Convert model to Firestore document [cite: 3, 13]
  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'regionId': regionId,
      'titleAr': titleAr,
      'titleEn': titleEn,
      // Keep legacy field for older app versions.
      'title': titleAr,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
    };
  }

  // Create model from Firestore document [cite: 3, 13]
  factory ChatSessionModel.fromMap(Map<String, dynamic> map) {
    final legacyTitle = (map['title'] as String?) ?? '';
    final arTitle = (map['titleAr'] as String?) ?? '';
    final enTitle = (map['titleEn'] as String?) ?? '';

    return ChatSessionModel(
      sessionId: map['sessionId'] ?? '',
      regionId: map['regionId'] ?? '',
      titleAr: arTitle,
      titleEn: enTitle,
      title: legacyTitle,
      lastMessageTime: map['lastMessageTime'] is Timestamp
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

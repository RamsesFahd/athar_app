import 'package:athar_app/features/home/models/hero_ai_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType { festival, exhibition, workshop, performance, other }

extension EventTypeExtension on EventType {
  String get value {
    switch (this) {
      case EventType.festival:
        return 'festival';
      case EventType.exhibition:
        return 'exhibition';
      case EventType.workshop:
        return 'workshop';
      case EventType.performance:
        return 'performance';
      case EventType.other:
        return 'other';
    }
  }

  String get labelAr {
    switch (this) {
      case EventType.festival:
        return 'مهرجان';
      case EventType.exhibition:
        return 'معرض';
      case EventType.workshop:
        return 'ورشة عمل';
      case EventType.performance:
        return 'عرض';
      case EventType.other:
        return 'أخرى';
    }
  }

  String get labelEn {
    switch (this) {
      case EventType.festival:
        return 'Festival';
      case EventType.exhibition:
        return 'Exhibition';
      case EventType.workshop:
        return 'Workshop';
      case EventType.performance:
        return 'Performance';
      case EventType.other:
        return 'Other';
    }
  }

  static EventType fromString(String? value) {
    switch (value) {
      case 'festival':
        return EventType.festival;
      case 'exhibition':
        return EventType.exhibition;
      case 'workshop':
        return EventType.workshop;
      case 'performance':
        return EventType.performance;
      default:
        return EventType.other;
    }
  }
}

class EventModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String imageUrl;
  final List<String> gallery;
  final String? videoUrl;
  final DateTime eventDate;
  final String timeAr;
  final String timeEn;
  final String? endTimeAr;
  final String? endTimeEn;
  final double latitude;
  final double longitude;
  final String regionId;
  final String regionAr;
  final String regionEn;
  final String categoryId;
  final EventType eventType;
  final String? ticketUrl;
  final bool isFree;
  final DateTime? endDate;
  final DateTime? createdAt;
  final String? createdBy;
  final List<String> interestIds;
  final HeroAiText? heroCopy;

  EventModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.imageUrl,
    this.gallery = const [],
    this.videoUrl,
    required this.eventDate,
    required this.timeAr,
    required this.timeEn,
    this.endTimeAr,
    this.endTimeEn,
    required this.latitude,
    required this.longitude,
    required this.regionId,
    required this.regionAr,
    required this.regionEn,
    required this.categoryId,
    required this.eventType,
    this.ticketUrl,
    required this.isFree,
    this.endDate,
    this.createdAt,
    this.createdBy,
    this.interestIds = const [],
    this.heroCopy,
  });

  String getTitle(bool isAr) => isAr ? titleAr : titleEn;
  String getDescription(bool isAr) => isAr ? descriptionAr : descriptionEn;
  String getTime(bool isAr) {
    final start = isAr ? timeAr : timeEn;
    final end = isAr ? endTimeAr : endTimeEn;
    if (end != null && end.isNotEmpty) return '$start – $end';
    return start;
  }
  String getRegion(bool isAr) => isAr ? regionAr : regionEn;

  Map<String, dynamic> toMap() {
    return {
      'titleAr': titleAr,
      'titleEn': titleEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'imageUrl': imageUrl,
      'gallery': gallery,
      if (videoUrl != null) 'videoUrl': videoUrl,
      'eventDate': Timestamp.fromDate(eventDate),
      'timeAr': timeAr,
      'timeEn': timeEn,
      if (endTimeAr != null) 'endTimeAr': endTimeAr,
      if (endTimeEn != null) 'endTimeEn': endTimeEn,
      'latitude': latitude,
      'longitude': longitude,
      'regionId': regionId,
      'regionAr': regionAr,
      'regionEn': regionEn,
      'categoryId': categoryId,
      'eventType': eventType.value,
      'ticketUrl': ticketUrl,
      'isFree': isFree,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'createdBy': createdBy,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map, String docId) {
    return EventModel(
      id: docId,
      titleAr: map['titleAr'] ?? '',
      titleEn: map['titleEn'] ?? '',
      descriptionAr: map['descriptionAr'] ?? '',
      descriptionEn: map['descriptionEn'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      gallery: (map['gallery'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList(),
      videoUrl: map['videoUrl']?.toString(),
      eventDate: map['eventDate'] != null
          ? (map['eventDate'] as Timestamp).toDate()
          : DateTime.now(),
      timeAr: map['timeAr'] ?? '',
      timeEn: map['timeEn'] ?? '',
      endTimeAr: map['endTimeAr'],
      endTimeEn: map['endTimeEn'],
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      regionId: map['regionId'] ?? '',
      regionAr: map['regionAr'] ?? '',
      regionEn: map['regionEn'] ?? '',
      categoryId: map['categoryId'] ?? '',
      eventType: EventTypeExtension.fromString(map['eventType']),
      ticketUrl: map['ticketUrl'],
      isFree: map['isFree'] ?? true,
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      createdBy: map['createdBy'] ?? 'Admin',
      interestIds: List<String>.from(map['interestIds'] ?? []),
      heroCopy: map['heroCopy'] is Map
          ? HeroAiText.fromMap(Map<String, dynamic>.from(map['heroCopy'] as Map))
          : null,
    );
  }
}

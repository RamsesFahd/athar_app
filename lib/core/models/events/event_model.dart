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
  final DateTime eventDate;
  final String timeAr;
  final String timeEn;
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

  EventModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.imageUrl,
    required this.eventDate,
    required this.timeAr,
    required this.timeEn,
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
  });

  String getTitle(bool isAr) => isAr ? titleAr : titleEn;
  String getDescription(bool isAr) => isAr ? descriptionAr : descriptionEn;
  String getTime(bool isAr) => isAr ? timeAr : timeEn;
  String getRegion(bool isAr) => isAr ? regionAr : regionEn;

  Map<String, dynamic> toMap() {
    return {
      'titleAr': titleAr,
      'titleEn': titleEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'imageUrl': imageUrl,
      'eventDate': Timestamp.fromDate(eventDate),
      'timeAr': timeAr,
      'timeEn': timeEn,
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
      eventDate: map['eventDate'] != null
          ? (map['eventDate'] as Timestamp).toDate()
          : DateTime.now(),
      timeAr: map['timeAr'] ?? '',
      timeEn: map['timeEn'] ?? '',
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
    );
  }
}

import 'package:athar_app/core/utils/currency_formatter.dart';
import 'package:athar_app/features/home/models/hero_ai_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final String cityAr;
  final String cityEn;
  final String guide;
  final String company;
  final double adultPrice;
  final double childPrice; // 0.0 = free for children
  final String imageUrl;
  final String descriptionAr;
  final String descriptionEn;
  final String license;
  final String shortDescriptionAr;
  final String shortDescriptionEn;
  final String regionId;
  final String? tutorId;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String tutorType; // 'individual' | 'company'
  final String tripType; // 'shared' | 'private'
  final List<String> accessibilityFeatures;
  final List<String> interestIds;
  final HeroAiText? heroCopy;

  // ── Guide snapshot ────────────────────────────────────────────────────────
  final String? guideBio;
  final List<String>? guideLanguages;
  final double? guideRating;
  final int? guideReviewsCount;

  // ── Trip languages (company-set per-trip) ─────────────────────────────────
  final List<String>? tripLanguages;

  // ── Capacity & kids policy ────────────────────────────────────────────────
  /// Whether child bookings are permitted on this trip.
  final bool allowsKids;

  /// Maximum adult-equivalent slots per booking window. 2 kids = 1 adult slot.
  final int? maxCapacity;

  // ── Schedule ──────────────────────────────────────────────────────────────
  /// Daily start time stored as "HH:mm", e.g. "08:00".
  final String? startTime;

  /// Daily end time stored as "HH:mm", e.g. "18:00".
  final String? endTime;

  /// How many consecutive days a single booking spans. null / 1 = same-day.
  final int? tripDurationDays;

  // ── Legacy availability window (kept for backward compat) ─────────────────
  final DateTime? startDate;
  final DateTime? endDate;

  /// Remaining bookable slots. Decremented by Cloud Function on each confirmed
  /// booking; restored on cancellation or rejection. Defaults to maxCapacity
  /// when the trip is first created.
  final int? availableSeats;

  TripModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.cityAr,
    required this.cityEn,
    required this.guide,
    required this.company,
    required this.adultPrice,
    required this.childPrice,
    required this.imageUrl,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.license,
    required this.shortDescriptionAr,
    required this.shortDescriptionEn,
    this.regionId = '',
    this.tutorId,
    this.status = 'pending',
    this.tutorType = 'individual',
    this.tripType = 'shared',
    this.accessibilityFeatures = const [],
    this.guideBio,
    this.guideLanguages,
    this.guideRating,
    this.guideReviewsCount,
    this.tripLanguages,
    this.interestIds = const [],
    this.heroCopy,
    this.allowsKids = false,
    this.maxCapacity,
    this.startTime,
    this.endTime,
    this.tripDurationDays,
    this.startDate,
    this.endDate,
    int? availableSeats,
  }) : availableSeats = availableSeats ?? maxCapacity;

  // ── Schedule helpers ──────────────────────────────────────────────────────

  /// Number of days the trip spans (1 = single-day).
  int get durationDays {
    if (startDate == null || endDate == null) return 1;
    final diff = endDate!
        .toLocal()
        .difference(startDate!.toLocal())
        .inDays;
    return diff + 1;
  }

  bool get isMultiDay => (tripDurationDays ?? 0) > 1 || durationDays > 1;

  bool get isPrivate => tripType == 'private';

  /// For shared trips: driven by availableSeats. For private trips use
  /// [isPrivateFullyBooked] instead (requires the async booked-dates set).
  bool get isFullyBooked => availableSeats != null && availableSeats! <= 0;

  /// Returns true when every calendar day in [startDate]→[endDate] has an
  /// active (pending/approved) booking. Only meaningful for private trips.
  bool isPrivateFullyBooked(Set<String> bookedDates) {
    if (startDate == null || endDate == null) return false;
    var day = DateTime(startDate!.year, startDate!.month, startDate!.day);
    final last = DateTime(endDate!.year, endDate!.month, endDate!.day);
    while (!day.isAfter(last)) {
      final key =
          '${day.year.toString().padLeft(4, '0')}-'
          '${day.month.toString().padLeft(2, '0')}-'
          '${day.day.toString().padLeft(2, '0')}';
      if (!bookedDates.contains(key)) return false;
      day = day.add(const Duration(days: 1));
    }
    return true;
  }

  /// Human-readable daily time slot, e.g. "08:00 – 18:00".
  String? get timeRange {
    if (startTime == null && endTime == null) return null;
    final s = startTime ?? '';
    final e = endTime ?? '';
    return '$s – $e';
  }

  // ── Display helpers ───────────────────────────────────────────────────────

  String get price => CurrencyFormatter.formatNumber(adultPrice);
  String getTitle(bool isAr) => isAr ? titleAr : titleEn;
  String getDescription(bool isAr) => isAr ? descriptionAr : descriptionEn;
  String getShortDescription(bool isAr) =>
      isAr ? shortDescriptionAr : shortDescriptionEn;
  String getCity(bool isAr) => isAr ? cityAr : cityEn;

  // ── Serialisation ─────────────────────────────────────────────────────────

  factory TripModel.fromMap(Map<String, dynamic> map, String documentId) {
    double parsePrice(dynamic raw) {
      if (raw == null) return 0.0;
      if (raw is num) return raw.toDouble();
      final cleaned = raw.toString().replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }

    return TripModel(
      id: documentId,
      titleAr: map['titleAr'] ?? '',
      titleEn: map['titleEn'] ?? '',
      cityAr: map['cityAr'] ?? map['city'] ?? '',
      cityEn: map['cityEn'] ?? map['city'] ?? '',
      guide: map['guide'] ?? '',
      company: map['company'] ?? '',
      adultPrice: parsePrice(map['adultPrice'] ?? map['price']),
      childPrice: parsePrice(map['childPrice']),
      imageUrl: map['imageUrl'] ?? '',
      descriptionAr: map['descriptionAr'] ?? '',
      descriptionEn: map['descriptionEn'] ?? '',
      license: map['license'] ?? '',
      shortDescriptionAr: map['shortDescriptionAr'] ?? '',
      shortDescriptionEn: map['shortDescriptionEn'] ?? '',
      regionId: map['regionId'] ?? '',
      tutorId: map['tutorId'],
      status: map['status'] ?? 'pending',
      tutorType: map['tutorType'] ?? 'individual',
      tripType: map['tripType'] as String? ?? 'shared',
      accessibilityFeatures:
          List<String>.from(map['accessibilityFeatures'] ?? []),
      interestIds: List<String>.from(map['interestIds'] ?? []),
      guideBio: map['guideBio'] as String?,
      guideLanguages: (map['guideLanguages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      guideRating: (map['guideRating'] as num?)?.toDouble(),
      guideReviewsCount: map['guideReviewsCount'] as int?,
      tripLanguages: (map['tripLanguages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      allowsKids: map['allowsKids'] as bool? ?? false,
      maxCapacity: map['maxCapacity'] as int?,
      startTime: map['startTime'] as String?,
      endTime: map['endTime'] as String?,
      tripDurationDays: map['tripDurationDays'] as int?,
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      availableSeats: map['availableSeats'] as int?,
      heroCopy: map['heroCopy'] is Map
          ? HeroAiText.fromMap(Map<String, dynamic>.from(map['heroCopy'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titleAr': titleAr,
      'titleEn': titleEn,
      'cityAr': cityAr,
      'cityEn': cityEn,
      'guide': guide,
      'company': company,
      'adultPrice': adultPrice,
      'childPrice': childPrice,
      'imageUrl': imageUrl,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'license': license,
      'shortDescriptionAr': shortDescriptionAr,
      'shortDescriptionEn': shortDescriptionEn,
      'regionId': regionId,
      'tutorId': tutorId,
      'status': status,
      'tutorType': tutorType,
      'tripType': tripType,
      'accessibilityFeatures': accessibilityFeatures,
      'guideBio': guideBio,
      'guideLanguages': guideLanguages,
      'guideRating': guideRating,
      'guideReviewsCount': guideReviewsCount,
      'tripLanguages': tripLanguages,
      'allowsKids': allowsKids,
      'maxCapacity': maxCapacity,
      'startTime': startTime,
      'endTime': endTime,
      'tripDurationDays': tripDurationDays,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'availableSeats': availableSeats,
    };
  }
}

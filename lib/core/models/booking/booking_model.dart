import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, approved, rejected, cancelled, completed }

class BookingModel {
  final String bookingId;
  final String touristId;
  final String tutorId;
  final String tripId;
  final String tripTitle;
  final String tripCity;
  final String date;
  final String timeSlot;
  final int adultsCount;
  final int childrenCount;
  final double adultPrice;
  final double childPrice;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;
  final String imageUrl;
  /// How many consecutive days this booking spans. null/1 = single day.
  final int? tripDurationDays;
  @Deprecated('Read live from users collection — see booking_view_screen')
  final String? tutorPhone;
  @Deprecated('Read live from users collection — see booking_view_screen')
  final String? tutorName;

  bool get isMultiDay => (tripDurationDays ?? 1) > 1;

  BookingModel({
    required this.bookingId,
    required this.touristId,
    required this.tutorId,
    required this.tripId,
    required this.tripTitle,
    this.tripCity = '',
    required this.date,
    required this.timeSlot,
    required this.adultsCount,
    required this.childrenCount,
    this.adultPrice = 0.0,
    this.childPrice = 0.0,
    required this.totalPrice,
    this.status = BookingStatus.pending,
    required this.createdAt,
    required this.imageUrl,
    this.tripDurationDays,
    this.tutorPhone,
    this.tutorName,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'touristId': touristId,
      'tutorId': tutorId,
      'tripId': tripId,
      'tripTitle': tripTitle,
      'tripCity': tripCity,
      'date': date,
      'timeSlot': timeSlot,
      'adultsCount': adultsCount,
      'childrenCount': childrenCount,
      'adultPrice': adultPrice,
      'childPrice': childPrice,
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'tripDurationDays': tripDurationDays,
      // ignore: deprecated_member_use_from_same_package
      'tutorPhone': tutorPhone,
      // ignore: deprecated_member_use_from_same_package
      'tutorName': tutorName,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingId: map['bookingId'] ?? '',
      touristId: map['touristId'] ?? '',
      tutorId: map['tutorId'] ?? '',
      tripId: map['tripId'] ?? '',
      tripTitle: map['tripTitle'] ?? '',
      tripCity: map['tripCity'] ?? '',
      date: map['date'] ?? '',
      timeSlot: map['timeSlot'] ?? '',
      adultsCount: map['adultsCount'] ?? 1,
      childrenCount: map['childrenCount'] ?? 0,
      adultPrice: (map['adultPrice'] as num?)?.toDouble() ?? 0.0,
      childPrice: (map['childPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'] ?? '',
      tripDurationDays: map['tripDurationDays'] as int?,
      tutorPhone: map['tutorPhone'] as String?,
      tutorName: map['tutorName'] as String?,
    );
  }

  BookingModel copyWith({
    String? bookingId,
    String? touristId,
    String? tutorId,
    String? tripId,
    String? tripTitle,
    String? tripCity,
    String? date,
    String? timeSlot,
    int? adultsCount,
    int? childrenCount,
    double? adultPrice,
    double? childPrice,
    double? totalPrice,
    BookingStatus? status,
    DateTime? createdAt,
    String? imageUrl,
    int? tripDurationDays,
    String? tutorPhone,
    String? tutorName,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      touristId: touristId ?? this.touristId,
      tutorId: tutorId ?? this.tutorId,
      tripId: tripId ?? this.tripId,
      tripTitle: tripTitle ?? this.tripTitle,
      tripCity: tripCity ?? this.tripCity,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      adultsCount: adultsCount ?? this.adultsCount,
      childrenCount: childrenCount ?? this.childrenCount,
      adultPrice: adultPrice ?? this.adultPrice,
      childPrice: childPrice ?? this.childPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      tripDurationDays: tripDurationDays ?? this.tripDurationDays,
      // ignore: deprecated_member_use_from_same_package
      tutorPhone: tutorPhone ?? this.tutorPhone,
      // ignore: deprecated_member_use_from_same_package
      tutorName: tutorName ?? this.tutorName,
    );
  }
}

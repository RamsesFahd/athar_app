part of 'user_model.dart';

class TouristModel extends UserModel {
  final int points;
  final List<String>? interests;
  final int contributionsCount;

  TouristModel({
    required super.uId,
    required super.fullName,
    required super.email,
    super.phoneNumber,
    super.phoneVerified,
    super.role = UserRole.tourist,
    required super.createdAt,
    super.profileImage,
    required super.accessibilitySettings,
    this.points = 0,
    this.interests,
    this.contributionsCount = 0,
    super.emailVerified,
  });

  @override
  Map<String, dynamic> toMap() => {
    'uId': uId,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'phoneVerified': phoneVerified,
    'role': role.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'profileImage': profileImage,
    'accessibilitySettings': accessibilitySettings.toMap(),
    'points': points,
    'interests': interests,
    'contributionsCount': contributionsCount,
    'emailVerified': emailVerified,

  };

  factory TouristModel.fromMap(Map<String, dynamic> map) {
    final roleString = map['role'] as String? ?? 'tourist';
    final userRole = UserRole.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => UserRole.tourist,
    );

    return TouristModel(
      uId: map['uId'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      phoneVerified: map['phoneVerified'] ?? false,
      role: userRole,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profileImage: map['profileImage'],
      accessibilitySettings: AccessibilitySettings.fromMap(map['accessibilitySettings']),
      points: map['points'] ?? 0,
      interests: map['interests'] != null ? List<String>.from(map['interests']) : null,
      contributionsCount: map['contributionsCount'] ?? 0,
      emailVerified: map['emailVerified'] ?? false,
    );
  }
}
part of 'user_model.dart';

class TouristModel extends UserModel {
  final int points;
  final List<String> culturalInterests;
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
    this.culturalInterests = const [],
    this.contributionsCount = 0,
    super.emailVerified,
    super.privacyPolicyAcceptedAt,
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
    'culturalInterests': culturalInterests,
    'contributionsCount': contributionsCount,
    'emailVerified': emailVerified,
    'privacyPolicyAcceptedAt': privacyPolicyAcceptedAt != null
        ? Timestamp.fromDate(privacyPolicyAcceptedAt!)
        : null,
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
      culturalInterests: List<String>.from(map['culturalInterests'] ?? map['interests'] ?? []),
      contributionsCount: map['contributionsCount'] ?? 0,
      emailVerified: map['emailVerified'] ?? false,
      privacyPolicyAcceptedAt:
          (map['privacyPolicyAcceptedAt'] as Timestamp?)?.toDate(),
    );
  }
}
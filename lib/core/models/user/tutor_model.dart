part of 'user_model.dart';

class TutorModel extends UserModel {
  final String? bio;
  final String? licenceNumber;
  final String? verificationStatus;

  TutorModel({
    required super.uId,
    required super.fullName,
    required super.email,
    super.role = UserRole.tutor,
    required super.createdAt,
    super.profileImage,
    required super.accessibilitySettings,
    this.bio,
    this.licenceNumber,
    this.verificationStatus,
  });

  @override
  Map<String, dynamic> toMap() => {
    'uId': uId,
    'fullName': fullName,
    'email': email,
    'role': role.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'profileImage': profileImage,
    'accessibilitySettings': accessibilitySettings.toMap(),
    'bio': bio,
    'licenceNumber': licenceNumber,
    'verificationStatus': verificationStatus,
  };

  factory TutorModel.fromMap(Map<String, dynamic> map) => TutorModel(
    uId: map['uId'] ?? '',
    fullName: map['fullName'] ?? '',
    email: map['email'] ?? '',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    profileImage: map['profileImage'],
    accessibilitySettings: AccessibilitySettings.fromMap(map['accessibilitySettings']),
    bio: map['bio'],
    licenceNumber: map['licenceNumber'],
    verificationStatus: map['verificationStatus'],
  );
}
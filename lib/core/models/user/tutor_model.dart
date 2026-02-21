part of 'user_model.dart';

class TutorModel extends UserModel {
  final String? bio;
  final String? licenceNumber;
  final String? verificationStatus;

  TutorModel({
    required super.uId,
    required super.fullName,
    required super.email,
    super.phoneNumber,
    super.role = UserRole.tutor,
    required super.createdAt,
    super.profileImage,
    required super.accessibilitySettings,
    this.bio,
    this.licenceNumber,
    this.verificationStatus,
    super.emailVerified,
  });

  @override
  Map<String, dynamic> toMap() => {
    'uId': uId,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'role': role.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'profileImage': profileImage,
    'accessibilitySettings': accessibilitySettings.toMap(),
    'bio': bio,
    'licenceNumber': licenceNumber,
    'verificationStatus': verificationStatus,
    'emailVerified': emailVerified,
  };

  factory TutorModel.fromMap(Map<String, dynamic> map) {
    
    final roleString = map['role'] as String? ?? 'tutor';
    final userRole = UserRole.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => UserRole.tutor,
    );

    
    return TutorModel(
      uId: map['uId'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      role: userRole, 
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profileImage: map['profileImage'],
      accessibilitySettings: AccessibilitySettings.fromMap(map['accessibilitySettings']),
      bio: map['bio'],
      licenceNumber: map['licenceNumber'],
      verificationStatus: map['verificationStatus'],
      emailVerified: map['emailVerified'] ?? false,
    );
  }
}
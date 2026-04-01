part of 'user_model.dart';
enum TutorType {
  individual,
  company,
}
class TutorModel extends UserModel {
  final TutorType? tutorType;
  final String? bio;
  final String? licenceNumber;
  final String? verificationStatus;
  final String? companyName; // companies only
  final String? commercialRegistration; // the commercial registration number for companies

  TutorModel({
    required super.uId,
    required super.fullName,
    required super.email,
    super.phoneNumber,
    super.role = UserRole.tutor,
    required super.createdAt,
    super.profileImage,
    required super.accessibilitySettings,
    this.tutorType,
    this.bio,
    this.licenceNumber,
    this.verificationStatus,
    this.companyName,
    this.commercialRegistration,  
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
    'tutorType': tutorType?.name,
    'licenceNumber': licenceNumber,
    'verificationStatus': verificationStatus,
    'companyName': companyName,
    'commercialRegistration': commercialRegistration,
    'emailVerified': emailVerified,
  };

  factory TutorModel.fromMap(Map<String, dynamic> map) {
    
    final roleString = map['role'] as String? ?? 'tutor';
    final userRole = UserRole.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => UserRole.tutor,
    );

    final tutorTypeString = map['tutorType'] as String? ?? 'individual';
    final tutorType = TutorType.values.firstWhere(
      (e) => e.name == tutorTypeString,
      orElse: () => TutorType.individual,
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
      tutorType: tutorType,
      bio: map['bio'],
      licenceNumber: map['licenceNumber'],
      verificationStatus: map['verificationStatus'],
      companyName: map['companyName'],
      commercialRegistration: map['commercialRegistration'],
      emailVerified: map['emailVerified'] ?? false,
    );
  }
}
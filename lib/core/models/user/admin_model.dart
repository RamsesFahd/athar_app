part of 'user_model.dart';

class AdminModel extends UserModel {
  AdminModel({
    required super.uId,
    required super.fullName,
    required super.email,
    super.role = UserRole.admin,
    required super.createdAt,
    super.profileImage,
    required super.accessibilitySettings,
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
  };

  factory AdminModel.fromMap(Map<String, dynamic> map) => AdminModel(
    uId: map['uId'] ?? '',
    fullName: map['fullName'] ?? 'Admin',
    email: map['email'] ?? '',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    profileImage: map['profileImage'],
    accessibilitySettings: AccessibilitySettings.fromMap(map['accessibilitySettings']),
  );
}
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

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    final roleString = map['role'] as String? ?? 'admin';
    final userRole = UserRole.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => UserRole.admin,
    );

    return AdminModel(
      uId: map['uId'] ?? '',
      fullName: map['fullName'] ?? 'Admin',
      email: map['email'] ?? '',
      role: userRole, // تمرير الـ role المستخرج هنا
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profileImage: map['profileImage'],
      accessibilitySettings:
          AccessibilitySettings.fromMap(map['accessibilitySettings']),
    );
  }
}

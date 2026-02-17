import 'package:cloud_firestore/cloud_firestore.dart';

// Defines the various roles available within the Athar application.
enum UserRole {
  tourist,
  guide,
  communityMember,
  admin,
  guest,
}

// Represents the accessibility settings for a user, allowing customization of font size and contrast for better usability.
class AccessibilitySettings {
  final String fontSize;
  final bool highContrast;
  final String languagePreference;
  final bool textReaderEnabled;
// Constructor for AccessibilitySettings with default values for font size, contrast, and language preference.
  AccessibilitySettings({
    this.fontSize = 'medium',
    this.highContrast = false,
    this.languagePreference = 'ar',
    this.textReaderEnabled = false,
  });
// Converts the AccessibilitySettings instance into a map for storage or transmission.
  Map<String, dynamic> toMap() {
    return {
      'fontSize': fontSize,
      'highContrast': highContrast,
      'languagePreference': languagePreference,
      'textReaderEnabled': textReaderEnabled,
    };
  }
// Factory constructor to create an AccessibilitySettings instance from a map, providing default values if the map is null or missing keys.
  factory AccessibilitySettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return AccessibilitySettings();
    return AccessibilitySettings(
      fontSize: map['fontSize'] ?? 'medium',
      highContrast: map['highContrast'] ?? false,
      languagePreference: map['languagePreference'] ?? 'ar',
      textReaderEnabled: map['textReaderEnabled'] ?? false,
    );
  }
}
// Represents the guide-specific data for users with the guide role, including biography, license number, and verification status.
class GuideData {
  final String? bio;
  final String? licenceNumber;
  final String? verificationStatus;

  GuideData({
    this.bio,
    this.licenceNumber,
    this.verificationStatus,
  });
// Converts the GuideData instance into a map for storage or transmission.
  Map<String, dynamic> toMap() {
    return {
      'bio': bio,
      'licenceNumber': licenceNumber,
      'verificationStatus': verificationStatus,
    };
  }
// Factory constructor to create a GuideData instance from a map, providing default values if the map is null or missing keys.
  factory GuideData.fromMap(Map<String, dynamic>? map) {
    if (map == null) return GuideData();
    return GuideData(
      bio: map['bio'],
      licenceNumber: map['licenceNumber'],
      verificationStatus: map['verificationStatus'],
    );
  }
}
// Represents a user in the Athar application, encompassing general user information as well as role-specific data for guides and community members.
class UserModel {
  final String uId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final UserRole role;
  final AccessibilitySettings accessibilitySettings;
  final int points;
  final DateTime createdAt;
  final String? profileImage;

  // Role-Specific Fields
  final List<String>? interests;
  final GuideData? guideData;
  final int contributionsCount;

  UserModel({
    required this.uId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.role = UserRole.tourist,
    required this.accessibilitySettings,
    this.points = 0,
    required this.createdAt,
    this.profileImage,
    this.interests,
    this.guideData,
    this.contributionsCount = 0,
  });

// Creates a copy of the UserModel instance with optional new values for each field, allowing for easy updates while maintaining immutability.
  UserModel copyWith({
    String? fullName,
    String? phoneNumber,
    UserRole? role,
    AccessibilitySettings? accessibilitySettings,
    int? points,
    String? profileImage,
    List<String>? interests,
    GuideData? guideData,
    int? contributionsCount,
  }) {
    return UserModel(
      uId: uId,
      email: email,
      createdAt: createdAt,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      accessibilitySettings:
          accessibilitySettings ?? this.accessibilitySettings,
      points: points ?? this.points,
      profileImage: profileImage ?? this.profileImage,
      interests: interests ?? this.interests,
      guideData: guideData ?? this.guideData,
      contributionsCount:
          contributionsCount ?? this.contributionsCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'accessibilitySettings': accessibilitySettings.toMap(),
      'points': points,
      'createdAt': Timestamp.fromDate(createdAt),
      'profileImage': profileImage,
      if (interests != null) 'interests': interests,
      if (guideData != null) 'guideData': guideData!.toMap(),
      'contributionsCount': contributionsCount,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final ts = map['createdAt'];

    return UserModel(
      uId: map['uId'] ?? '',
      fullName: map['fullName'] ?? 'Guest',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.tourist,
      ),
      accessibilitySettings: AccessibilitySettings.fromMap(
        map['accessibilitySettings'],
      ),
      points: map['points'] ?? 0,
      createdAt:
          ts is Timestamp ? ts.toDate() : DateTime.now(),
      profileImage: map['profileImage'],
      interests: map['interests'] != null
          ? List<String>.from(map['interests'])
          : null,
      guideData: map['guideData'] != null
          ? GuideData.fromMap(map['guideData'])
          : null,
      contributionsCount: map['contributionsCount'] ?? 0,
    );
  }
}

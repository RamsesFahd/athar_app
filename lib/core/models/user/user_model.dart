import 'package:cloud_firestore/cloud_firestore.dart';

part 'admin_model.dart';
part 'tutor_model.dart';
part 'tourist_model.dart';
// Defines the various roles available within the Athar application.
enum UserRole {
  admin,
  tutor,    // instead of guide, we can use tutor 
  tourist, // represents regular users who explore the app and contribute content
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

abstract class UserModel {
  final String uId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final UserRole role;
  final DateTime createdAt;
  final String? profileImage;
  final AccessibilitySettings accessibilitySettings;
  final bool emailVerified;

  UserModel({
    required this.uId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.createdAt,
    this.profileImage,
    required this.accessibilitySettings,
    this.emailVerified = false,
  });

  // المصنع الذكي الذي يقرر أي ملف فرعي سيتم استدعاؤه
  factory UserModel.fromMap(Map<String, dynamic> map) {
    final roleString = map['role'] as String? ?? 'tourist';
    final role = UserRole.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => UserRole.tourist,
    );

    switch (role) {
      case UserRole.tutor: return TutorModel.fromMap(map);
      case UserRole.admin: return AdminModel.fromMap(map);
      default: return TouristModel.fromMap(map);
    }
  }

  Map<String, dynamic> toMap();
}
part of 'user_model.dart';

enum TutorType {
  individual,
  company,
}

enum VerificationStatus {
  unverified,
  pending,
  verified,
  rejected,
  expired,
}

class TutorModel extends UserModel {
  final TutorType? tutorType;
  final String? bio;
  final VerificationStatus? verificationStatus;
  final String? companyName;

  // Shared
  final List<String>? languages;
  final double? rating;
  final int? reviewsCount;

  // Individual only
  final String? licenceNumber;
  final DateTime? licenceExpiryDate;
  final int? experienceYears;

  // Company only
  final String? commercialRegistration;
  final DateTime? commercialRegExpiryDate;
  final String? tourismLicenceNumber;
  final DateTime? tourismLicenceExpiryDate;
  final int? foundedYear;

  TutorModel({
    required super.uId,
    required super.fullName,
    required super.email,
    super.phoneNumber,
    super.phoneVerified,
    super.role = UserRole.tutor,
    required super.createdAt,
    super.profileImage,
    required super.accessibilitySettings,
    super.emailVerified,
    this.tutorType,
    this.bio,
    this.verificationStatus,
    this.companyName,
    this.languages,
    this.rating,
    this.reviewsCount,
    this.licenceNumber,
    this.licenceExpiryDate,
    this.experienceYears,
    this.commercialRegistration,
    this.commercialRegExpiryDate,
    this.tourismLicenceNumber,
    this.tourismLicenceExpiryDate,
    this.foundedYear,
  });

  // ── Credential helpers ────────────────────────────────────────────────────

  DateTime? get _credentialExpiry {
    if (tutorType == TutorType.individual) return licenceExpiryDate;
    // For companies, both documents must be valid — use the earlier expiry
    if (commercialRegExpiryDate == null && tourismLicenceExpiryDate == null) {
      return null;
    }
    if (commercialRegExpiryDate == null) return tourismLicenceExpiryDate;
    if (tourismLicenceExpiryDate == null) return commercialRegExpiryDate;
    return commercialRegExpiryDate!.isBefore(tourismLicenceExpiryDate!)
        ? commercialRegExpiryDate
        : tourismLicenceExpiryDate;
  }
// gradlew signingReport
  bool get isCredentialExpired {
    final expiry = _credentialExpiry;
    if (expiry == null) return false;
    return expiry.isBefore(DateTime.now());
  }

  bool get isCredentialExpiringSoon {
    final expiry = _credentialExpiry;
    if (expiry == null) return false;
    final daysLeft = expiry.difference(DateTime.now()).inDays;
    return daysLeft >= 0 && daysLeft < 30;
  }

  bool get isCredentialValid {
    final expiry = _credentialExpiry;
    if (expiry == null) return false;
    return expiry.isAfter(DateTime.now());
  }

  // ── Profile completeness ──────────────────────────────────────────────────

  bool get isProfileComplete {
    // Common required fields
    if (bio == null || bio!.trim().isEmpty) return false;
    if (languages == null || languages!.isEmpty) return false;

    if (tutorType == TutorType.individual) {
      return licenceNumber != null && licenceExpiryDate != null;
    } else if (tutorType == TutorType.company) {
      return companyName != null &&
          commercialRegistration != null &&
          commercialRegExpiryDate != null &&
          tourismLicenceNumber != null &&
          tourismLicenceExpiryDate != null;
    }
    return false;
  }

  // ── Years active (works for both types) ──────────────────────────────────

  int? get yearsActive {
    if (tutorType == TutorType.company && foundedYear != null) {
      return DateTime.now().year - foundedYear!;
    }
    return experienceYears;
  }

  // ── Serialisation ─────────────────────────────────────────────────────────

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
        'emailVerified': emailVerified,
        'tutorType': tutorType?.name,
        'bio': bio,
        'verificationStatus': verificationStatus?.name,
        'companyName': companyName,
        'languages': languages,
        'rating': rating,
        'reviewsCount': reviewsCount,
        // Individual
        'licenceNumber': licenceNumber,
        'licenceExpiryDate': licenceExpiryDate != null
            ? Timestamp.fromDate(licenceExpiryDate!)
            : null,
        'experienceYears': experienceYears,
        // Company
        'commercialRegistration': commercialRegistration,
        'commercialRegExpiryDate': commercialRegExpiryDate != null
            ? Timestamp.fromDate(commercialRegExpiryDate!)
            : null,
        'tourismLicenceNumber': tourismLicenceNumber,
        'tourismLicenceExpiryDate': tourismLicenceExpiryDate != null
            ? Timestamp.fromDate(tourismLicenceExpiryDate!)
            : null,
        'foundedYear': foundedYear,
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

    final verificationStatusString = map['verificationStatus'] as String?;
    final verificationStatus = verificationStatusString != null
        ? VerificationStatus.values.firstWhere(
            (e) => e.name == verificationStatusString,
            orElse: () => VerificationStatus.unverified,
          )
        : VerificationStatus.unverified;

    return TutorModel(
      uId: map['uId'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      phoneVerified: map['phoneVerified'] ?? false,
      role: userRole,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profileImage: map['profileImage'],
      accessibilitySettings:
          AccessibilitySettings.fromMap(map['accessibilitySettings']),
      emailVerified: map['emailVerified'] ?? false,
      tutorType: tutorType,
      bio: map['bio'],
      verificationStatus: verificationStatus,
      companyName: map['companyName'],
      languages: (map['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      rating: (map['rating'] as num?)?.toDouble(),
      reviewsCount: map['reviewsCount'] as int?,
      // Individual
      licenceNumber: map['licenceNumber'],
      licenceExpiryDate:
          (map['licenceExpiryDate'] as Timestamp?)?.toDate(),
      experienceYears: map['experienceYears'] as int?,
      // Company
      commercialRegistration: map['commercialRegistration'],
      commercialRegExpiryDate:
          (map['commercialRegExpiryDate'] as Timestamp?)?.toDate(),
      tourismLicenceNumber: map['tourismLicenceNumber'],
      tourismLicenceExpiryDate:
          (map['tourismLicenceExpiryDate'] as Timestamp?)?.toDate(),
      foundedYear: map['foundedYear'] as int?,
    );
  }
}
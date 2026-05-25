import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Displays a contextual banner on the tutor profile settings tab explaining
/// what is blocking the tutor from publishing trips (expired credentials,
/// pending verification, incomplete profile fields, etc.).
///
/// Returns an empty widget if the tutor already has publish rights.
class TutorCompletenessCard extends ConsumerWidget {
  final TutorModel tutor;

  const TutorCompletenessCard({super.key, required this.tutor});

  /// Profile-level fields the tutor controls (bio, phone, languages).
  List<String> _missingProfileFields(TutorModel t, AppLocalizations l10n) {
    final missing = <String>[];
    if (t.bio == null || t.bio!.trim().isEmpty) missing.add(l10n.profileBioLabel);
    if (!t.phoneVerified) missing.add(l10n.profilePhoneMustBeVerified);
    // Languages are per-profile for individuals; companies set them per-trip.
    if (t.tutorType == TutorType.individual) {
      if (t.languages == null || t.languages!.isEmpty) {
        missing.add(l10n.profileLanguagesLabel);
      }
    }
    return missing;
  }

  /// Credential fields required for admin verification.
  List<String> _missingVerificationFields(TutorModel t, AppLocalizations l10n) {
    final missing = <String>[];
    if (t.tutorType == TutorType.individual) {
      if (t.licenceNumber == null) missing.add(l10n.profileMissingLicenceNumber);
      if (t.licenceExpiryDate == null) missing.add(l10n.profileMissingLicenceExpiryDate);
    } else if (t.tutorType == TutorType.company) {
      if (t.companyName == null) missing.add(l10n.profileMissingCompanyName);
      if (t.commercialRegistration == null) missing.add(l10n.profileMissingCommercialRegistration);
      if (t.commercialRegExpiryDate == null) missing.add(l10n.profileMissingCommercialRegExpiry);
      if (t.tourismLicenceNumber == null) missing.add(l10n.profileMissingTourismLicenceNumber);
      if (t.tourismLicenceExpiryDate == null) missing.add(l10n.profileMissingTourismLicenceExpiry);
    }
    return missing;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tutor.canPublishTrips) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isHighContrast = ref.watch(settingsProvider).highContrast;

    final profileMissing = _missingProfileFields(tutor, l10n);
    final verificationMissing = _missingVerificationFields(tutor, l10n);
    final isExpired  = tutor.verificationStatus == VerificationStatus.expired;
    final isPending  = tutor.verificationStatus == VerificationStatus.pending;
    final isRejected = tutor.verificationStatus == VerificationStatus.rejected;
    final isVerified = tutor.verificationStatus == VerificationStatus.verified;

    late String headline;
    String? subtext;
    late Color color;
    late IconData icon;
    List<String> itemsToList = const [];

    // Priority order: show the most blocking state first.
    if (isExpired) {
      headline = l10n.profileCredentialExpiredReverify;
      color = theme.colorScheme.error;
      icon = Icons.lock_outline;
    } else if (isRejected) {
      headline = l10n.profileVerificationRejectedTitle;
      subtext = tutor.rejectionReason;
      color = theme.colorScheme.error;
      icon = Icons.error_outline;
    } else if (isPending) {
      headline = l10n.profileVerificationPendingTitle;
      subtext = l10n.profileVerificationPendingSubtitle;
      color = isHighContrast ? theme.colorScheme.primary : Colors.orange;
      icon = Icons.hourglass_top_outlined;
    } else if (verificationMissing.isNotEmpty) {
      headline = l10n.profileCompleteVerificationToAddTrips;
      color = theme.colorScheme.primary;
      icon = Icons.assignment_ind_outlined;
      itemsToList = verificationMissing;
    } else if (isVerified && profileMissing.isNotEmpty) {
      headline = l10n.profileCompleteProfileToAddTrips;
      color = theme.colorScheme.primary;
      icon = Icons.info_outline;
      itemsToList = profileMissing;
    } else if (isVerified) {
      headline = l10n.profileCheckCredentialValidity;
      color = theme.colorScheme.error;
      icon = Icons.warning_amber_outlined;
    } else {
      headline = l10n.profileAwaitingAdminVerification;
      color = isHighContrast ? theme.colorScheme.primary : Colors.orange;
      icon = Icons.pending_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    if (subtext != null && subtext.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtext,
                        style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.85)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (itemsToList.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...itemsToList.map(
              (f) => Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 4, start: 28, end: 4),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: color.withValues(alpha: 0.7)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: TextStyle(fontSize: 13, color: color.withValues(alpha: 0.85)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

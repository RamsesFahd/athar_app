import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';
import 'package:athar_app/features/guide_market/Screens/add_trip_screen.dart';
import 'package:athar_app/features/guide_market/screens/booking_view_screen.dart';
import 'package:athar_app/features/profile/logic/profile_notifier.dart';
import 'package:flutter/scheduler.dart';
import 'package:athar_app/features/profile/screens/credential_verification_screen.dart';
import 'package:athar_app/features/profile/screens/phone_otp_dialog.dart';
import 'package:athar_app/features/profile/widgets/tutor_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../widgets/saved_card.dart';
import '../widgets/settings_tile.dart';
import '../widgets/guest_profile_view.dart';
import '../widgets/tourist_profile.dart';
import 'package:athar_app/core/providers/settings_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).value;
      if (user is TutorModel) {
        ref.read(profileNotifierProvider.notifier).checkAndExpireCredentials(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Watch the authentication state to conditionally render content or redirect if not authenticated
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (user) {
        if (user == null || user.role == UserRole.guest) {
          return const GuestProfileView();
        }
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildUserInformationHeader(theme, l10n, user),
                _buildNavigationTabs(theme, l10n),
                Expanded(
                  child: _buildDynamicContentArea(theme, l10n, user),
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text("Error: $e"))),
    );
  }

  Widget _buildUserInformationHeader(
      ThemeData theme, AppLocalizations l10n, UserModel user) {
    if (user is TouristModel) {
      return TouristHeader(user: user);
    } else if (user is TutorModel) {
      return TutorHeader(user: user);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildNavigationTabs(ThemeData theme, AppLocalizations l10n) {
    return Container(
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          _tabItem(l10n.profileTabSettings, 0, theme),
          _tabItem(l10n.profileTabBooking, 1, theme),
          _tabItem(l10n.profileTabSaved, 2, theme),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index, ThemeData theme) {
    final bool isSelected = _activeTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTabIndex = index),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.5),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 2,
              width: isSelected ? 40 : 0,
              color: theme.colorScheme.primary,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicContentArea(
      ThemeData theme, AppLocalizations l10n, UserModel user) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    switch (_activeTabIndex) {
      case 2:
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            SavedCard(
              title: "Edge of the World",
              location: "Riyadh",
              typeText: "Landmark",
              image:
                  "https://images.pexels.com/photos/6650442/pexels-photo-6650442.jpeg",
              isSaved: true,
              onTap: () {},
            ),
            SavedCard(
              title: "Janadriyah Festival",
              location: "Riyadh",
              typeText: "Event",
              dateText: "Mar 15-25, 2025",
              image:
                  "https://images.pexels.com/photos/4662950/pexels-photo-4662950.jpeg",
              isSaved: true,
              onTap: () {},
            ),
          ],
        );
      case 1:
        return StreamBuilder<List<BookingModel>>(
          stream: ref
              .read(marketplaceRepositoryProvider)
              .fetchUserBookings(user.uId, user.role),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final bookings = snapshot.data ?? [];
            if (bookings.isEmpty) {
              return Center(
                child: Text(
                  'No bookings yet',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: Colors.grey.shade500),
                ),
              );
            }
            final isTutor = user is TutorModel;
            // Sort: pending first for tutors
            List<BookingModel> sorted = List.from(bookings);
            if (isTutor) {
              sorted.sort((a, b) =>
                  a.status == BookingStatus.pending ? -1 : 1);
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final b = sorted[index];
                return _buildBookingItem(context, b, theme, l10n, user);
              },
            );
          },
        );
      case 0:
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                        if (user is TutorModel)
                          _buildTutorCompletenessCard(user, theme, isAr, context),
                    _buildSettingsGroup(
                      title: l10n.profileSettingsTitle,
                      theme: theme,
                      tiles: [
                        SettingsTile(
                          title: l10n.profileEditProfileTitle,
                          leadingIcon: Icons.mode_edit,
                          onTap: () => _showEditProfileSheet(context, l10n, user),
                        ),
                        if (user is TutorModel) ...[
                          if (user.verificationStatus != VerificationStatus.verified) ...[
                            SettingsTile(
                              title: user.verificationStatus == VerificationStatus.expired
                                  ? (isAr ? 'رخصتك منتهية — جدّد وأعد التوثيق' : 'Credential Expired — Re-verify')
                                  : l10n.tutorLicenseNumberTitle,
                              subtitle: user.verificationStatus == VerificationStatus.rejected
                                  ? (user.rejectionReason != null
                                      ? '${isAr ? 'سبب الرفض: ' : 'Reason: '}${user.rejectionReason}'
                                      : (isAr ? 'تم رفض طلبك، يمكنك إعادة التقديم' : 'Request rejected, you may resubmit'))
                                  : l10n.tutorCompleteVerificationSubtitle,
                              leadingIcon: Icons.assignment_ind_outlined,
                              titleColor: user.verificationStatus == VerificationStatus.expired
                                  ? Colors.red
                                  : theme.colorScheme.primary,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CredentialVerificationScreen(),
                                ),
                              ),
                            ),
                          ],
                          _buildAddTripTile(user, theme, l10n, isAr, context),
                        ],
                        if (user is TouristModel) ...[
                          SettingsTile(
                            title: l10n.manageContributions,
                            leadingIcon: Icons.edit_note_rounded,
                            onTap: () {},
                          ),
                          SettingsTile(
                            title: l10n.myInterests,
                            leadingIcon: Icons.favorite_border_rounded,
                            onTap: () {},
                          ),
                        ],
                        SettingsTile(
                          title: l10n.settingsChangePassword,
                          leadingIcon: Icons.lock_outline_rounded,
                          onTap: () async {
                            final email = user.email;
                            final messenger = ScaffoldMessenger.of(context);
                            await ref.read(authNotifierProvider.notifier).resetPassword(email: email);
                            messenger.showSnackBar(
                              const SnackBar(content: Text("تم إرسال رابط تغيير كلمة المرور إلى بريدك الإلكتروني")),
                            );
                          },
                          showDivider: false,
                        ),
                        SettingsTile(
                          title: l10n.profileEditPhone,
                          subtitle: user.phoneNumber,
                          leadingIcon: Icons.phone_android_outlined,
                          onTap: () => _showPhoneInputDialog(context, l10n, user.phoneNumber),
                          showDivider: false,
                        ),
                        SettingsTile(
                          title: l10n.profileLanguage,
                          subtitle: isAr
                              ? l10n.profileLanguageArabic
                              : l10n.profileLanguageEnglish,
                          leadingIcon: Icons.language_rounded,
                          onTap: () => _showLanguageBottomSheet(context, l10n),
                          showDivider: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSettingsGroup(
                      title: l10n.profileNotifications,
                      theme: theme,
                      tiles: [
                        SettingsTile(
                          title: l10n.profileBookingNotifications,
                          leadingIcon: Icons.notifications_none_rounded,
                          showDivider: false,
                          trailing: Switch(
                              value: true,
                              onChanged: (v) {},
                              activeThumbColor: theme.colorScheme.primary),
                        ),
                        SettingsTile(
                          title: l10n.profileEventReminders,
                          leadingIcon: Icons.calendar_today_outlined,
                          showDivider: false,
                          trailing: Switch(
                              value: true,
                              onChanged: (v) {},
                              activeThumbColor: theme.colorScheme.primary),
                        ),
                        SettingsTile(
                          title: l10n.profileMarketingEmails,
                          leadingIcon: Icons.mail_outline_rounded,
                          showDivider: false,
                          trailing: Switch(
                              value: false,
                              onChanged: (v) {},
                              activeThumbColor: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSettingsGroup(
                      title: l10n.settingsSupportLegal,
                      theme: theme,
                      tiles: [
                        SettingsTile(
                          title: l10n.settingsContactUs,
                          leadingIcon: Icons.support_agent_rounded,
                          onTap: () {},
                        ),
                        SettingsTile(
                          title: l10n.settingsPrivacyPolicy,
                          leadingIcon: Icons.privacy_tip_outlined,
                          onTap: () {},
                        ),
                        SettingsTile(
                          title: l10n.settingsAboutAthar,
                          leadingIcon: Icons.info_outline_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildAccountSection(theme, l10n, user),
                  ],
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Color _statusColor(BookingStatus status, ThemeData theme) {
    switch (status) {
      case BookingStatus.accepted:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.red;
      case BookingStatus.completed:
        return theme.colorScheme.primary;
      case BookingStatus.pending:
        return Colors.amber.shade700;
    }
  }

  String _statusLabel(BookingStatus status, AppLocalizations l10n) {
    switch (status) {
      case BookingStatus.accepted:
        return l10n.booking_status_accepted;
      case BookingStatus.rejected:
        return l10n.booking_status_rejected;
      case BookingStatus.completed:
        return l10n.booking_status_completed;
      case BookingStatus.pending:
        return l10n.booking_status_pending;
    }
  }

Widget _buildBookingItem(
  BuildContext context,
  BookingModel b,
  ThemeData theme,
  AppLocalizations l10n,
  UserModel user,
) {
  final isTutor = user is TutorModel;
  final statusColor = _statusColor(b.status, theme);

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: theme.colorScheme.primary.withOpacity(0.08),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة
            if (b.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  b.imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(width: 12),

            // النصوص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.tripTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),

                  if (b.tripCity.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            b.tripCity,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 6),

                  // 🔥 زر التفاصيل الجديد (صغير)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingViewScreen(booking: b),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.view_details,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // الحالة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _statusLabel(b.status, l10n),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        // أزرار المرشد
        if (isTutor && b.status == BookingStatus.pending) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => ref
                      .read(marketplaceRepositoryProvider)
                      .acceptBooking(
                        b.bookingId,
                        user.phoneNumber ?? '',
                        user.fullName,
                      ),
                  child: Text(l10n.accept_booking),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => ref
                      .read(marketplaceRepositoryProvider)
                      .updateBookingStatus(
                        b.bookingId,
                        BookingStatus.rejected,
                      ),
                  child: Text(
                    l10n.reject_booking,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}
  // ── Tutor-specific helpers ────────────────────────────────────────────────

  /// Profile-level requirements (bio, languages for individuals, phone for contact).
  /// These are independent of admin verification — the user controls them.
  List<String> _missingProfileFields(TutorModel tutor, bool isAr) {
    final missing = <String>[];
    if (tutor.bio == null || tutor.bio!.trim().isEmpty) {
      missing.add(isAr ? 'نبذة شخصية' : 'Bio');
    }
    if (tutor.phoneNumber == null || tutor.phoneNumber!.trim().isEmpty) {
      missing.add(isAr ? 'رقم الهاتف (للتواصل مع السياح)' : 'Phone number (for tourist contact)');
    }
    // Languages live on the profile for individuals only.
    // Companies pick languages per-trip (different employees, different langs).
    if (tutor.tutorType == TutorType.individual) {
      if (tutor.languages == null || tutor.languages!.isEmpty) {
        missing.add(isAr ? 'اللغات' : 'Languages');
      }
    }
    return missing;
  }

  /// Credential/verification requirements — what admin needs to approve the tutor.
  List<String> _missingVerificationFields(TutorModel tutor, bool isAr) {
    final missing = <String>[];
    if (tutor.tutorType == TutorType.individual) {
      if (tutor.licenceNumber == null) {
        missing.add(isAr ? 'رقم الرخصة' : 'Licence number');
      }
      if (tutor.licenceExpiryDate == null) {
        missing.add(isAr ? 'تاريخ انتهاء الرخصة' : 'Licence expiry date');
      }
    } else if (tutor.tutorType == TutorType.company) {
      if (tutor.companyName == null) {
        missing.add(isAr ? 'اسم الشركة' : 'Company name');
      }
      if (tutor.commercialRegistration == null) {
        missing.add(isAr ? 'رقم السجل التجاري' : 'Commercial registration');
      }
      if (tutor.commercialRegExpiryDate == null) {
        missing.add(isAr ? 'تاريخ انتهاء السجل التجاري' : 'Commercial reg. expiry');
      }
      if (tutor.tourismLicenceNumber == null) {
        missing.add(isAr ? 'رقم الترخيص السياحي' : 'Tourism licence number');
      }
      if (tutor.tourismLicenceExpiryDate == null) {
        missing.add(isAr ? 'تاريخ انتهاء الترخيص السياحي' : 'Tourism licence expiry');
      }
    }
    return missing;
  }

  /// Combined list used by the "Cannot Add Trip" dialog.
  List<String> _missingFields(TutorModel tutor, bool isAr) => [
        ..._missingProfileFields(tutor, isAr),
        ..._missingVerificationFields(tutor, isAr),
      ];

  bool _canAddTrip(TutorModel tutor) =>
      tutor.verificationStatus == VerificationStatus.verified &&
      tutor.isCredentialValid &&
      _missingProfileFields(tutor, false).isEmpty;

  Widget _buildTutorCompletenessCard(
    TutorModel tutor,
    ThemeData theme,
    bool isAr,
    BuildContext context,
  ) {
    if (_canAddTrip(tutor)) return const SizedBox.shrink();

    final profileMissing = _missingProfileFields(tutor, isAr);
    final verificationMissing = _missingVerificationFields(tutor, isAr);
    final isExpired = tutor.verificationStatus == VerificationStatus.expired;
    final isPending = tutor.verificationStatus == VerificationStatus.pending;
    final isRejected = tutor.verificationStatus == VerificationStatus.rejected;
    final isVerified = tutor.verificationStatus == VerificationStatus.verified;

    String headline;
    String? subtext;
    Color color;
    IconData icon;
    List<String> itemsToList = const [];

    // Priority order matters here — show the most blocking state first.
    if (isExpired) {
      headline = isAr
          ? 'رخصتك منتهية — جدّد وأعد التوثيق'
          : 'Credential expired — renew and re-verify';
      color = theme.colorScheme.error;
      icon = Icons.lock_outline;
    } else if (isRejected) {
      headline = isAr
          ? 'تم رفض طلب التوثيق'
          : 'Verification request rejected';
      subtext = tutor.rejectionReason;
      color = theme.colorScheme.error;
      icon = Icons.error_outline;
    } else if (isPending) {
      headline = isAr
          ? 'طلب التوثيق قيد المراجعة'
          : 'Verification request under review';
      subtext = isAr
          ? 'سنُعلمك حالما يتم اعتماد طلبك'
          : "We'll notify you once your request is approved";
      color = Colors.orange;
      icon = Icons.hourglass_top_outlined;
    } else if (verificationMissing.isNotEmpty) {
      // Not yet submitted for verification
      headline = isAr
          ? 'أكمل بيانات التوثيق لإضافة رحلات'
          : 'Complete verification to add trips';
      color = theme.colorScheme.primary;
      icon = Icons.assignment_ind_outlined;
      itemsToList = verificationMissing;
    } else if (isVerified && profileMissing.isNotEmpty) {
      // Verified but profile still incomplete
      headline = isAr
          ? 'أكمل ملفك الشخصي لإضافة رحلات'
          : 'Complete your profile to add trips';
      color = theme.colorScheme.primary;
      icon = Icons.info_outline;
      itemsToList = profileMissing;
    } else {
      // Credentials submitted, awaiting admin action
      headline = isAr
          ? 'في انتظار التوثيق من الإدارة'
          : 'Awaiting admin verification';
      color = Colors.orange;
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
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (subtext != null && subtext.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtext,
                        style: TextStyle(
                          fontSize: 12,
                          color: color.withValues(alpha: 0.85),
                        ),
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
                padding: const EdgeInsetsDirectional.only(
                    bottom: 4, start: 28, end: 4),
                child: Row(
                  children: [
                    Icon(Icons.circle,
                        size: 6, color: color.withValues(alpha: 0.7)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(f,
                          style: TextStyle(
                              fontSize: 13,
                              color: color.withValues(alpha: 0.85))),
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

  Widget _buildAddTripTile(
    TutorModel tutor,
    ThemeData theme,
    AppLocalizations l10n,
    bool isAr,
    BuildContext context,
  ) {
    final canAdd = _canAddTrip(tutor);
    final blockedColor = theme.colorScheme.onSurface.withValues(alpha: 0.35);

    return SettingsTile(
      title: l10n.add_new_trip,
      subtitle: canAdd
          ? l10n.add_trip_subtitle
          : (isAr ? 'أكمل التوثيق أولاً' : 'Complete verification first'),
      leadingIcon: canAdd
          ? Icons.add_location_alt_outlined
          : Icons.lock_outline,
      titleColor: canAdd ? theme.colorScheme.primary : blockedColor,
      onTap: canAdd
          ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTripScreen()),
              )
          : () {
              final missing = _missingFields(tutor, isAr);
              final lines = <String>[];
              if (tutor.verificationStatus != VerificationStatus.verified) {
                lines.add(isAr
                    ? '• حسابك غير موثّق بعد'
                    : '• Account not verified yet');
              }
              if (tutor.isCredentialExpired) {
                lines.add(isAr ? '• رخصتك منتهية' : '• Credential expired');
              }
              for (final f in missing) {
                lines.add('• $f');
              }
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(isAr ? 'لا يمكن إضافة رحلة' : 'Cannot Add Trip'),
                  content: Text(lines.join('\n')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(isAr ? 'حسناً' : 'OK'),
                    ),
                  ],
                ),
              );
            },
    );
  }

  Widget _buildSettingsGroup(
      {required String title,
      required List<Widget> tiles,
      required ThemeData theme}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
           padding: const EdgeInsetsDirectional.only(start: 16, top: 16, bottom: 8),
            child: Text(title,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
          ),
          ...tiles,
        ],
      ),
    );
  }

  Widget _buildAccountSection(
      ThemeData theme, AppLocalizations l10n, UserModel user) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final showDelete = user is TutorModel || user is TouristModel;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
                start: 16, top: 16, bottom: 8),
            child: Text(
              isAr ? 'الحساب' : 'Account',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
            ),
          ),
          // Logout tile
          _buildDestructiveTile(
            theme: theme,
            icon: Icons.logout_rounded,
            title: l10n.profileLogout,
            color: theme.colorScheme.error,
            showDivider: showDelete,
            onTap: () async {
              await ref.read(authNotifierProvider.notifier).logout();
            },
          ),
          // Delete account tile — tutors and tourists only
          if (showDelete)
            _buildDestructiveTile(
              theme: theme,
              icon: Icons.delete_forever_outlined,
              title: isAr ? 'حذف الحساب' : 'Delete Account',
              color: Colors.red.shade800,
              showDivider: false,
              onTap: () => _handleDeleteAccount(context, user, isAr),
            ),
        ],
      ),
    );
  }

  Widget _buildDestructiveTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required Color color,
    required bool showDivider,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 54,
            endIndent: 16,
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
      ],
    );
  }

  Future<void> _handleDeleteAccount(
      BuildContext context, UserModel user, bool isAr) async {
    // Safety check: fetch active bookings before showing the dialog
    final bookings = await ref
        .read(marketplaceRepositoryProvider)
        .fetchUserBookingsOnce(user.uId, user.role);

    final hasActive = bookings.any((b) =>
        b.status == BookingStatus.pending ||
        b.status == BookingStatus.accepted);

    if (hasActive) {
      if (!context.mounted) return;
      final msg = user is TouristModel
          ? (isAr
              ? 'لا يمكن حذف حسابك لوجود حجوزات نشطة. يرجى إلغاء رحلاتك القادمة أولاً.'
              : 'Cannot delete your account while you have active bookings. Please cancel your upcoming trips first.')
          : (isAr
              ? 'لا يمكن حذف حسابك لوجود حجوزات نشطة من السياح. يرجى إنهاء التزاماتك أولاً.'
              : 'Cannot delete your account while tourists have active bookings with you. Please fulfill or cancel these first.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5)),
      );
      return;
    }

    if (!context.mounted) return;

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(isAr ? 'حذف الحساب' : 'Delete Account'),
        content: Text(
          isAr
              ? 'هل أنت متأكد أنك تريد حذف حسابك نهائياً؟\nسيتم حذف جميع بياناتك ولا يمكن التراجع عن هذا الإجراء.'
              : 'Are you sure you want to permanently delete your account?\nAll your data will be erased and this cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isAr ? 'حذف حسابي نهائياً' : 'Delete My Account',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(authNotifierProvider.notifier).deleteAccount();
  }

  //
// أضيفي هذه الدالة داخل كلاس _ProfileScreenState
void _showPhoneInputDialog(BuildContext context, AppLocalizations l10n, String? currentPhone) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => PhoneOtpDialog(currentPhone: currentPhone),
  );
}
//
  static const _allLanguages = [
    'Arabic', 'English', 'French', 'German', 'Spanish', 'Italian',
    'Chinese', 'Japanese', 'Korean', 'Russian', 'Turkish', 'Portuguese',
    'Hindi', 'Urdu', 'Malay', 'Indonesian',
  ];

  void _showEditProfileSheet(BuildContext context, AppLocalizations l10n, UserModel user) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final tutor = user is TutorModel ? user : null;
    final isTutor = tutor != null;
    final isIndividualTutor = isTutor && tutor.tutorType == TutorType.individual;
    final nameController = TextEditingController(text: user.fullName);
    final bioController = TextEditingController(text: tutor?.bio ?? '');
    final selectedLanguages = List<String>.from(tutor?.languages ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final theme = Theme.of(ctx);
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Unified with _buildSettingsGroup title → titleLarge
                  Text(
                    l10n.profileEditProfileTitle,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: isAr ? 'الاسم الكامل' : 'Full Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (isTutor) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: bioController,
                      maxLines: 4,
                      maxLength: 200,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        labelText: isAr ? 'نبذة شخصية' : 'Bio',
                        hintText: isAr
                            ? 'تحدث قليلاً عن نفسك وخبراتك...'
                            : 'Tell us a bit about yourself and your experience...',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    // Languages on profile → individuals only.
                    // Companies pick languages per-trip in AddTripScreen.
                    if (isIndividualTutor) ...[
                      const SizedBox(height: 16),
                      Text(
                        isAr ? 'اللغات التي تتحدث بها' : 'Languages spoken',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      _buildLanguagePicker(
                        theme: theme,
                        selected: selectedLanguages,
                        onToggle: (lang, isNowSelected) => setSheetState(() {
                          if (isNowSelected) {
                            selectedLanguages.add(lang);
                          } else {
                            selectedLanguages.remove(lang);
                          }
                        }),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 16,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isAr
                                    ? 'بصفتك شركة، حدد اللغات لكل رحلة على حدة عند إنشائها'
                                    : 'As a company, specify languages per-trip when creating it',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        final nav = Navigator.of(sheetCtx);
                        await ref.read(profileNotifierProvider.notifier).updateProfileData(
                          name: name,
                          bio: isTutor ? bioController.text.trim() : null,
                          languages: isIndividualTutor
                              ? List<String>.from(selectedLanguages)
                              : null,
                        );
                        nav.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isAr ? 'حفظ' : 'Save'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  /// Clean rectangular language picker — selected = filled primary + white text,
  /// unselected = transparent with primary outline.
  Widget _buildLanguagePicker({
    required ThemeData theme,
    required List<String> selected,
    required void Function(String lang, bool isNowSelected) onToggle,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allLanguages.map((lang) {
        final isSelected = selected.contains(lang);
        return InkWell(
          onTap: () => onToggle(lang, !isSelected),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Text(
                  lang,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        final theme = Theme.of(sheetCtx);
        final currentLocale = Localizations.localeOf(context).languageCode;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.profileLanguage,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildLanguageOption(
                  theme: theme,
                  label: l10n.profileLanguageArabic,
                  isSelected: currentLocale == 'ar',
                  onTap: () {
                    ref.read(settingsProvider.notifier).setLocale(const Locale('ar'));
                    Navigator.pop(sheetCtx);
                  },
                ),
                const SizedBox(height: 10),
                _buildLanguageOption(
                  theme: theme,
                  label: l10n.profileLanguageEnglish,
                  isSelected: currentLocale == 'en',
                  onTap: () {
                    ref.read(settingsProvider.notifier).setLocale(const Locale('en'));
                    Navigator.pop(sheetCtx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Clean rectangular language option — selected = filled primary + white text + check,
  /// unselected = transparent with primary outline.
  Widget _buildLanguageOption({
    required ThemeData theme,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withValues(alpha: 0.4),
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded,
                  size: 20, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

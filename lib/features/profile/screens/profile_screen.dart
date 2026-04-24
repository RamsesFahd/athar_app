import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';
import 'package:athar_app/features/guide_market/screens/add_trip_screen.dart';
import 'package:athar_app/features/guide_market/screens/booking_view_screen.dart';
import 'package:athar_app/features/profile/logic/profile_notifier.dart';
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
import 'package:athar_app/features/contributions/screens/contributions_achievements_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _activeTabIndex = 0;

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
                return _buildBookingItem(context, b, theme, l10n, isTutor);
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
                    _buildSettingsGroup(
                      title: l10n.profileSettingsTitle,
                      theme: theme,
                      tiles: [
                        SettingsTile(
                          title: l10n.profileEditProfileTitle,
                          leadingIcon: Icons.mode_edit,
                          onTap: () => _showNameInputDialog(context, l10n, user.fullName),
                        ),
                        if (user is TutorModel) ...[
                          if (user.verificationStatus != VerificationStatus.verified)
                            SettingsTile(
                              title: l10n.tutorLicenseNumberTitle,
                              subtitle: l10n.tutorCompleteVerificationSubtitle,
                              leadingIcon: Icons.assignment_ind_outlined,
                              titleColor: theme.colorScheme.primary,
                              onTap: () {},
                            ),
                          SettingsTile(
                            title: l10n.add_new_trip,
                            subtitle: l10n.add_trip_subtitle,
                            leadingIcon: Icons.add_location_alt_outlined,
                            titleColor: theme.colorScheme.primary,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AddTripScreen()),
                            ),
                          ),
                        ],
                        if (user is TouristModel) ...[
                          SettingsTile(
                            title: l10n.manageContributions,
                            leadingIcon: Icons.edit_note_rounded,
                            onTap: () {
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                              builder: (_) => const ContributionsAchievementsScreen(),
                               ),
                              );

                            },
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
                    _buildLogoutButton(theme, l10n),
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
  bool isTutor,
) {
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
                      .updateBookingStatus(
                        b.bookingId,
                        BookingStatus.accepted,
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

  Widget _buildLogoutButton(ThemeData theme, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: TextButton.icon(
        onPressed: () async {
          // استدعاء دالة تسجيل الخروج من النوتيفاير
          await ref.read(authNotifierProvider.notifier).logout();
        },
        style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16)),
        icon: const Icon(Icons.logout, color: Colors.red, size: 20),
        label: Text(
          l10n.profileLogout,
          style: const TextStyle(
              color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
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
  void _showNameInputDialog(BuildContext context, AppLocalizations l10n, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileEditProfileTitle),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ), // TextField
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("cancel")), // 
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final nav = Navigator.of(context);
                await ref.read(profileNotifierProvider.notifier).updateProfileName(controller.text);
                nav.pop();
              }
            },
            child: Text("save"),
          ), // TextButton
        ],
      ), // AlertDialog
    );
  }
  void _showLanguageBottomSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ), // RoundedRectangleBorder
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.profileLanguageArabic),
              onTap: () {
                ref.read(settingsProvider.notifier).setLocale(const Locale('ar')); // تغيير اللغة للعربية
                Navigator.pop(context);
              },
            ), // ListTile
            ListTile(
              title: Text(l10n.profileLanguageEnglish),
              onTap: () {
                ref.read(settingsProvider.notifier).setLocale(const Locale('en')); // تغيير اللغة للإنجليزية
                Navigator.pop(context);
              },
            ), // ListTile
          ],
        ), // Column
      ), // SafeArea
    );
  }
}

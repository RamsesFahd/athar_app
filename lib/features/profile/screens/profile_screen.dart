import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/profile/logic/profile_notifier.dart';
import 'package:athar_app/features/profile/widgets/tutor_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../widgets/booking_card.dart';
import '../widgets/saved_card.dart';
import '../widgets/settings_tile.dart';
import '../widgets/guest_profile_view.dart';
import '../widgets/tourist_profile.dart';

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
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            BookingCard(
              title: "Old Jeddah Tour with Layla",
              guide: "Layla Hashim",
              dateText: "Nov 10, 2025",
              timeText: "10:00 AM",
              duration: "3 hours",
              detailsLabel: l10n.profileDetails,
              imageUrl:
                  "https://images.pexels.com/photos/4662950/pexels-photo-4662950.jpeg",
              onDetails: () {},
            ),
            BookingCard(
              title: "AlUla Archaeological Sites",
              guide: "Omar Al-Qahtani",
              dateText: "Dec 5, 2025",
              timeText: "9:00 AM",
              duration: "5 hours",
              detailsLabel: l10n.profileDetails,
              imageUrl:
                  "https://images.pexels.com/photos/6650442/pexels-photo-6650442.jpeg",
              onDetails: () {},
            ),
          ],
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
                          onTap: () {},
                        ),
                        if (user is TutorModel &&
                            user.verificationStatus != 'verified')
                          SettingsTile(
                            title: l10n.tutorLicenseNumberTitle,
                            subtitle: l10n.tutorCompleteVerificationSubtitle,
                            leadingIcon: Icons.assignment_ind_outlined,
                            titleColor: theme
                                .colorScheme.primary, // تمييز الزر بلون التطبيق
                            onTap: () {
                              // فتح صفحة التوثيق
                            },
                          ),
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
                            await ref.read(authNotifierProvider.notifier).resetPassword(email: email); //
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("تم إرسال رابط تغيير كلمة المرور إلى بريدك الإلكتروني")),
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
                          onTap: () {},
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
                              activeColor: theme.colorScheme.primary),
                        ),
                        SettingsTile(
                          title: l10n.profileEventReminders,
                          leadingIcon: Icons.calendar_today_outlined,
                          showDivider: false,
                          trailing: Switch(
                              value: true,
                              onChanged: (v) {},
                              activeColor: theme.colorScheme.primary),
                        ),
                        SettingsTile(
                          title: l10n.profileMarketingEmails,
                          leadingIcon: Icons.mail_outline_rounded,
                          showDivider: false,
                          trailing: Switch(
                              value: false,
                              onChanged: (v) {},
                              activeColor: theme.colorScheme.primary),
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
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
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
  final controller = TextEditingController(text: currentPhone);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.profileEditPhone),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(hintText: "05xxxxxxxx"),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("cancel")), // تأكدي من وجود مفتاح cancel في l10n
        TextButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              ref.read(profileNotifierProvider.notifier).addPhoneNumber(controller.text); //
              Navigator.pop(context);
            }
          },
          child: Text("save"), // تأكدي من وجود مفتاح save في l10n
        ),
      ],
    ),
  );
}



}

import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../widgets/booking_card.dart';
import '../widgets/saved_card.dart';
import '../widgets/settings_tile.dart';
import '../widgets/guest_profile_view.dart';

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
        // if user is null or has guest role, show guest profile view
        if (user == null || user.role == UserRole.guest) {
          return const GuestProfileView();
        }
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildUserInformationHeader(theme, l10n),
                _buildNavigationTabs(theme, l10n),
                Expanded(
                  child: _buildDynamicContentArea(theme, l10n),
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

  Widget _buildUserInformationHeader(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildAvatarWithEditIcon(theme),
          const SizedBox(width: 16),
          _buildUserMetaDetails(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildAvatarWithEditIcon(ThemeData theme) {
    return CircleAvatar(
      radius: 42,
      backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
      backgroundImage: const NetworkImage(
        'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=150',
      ),
    );
  }

  Widget _buildUserMetaDetails(ThemeData theme, AppLocalizations l10n) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sample User',
            style: theme.textTheme.titleLarge,
          ),
          Text(
            'hanan@gmail.com',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _buildEditProfileButton(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton(ThemeData theme, AppLocalizations l10n) {
    return SizedBox(
      height: 34,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.edit_outlined, size: 14),
        label: Text(l10n.profileEditProfileTitle),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle:
              theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNavigationTabs(ThemeData theme, AppLocalizations l10n) {
    return Container(
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          _tabItem(l10n.profileTabSettings, 2, theme),
          _tabItem(l10n.profileTabBooking, 1, theme),
          _tabItem(l10n.profileTabSaved, 0, theme),
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
                      : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
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

  Widget _buildDynamicContentArea(ThemeData theme, AppLocalizations l10n) {
    switch (_activeTabIndex) {
      case 0:
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
      case 2:
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    _buildSettingsGroup(
                      title: "Account",
                      theme: theme,
                      tiles: [
                        SettingsTile(
                          title: l10n.profileEditProfileTitle,
                          leadingIcon: Icons.person_outline_rounded,
                          onTap: () {},
                          showDivider: false,
                        ),
                        SettingsTile(
                          title: "Change Password",
                          leadingIcon: Icons.lock_outline_rounded,
                          onTap: () {},
                          showDivider: false,
                        ),
                        SettingsTile(
                          title: "Add Phone Number",
                          leadingIcon: Icons.phone_android_outlined,
                          onTap: () {},
                          showDivider: false,
                        ),
                        SettingsTile(
                          title: l10n.profileLanguage,
                          subtitle: "English",
                          leadingIcon: Icons.language_rounded,
                          onTap: () {},
                          showDivider: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSettingsGroup(
                      title: "Notifications",
                      theme: theme,
                      tiles: [
                        SettingsTile(
                          title: "Booking Notifications",
                          leadingIcon: Icons.notifications_none_rounded,
                          showDivider: false,
                          trailing: Switch(
                              value: true,
                              onChanged: (v) {},
                              activeColor: theme.colorScheme.primary),
                        ),
                        SettingsTile(
                          title: "Event Reminders",
                          leadingIcon: Icons.calendar_today_outlined,
                          showDivider: false,
                          trailing: Switch(
                              value: true,
                              onChanged: (v) {},
                              activeColor: theme.colorScheme.primary),
                        ),
                        SettingsTile(
                          title: "Marketing Emails",
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
                      title: "Support & Legal",
                      theme: theme,
                      tiles: [
                        SettingsTile(
                          title: "Contact Us",
                          leadingIcon: Icons.support_agent_rounded,
                          onTap: () {},
                        ),
                        SettingsTile(
                          title: "Privacy Policy",
                          leadingIcon: Icons.privacy_tip_outlined,
                          onTap: () {},
                        ),
                        SettingsTile(
                          title: "About Athar",
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: TextButton.icon(
        onPressed: () {},
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
}

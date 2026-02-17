/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:athar_app/core/navigation/app_routes.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

import '../widgets/saved_item_card.dart';
import '../widgets/booking_card.dart';
import '../widgets/settings_tile.dart';

import 'settings/edit_profile_screen.dart';
import 'saved_screen.dart';
import 'booking_screen.dart';

import 'settings/change_email_screen.dart';
import 'settings/add_phone_screen.dart';
import 'settings/app_language_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _tabIndex = 0;

  // Notification switches (UI فقط)
  bool _bookingNoti = true;
  bool _eventNoti = true;
  bool _marketingNoti = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header (صورة + اسم + ايميل كـ placeholder)
          _profileHeader(l10n, theme),

          const SizedBox(height: 18),

          // Tabs (Saved / Bookings / Settings)
          _tabs(l10n, theme),

          const SizedBox(height: 18),

          // Saved tab content 
          if (_tabIndex == 0) ..._savedTab(l10n),

          // Booking tab content 
          if (_tabIndex == 1) ..._bookingTab(l10n),

          // Settings tab content
          if (_tabIndex == 2) ..._settingsTab(context, l10n, theme),
        ],
      ),
    );
  }

  Widget _profileHeader(AppLocalizations l10n, ThemeData theme) {
    return Row(
      children: [
        // Profile photo placeholder
        Stack(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
              child: Icon(Icons.person,
                  color: theme.colorScheme.primary.withOpacity(0.7), size: 34),
            ),

            // Camera icon 
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withOpacity(0.25)),
                ),
                child: const Icon(Icons.camera_alt_outlined, size: 14),
              ),
            ),
          ],
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name placeholder 
              _bar(w: 150, h: 16),

              const SizedBox(height: 8),

              // Email placeholder 
              _bar(w: 170, h: 14),

              const SizedBox(height: 10),

              // Edit profile button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(l10n.profileEditButton),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabs(AppLocalizations l10n, ThemeData theme) {
    Widget tabItem(String label, int index) {
      final active = _tabIndex == index;

      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _tabIndex = index),
          child: Column(
            children: [
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 2,
                width: double.infinity,
                color: active ? theme.colorScheme.primary : Colors.transparent,
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        tabItem(l10n.profileTabSaved, 0),
        tabItem(l10n.profileTabBookings, 1),
        tabItem(l10n.profileTabSettings, 2),
      ],
    );
  }

  List<Widget> _savedTab(AppLocalizations l10n) {
    return [
      // Saved title + open saved page
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.profileSavedTitle, style: Theme.of(context).textTheme.titleLarge),

          // Go to Saved page 
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SavedScreen()));
            },
            child: Text(l10n.openButton),
          ),
        ],
      ),

      const SizedBox(height: 12),

      // Saved cards 
      const SavedItemCard(),
      const SavedItemCard(),
      const SavedItemCard(),
    ];
  }

  List<Widget> _bookingTab(AppLocalizations l10n) {
    return [
      // Booking title + open booking page
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.upcomingBookingTitle,
              style: Theme.of(context).textTheme.titleLarge),

          // Go to Booking page 
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const BookingScreen()));
            },
            child: Text(l10n.openButton),
          ),
        ],
      ),

      const SizedBox(height: 12),

      // Booking cards 
      BookingCard(detailsText: l10n.profileDetailsButton),
      BookingCard(detailsText: l10n.profileDetailsButton),
    ];
  }

  List<Widget> _settingsTab(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return [
      // Settings title
      Text(l10n.profileSettingsTitle, style: theme.textTheme.titleLarge),
      const SizedBox(height: 12),

      // Account section
      _card(
        theme,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(l10n.profileSettingsAccount, style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),

            // Contribute content 
            SettingsTile(
              icon: Icons.add_circle_outline,
              title: l10n.profileSettingsContribute,
              onTap: null,
            ),
            Divider(color: Colors.grey.withOpacity(0.15)),

            // Change email
            SettingsTile(
              icon: Icons.mail_outline,
              title: l10n.profileSettingsChangeEmail,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ChangeEmailScreen()));
              },
            ),
            Divider(color: Colors.grey.withOpacity(0.15)),

            // Add phone
            SettingsTile(
              icon: Icons.phone_outlined,
              title: l10n.profileSettingsAddPhone,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddPhoneScreen()));
              },
            ),
            Divider(color: Colors.grey.withOpacity(0.15)),

            // App language
            SettingsTile(
              icon: Icons.language_outlined,
              title: l10n.profileSettingsLanguage,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AppLanguageScreen()));
              },
            ),
          ],
        ),
      ),

      const SizedBox(height: 14),

      // Notifications section
      _card(
        theme,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(l10n.profileSettingsNotifications,
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),

            // Booking notifications
            _switchRow(l10n.profileNotiBooking, _bookingNoti, (v) {
              setState(() => _bookingNoti = v);
            }, theme),

            const SizedBox(height: 10),

            // Events notifications
            _switchRow(l10n.profileNotiEvents, _eventNoti, (v) {
              setState(() => _eventNoti = v);
            }, theme),

            const SizedBox(height: 10),

            // Marketing notifications
            _switchRow(l10n.profileNotiMarketing, _marketingNoti, (v) {
              setState(() => _marketingNoti = v);
            }, theme),
          ],
        ),
      ),

      const SizedBox(height: 14),

      // Log out button -> Splash
      InkWell(
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.splash,
            (route) => false,
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.error.withOpacity(0.18)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: theme.colorScheme.error),
              const SizedBox(width: 10),
              Text(
                l10n.profileLogout,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _card(ThemeData theme, Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: child,
    );
  }

  Widget _switchRow(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _bar({required double w, required double h}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'booking_screen.dart';
import 'saved_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (photo + placeholders for name/email)
          Row(
            children: [
              // Profile photo placeholder
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                child: Icon(Icons.person,
                    color: theme.colorScheme.primary.withOpacity(0.7), size: 34),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name placeholder
                    _bar(150, 16),
                    const SizedBox(height: 8),

                    // Email placeholder
                    _bar(190, 14),
                    const SizedBox(height: 10),

                    // Edit profile button (page)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(l10n.profileEditButton),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Saved
          _navBox(
            context,
            icon: Icons.bookmark_outline,
            title: l10n.savedTitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedScreen()),
            ),
          ),

          const SizedBox(height: 14),

          // Booking
          _navBox(
            context,
            icon: Icons.calendar_month_outlined,
            title: l10n.bookingTitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingScreen()),
            ),
          ),

          const SizedBox(height: 14),

          // Settings
          _navBox(
            context,
            icon: Icons.settings_outlined,
            title: l10n.settingsTitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  // Simple nav box
  Widget _navBox(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          // Box background
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            // Leading icon
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),

            // Title
            Expanded(
              child: Text(title, style: theme.textTheme.bodyLarge),
            ),

            // Arrow
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  // Placeholder bar
  Widget _bar(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        // Grey placeholder
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
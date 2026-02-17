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
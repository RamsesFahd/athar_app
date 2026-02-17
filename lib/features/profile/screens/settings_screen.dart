import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:athar_app/core/navigation/app_routes.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Controllers
  final _newEmail = TextEditingController();
  final _confirmEmail = TextEditingController();
  final _newPhone = TextEditingController();
  final _confirmPhone = TextEditingController();

  // Switches
  bool _bookingNoti = true;
  bool _eventNoti = true;
  bool _marketingNoti = false;

  @override
  void dispose() {
    _newEmail.dispose();
    _confirmEmail.dispose();
    _newPhone.dispose();
    _confirmPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    // Input decoration
    final inputDec = InputDecoration(
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Scaffold(
      appBar: AppBar(
        // Page title
        title: Text(l10n.settingsTitle, style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contribute content 
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                // Card background
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  // Icon
                  Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),

                  // Text
                  Expanded(child: Text(l10n.contributeContent, style: theme.textTheme.bodyLarge)),

                  // Arrow
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Change Email section 
            Text(l10n.changeEmailTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),

            // New email label
            Text(l10n.newEmailLabel, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            TextField(controller: _newEmail, decoration: inputDec),

            const SizedBox(height: 12),

            // Confirm email label
            Text(l10n.confirmEmailLabel, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            TextField(controller: _confirmEmail, decoration: inputDec),

            const SizedBox(height: 14),

            // Save email button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(l10n.continueButton),
              ),
            ),

            const SizedBox(height: 20),

            // Add Phone section 
            Text(l10n.addPhoneTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),

            // New phone label
            Text(l10n.newPhoneLabel, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _newPhone,
              keyboardType: TextInputType.phone,
              decoration: inputDec,
            ),

            const SizedBox(height: 12),

            // Confirm phone label
            Text(l10n.confirmPhoneLabel, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPhone,
              keyboardType: TextInputType.phone,
              decoration: inputDec,
            ),

            const SizedBox(height: 14),

            // Save phone button (UI only)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(l10n.continueButton),
              ),
            ),

            const SizedBox(height: 20),

            // Language (tap = toggle) 
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                // Card background
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: InkWell(
                onTap: () => ref.read(settingsProvider.notifier).toggleLocale(),
                child: Row(
                  children: [
                    // Icon
                    Icon(Icons.language_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),

                    // Title
                    Expanded(child: Text(l10n.languageTitle, style: theme.textTheme.bodyLarge)),

                    // Selected language
                    Text(
                      settings.locale.languageCode == 'ar'
                          ? l10n.languageArabic
                          : l10n.languageEnglish,
                      style: theme.textTheme.bodyMedium,
                    ),

                    const SizedBox(width: 8),

                    // Arrow
                    const Icon(Icons.swap_horiz),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            //  Notifications 
            Text(l10n.notificationsTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),

            // Booking notifications
            _switchRow(theme, l10n.bookingNotifications, _bookingNoti, (v) {
              setState(() => _bookingNoti = v);
            }),

            // Event reminders
            _switchRow(theme, l10n.eventReminders, _eventNoti, (v) {
              setState(() => _eventNoti = v);
            }),

            // Marketing emails
            _switchRow(theme, l10n.marketingEmails, _marketingNoti, (v) {
              setState(() => _marketingNoti = v);
            }),

            const SizedBox(height: 22),

            // Logout
            InkWell(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.splash,
                  (route) => false,
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  // Logout box style
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
                      l10n.logoutTitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simple switch row
  Widget _switchRow(
    ThemeData theme,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
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
}
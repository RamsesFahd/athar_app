import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../generated/l10n/app_localizations.dart';

import 'package:athar_app/features/profile/widgets/booking_card.dart';
import 'package:athar_app/features/profile/widgets/saved_card.dart';
import 'package:athar_app/features/profile/widgets/settings_tile.dart';

enum _ProfileTab { booking, saved, settings }

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Current selected tab
  _ProfileTab _tab = _ProfileTab.saved;

  // Sample UI-only state
  String _name = 'user';

  // Notifications state
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Localization instance
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page title (use localization)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text(
                    l10n.profileLabel,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),

            // Profile top section 
            _ProfileTopSection(
              name: _name,
              email: 'user@email.com', // (المفترض يكون نفس الايميل يلي انحط في الساين ان او اب)
              editLabel: l10n.profileEditProfileTitle,
              onEdit: () => _showEditProfileDialog(context, l10n),
            ),

            // Tabs underline (Saved / Bookings / Settings)
            _Tabs(
              selected: _tab,
              savedLabel: l10n.profileTabSaved,
              bookingLabel: l10n.profileTabBooking,
              settingsLabel: l10n.profileTabSettings,
              onChanged: (t) => setState(() => _tab = t),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Saved content
                  if (_tab == _ProfileTab.saved) ...[
                    Text(
                      l10n.profileSavedItemsTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    ..._savedSamples.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SavedCard(
                          title: s.title,
                          location: s.location,
                          typeText: s.typeText,
                          isSaved: s.isSaved,
                          dateText: s.dateText, 
                          onTap: null,
                        ),
                      ),
                    ),
                  ],

                  //  Booking content 
                  if (_tab == _ProfileTab.booking) ...[
                    Text(
                      l10n.profileUpcomingBooking,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    ..._bookingSamples.map(
                      (b) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BookingCard(
                          title: b.title,
                          guide: b.guide,
                          dateText: b.dateText,
                          timeText: b.timeText,
                          durationText: b.durationText,
                          withLabel: l10n.profileWithLabel,
                          detailsLabel: l10n.profileDetails,
                          onDetails: null, 
                        ),
                      ),
                    ),
                  ],

                  // Settings content 
                  if (_tab == _ProfileTab.settings) ...[
                    Text(
                      l10n.profileSettingsTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    // Account card
                    _SettingsCard(
                      title: l10n.profileAccountTitle,
                      children: [
                        // Contribute Content 
                        SettingsTile(
                          title: l10n.profileContributeContent,
                          leadingIcon: Icons.add_circle_outline,
                          enabled: false,
                          onTap: null,
                        ),
                        const SizedBox(height: 10),

                        // Edit Email dialog
                        SettingsTile(
                          title: l10n.profileEditEmail,
                          leadingIcon: Icons.email_outlined,
                          onTap: () => _showEditEmailDialog(context, l10n),
                        ),
                        const SizedBox(height: 10),

                        // Edit Phone dialog
                        SettingsTile(
                          title: l10n.profileEditPhone,
                          leadingIcon: Icons.phone_outlined,
                          onTap: () => _showEditPhoneDialog(context, l10n),
                        ),
                        const SizedBox(height: 10),

                        // Language dialog
                        SettingsTile(
                          title: l10n.profileLanguage,
                          leadingIcon: Icons.language_outlined,
                          trailing: Text(
                            ref.watch(settingsProvider).locale.languageCode == 'ar'
                                ? l10n.profileLanguageArabic
                                : l10n.profileLanguageEnglish,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          onTap: () => _showLanguageDialog(context, l10n),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Notifications card 
                    _SettingsCard(
                      title: l10n.profileNotifications,
                      children: [
                        _SwitchRow(
                          title: l10n.profileBookingNotifications,
                          value: _notificationsEnabled,
                          onChanged: (v) => setState(() => _notificationsEnabled = v),
                        ),
                        const SizedBox(height: 10),
                        _SwitchRow(
                          title: l10n.profileEventReminders,
                          value: true,
                          onChanged: (_) {}, 
                        ),
                        const SizedBox(height: 10),
                        _SwitchRow(
                          title: l10n.profileMarketingEmails,
                          value: false,
                          onChanged: (_) {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Logout button -> Splash
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.splash,
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout),
                        label: Text(l10n.profileLogout),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(color: theme.colorScheme.error.withOpacity(0.4)),
                          backgroundColor: theme.colorScheme.error.withOpacity(0.06),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  // Dialogs (كلها فيها زر X داخل _SimpleDialog)

  void _showEditProfileDialog(BuildContext context, AppLocalizations l10n) {
    final nameCtrl = TextEditingController(text: _name);

    showDialog(
      context: context,
      builder: (_) {
        return _SimpleDialog(
          title: l10n.profileEditProfileTitle,
          closeLabel: l10n.profileClose,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar + Change photo button
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.person_outline),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        
                      },
                      child: Text(l10n.profileChangePhoto),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Name label
              Text(
                l10n.profileNameLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                    ),
              ),
              const SizedBox(height: 8),

              // Name input
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: l10n.profileNameHint,
                ),
              ),
              const SizedBox(height: 16),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _name = nameCtrl.text.trim());
                    Navigator.pop(context);
                  },
                  child: Text(l10n.profileSave),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditEmailDialog(BuildContext context, AppLocalizations l10n) {
    final emailCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return _SimpleDialog(
          title: l10n.profileEditEmailTitle,
          closeLabel: l10n.profileClose,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // New Email label
              Text(
                l10n.profileNewEmailLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                    ),
              ),
              const SizedBox(height: 8),

              // New Email input
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: l10n.profileEmailHint,
                ),
              ),
              const SizedBox(height: 12),

              // Confirm Email label
              Text(
                l10n.profileConfirmEmailLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                    ),
              ),
              const SizedBox(height: 8),

              // Confirm Email input
              TextField(
                controller: confirmCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: l10n.profileConfirmEmailHint,
                ),
              ),
              const SizedBox(height: 16),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    
                    Navigator.pop(context);
                  },
                  child: Text(l10n.profileSubmit),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditPhoneDialog(BuildContext context, AppLocalizations l10n) {
    final phoneCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return _SimpleDialog(
          title: l10n.profileEditPhoneTitle,
          closeLabel: l10n.profileClose,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // New Phone label
              Text(
                l10n.profileNewPhoneLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                    ),
              ),
              const SizedBox(height: 8),

              // New Phone input
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: l10n.profilePhoneHint,
                ),
              ),
              const SizedBox(height: 12),

              // Confirm Phone label
              Text(
                l10n.profileConfirmPhoneLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                    ),
              ),
              const SizedBox(height: 8),

              // Confirm Phone input
              TextField(
                controller: confirmCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: l10n.profileConfirmPhoneHint,
                ),
              ),
              const SizedBox(height: 16),

              // Submit button (UI only)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    
                    Navigator.pop(context);
                  },
                  child: Text(l10n.profileSubmit),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    // Current locale from settings
    final current = ref.watch(settingsProvider).locale;

    // Selected locale in dialog
    Locale selected = current;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return _SimpleDialog(
              title: l10n.profileLanguageTitle,
              closeLabel: l10n.profileClose,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // English option
                  RadioListTile<Locale>(
                    value: const Locale('en'),
                    groupValue: selected,
                    onChanged: (v) => setLocal(() => selected = v!),
                    title: Text(l10n.profileLanguageEnglish),
                  ),

                  // Arabic option
                  RadioListTile<Locale>(
                    value: const Locale('ar'),
                    groupValue: selected,
                    onChanged: (v) => setLocal(() => selected = v!),
                    title: Text(l10n.profileLanguageArabic),
                  ),

                  const SizedBox(height: 8),

                  // Save language button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(settingsProvider.notifier).setLocale(selected);
                        Navigator.pop(context);
                      },
                      child: Text(l10n.profileSave),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


// Widgets (inside same file)


class _ProfileTopSection extends StatelessWidget {
  const _ProfileTopSection({
    required this.name,
    required this.email,
    required this.editLabel,
    required this.onEdit,
  });

  final String name;
  final String email;
  final String editLabel;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          const CircleAvatar(
            radius: 34,
            child: Icon(Icons.person_outline),
          ),
          const SizedBox(width: 12),

          // Name + email + edit button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.65),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 34,
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Text(editLabel),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.selected,
    required this.savedLabel,
    required this.bookingLabel,
    required this.settingsLabel,
    required this.onChanged,
  });

  final _ProfileTab selected;
  final String savedLabel;
  final String bookingLabel;
  final String settingsLabel;
  final ValueChanged<_ProfileTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget tab(String text, _ProfileTab tab) {
      final isSelected = selected == tab;

      return Expanded(
        child: InkWell(
          onTap: () => onChanged(tab),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.65),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          tab(savedLabel, _ProfileTab.saved),
          tab(bookingLabel, _ProfileTab.booking),
          tab(settingsLabel, _ProfileTab.settings),
        ],
      ),
    );
  }
}

// Dialog with X close button
class _SimpleDialog extends StatelessWidget {
  const _SimpleDialog({
    required this.title,
    required this.closeLabel,
    required this.child,
  });

  final String title;
  final String closeLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: closeLabel,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}


// Sample Data (بس عشان اشوف الشكل بعدين عادي احذفي)


class _BookingSample {
  const _BookingSample({
    required this.title,
    required this.guide,
    required this.dateText,
    required this.timeText,
    required this.durationText,
  });

  final String title;
  final String guide;
  final String dateText;
  final String timeText;
  final String durationText;
}

class _SavedSample {
  const _SavedSample({
    required this.title,
    required this.location,
    required this.typeText,
    required this.isSaved,
    this.dateText,
  });

  final String title;
  final String location;
  final String typeText;
  final bool isSaved;
  final String? dateText;
}

// Sample booking cards
const _bookingSamples = <_BookingSample>[
  _BookingSample(
    title: 'Old Jeddah Tour',
    guide: 'Layla Hashim',
    dateText: 'Nov 10, 2025',
    timeText: '10:00 AM',
    durationText: '3 hours',
  ),
  _BookingSample(
    title: 'AlUla Archaeological Sites',
    guide: 'Omar Al-Qahtani',
    dateText: 'Dec 5, 2025',
    timeText: '9:00 AM',
    durationText: '5 hours',
  ),
];

// Sample saved cards
const _savedSamples = <_SavedSample>[
  _SavedSample(
    title: 'Edge of the World',
    location: 'Riyadh',
    typeText: 'Landmark',
    isSaved: true,
  ),
  _SavedSample(
    title: 'Janadriyah Festival',
    location: 'Riyadh',
    typeText: 'Event',
    isSaved: true,
    dateText: 'Mar 15-25, 2025',
  ),
  _SavedSample(
    title: 'Ahmed Al-Saud',
    location: 'Riyadh',
    typeText: 'Guide',
    isSaved: true,
  ),
];

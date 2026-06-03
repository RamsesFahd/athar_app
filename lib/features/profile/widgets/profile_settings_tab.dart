import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/core/services/notification_service.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/bookings/logic/booking_repository.dart';
import 'package:athar_app/features/onboarding/screens/user_preferences_screen.dart';
import 'package:athar_app/features/profile/logic/profile_notifier.dart';
import 'package:athar_app/features/profile/logic/profile_repository.dart';
import 'package:athar_app/features/profile/screens/about_athar_screen.dart';
import 'package:athar_app/features/profile/screens/contact_us_screen.dart';
import 'package:athar_app/features/profile/screens/credential_verification_screen.dart';
import 'package:athar_app/features/profile/screens/phone_otp_dialog.dart';
import 'package:athar_app/features/profile/screens/privacy_policy_screen.dart';
import 'package:athar_app/features/profile/widgets/settings_tile.dart';
import 'package:athar_app/features/profile/widgets/tutor_completeness_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// The "Settings" tab of the profile screen.
///
/// Owns notification-preference state and all modal sheets so that
/// profile_screen.dart only coordinates tab navigation.
class ProfileSettingsTab extends ConsumerStatefulWidget {
  final UserModel user;

  const ProfileSettingsTab({super.key, required this.user});

  @override
  ConsumerState<ProfileSettingsTab> createState() => _ProfileSettingsTabState();
}

class _ProfileSettingsTabState extends ConsumerState<ProfileSettingsTab> {
  static const _kBookingNotif  = 'notif_booking';
  static const _kEventReminders = 'notif_events';
  static const _kMarketingEmails = 'notif_marketing';

  bool _bookingNotifications = true;
  bool _eventReminders = true;
  bool _marketingEmails = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPrefs();
  }

  Future<void> _loadNotificationPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _bookingNotifications = prefs.getBool(_kBookingNotif) ?? true;
      _eventReminders       = prefs.getBool(_kEventReminders) ?? true;
      _marketingEmails      = prefs.getBool(_kMarketingEmails) ?? false;
    });
  }

  Future<void> _saveAccessibilitySetting(String key, dynamic value) async {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;
    await ref.read(profileRepositoryProvider).updateUserData(
      user.uId,
      {'accessibilitySettings.$key': value},
    );
  }

  /// Toggles a notification preference:
  /// - Requests OS permission when enabling push topics.
  /// - Persists to SharedPreferences (local) and Firestore (for Cloud Function gating).
  /// - Reverts if the OS permission is denied.
  Future<void> _onNotificationToggle({
    required bool value,
    required String prefKey,
    required void Function(bool) setter,
    String? firestoreKey,
  }) async {
    setState(() => setter(value));
    if (value) {
      final granted = await NotificationService.instance.requestPermissions();
      if (!granted) {
        if (mounted) setState(() => setter(!value));
        return;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, value);
    if (firestoreKey != null) {
      final user = ref.read(authNotifierProvider).valueOrNull;
      if (user != null) {
        await ref.read(profileRepositoryProvider).updateUserData(
          user.uId,
          {'notificationPrefs.$firestoreKey': value},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final user = widget.user;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                if (user is TutorModel)
                  TutorCompletenessCard(tutor: user),
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
                              ? l10n.profileCredentialExpiredReverify
                              : l10n.tutorLicenseNumberTitle,
                          subtitle: user.verificationStatus == VerificationStatus.rejected
                              ? (user.rejectionReason != null
                                  ? l10n.profileRejectionReason(user.rejectionReason!)
                                  : l10n.profileVerificationRejectedResubmit)
                              : l10n.tutorCompleteVerificationSubtitle,
                          leadingIcon: Icons.assignment_ind_outlined,
                          titleColor: user.verificationStatus == VerificationStatus.expired
                              ? Colors.red
                              : theme.colorScheme.primary,
                          onTap: () {
                            if (!user.phoneVerified) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.credVerifPhoneRequiredFirst),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CredentialVerificationScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                    if (user is TouristModel) ...[
                      SettingsTile(
                        title: l10n.myInterests,
                        leadingIcon: Icons.favorite_border_rounded,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserPreferencesScreen(
                              isEditMode: true,
                              initialInterests: user.culturalInterests,
                            ),
                          ),
                        ),
                      ),
                    ],
                    SettingsTile(
                      title: l10n.settingsChangePassword,
                      leadingIcon: Icons.lock_outline_rounded,
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final errorColor = Theme.of(context).colorScheme.error;
                        final error = await ref
                            .read(authNotifierProvider.notifier)
                            .resetPassword(email: user.email);
                        if (error == null) {
                          messenger.showSnackBar(
                              SnackBar(content: Text(l10n.profilePasswordResetLinkSent)));
                        } else {
                          messenger.showSnackBar(SnackBar(
                            content: Text(l10n.profilePasswordResetLinkFailed),
                            backgroundColor: errorColor,
                          ));
                        }
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
                      subtitle: isAr ? l10n.profileLanguageArabic : l10n.profileLanguageEnglish,
                      leadingIcon: Icons.language_rounded,
                      onTap: () => _showLanguageBottomSheet(context, l10n),
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildAccessibilityGroup(theme, l10n),
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
                        value: _bookingNotifications,
                        onChanged: (v) => _onNotificationToggle(
                          value: v,
                          prefKey: _kBookingNotif,
                          setter: (val) => _bookingNotifications = val,
                          firestoreKey: 'bookingNotifications',
                        ),
                        activeThumbColor: theme.colorScheme.primary,
                      ),
                    ),
                    SettingsTile(
                      title: l10n.profileEventReminders,
                      leadingIcon: Icons.calendar_today_outlined,
                      showDivider: false,
                      trailing: Switch(
                        value: _eventReminders,
                        onChanged: (v) => _onNotificationToggle(
                          value: v,
                          prefKey: _kEventReminders,
                          setter: (val) => _eventReminders = val,
                          firestoreKey: 'eventReminders',
                        ),
                        activeThumbColor: theme.colorScheme.primary,
                      ),
                    ),
                    SettingsTile(
                      title: l10n.profileMarketingEmails,
                      leadingIcon: Icons.mail_outline_rounded,
                      showDivider: false,
                      trailing: Switch(
                        value: _marketingEmails,
                        onChanged: (v) => _onNotificationToggle(
                          value: v,
                          prefKey: _kMarketingEmails,
                          setter: (val) => _marketingEmails = val,
                          firestoreKey: 'marketingEmails',
                        ),
                        activeThumbColor: theme.colorScheme.primary,
                      ),
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
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ContactUsScreen())),
                    ),
                    SettingsTile(
                      title: l10n.settingsPrivacyPolicy,
                      leadingIcon: Icons.privacy_tip_outlined,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                    ),
                    SettingsTile(
                      title: l10n.settingsAboutAthar,
                      leadingIcon: Icons.info_outline_rounded,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AboutAtharScreen())),
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
  }

  Widget _buildAccessibilityGroup(ThemeData theme, AppLocalizations l10n) {
    final settings = ref.watch(settingsProvider);
    return _buildSettingsGroup(
      title: l10n.accessibilityOptionsTitle,
      theme: theme,
      tiles: [
        SettingsTile(
          title: l10n.accessibilityHighContrast,
          leadingIcon: Icons.contrast_rounded,
          showDivider: true,
          trailing: Switch(
            value: settings.highContrast,
            onChanged: (v) {
              ref.read(settingsProvider.notifier).toggleContrast();
              _saveAccessibilitySetting('highContrast', v);
            },
            activeThumbColor: theme.colorScheme.primary,
          ),
        ),
        SettingsTile(
          title: l10n.accessibilityTextReader,
          subtitle: l10n.accessibilityTextReaderHint,
          leadingIcon: Icons.record_voice_over_outlined,
          showDivider: false,
          trailing: Switch(
            value: settings.isTtsEnabled,
            onChanged: (v) {
              ref.read(settingsProvider.notifier).toggleTts();
              _saveAccessibilitySetting('textReaderEnabled', v);
            },
            activeThumbColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> tiles,
    required ThemeData theme,
  }) {
    final isHighContrast = ref.watch(settingsProvider).highContrast;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isHighContrast
            ? []
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        border: Border.all(
          color: isHighContrast
              ? theme.colorScheme.onSurface
              : theme.dividerColor.withValues(alpha: 0.1),
          width: isHighContrast ? 2 : 1,
        ),
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

  Widget _buildAccountSection(ThemeData theme, AppLocalizations l10n, UserModel user) {
    final isHighContrast = ref.watch(settingsProvider).highContrast;
    final showDelete = user is TutorModel || user is TouristModel;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isHighContrast
            ? []
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        border: Border.all(
          color: isHighContrast
              ? theme.colorScheme.onSurface
              : theme.dividerColor.withValues(alpha: 0.1),
          width: isHighContrast ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, top: 16, bottom: 8),
            child: Text(l10n.profileAccountTitle,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
          ),
          _buildDestructiveTile(
            theme: theme,
            icon: Icons.logout_rounded,
            title: l10n.profileLogout,
            color: theme.colorScheme.error,
            showDivider: showDelete,
            onTap: () async => ref.read(authNotifierProvider.notifier).logout(),
          ),
          if (showDelete)
            _buildDestructiveTile(
              theme: theme,
              icon: Icons.delete_forever_outlined,
              title: l10n.profileDeleteAccount,
              color: Colors.red.shade800,
              showDivider: false,
              onTap: () => _handleDeleteAccount(context, user, l10n),
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
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500, color: color)),
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
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
      ],
    );
  }

  Future<void> _handleDeleteAccount(
      BuildContext context, UserModel user, AppLocalizations l10n) async {
    final bookings = await ref
        .read(bookingRepositoryProvider)
        .fetchUserBookingsOnce(user.uId, user.role);
    final hasActive = bookings.any(
        (b) => b.status == BookingStatus.pending || b.status == BookingStatus.approved);
    if (hasActive) {
      if (!context.mounted) return;
      final msg = user is TouristModel
          ? l10n.profileDeleteAccountActiveBookingsTourist
          : l10n.profileDeleteAccountActiveBookingsTutor;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 5),
      ));
      return;
    }
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l10n.profileDeleteAccount),
        content: Text(l10n.profileDeleteAccountConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.profileDeleteAccountConfirmButton,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(authNotifierProvider.notifier).deleteAccount();
  }

  void _showPhoneInputDialog(BuildContext context, AppLocalizations l10n, String? currentPhone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PhoneOtpDialog(currentPhone: currentPhone),
    );
  }

  static const _allLanguages = [
    'Arabic', 'English', 'French', 'German', 'Spanish', 'Italian',
    'Chinese', 'Japanese', 'Korean', 'Russian', 'Turkish', 'Portuguese',
    'Hindi', 'Urdu', 'Malay', 'Indonesian',
  ];

  void _showEditProfileSheet(BuildContext context, AppLocalizations l10n, UserModel user) {
    final tutor = user is TutorModel ? user : null;
    final isTutor = tutor != null;
    final isIndividualTutor = isTutor && tutor.tutorType == TutorType.individual;
    final nameController = TextEditingController(text: user.fullName);
    final bioController  = TextEditingController(text: tutor?.bio ?? '');
    final selectedLanguages = List<String>.from(tutor?.languages ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                        color: theme.colorScheme.onSurfaceVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      labelText: l10n.fullNameLabel,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                        labelText: l10n.profileBioLabel,
                        hintText: l10n.profileBioHint,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    // Languages are per-profile for individuals; companies set them per-trip.
                    if (isIndividualTutor) ...[
                      const SizedBox(height: 16),
                      Text(l10n.profileLanguagesSpoken,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      _buildLanguagePicker(
                        theme: theme,
                        l10n: l10n,
                        selected: selectedLanguages,
                        onToggle: (lang, isNowSelected) => setSheetState(() {
                          isNowSelected
                              ? selectedLanguages.add(lang)
                              : selectedLanguages.remove(lang);
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
                                size: 16, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.profileCompanyLanguagesHint,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: theme.colorScheme.primary),
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
                        final messenger = ScaffoldMessenger.of(context);
                        final errorColor = Theme.of(context).colorScheme.error;
                        final success = await ref
                            .read(profileNotifierProvider.notifier)
                            .updateProfileData(
                              name: name,
                              bio: isTutor ? bioController.text.trim() : null,
                              languages: isIndividualTutor
                                  ? List<String>.from(selectedLanguages)
                                  : null,
                            );
                        if (success) {
                          nav.pop();
                        } else {
                          messenger.showSnackBar(SnackBar(
                            content: Text(l10n.errorNoInternetConnection),
                            backgroundColor: errorColor,
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.profileSave),
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

  Widget _buildLanguagePicker({
    required ThemeData theme,
    required AppLocalizations l10n,
    required List<String> selected,
    required void Function(String lang, bool isNowSelected) onToggle,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allLanguages.map((lang) {
        final isSelected = selected.contains(lang);
        final label = _languageLabel(lang, l10n);
        return InkWell(
          onTap: () => onToggle(lang, !isSelected),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
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
                  Icon(Icons.check_rounded, size: 16, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
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

  /// Maps an English language key to its localised display label.
  String _languageLabel(String lang, AppLocalizations l10n) {
    final labels = <String, String Function(AppLocalizations)>{
      'Arabic':     (l) => l.arabic,
      'English':    (l) => l.english,
      'French':     (l) => l.french,
      'German':     (l) => l.german,
      'Spanish':    (l) => l.spanish,
      'Italian':    (l) => l.italian,
      'Chinese':    (l) => l.chinese,
      'Japanese':   (l) => l.japanese,
      'Korean':     (l) => l.korean,
      'Russian':    (l) => l.russian,
      'Turkish':    (l) => l.turkish,
      'Portuguese': (l) => l.portuguese,
      'Hindi':      (l) => l.hindi,
      'Urdu':       (l) => l.urdu,
      'Malay':      (l) => l.malay,
      'Indonesian': (l) => l.indonesian,
    };
    return labels[lang]?.call(l10n) ?? lang;
  }

  void _showLanguageBottomSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                      color: theme.colorScheme.onSurfaceVariant,
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
                    _saveAccessibilitySetting('languagePreference', 'ar');
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
                    _saveAccessibilitySetting('languagePreference', 'en');
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
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
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
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, size: 20, color: theme.colorScheme.onPrimary),
          ],
        ),
      ),
    );
  }
}

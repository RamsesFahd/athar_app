import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';


class AccessibilityControls extends ConsumerWidget {
  const AccessibilityControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // to shrink the dialog to fit content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // the header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.accessibilityOptionsTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(), // close the dialog
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Font Size Section
            _buildSectionHeader(Icons.text_fields, l10n.accessibilityFontSize, theme.colorScheme.primary),
            Row(
              children: [
                Expanded(child: _buildOptionButton(l10n.accessibilitySmall, settings.fontSize == AppFontSize.small, () => notifier.setFontSize(AppFontSize.small), theme.colorScheme.primary)),
                Expanded(child: _buildOptionButton(l10n.accessibilityMedium, settings.fontSize == AppFontSize.medium, () => notifier.setFontSize(AppFontSize.medium), theme.colorScheme.primary)),
                Expanded(child: _buildOptionButton(l10n.accessibilityLarge, settings.fontSize == AppFontSize.large, () => notifier.setFontSize(AppFontSize.large), theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 16),

            // Language Section
            _buildSectionHeader(Icons.language, l10n.accessibilityLanguage, theme.colorScheme.primary),
            Row(
              children: [
                Expanded(child: _buildOptionButton(l10n.accessibilityEnglish, settings.locale.languageCode == 'en', () => notifier.setLocale(const Locale('en')), theme.colorScheme.primary)),
                Expanded(child: _buildOptionButton(l10n.accessibilityArabic, settings.locale.languageCode == 'ar', () => notifier.setLocale(const Locale('ar')), theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 16),

            // Contrast Section
            _buildSectionHeader(Icons.brightness_6, l10n.accessibilityContrast, theme.colorScheme.primary),
            Row(
              children: [
                Expanded(child: _buildOptionButton(l10n.accessibilityRegular, !settings.highContrast, () { if(settings.highContrast) notifier.toggleContrast(); }, theme.colorScheme.primary)),
                Expanded(child: _buildOptionButton(l10n.accessibilityHighContrast, settings.highContrast, () { if(!settings.highContrast) notifier.toggleContrast(); }, theme.colorScheme.primary)),
              ],
            ),
            
            const Divider(height: 32),

            // Text-to-Speech Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(Icons.volume_up, l10n.accessibilityTextReader, theme.colorScheme.primary, padding: 0),
                Switch(
                  value: settings.isTtsEnabled,
                  onChanged: (_) => notifier.toggleTts(),
                  activeTrackColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // helper widgets for consistent styling
  // section header with icon and title
  Widget _buildSectionHeader(IconData icon, String title, Color color, {double padding = 8}) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        ],
      ),
    );
  }
// option button with selected state
  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap, Color activeColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? activeColor : Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
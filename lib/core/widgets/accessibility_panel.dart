import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class AccessibilityPanel extends ConsumerWidget {
  const AccessibilityPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('خيارات سهولة الوصول', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              title: const Text('حجم الخط'),
              trailing: DropdownButton<AppFontSize>(
                value: settings.fontSize,
                onChanged: (val) => notifier.setFontSize(val!),
                items: AppFontSize.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
              ),
            ),
            SwitchListTile(
              title: const Text('تباين عالي'),
              value: settings.highContrast,
              onChanged: (_) => notifier.toggleContrast(),
            ),
          ],
        ),
      ),
    );
  }
}
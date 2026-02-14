import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class AccessibilityControls extends ConsumerStatefulWidget {
  const AccessibilityControls({super.key});

  @override
  ConsumerState<AccessibilityControls> createState() => _AccessibilityControlsState();
}

class _AccessibilityControlsState extends ConsumerState<AccessibilityControls> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    // مراقبة حالة الإعدادات (ستفعل برمجياً في الخطوة الرابعة)
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Stack(
      children: [
        Positioned(
          top: 45,
          // الزر يتبع الاتجاه تلقائياً: يمين في الإنجليزي، يسار في العربي
          right: isRtl ? null : 16,
          left: isRtl ? 16 : null,
          child: Column(
            crossAxisAlignment: isRtl ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              // الزر العائم الأساسي
              FloatingActionButton.small(
                heroTag: 'accessibility_fab',
                backgroundColor: const Color(0xFF6B8E23), // لون الـ Sage المعتمد لأثر
                onPressed: () => setState(() => _isOpen = !_isOpen),
                child: Icon(_isOpen ? Icons.close : Icons.accessibility_new, color: Colors.white),
              ),
              if (_isOpen) ...[
                const SizedBox(height: 10),
                _buildOptionsPanel(l10n, isRtl, settings),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsPanel(AppLocalizations l10n, bool isRtl, dynamic settings) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRtl ? 'سهولة الوصول' : 'Accessibility',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Divider(height: 20),
          
          // خيار تغيير اللغة
          _buildOptionItem(
            icon: Icons.language,
            label: isRtl ? 'English' : 'العربية',
            onTap: () {
              // TODO: سيتم ربط منطق تغيير اللغة هنا في الخطوة الرابعة
              debugPrint("Language toggle clicked");
            },
          ),
          
          const SizedBox(height: 10),
          
          // خيار حجم الخط (قالب فقط حالياً)
          _buildOptionItem(
            icon: Icons.text_fields,
            label: isRtl ? 'حجم الخط' : 'Font Size',
            onTap: () => debugPrint("Font size clicked"),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF6B8E23)),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
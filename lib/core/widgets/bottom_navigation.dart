import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class AtharBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AtharBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          // إعدادات التصميم لتبدو مثل كود React (بدون خلفية افتراضية)
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: theme.colorScheme.primary, // Sage 700
          unselectedItemColor: Colors.grey.shade400,

          // ربط الخطوط بالثيم (IBM Plex Sans Arabic)
          selectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
            fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 12) *
                0.8, // نص صغير 9px تقريباً
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
            fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 12) * 0.8,
          ),

          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.homeLabel, // 'الرئيسية'
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map),
              label: l10n.mapLabel, // 'الخريطة'
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.message_outlined),
              activeIcon: const Icon(Icons.message),
              label: l10n.assistantLabel, // 'المساعد'
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_outlined),
              activeIcon: const Icon(Icons.calendar_today),
              label: l10n.calendarLabel, // 'التقويم'
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l10n.profileLabel, // 'الملف'
            ),
          ],
        ),
      ),
    );
  }
}

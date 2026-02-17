import 'package:flutter/material.dart';

import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/navigation/app_routes.dart';


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

    final l10n = AppLocalizations.of(context)!;

    // نفس ترتيب الأيقونات
    final routes = <String>[
      AppRoutes.home,     // Home tab
      AppRoutes.home,     // Map tab (مؤقت لين يكون عندك route خاص)
      AppRoutes.home,     // Assistant tab (مؤقت)
      AppRoutes.home,     // Booking tab (مؤقت)
      AppRoutes.profile,  // Profile tab ✅
    ];

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

          type: BottomNavigationBarType.fixed,

          backgroundColor: Colors.transparent,

          elevation: 0,

          selectedItemColor: theme.colorScheme.primary,

          unselectedItemColor: Colors.grey.shade400,

          // تم إزالة const من هنا ليعمل الثيم بشكل ديناميكي

          selectedLabelStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),

          unselectedLabelStyle: TextStyle(
            fontSize: 10,
          ),

          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.homeLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map),
              label: l10n.mapLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.message_outlined),
              activeIcon: const Icon(Icons.message),
              label: l10n.assistantLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_outlined),
              activeIcon: const Icon(Icons.calendar_today, size: 22),
              label: l10n.calendarLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l10n.profileLabel,
            ),
          ],
        ),
      ),
    );
  }
}

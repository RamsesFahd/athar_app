import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class AtharBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isTutor;

  const AtharBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isTutor = false,
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.1),
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
          selectedLabelStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 10,
          ),
          items: [
            // Home
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.homeLabel,
            ),
            // Map
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map),
              label: l10n.mapLabel,
            ),
            // AI Chatbot
            BottomNavigationBarItem(
              icon: const Icon(Icons.message_outlined),
              activeIcon: const Icon(Icons.message),
              label: l10n.assistantLabel,
            ),
            // Trips (tutor) / Contribution (tourist)
            if (isTutor)
              BottomNavigationBarItem(
                icon: const Icon(Icons.route_outlined),
                activeIcon: const Icon(Icons.route),
                label: l10n.calendarLabel,
              )
            else
              BottomNavigationBarItem(
                icon: const Icon(Icons.volunteer_activism_outlined),
                activeIcon: const Icon(Icons.volunteer_activism),
                label: l10n.contributions,
              ),
            // Profile
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

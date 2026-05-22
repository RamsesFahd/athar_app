import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/navigation/app_routes.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/admin/screens/trip_approvals_screen.dart';
import 'package:athar_app/features/admin/screens/users_management_screen.dart';
import 'package:athar_app/features/admin/screens/all_bookings_screen.dart';
import 'package:athar_app/features/admin/screens/cultural_archive_admin_screen.dart';
import 'package:athar_app/features/admin/screens/add_event_screen.dart';
import 'package:athar_app/features/admin/screens/contributions_review_screen.dart';
import 'package:athar_app/features/admin/screens/attractions_admin_screen.dart';
import 'package:athar_app/features/admin/screens/content_migration_screen.dart';

class AdminNavigationContainer extends ConsumerStatefulWidget {
  const AdminNavigationContainer({super.key});

  @override
  ConsumerState<AdminNavigationContainer> createState() =>
      _AdminNavigationContainerState();
}

class _AdminNavigationContainerState
    extends ConsumerState<AdminNavigationContainer> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    UsersManagementScreen(),
    TripApprovalsScreen(),
    AllBookingsScreen(),
    CulturalArchiveAdminScreen(),
    AddEventScreen(),
    ContributionsReviewScreen(),
    AttractionsAdminScreen(),
    ContentMigrationScreen(),
  ];

  final List<({String label, IconData icon})> _tabs = const [
    (label: 'People', icon: Icons.people_outline),
    (label: 'Trips', icon: Icons.card_travel_outlined),
    (label: 'Bookings', icon: Icons.book_online_outlined),
    (label: 'Archive', icon: Icons.museum_outlined),
    (label: 'Events', icon: Icons.celebration_outlined),
    (label: 'Contributions', icon: Icons.volunteer_activism_outlined),
    (label: 'Attractions', icon: Icons.place_outlined),
    (label: 'Migration', icon: Icons.auto_awesome_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin — ${_tabs[_currentIndex].label}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final navigator = Navigator.of(context);
              await ref.read(authNotifierProvider.notifier).logout();
              navigator.pushNamedAndRemoveUntil(
                AppRoutes.signIn,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurfaceVariant,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        items: _tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

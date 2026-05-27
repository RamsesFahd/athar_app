import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/navigation/app_routes.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/core/theme/app_theme.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/admin/screens/trip_bookings_screen.dart';
import 'package:athar_app/features/admin/screens/users_management_screen.dart';
import 'package:athar_app/features/admin/screens/cultural_archive_admin_screen.dart';
import 'package:athar_app/features/admin/screens/contributions_review_screen.dart';
import 'package:athar_app/features/admin/screens/events_attractions_admin_screen.dart';

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
    TripBookingsScreen(),
    CulturalArchiveAdminScreen(),
    EventsAttractionsAdminScreen(),
    ContributionsReviewScreen(),
  ];

  final List<({String label, IconData icon})> _tabs = const [
    (label: 'المستخدمون', icon: Icons.people_outline),
    (label: 'الرحلات', icon: Icons.card_travel_outlined),
    (label: 'الأرشيف الثقافي', icon: Icons.museum_outlined),
    (label: 'الفعاليات', icon: Icons.celebration_outlined),
    (label: 'المساهمات', icon: Icons.volunteer_activism_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final adminTheme = AppTheme.getTheme(
      AppSettings(fontSize: AppFontSize.medium, locale: const Locale('ar')),
    );
    final fixedTheme = adminTheme.copyWith(
      colorScheme: adminTheme.colorScheme.copyWith(
        brightness: Brightness.light,
      ),
      textTheme: adminTheme.textTheme.apply(fontSizeFactor: 1.0),
      primaryTextTheme:
          adminTheme.primaryTextTheme.apply(fontSizeFactor: 1.0),
    );
    final theme = fixedTheme;

    return Localizations.override(
      context: context,
      locale: const Locale('ar'),
      child: Theme(
        data: fixedTheme,
        child: MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                _tabs[_currentIndex].label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'تسجيل الخروج',
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
              unselectedItemColor:
                  theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
              selectedIconTheme: const IconThemeData(size: 24),
              unselectedIconTheme: const IconThemeData(size: 24),
              selectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
              items: _tabs
                  .map((t) => BottomNavigationBarItem(
                        icon: Icon(t.icon),
                        label: t.label,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

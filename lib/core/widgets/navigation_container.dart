import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/widgets/bottom_navigation.dart';
import 'package:athar_app/core/widgets/header.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/interactive_map/logic/map_notifier.dart';

// Screens
import 'package:athar_app/features/cultural_archive/screens/cultural_archive.dart';
import 'package:athar_app/features/profile/screens/profile_screen.dart';
import 'package:athar_app/features/home/screens/home_screen.dart';
import 'package:athar_app/features/historical_chat/screens/rawi_landing_screen.dart';
import 'package:athar_app/features/interactive_map/screens/map_screen.dart';
import 'package:athar_app/features/guide_market/screens/trip_management_screen.dart';
import 'package:athar_app/features/contributions/screens/contributions_achievements_screen.dart';

class NavigationContainer extends ConsumerStatefulWidget {
  const NavigationContainer({super.key});

  @override
  ConsumerState<NavigationContainer> createState() =>
      _NavigationContainerState();
}

class _NavigationContainerState extends ConsumerState<NavigationContainer> {
  int _currentIndex = 0;
  int _previousIndex = 0;
  Widget? _subPage;

  // Screens are built lazily once auth resolves and cached per role.
  // Never built in initState to avoid reading a potentially-disposed provider.
  List<Widget>? _screens;
  bool? _lastIsTutor;

  List<Widget> _buildScreens(bool isTutor) {
    return [
      HomeScreen(
        onSeeAllArchive: () => _onNavigateToSubPage(const CulturalArchive()),
        onEventTap: (EventModel event) {
          ref.read(pendingMapPinIdProvider.notifier).state = event.id;
          setState(() {
            _previousIndex = _currentIndex;
            _currentIndex = 1;
            _subPage = null;
          });
        },
      ),
      const MapScreen(),
      const RawiLandingScreen(),
      if (isTutor)
        const TripManagementScreen()
      else
        const ContributionsAchievementsScreen(),
      const ProfileScreen(),
    ];
  }

  void _onNavigateToSubPage(Widget page) {
    setState(() {
      _subPage = page;
    });
  }

  String _getPageTitle(BuildContext context, bool isTutor) {
    final l10n = AppLocalizations.of(context);

    if (_subPage is CulturalArchive) {
      return l10n.culturalArchiveTitle;
    }

    switch (_currentIndex) {
      case 0:
        return l10n.homeLabel;
      case 1:
        return l10n.mapLabel;
      case 2:
        return l10n.assistantLabel;
      case 3:
        return isTutor ? l10n.calendarLabel : l10n.contributions;
      case 4:
        return l10n.profileLabel;
      default:
        return l10n.homeLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch keeps authNotifierProvider alive for the full lifetime of this
    // widget and reacts correctly if the user logs out or switches accounts.
    final userAsync = ref.watch(authNotifierProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (_, __) => const Scaffold(
        body: Center(child: Icon(Icons.error_outline)),
      ),
      data: (user) {
        final isTutor = user?.role == UserRole.tutor;

        // Rebuild screen list only when the role actually changes.
        // This avoids re-instantiating all 5 screens on every auth update.
        if (_screens == null || _lastIsTutor != isTutor) {
          _screens = _buildScreens(isTutor);
          _lastIsTutor = isTutor;
          // Guard against a stale index that would exceed the new list length.
          if (_currentIndex >= _screens!.length) {
            _currentIndex = 0;
            _previousIndex = 0;
          }
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _subPage != null
              ? null
              : Header(
                  isHome: _currentIndex == 0 && _subPage == null,
                  title: _getPageTitle(context, isTutor),
                ),
          body: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final isMovingForward = _currentIndex > _previousIndex;
                  final beginOffset = isMovingForward
                      ? const Offset(1.0, 0.0)
                      : const Offset(-1.0, 0.0);

                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: beginOffset,
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutQuart,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<String>(_subPage != null
                      ? 'subpage_${_subPage.hashCode}'
                      : 'tab_$_currentIndex'),
                  child: _subPage ?? _screens![_currentIndex],
                ),
              ),
            ],
          ),
          bottomNavigationBar: AtharBottomNavigation(
            currentIndex: _currentIndex,
            isTutor: isTutor,
            onTap: (index) {
              if (index != _currentIndex || _subPage != null) {
                setState(() {
                  _previousIndex = _currentIndex;
                  _currentIndex = index;
                  _subPage = null;
                });
              }
            },
          ),
        );
      },
    );
  }
}

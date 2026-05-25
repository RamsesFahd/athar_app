import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/widgets/bottom_navigation.dart';
import 'package:athar_app/core/widgets/header.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/events/screens/event_details_screen.dart';
import 'package:athar_app/features/events/screens/events_list_screen.dart';

// Screens
import 'package:athar_app/features/cultural_archive/screens/cultural_archive.dart';
import 'package:athar_app/features/profile/screens/profile_screen.dart';
import 'package:athar_app/features/home/screens/home_screen.dart';
import 'package:athar_app/features/rawi/screens/rawi_landing_screen.dart';
import 'package:athar_app/features/interactive_map/screens/map_screen.dart';
import 'package:athar_app/features/trip_management/screens/trip_management_screen.dart';
import 'package:athar_app/features/contributions/screens/contributions_achievements_screen.dart';

class NavigationContainer extends ConsumerStatefulWidget {
  const NavigationContainer({super.key});

  @override
  ConsumerState<NavigationContainer> createState() =>
      _NavigationContainerState();
}

class _NavigationContainerState extends ConsumerState<NavigationContainer> {
  int _currentIndex = 0;
  Widget? _subPage;

  // Screens are built lazily once auth resolves and cached per role.
  // Never built in initState to avoid reading a potentially-disposed provider.
  List<Widget>? _screens;
  bool? _lastIsTutor;

  // LAZY LOADING: tracks which tabs the user has actually opened. A tab's heavy
  // widget tree (e.g. MapScreen's GoogleMap) is only built the first time its
  // index is visited — not all five at once on first paint. Once visited, the
  // tab stays in this set so its state is preserved across further navigation
  // (the IndexedStack keeps it mounted), exactly like before.
  final Set<int> _visitedIndexes = {0};

  List<Widget> _buildScreens(bool isTutor) {
    return [
      HomeScreen(
        onSeeAllArchive: () => _onNavigateToSubPage(
              CulturalArchive(onBack: () => setState(() => _subPage = null)),
            ),
        onSeeAllEvents: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EventsListScreen()),
        ),
        onEventTap: (EventModel event) => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EventDetailsScreen(event: event)),
        ),
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
              // IndexedStack keeps visited tab screens mounted (just hidden).
              // _HomeHeroSliderState — and every other visited tab's state —
              // survives tab switches, so the slider never resets to skeleton.
              // Unvisited tabs render as a cheap placeholder until first opened,
              // so heavy screens (MapScreen's GoogleMap) don't build on startup.
              IndexedStack(
                index: _currentIndex,
                children: List.generate(_screens!.length, (i) {
                  if (_visitedIndexes.contains(i)) return _screens![i];
                  return const SizedBox.shrink();
                }),
              ),
              // Sub-pages (e.g. CulturalArchive) slide in over the tabs and
              // are disposed when the user goes back. This is the only place
              // AnimatedSwitcher is still used, scoped to sub-page transitions.
              if (_subPage != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutQuart,
                    )),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey<int>(_subPage.hashCode),
                    child: _subPage!,
                  ),
                ),
            ],
          ),
          bottomNavigationBar: _subPage != null ? null : AtharBottomNavigation(
            currentIndex: _currentIndex,
            isTutor: isTutor,
            onTap: (index) {
              if (index != _currentIndex || _subPage != null) {
                setState(() {
                  _currentIndex = index;
                  _subPage = null;
                  // Mark this tab visited so it builds now and stays mounted.
                  _visitedIndexes.add(index);
                });
              }
            },
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/widgets/bottom_navigation.dart';
import 'package:athar_app/core/widgets/header.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';

// Screens
import 'package:athar_app/features/cultural_archive/screens/cultural_archive.dart';
import 'package:athar_app/features/profile/screens/profile_screen.dart';
import 'package:athar_app/features/home/screens/home_screen.dart';
import 'package:athar_app/features/historical_chat/screens/rawi_landing_screen.dart';
import 'package:athar_app/features/interactive_map/screens/map_screen.dart';
import 'package:athar_app/features/guide_market/screens/trip_management_screen.dart';
import 'package:athar_app/features/contribution/screens/contribution_screen.dart';

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
  late final List<Widget> screens;
  late final bool _isTutor;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).value;
    _isTutor = user?.role == UserRole.tutor;
    screens = [
      HomeScreen(
        onSeeAllArchive: () => _onNavigateToSubPage(const CulturalArchive()),
      ),
      const MapScreen(),
      const RawiLandingScreen(),
      if (_isTutor) const TripManagementScreen() else const ContributionScreen(),
      const ProfileScreen(),
    ];
  }

  // Go to a subpage (like Cultural Archive) from Home
  void _onNavigateToSubPage(Widget page) {
    setState(() {
      _subPage = page;
    });
  }

  String _getPageTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // if there's a subpage, we show its title (for now we only have Cultural Archive as a subpage, but this will extended)
    if (_subPage is CulturalArchive) {
      return l10n.culturalArchiveTitle;
    }

    // otherwise, we show the title based on the current tab
    switch (_currentIndex) {
      case 0:
        return l10n.homeLabel;
      case 1:
        return l10n.mapLabel;
      case 2:
        return l10n.assistantLabel;
      case 3:
        return _isTutor ? l10n.calendarLabel : l10n.contributions;
      case 4:
        return l10n.profileLabel;
      default:
        return l10n.homeLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // the AppBar is only shown when we're not in a subpage. If we are in a subpage, we want to hide the AppBar to give more space for the content (especially for the Cultural Archive which has a lot of content). The Header widget will automatically show the correct title based on the current tab or subpage.
      appBar: _subPage != null
          ? null
          : Header(
              isHome: _currentIndex == 0 && _subPage == null,
              title: _getPageTitle(context),
            ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
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
            child: Container(
              // The key is important to tell the AnimatedSwitcher when to animate. We use a different key for each tab and for the subpage, so that it knows when to animate between them.
              key: ValueKey<String>(_subPage != null
                  ? 'subpage_${_subPage.hashCode}'
                  : 'tab_$_currentIndex'),
              child: _subPage ?? screens[_currentIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AtharBottomNavigation(
        currentIndex: _currentIndex,
        isTutor: _isTutor,
        onTap: (index) {
          if (index != _currentIndex || _subPage != null) {
            setState(() {
              _previousIndex = _currentIndex;
              _currentIndex = index;
              _subPage =
                  null; // whenever we switch tabs, we want to exit any subpage and go back to the main screen of the new tab
            });
          }
        },
      ),
    );
  }
}

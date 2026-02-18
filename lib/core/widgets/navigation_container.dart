import 'package:flutter/material.dart';
import 'package:athar_app/core/widgets/bottom_navigation.dart';
import 'package:athar_app/core/widgets/header.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

// Screens
import 'package:athar_app/features/cultural_archive/screens/cultural_archive.dart';
import 'package:athar_app/features/profile/screens/profile_screen.dart';
import 'package:athar_app/features/home/screens/home_screen.dart';


class NavigationContainer extends StatefulWidget {
  const NavigationContainer({super.key});

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  int _currentIndex = 0;
  int _previousIndex = 0;
  Widget? _subPage; 

  // Go to a subpage (like Cultural Archive) from Home
  void _onNavigateToSubPage(Widget page) {
    setState(() {
      _subPage = page;
    });
  }

  String _getPageTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // if there's a subpage, we show its title (for now we only have Cultural Archive as a subpage, but this will extended)
    if (_subPage is CulturalArchive) {
      return l10n.culturalArchiveTitle;
    }

    // otherwise, we show the title based on the current tab
    switch (_currentIndex) {
      case 0: return l10n.homeLabel;
      case 1: return l10n.mapLabel;
      case 2: return l10n.assistantLabel;
      case 3: return l10n.calendarLabel;
      case 4: return l10n.profileLabel;
      default: return l10n.homeLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    // defining the main screens for each tab. The HomeScreen receives a callback to navigate to the Cultural Archive subpage.
    final List<Widget> _screens = [
      HomeScreen(
        onSeeAllArchive: () => _onNavigateToSubPage(const CulturalArchive()),
      ),
      const Scaffold(body: Center(child: Text('Map Screen'))),
      const Scaffold(body: Center(child: Text('AI Assistant'))),
      const Scaffold(body: Center(child: Text('Calendar'))),
      const ProfileScreen(), 
    ];

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
              key: ValueKey<String>(
                  _subPage != null ? 'subpage_${_subPage.hashCode}' : 'tab_$_currentIndex'),
              child: _subPage ?? _screens[_currentIndex],
            ),
          ),
          
        ],
      ),
      bottomNavigationBar: AtharBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex || _subPage != null) {
            setState(() {
              _previousIndex = _currentIndex;
              _currentIndex = index;
              _subPage = null; // whenever we switch tabs, we want to exit any subpage and go back to the main screen of the new tab
            });
          }
        },
      ),
    );
  }
}
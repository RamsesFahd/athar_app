import 'package:flutter/material.dart';
import 'package:athar_app/core/widgets/bottom_navigation.dart';
import 'package:athar_app/features/auth/screens/home.dart';
import 'package:athar_app/core/widgets/header.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

// Screens:
import 'package:athar_app/features/profile/screens/profile_screen.dart';


class NavigationContainer extends StatefulWidget {
  const NavigationContainer({super.key});

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  int _currentIndex = 0;
  int _previousIndex = 0; // to track the previous index for animation direction

  final List<Widget> _screens = [
    const HomeScreen(),
    // these are placeholders for the actual screens, replace with real ones when implemented
    const Scaffold(body: Center(child: Text('Map Screen'))),
    const Scaffold(body: Center(child: Text('AI Assistant'))),
    const Scaffold(body: Center(child: Text('Calendar'))),
    const ProfileScreen(),
  ];

  String _getPageTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_currentIndex) {
      case 0:
        return l10n.homeLabel;
      case 1:
        return l10n.mapLabel;
      case 2:
        return l10n.assistantLabel;
      case 3:
        return l10n.calendarLabel;
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
      appBar: Header(
        isHome: _currentIndex == 0,
        title: _getPageTitle(context),
      ),

      // we need a stack to layer the accessibility controls on top of the content
      body: Stack(
        children: [
      
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        // Slide and fade transition for smoother navigation between screens
        transitionBuilder: (Widget child, Animation<double> animation) {
          final isMovingForward = _currentIndex > _previousIndex;

          // To determine the direction of the slide based on whether we're moving forward or backward in the navigation
          final beginOffset = isMovingForward
              ? const Offset(1.0, 0.0) // From the right when moving forward
              : const Offset(-1.0, 0.0); // From the left when moving backward

          return SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            )
            .animate(CurvedAnimation(
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
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      
        ],
      ),
      // we use a custom bottom navigation bar to have more control over the styling and behavior
      bottomNavigationBar: AtharBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() {
              _previousIndex = _currentIndex; // to track the previous index 
              _currentIndex = index; // to update the current index and trigger the screen change
            });
          }
        },
      ),
    );
  }
}

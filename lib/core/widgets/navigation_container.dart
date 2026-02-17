import 'package:flutter/material.dart';
import 'package:athar_app/core/widgets/bottom_navigation.dart';
import 'package:athar_app/features/auth/screens/home.dart';
import 'package:athar_app/core/widgets/header.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class NavigationContainer extends StatefulWidget {
  const NavigationContainer({super.key});

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  int _currentIndex = 0;
  int _previousIndex = 0; // لمقارنة اتجاه الحركة (يمين/يسار)

  final List<Widget> _screens = [
    const HomeScreen(),
    const Scaffold(body: Center(child: Text('Map Screen'))),
    const Scaffold(body: Center(child: Text('AI Assistant'))),
    const Scaffold(body: Center(child: Text('Calendar'))),
    const Scaffold(body: Center(child: Text('Profile'))),
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        // هذا هو الجزء السحري لتحقيق حركة الفيديو (Slide Animation)
        transitionBuilder: (Widget child, Animation<double> animation) {
          final isMovingForward = _currentIndex > _previousIndex;

          // تحديد من أين تبدأ الصفحة الجديدة بالظهور
          final beginOffset = isMovingForward
              ? const Offset(1.0, 0.0) // تدخل من اليمين
              : const Offset(-1.0, 0.0); // تدخل من اليسار

          return SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart, // حركة ناعمة جداً
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
      bottomNavigationBar: AtharBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() {
              _previousIndex = _currentIndex; // حفظ المكان السابق
              _currentIndex = index; // التوجه للمكان الجديد
            });
          }
        },
      ),
    );
  }
}

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

  final List<Widget> _screens = [
    const HomeScreen(),
    const Scaffold(body: Center(child: Text('Map Screen'))),
    const Scaffold(body: Center(child: Text('AI Assistant'))),
    const Scaffold(body: Center(child: Text('Calendar'))),
    const Scaffold(body: Center(child: Text('Profile'))),
  ];

  // دالة ديناميكية تجلب الترجمة الصحيحة بناءً على الـ index ولغة التطبيق الحالية
  String _getPageTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
      appBar: Header(
        isHome: _currentIndex == 0,
        title: _getPageTitle(context), // تمرير context لجلب الترجمة
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AtharBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

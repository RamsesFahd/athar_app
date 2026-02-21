import 'dart:ui';
import 'package:athar_app/core/widgets/accessibility_controls.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool isHome;

  const Header({
    super.key,
    this.title,
    this.isHome = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ClipRect(
      child: BackdropFilter(
        // Blur effect for the header background
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: colorScheme.surface.withValues(alpha: 0.08),
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading:
              false, // Hides the default back button on non-home screens

          // Implementing the animated title/logo switch
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: isHome
                ? Image.asset(
                    'assets/images/athar_header_logo.png',
                    key: const ValueKey('logo'),
                    height: 35,
                  )
                : Text(
                    title ?? '',
                    key: ValueKey(title),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme
                      .primary, // Thematic color for accessibility button
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.accessibility_new,
                      color: Colors.white, size: 22),
                  tooltip: 'سهولة الوصول',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AccessibilityControls(),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: Colors.black87),
                    onPressed: () {},
                  ),
                  // Indicator for unread notifications
                  Positioned(
                    top: 15,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Adding a subtle bottom border to separate the header from content
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

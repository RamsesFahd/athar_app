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
    // الاعتماد على context الثيم لضمان التوافق مع الـ High Contrast وإعدادات الخطوط العالمية
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: !isHome,

      title: isHome
          ? Image.asset('assets/images/athar_logo.png', height: 35)
          : Text(
              title ?? '',
              // الالتزام بـ titleLarge لضمان تفعيل الـ Fallback للحروف العربية المعرف في AppTheme
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

      actions: [
        if (isHome)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon:
                    const Icon(Icons.notifications_none, color: Colors.black87),
                onPressed: () {},
              ),
              // Indicator مرتبط بالـ primary color لتعزيز الهوية البصرية في الـ Header
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    // إضافة Stroke أبيض لمنع تداخل لون النقطة مع خلفية الـ AppBar
                    border: Border.all(color: colorScheme.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
      ],

      // تعويض الـ elevation بـ Border شفاف (0.1 opacity) للحفاظ على هوية الـ Minimal Design
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
            color: colorScheme.onSurface.withOpacity(0.1), height: 1.0),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

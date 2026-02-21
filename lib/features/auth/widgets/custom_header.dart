import 'package:athar_app/core/widgets/accessibility_controls.dart';
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  const CustomHeader(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. صورة الخلفية الخاصة بمشروع أثر
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),

          // 2. التدرج اللوني لضمان وضوح النص
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

          // 3. نصوص الهيدر (العنوان والوصف)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              // التعديل الجوهري: CrossAxisAlignment.start تعني اليمين في العربي تلقائيًا
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  // TextAlign.start تتبع اتجاه لغة التطبيق الحالية
                  textAlign: TextAlign.start,
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // ✨ 4. زر سهولة الوصول (في الزاوية العلوية)
          PositionedDirectional(
            top: 50, // مسافة من الأعلى ليتجاوز النوتش
            end: 20, // في نهاية الشاشة حسب اتجاه اللغة
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                // أضفنا ظل خفيف عشان تبرز الأيقونة فوق صورة الخلفية
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black45,
                      blurRadius: 8,
                      offset: Offset(0, 2))
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.accessibility_new,
                    color: Colors.white, size: 22),
                tooltip: 'سهولة الوصول',
                onPressed: () {
                  // فتح النافذة المنبثقة للأداة
                  showDialog(
                    context: context,
                    builder: (context) => const AccessibilityControls(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

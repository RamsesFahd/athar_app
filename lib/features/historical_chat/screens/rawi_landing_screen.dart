import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/historical_chat/screens/chat_screen.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:athar_app/core/constants/region_data.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/features/historical_chat/widgets/region_story.dart';

class RawiLandingScreen extends ConsumerWidget {
  const RawiLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // (1) الهيدر محذوف من هنا نهائياً لأنه موجود في الـ NavigationContainer
      //use safe area to avoid the notch and status bar
    
      body: SafeArea(
        child: Column(
          children: [
        

          // (3) قسم الستوريز الدائرية (باستخدام الصورة المؤقتة)
          _buildStoriesRow(),

          // (4) فيلد البحث السادة (نفس ستايل الأرشيف)
          _buildSimpleSearchField(theme),

          // (5) المساحة الفارغة (Empty State)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forum_outlined, // أيقونة توحي بالمحادثة والمجلس
                    size: 80,
                    color: AppColors.primary.withValues(alpha: 0.1), // لون خفيف جداً
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "مجلس راوي ينتظر سوالفك .. \nاختر منطقة وابدأ أول رحلة",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),

      // (6) الزر العائم (FAB)
      floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()), // يفتح شات راوي العام
      );},
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
      label: const Text(
        "محادثة جديدة",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    );
  }

  Widget _buildStoriesRow() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: regionsData.length, //
        itemBuilder: (context, index) {
          final region = regionsData[index];
          return GestureDetector(
            onTap: () => _showStory(context, index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      // الصورة المؤقتة للجميع حالياً
                      backgroundImage: AssetImage(region.logoImage), 
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    region.nameAr, 
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleSearchField(ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: SizedBox(
      height: 48, 
      child: TextField(
        textAlign: TextAlign.right, 
        decoration: InputDecoration(
          hintText: "ابحث في محادثاتك السابقة", 
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.sage800, // نفس المستخدم في الأرشيف
          ),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          filled: true,
          fillColor: AppColors.surface, // لضمان التناسق مع الأرشيف
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ),
  );
}
}

void _showStory(BuildContext context, int index) {
  Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => RegionStoryScreen(initialIndex: index),
    ),
  );
}
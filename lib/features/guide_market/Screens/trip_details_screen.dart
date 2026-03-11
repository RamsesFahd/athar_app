import 'package:flutter/material.dart';
import 'package:athar_app/core/models/trip/trip.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:athar_app/features/guide_market/screens/booking_details_screen.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
  final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        
        children: [
          // محتوى الصفحة
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. الصورة الرئيسية
                Image.network(
                  trip.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                // 2. المحتوى النصي
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // 1. العنوان 
                    Text(trip.getTitle(isAr), style: theme.textTheme.displayLarge),
                    const SizedBox(height: 24),
  
                   // 2. العنوان 
                   Text(l10n.about_trip, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 12),
  
                   // 3. الوصف 
                 MarkdownBody(
                 data: trip.getDescription(isAr), 
                 styleSheet: MarkdownStyleSheet(
                 p: theme.textTheme.bodyLarge?.copyWith(height: 1.8), 
                          listBullet: TextStyle(color: theme.colorScheme.primary, fontSize: 16),
                          strong: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // قسم التفاصيل
                      _buildInfoRow(context, Icons.person_outline, "${l10n.guide}: ${trip.guide}"),
                      _buildInfoRow(context, Icons.business_outlined, "${l10n.company}: ${trip.company}"),
                      _buildInfoRow(context, Icons.verified_outlined, "${l10n.license}: ${trip.license}"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // إضافة الأزرار فوق الصورة
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      // كود المشاركة هنا
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. زر الحجز في الأسفل
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDetailsScreen(
                          trip: trip,
                        ),
                      ),
                    );
                  },
                  child: Text(l10n.book_now),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لتنسيق البيانات
  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
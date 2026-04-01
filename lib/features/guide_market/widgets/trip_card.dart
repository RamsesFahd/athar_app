import 'package:flutter/material.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/features/guide_market/screens/trip_details_screen.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final bool isGridView; // لنتحكم في شكل العرض

  const TripCard({
    super.key,
    required this.trip,
    this.isGridView = true,
  });

  // دالة الزر
  Widget _buildDetailsButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TripDetailsScreen(trip: trip)),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        child: Text(
          l10n.details, // قمنا باستخدام مفتاح الترجمة هنا
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. تحديد اللغة الحالية
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // نمرر isAr و l10n للدوال
      child: isGridView
          ? _buildGridContent(context, isAr, l10n)
          : _buildListContent(context, isAr, l10n),
    );
  }

  // 1. شكل الشبكة (صورة بالأعلى)
  Widget _buildGridContent(
      BuildContext context, bool isAr, AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
            child: Image.network(trip.imageUrl,
                fit: BoxFit.cover, width: double.infinity)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(trip.getTitle(isAr),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(trip.getShortDescription(isAr).split('\n').first,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 6),
              Text(trip.price,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                  width: double.infinity,
                  child: _buildDetailsButton(context, l10n)),
            ],
          ),
        ),
      ],
    );
  }

  // 2. شكل القائمة (صورة بالجانب)
  Widget _buildListContent(
      BuildContext context, bool isAr, AppLocalizations l10n) {
    return Row(
      children: [
        Image.network(trip.imageUrl,
            width: 120, height: 120, fit: BoxFit.cover),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.getTitle(isAr),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                // جزء من الوصف في القائمة
                Text(trip.getDescription(isAr).split('\n').first,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(trip.price,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildDetailsButton(context, l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

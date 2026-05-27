import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/features/attractions/screens/attraction_details_screen.dart';
import 'package:athar_app/features/cultural_archive/widgets/cultural_item_details.dart';
import 'package:athar_app/features/events/screens/event_details_screen.dart';
import 'package:athar_app/features/guide_market/screens/trip_details_screen.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:athar_app/core/theme/app_colors.dart';

class RawiSuggestionsRow extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool isAr;

  const RawiSuggestionsRow({
    super.key,
    required this.items,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 4),
          child: Text(
            l10n.rawiSuggestedItems,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => RawiSuggestionCard(
              item: items[index],
              isAr: isAr,
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class RawiSuggestionCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isAr;

  const RawiSuggestionCard({super.key, required this.item, required this.isAr});

  String get _id => item['id']?.toString() ?? '';
  String get _type => item['type']?.toString() ?? '';
  String get _imageUrl => item['imageUrl']?.toString() ?? '';
  String get _title {
    if (isAr) {
      return item['titleAr']?.toString().isNotEmpty == true
          ? item['titleAr'].toString()
          : item['titleEn']?.toString() ?? '';
    }
    return item['titleEn']?.toString().isNotEmpty == true
        ? item['titleEn'].toString()
        : item['titleAr']?.toString() ?? '';
  }

  IconData get _typeIcon {
    switch (_type) {
      case 'attraction':
        return Icons.place_rounded;
      case 'trip':
        return Icons.explore_rounded;
      case 'event':
        return Icons.event_rounded;
      case 'cultural_item':
        return Icons.museum_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Future<void> _navigate(BuildContext context) async {
    if (_id.isEmpty || _type.isEmpty) return;
    final db = FirebaseFirestore.instance;

    try {
      switch (_type) {
        case 'attraction':
          {
            final doc = await db.collection('attractions').doc(_id).get();
            if (!doc.exists || doc.data() == null) return;
            final model = AttractionModel.fromMap(doc.data()!, doc.id);
            if (!context.mounted) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AttractionDetailsScreen(attraction: model),
                ));
            break;
          }
        case 'trip':
          {
            final doc = await db.collection('trips').doc(_id).get();
            if (!doc.exists || doc.data() == null) return;
            final model = TripModel.fromMap(doc.data()!, doc.id);
            if (!context.mounted) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TripDetailsScreen(trip: model),
                ));
            break;
          }
        case 'cultural_item':
          {
            final doc = await db.collection('cultural_items').doc(_id).get();
            if (!doc.exists || doc.data() == null) return;
            final model = CulturalItemModel.fromMap(doc.data()!, doc.id);
            if (!context.mounted) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CulturalItemDetails(item: model),
                ));
            break;
          }
        case 'event':
          {
            final doc = await db.collection('events').doc(_id).get();
            if (!doc.exists || doc.data() == null) return;
            final model = EventModel.fromMap(doc.data()!, doc.id);
            if (!context.mounted) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailsScreen(event: model),
                ));
            break;
          }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigate(context),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Icon(_typeIcon, size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(_typeIcon,
            color: AppColors.primary.withValues(alpha: 0.4), size: 32),
      ),
    );
  }
}

import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/features/attractions/screens/attraction_details_screen.dart';
import 'package:athar_app/features/cultural_archive/widgets/cultural_item_details.dart';
import 'package:athar_app/features/guide_market/screens/trip_details_screen.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final rowExtra = ((textScale - 1.0).clamp(0.0, 1.0) * 34).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
              start: 12, end: 12, top: 6, bottom: 4),
          child: Text(
            l10n.rawiSuggestedItems,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        SizedBox(
          height: 130 + rowExtra,
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
  String get _imageUrl {
    final url = item['imageUrl']?.toString() ?? '';
    if (url.isNotEmpty) return url;
    return item['mainImage']?.toString() ?? '';
  }

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
            _showEventSheet(context, model);
            break;
          }
      }
    } catch (_) {}
  }

  void _showEventSheet(BuildContext context, EventModel event) {
    final isAr = this.isAr;
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr
                    ? (event.titleAr.isNotEmpty ? event.titleAr : event.titleEn)
                    : (event.titleEn.isNotEmpty
                        ? event.titleEn
                        : event.titleAr),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                isAr
                    ? (event.descriptionAr.isNotEmpty
                        ? event.descriptionAr
                        : event.descriptionEn)
                    : (event.descriptionEn.isNotEmpty
                        ? event.descriptionEn
                        : event.descriptionAr),
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _navigate(context),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.07),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: _imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      // 2× physical pixels for the 140 px logical card width
                      memCacheWidth: 280,
                      fadeInDuration: const Duration(milliseconds: 150),
                      placeholder: (_, __) => _placeholder(context),
                      errorWidget: (_, __, ___) => _placeholder(context),
                    )
                  : _placeholder(context),
            ),
            // Title + icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      _typeIcon,
                      size: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
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

  Widget _placeholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          _typeIcon,
          color: colorScheme.primary.withValues(alpha: 0.4),
          size: 32,
        ),
      ),
    );
  }
}

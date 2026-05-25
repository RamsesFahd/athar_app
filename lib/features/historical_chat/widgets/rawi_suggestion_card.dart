import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/features/attractions/logic/attractions_repository.dart';
import 'package:athar_app/features/attractions/widgets/attraction_card.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_repository.dart';
import 'package:athar_app/features/cultural_archive/widgets/cultural_item_card.dart';
import 'package:athar_app/features/events/logic/events_repository.dart';
import 'package:athar_app/features/events/widgets/event_card.dart';
import 'package:athar_app/features/guide_market/logic/trips_repository.dart';
import 'package:athar_app/features/guide_market/widgets/trip_card.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final rowExtra = ((textScale - 1.0).clamp(0.0, 1.0) * 54).toDouble();

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
          height: 230 + rowExtra,
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

class RawiSuggestionCard extends ConsumerWidget {
  final Map<String, dynamic> item;
  final bool isAr;

  const RawiSuggestionCard({super.key, required this.item, required this.isAr});

  String get _id => item['id']?.toString() ?? '';
  String get _type => item['type']?.toString() ?? '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_id.isEmpty || _type.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (_type) {
      case 'trip':
        return _ResolvedTripSuggestion(id: _id);
      case 'event':
        return _ResolvedEventSuggestion(id: _id);
      case 'attraction':
        return _ResolvedAttractionSuggestion(id: _id);
      case 'cultural_item':
        return _ResolvedCulturalSuggestion(id: _id, isAr: isAr);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ResolvedTripSuggestion extends ConsumerWidget {
  final String id;

  const _ResolvedTripSuggestion({required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<TripModel?>(
      future: ref.read(tripsRepositoryProvider).fetchTripById(id),
      builder: (context, snapshot) {
        final trip = snapshot.data;
        if (trip == null) {
          return _SuggestionPlaceholder(isLoading: !snapshot.hasError);
        }
        return SizedBox(
          width: 190,
          child: TripCard(trip: trip),
        );
      },
    );
  }
}

class _ResolvedEventSuggestion extends ConsumerWidget {
  final String id;

  const _ResolvedEventSuggestion({required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsStreamProvider);
    return eventsAsync.when(
      data: (events) {
        final event = _firstWhereOrNull<EventModel>(events, (e) => e.id == id);
        if (event == null) return const SizedBox.shrink();
        return SizedBox(
          width: 180,
          child: EventCard(event: event),
        );
      },
      loading: () => const _SuggestionPlaceholder(isLoading: true),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ResolvedAttractionSuggestion extends ConsumerWidget {
  final String id;

  const _ResolvedAttractionSuggestion({required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attractionsAsync = ref.watch(attractionsStreamProvider);
    return attractionsAsync.when(
      data: (attractions) {
        final attraction =
            _firstWhereOrNull<AttractionModel>(attractions, (a) => a.id == id);
        if (attraction == null) return const SizedBox.shrink();
        return SizedBox(
          width: 180,
          child: AttractionCard(attraction: attraction),
        );
      },
      loading: () => const _SuggestionPlaceholder(isLoading: true),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ResolvedCulturalSuggestion extends ConsumerWidget {
  final String id;
  final bool isAr;

  const _ResolvedCulturalSuggestion({required this.id, required this.isAr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<CulturalItemModel?>(
      future: ref.read(culturalRepositoryProvider).fetchItemDetails(id),
      builder: (context, snapshot) {
        final item = snapshot.data;
        if (item == null) {
          return _SuggestionPlaceholder(isLoading: !snapshot.hasError);
        }
        return CulturalItemCard(
          id: item.id,
          item: item,
          imageUrl: item.imageUrl,
          categoryId: item.categoryId,
          region: isAr ? item.regionAr : item.regionEn,
          title: isAr ? item.titleAr : item.titleEn,
          description: isAr ? item.descriptionAr : item.descriptionEn,
        );
      },
    );
  }
}

class _SuggestionPlaceholder extends StatelessWidget {
  final bool isLoading;

  const _SuggestionPlaceholder({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 180,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.image_not_supported_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}

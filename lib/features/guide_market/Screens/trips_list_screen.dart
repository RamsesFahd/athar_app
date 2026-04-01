import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/trip_card.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../../../core/widgets/search_bar.dart';
import 'package:athar_app/features/guide_market/screens/trip_details_screen.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';

class TripsListScreen extends ConsumerStatefulWidget {
  final String? selectedRegion;

  const TripsListScreen({super.key, this.selectedRegion});

  @override
  ConsumerState<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends ConsumerState<TripsListScreen> {
  String _searchQuery = '';
  bool? _ascending; // null = no sort applied
  bool isGridView = true;

  List<TripModel> _filterAndSort(List<TripModel> trips) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    var result = _searchQuery.isEmpty
        ? trips
        : trips
            .where((t) =>
                t
                    .getTitle(isAr)
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                t.company.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    if (_ascending != null) {
      result = List.from(result);
      result.sort((a, b) {
        final priceA =
            int.tryParse(a.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final priceB =
            int.tryParse(b.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return _ascending! ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectedRegion == null
              ? l10n.all_trips
              : l10n.trips_in(widget.selectedRegion!),
        ),
      ),
      body: StreamBuilder<List<TripModel>>(
        stream: ref.read(marketplaceRepositoryProvider).fetchAllTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTrips = snapshot.data ?? [];
          final displayedTrips = _filterAndSort(allTrips);

          return Column(
            children: [
              CustomSearchBar(
                hintText: l10n.search_trips_hint,
                isGridView: isGridView,
                onChanged: (v) =>
                    setState(() => _searchQuery = v.trim()),
                onFilterTap: () async {
                  final RenderBox button =
                      context.findRenderObject() as RenderBox;
                  final RenderBox overlay =
                      Overlay.of(context).context.findRenderObject()
                          as RenderBox;
                  final RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(Offset.zero, ancestor: overlay),
                      button.localToGlobal(
                          button.size.bottomRight(Offset.zero),
                          ancestor: overlay),
                    ),
                    Offset.zero & overlay.size,
                  );
                  final String? result = await showMenu<String>(
                    context: context,
                    position: position,
                    items: [
                      PopupMenuItem<String>(
                        value: 'low',
                        child: Row(children: [
                          const Icon(Icons.arrow_upward, size: 20),
                          const SizedBox(width: 10),
                          Text(l10n.price_low_first),
                        ]),
                      ),
                      PopupMenuItem<String>(
                        value: 'high',
                        child: Row(children: [
                          const Icon(Icons.arrow_downward, size: 20),
                          const SizedBox(width: 10),
                          Text(l10n.price_high_first),
                        ]),
                      ),
                    ],
                  );
                  if (result == 'low') {
                    setState(() => _ascending = true);
                  } else if (result == 'high') {
                    setState(() => _ascending = false);
                  }
                },
                onToggleView: () {
                  setState(() => isGridView = !isGridView);
                },
              ),

              if (displayedTrips.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      allTrips.isEmpty
                          ? 'No trips available'
                          : 'No results found',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade500),
                    ),
                  ),
                )
              else
                Expanded(
                  child: isGridView
                      ? GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: displayedTrips.length,
                          itemBuilder: (context, index) => TripCard(
                            trip: displayedTrips[index],
                            isGridView: true,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: displayedTrips.length,
                          itemBuilder: (context, index) => TripCard(
                            trip: displayedTrips[index],
                            isGridView: false,
                          ),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}

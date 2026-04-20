import 'package:athar_app/features/guide_market/logic/trips_filter_notifier.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';
import 'package:athar_app/features/guide_market/widgets/trip_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/trip_card.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../../../core/widgets/search_bar.dart';

class TripsListScreen extends ConsumerStatefulWidget {
  final String? selectedRegion;

  const TripsListScreen({super.key, this.selectedRegion});

  @override
  ConsumerState<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends ConsumerState<TripsListScreen> {
  // isGridView is pure UI preference – not business logic, so setState is correct here.
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    // Issue V fix: watch the StreamProvider instead of calling ref.read()
    // inside a StreamBuilder. The stream is now re-created reactively.
    final tripsAsync = ref.watch(allTripsStreamProvider);

    // Issue K fix: filter state lives in the notifier, not in screen state.
    final filter = ref.watch(tripsFilterProvider);
    final filterNotifier = ref.read(tripsFilterProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectedRegion == null
              ? l10n.all_trips
              : l10n.trips_in(widget.selectedRegion!),
        ),
      ),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (allTrips) {
          final displayedTrips =
              filterNotifier.filterAndSort(allTrips, isAr);

          final uniqueCities = allTrips
              .map((trip) => trip.getCity(isAr))
              .where((city) => city.trim().isNotEmpty)
              .toSet()
              .toList();

          return Column(
            children: [
              CustomSearchBar(
                hintText: l10n.search_trips_hint,
                isGridView: _isGridView,
                isFilterActive: filter.hasActiveFilters,
                onChanged: filterNotifier.setSearchQuery,
                onFilterTap: () async {
                  final result =
                      await showModalBottomSheet<Map<String, dynamic>>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => TripFilterBottomSheet(
                      initialPriceRange: filter.priceRange,
                      initialSelectedCities: filter.selectedCities,
                      initialAscending: filter.ascending,
                      availableCities: uniqueCities,
                    ),
                  );

                  if (result != null) {
                    filterNotifier.applyFilters(
                      priceRange: result['priceRange'] as RangeValues,
                      cities:
                          (result['cities'] as List).cast<String>(),
                      ascending: result['ascending'] as bool?,
                    );
                  }
                },
                onToggleView: () {
                  setState(() => _isGridView = !_isGridView);
                },
              ),
              if (displayedTrips.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      allTrips.isEmpty
                          ? 'No trips available'
                          : 'No results found',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.grey.shade500),
                    ),
                  ),
                )
              else
                Expanded(
                  child: _isGridView
                      ? GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.6,
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
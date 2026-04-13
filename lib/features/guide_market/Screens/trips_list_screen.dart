import 'package:athar_app/features/guide_market/widgets/trip_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/trip_card.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../../../core/widgets/search_bar.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';

class TripsListScreen extends ConsumerStatefulWidget {
  final String? selectedRegion;

  const TripsListScreen({super.key, this.selectedRegion});

  @override
  ConsumerState<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends ConsumerState<TripsListScreen> {
  String _searchQuery = '';
  
  bool isGridView = true;
  //the filltering variables:
  RangeValues _priceRange = const RangeValues(0, 5000);
  List<String> _selectedCities = [];
  bool? _ascending; // null = no sort applied
  
  List<TripModel> _filterAndSort(List<TripModel> trips) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    var result = trips;

    // 1. فلتر البحث النصي
    if (_searchQuery.isNotEmpty) {
      result = result.where((t) =>
          t.getTitle(isAr).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.company.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // 2. فلتر المدن (مُعطل مؤقتاً حتى يتم إضافته في TripModel)
    /* if (_selectedCities.isNotEmpty) {
      result = result.where((t) => 
        // سيتم تفعيل هذا السطر لاحقاً بعد إضافة المتغيرات للمودل
        _selectedCities.any((city) => (isAr ? t.regionAr : t.regionEn).contains(city))
      ).toList();
    }
    */

    // 3. فلتر نطاق السعر
    result = result.where((t) {
      final tripPrice = int.tryParse(t.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return tripPrice >= _priceRange.start && tripPrice <= _priceRange.end;
    }).toList();

    // 4. الترتيب
    if (_ascending != null) {
      result = List.from(result);
      result.sort((a, b) {
        final priceA = int.tryParse(a.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final priceB = int.tryParse(b.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
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
          final isAr = Localizations.localeOf(context).languageCode == 'ar';
          final uniqueCities = allTrips
              .map((trip) => trip.getCity(isAr))
              .where((city) => city.trim().isNotEmpty) // نتجاهل المدن الفاضية
              .toSet() // ToSet تمنع تكرار اسم المدينة
              .toList();

          return Column(
            children: [
              CustomSearchBar(
                hintText: l10n.search_trips_hint,
                isGridView: isGridView,
                isFilterActive: _ascending != null || _selectedCities.isNotEmpty || _priceRange.start > 0 || _priceRange.end < 5000,
                onChanged: (v) =>
                    setState(() => _searchQuery = v.trim()),
                onFilterTap: () async {
                  // open the filter bottom sheet and wait for the result
                final result = await showModalBottomSheet<Map<String, dynamic>>(
                    context: context,
                    isScrollControlled: true, 
                    backgroundColor: Colors.transparent, 
                    builder: (context) => TripFilterBottomSheet(
                      initialPriceRange: _priceRange,
                      initialSelectedCities: _selectedCities,
                      initialAscending: _ascending,
                      availableCities: uniqueCities,
                    ),
                  );

                  // if the user applied filters and closed the sheet, update the state
                  if (result != null) {
                    setState(() {
                      _priceRange = result['priceRange'];
                      _selectedCities = result['cities'];
                      _ascending = result['ascending'];
                    });
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/features/interactive_map/logic/map_notifier.dart';

class MapFilterChips extends ConsumerWidget {
  final MapFilter activeFilter;
  final ValueChanged<MapFilter> onChanged;

  const MapFilterChips({
    super.key,
    required this.activeFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(settingsProvider).locale.languageCode == 'ar';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _chip(context, isAr ? 'الكل' : 'All', MapFilter.all),
          const SizedBox(width: 8),
          _chip(context, isAr ? 'المعالم الثقافية' : 'Landmarks', MapFilter.landmarks),
          const SizedBox(width: 8),
          _chip(context, isAr ? 'المعالم السياحية' : 'Attractions', MapFilter.attractions),
          const SizedBox(width: 8),
          _chip(context, isAr ? 'الفعاليات' : 'Events', MapFilter.events),
          const SizedBox(width: 8),
          _chip(context, isAr ? 'قريب مني' : 'Near Me', MapFilter.nearMe),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, MapFilter filter) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = activeFilter == filter;

    return GestureDetector(
      onTap: () => onChanged(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: colorScheme.primary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

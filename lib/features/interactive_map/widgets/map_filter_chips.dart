import 'package:flutter/material.dart';
import 'package:athar_app/features/interactive_map/logic/map_notifier.dart';

class MapFilterChips extends StatelessWidget {
  final MapFilter activeFilter;
  final bool showNearMe;
  final ValueChanged<MapFilter> onChanged;

  const MapFilterChips({
    super.key,
    required this.activeFilter,
    required this.showNearMe,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _chip(context, 'الكل', MapFilter.all),
          const SizedBox(width: 8),
          _chip(context, 'المعالم الثقافية', MapFilter.landmarks),
          const SizedBox(width: 8),
          _chip(context, 'الفعاليات', MapFilter.events),
          if (showNearMe) ...[
            const SizedBox(width: 8),
            _chip(context, 'قريب مني', MapFilter.nearMe),
          ],
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

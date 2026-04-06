import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class TripFilterBottomSheet extends StatefulWidget {
  final RangeValues initialPriceRange;
  final List<String> initialSelectedCities;
  final bool? initialAscending;
  final List<String> availableCities;

  const TripFilterBottomSheet({
    super.key,
    required this.initialPriceRange,
    required this.initialSelectedCities,
    this.initialAscending,
    required this.availableCities,
  });

  @override
  State<TripFilterBottomSheet> createState() => _TripFilterBottomSheetState();
}

class _TripFilterBottomSheetState extends State<TripFilterBottomSheet> {
  late RangeValues _priceRange;
  late List<String> _selectedCities;
  bool? _ascending;

  late TextEditingController _minPriceCtrl;
  late TextEditingController _maxPriceCtrl;

  @override
  void initState() {
    super.initState();
    _priceRange = widget.initialPriceRange;
    _selectedCities = List.from(widget.initialSelectedCities);
    _ascending = widget.initialAscending;

    _minPriceCtrl = TextEditingController(text: _priceRange.start.toInt().toString());
    _maxPriceCtrl = TextEditingController(text: _priceRange.end.toInt().toString());
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  void _updateRangeFromInputs() {
    double min = double.tryParse(_minPriceCtrl.text) ?? 0;
    double max = double.tryParse(_maxPriceCtrl.text) ?? 5000;
    
    // حماية من الأخطاء (لو كتب الحد الأدنى أعلى من الأقصى)
    if (min > max) min = max;
    if (min < 0) min = 0;
    if (max > 5000) max = 5000;

    setState(() {
      _priceRange = RangeValues(min, max);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // a unified shape for both ChoiceChip and FilterChip with dynamic border color based on selection
    RoundedRectangleBorder chipShape(bool isSelected) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          
          Text(l10n.filterAndSortTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),

          // 1. Sorting options
          Text(l10n.sortBy, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap( 
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.priceLowToHigh),
                selected: _ascending == true,
                onSelected: (val) => setState(() => _ascending = true),
                showCheckmark: false, 
                selectedColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surface,
                shape: chipShape(_ascending == true),
                labelStyle: TextStyle(
                  color: _ascending == true ? Colors.white : theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ChoiceChip(
                label: Text(l10n.priceHighToLow),
                selected: _ascending == false,
                onSelected: (val) => setState(() => _ascending = false),
                showCheckmark: false,
                selectedColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surface,
                shape: chipShape(_ascending == false),
                labelStyle: TextStyle(
                  color: _ascending == false ? Colors.white : theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 32),

          // 2. Price range filter (تم تصحيح الأقواس هنا)
          Text(l10n.priceRange, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "الحد الأدنى",
                    suffixText: l10n.currencySAR,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (val) => _updateRangeFromInputs(),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("-", style: TextStyle(fontSize: 24, color: Colors.grey)),
              ),
              Expanded(
                child: TextField(
                  controller: _maxPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "الحد الأقصى",
                    suffixText: l10n.currencySAR,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (val) => _updateRangeFromInputs(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // شريط السحب المتزامن مع الحقول
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 5000,
            divisions: 100, 
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
                _minPriceCtrl.text = values.start.toInt().toString();
                _maxPriceCtrl.text = values.end.toInt().toString();
              });
            },
          ),
          const Divider(height: 32),

          // 3. Destination filter (Cities)
          Text(l10n.destination, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.availableCities.map((city) {
              final isSelected = _selectedCities.contains(city);
              return FilterChip(
                label: Text(city),
                selected: isSelected,
                showCheckmark: false, 
                selectedColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surface,
                shape: chipShape(isSelected),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCities.add(city);
                    } else {
                      _selectedCities.remove(city);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // 4. Apply filters button
          SizedBox(
            width: double.infinity,
            height: 54, 
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'priceRange': _priceRange,
                  'cities': _selectedCities,
                  'ascending': _ascending,
                });
              },
              child: Text(l10n.showResults),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
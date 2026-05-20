import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class MapSearchBar extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  const MapSearchBar({
    super.key,
    required this.onChanged,
    required this.controller,
  });

  @override
  ConsumerState<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends ConsumerState<MapSearchBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    final has = widget.controller.text.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isAr = ref.watch(settingsProvider).locale.languageCode == 'ar';
    final textDir = isAr ? TextDirection.rtl : TextDirection.ltr;

    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        textDirection: textDir,
        decoration: InputDecoration(
          hintText: l10n.mapSearchHint,
          hintTextDirection: textDir,
          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
          suffixIcon: _hasText
              ? IconButton(
                  icon: Icon(Icons.close,
                      size: 18, color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MapSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  const MapSearchBar({
    super.key,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث عن معالم أو فعاليات...',
          hintTextDirection: TextDirection.rtl,
          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
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

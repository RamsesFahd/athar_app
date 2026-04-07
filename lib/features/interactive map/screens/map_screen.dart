import 'package:flutter/material.dart';
import 'landmark_detail_screen.dart';
import 'event_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String selectedFilter = "الكل"; 
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // استخدام ألوان الثيم مباشرة عبر context
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // 1. الخريطة (Placeholder)
          Positioned.fill(
            child: Container(
              color: colorScheme.surface,
              child: Center(
                child: Text(
                  "Waiting for API integration...", 
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
// 2. شريط البحث
Positioned(
  top: 100, // نزلناه لـ 100 عشان يطلع تحت الـ Status Bar بوضوح
  left: 20,
  right: 20,
  child: Material(
    elevation: 5,
    borderRadius: BorderRadius.circular(30),
    child: TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "ابحث عن معالم أو فعاليات...",
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
  ),
),

// 3. أزرار التصفية (Filtering) 
Positioned(
  top: 170, // نزلنا الأزرار لـ 170 عشان تكون تحت البحث بمسافة كافية
  left: 0, right: 0,
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        _buildFilterChip("الكل"),
        const SizedBox(width: 8),
        _buildFilterChip("المعالم الثقافية"),
        const SizedBox(width: 8),
        _buildFilterChip("الفعاليات"),
      ],
    ),
  ),
),
          // 3. الماركرز (Markers)
          if (selectedFilter == "الكل" || selectedFilter == "المعالم الثقافية")
            _buildMarker(
              top: 300, left: 100, 
              icon: Icons.account_balance_rounded, 
              color: colorScheme.primary, // يتبع الثيم (حتى في الـ High Contrast)
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandmarkDetailScreen())),
            ),

          if (selectedFilter == "الكل" || selectedFilter == "الفعاليات")
            _buildMarker(
              top: 450, left: 200, 
              icon: Icons.event_available_rounded, 
              color: colorScheme.secondary, 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventDetailScreen())),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
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

  Widget _buildMarker({required double top, required double left, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Positioned(
      top: top, left: left,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
          child: Icon(icon, size: 30, color: color),
        ),
      ),
    );
  }
}
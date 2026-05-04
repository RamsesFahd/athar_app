import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:athar_app/core/models/map/map_pin_model.dart';
import 'package:athar_app/features/interactive_map/logic/map_notifier.dart';
import 'package:athar_app/features/interactive_map/widgets/map_filter_chips.dart';
import 'package:athar_app/features/interactive_map/widgets/map_search_bar.dart';
import 'package:athar_app/features/interactive_map/widgets/map_results_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<double> _sheetExtent = ValueNotifier(0.30);
  LatLngBounds? _visibleBounds;

  // Landmark and event icons (static colors)
  BitmapDescriptor _landmarkIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  BitmapDescriptor _landmarkIconSelected =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  BitmapDescriptor _eventIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
  BitmapDescriptor _eventIconSelected =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);

  // Per-attraction-color icon cache: hex → BitmapDescriptor
  final Map<String, BitmapDescriptor> _attractionColorIcons = {};
  final Map<String, BitmapDescriptor> _attractionColorIconsSelected = {};

  // Fallback used before the async per-color icon is built
  BitmapDescriptor _attractionFallback =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  BitmapDescriptor _attractionFallbackSelected =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

  static const _saudiCenter = CameraPosition(
    target: LatLng(24.7, 46.7),
    zoom: 5.5,
  );

  // App theme colors
  static const _sage = Color(0xFF344235);
  static const _sand = Color(0xFFCC9A53);

  @override
  void initState() {
    super.initState();
    _initMarkerIcons();
  }

  Future<void> _initMarkerIcons() async {
    final results = await Future.wait([
      _buildPinMarker(_sage, Icons.account_balance),
      _buildPinMarker(_sage, Icons.account_balance, selected: true),
      // Default fallback for attraction pins before per-color icons are ready
      _buildPinMarker(const Color(0xFF3A6EA5), Icons.place_outlined),
      _buildPinMarker(const Color(0xFF3A6EA5), Icons.place_outlined, selected: true),
      _buildPinMarker(_sand, Icons.celebration),
      _buildPinMarker(_sand, Icons.celebration, selected: true),
    ]);
    if (mounted) {
      setState(() {
        _landmarkIcon = results[0];
        _landmarkIconSelected = results[1];
        _attractionFallback = results[2];
        _attractionFallbackSelected = results[3];
        _eventIcon = results[4];
        _eventIconSelected = results[5];
      });
    }
  }

  Color _hexToColor(String hex) {
    final n = hex.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$n', radix: 16));
  }

  Future<void> _preloadAttractionIcons(List<MapPinModel> pins) async {
    final newHexCodes = pins
        .where((p) =>
            p.type == MapPinType.attraction &&
            p.categoryColorCode != null &&
            !_attractionColorIcons.containsKey(p.categoryColorCode))
        .map((p) => p.categoryColorCode!)
        .toSet();

    if (newHexCodes.isEmpty) return;

    final entries = await Future.wait(
      newHexCodes.map((hex) async {
        final color = _hexToColor(hex);
        final normal =
            await _buildPinMarker(color, Icons.place_outlined);
        final selected =
            await _buildPinMarker(color, Icons.place_outlined, selected: true);
        return (hex, normal, selected);
      }),
    );

    if (!mounted) return;
    setState(() {
      for (final entry in entries) {
        _attractionColorIcons[entry.$1] = entry.$2;
        _attractionColorIconsSelected[entry.$1] = entry.$3;
      }
    });
  }

  /// Builds a teardrop-shaped map pin marker.
  ///
  /// Normal:   filled with [color], white border, white icon.
  /// Selected: white fill, [color] border, [color] icon — inverted look.
  Future<BitmapDescriptor> _buildPinMarker(
    Color color,
    IconData icon, {
    bool selected = false,
  }) async {
    final double w = selected ? 80.0 : 64.0;
    final double h = selected ? 100.0 : 80.0;
    final double cx = w / 2;
    final double r = w * 0.40;
    final double cy = r + 6;
    final double tipY = h - 4;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));

    // ── Teardrop path ────────────────────────────────────────────────────────
    Path tearPath({double dx = 0, double dy = 0}) {
      final path = Path();
      // Start at right junction (60° CW from positive-x in Flutter canvas coords)
      path.moveTo(cx + r * 0.5 + dx, cy + r * 0.866 + dy);
      // Right side of tail → tip
      path.quadraticBezierTo(
        cx + r * 0.25 + dx, tipY - 10 + dy,
        cx + dx, tipY + dy,
      );
      // Left side of tail → left junction
      path.quadraticBezierTo(
        cx - r * 0.25 + dx, tipY - 10 + dy,
        cx - r * 0.5 + dx, cy + r * 0.866 + dy,
      );
      // Arc from 120° sweeping 300° CW — traces the top of the circle
      // (120° → 180° → 270°/top → 0° → 60°)
      path.arcTo(
        Rect.fromCircle(center: Offset(cx + dx, cy + dy), radius: r),
        120 * pi / 180, // start angle (measured CW from 3-o'clock)
        300 * pi / 180, // sweep CW, lands at 420° mod 360° = 60° ✓
        false,
      );
      path.close();
      return path;
    }

    // 1. Shadow
    canvas.drawPath(
      tearPath(dx: 1, dy: 2),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // 2. Fill
    canvas.drawPath(
      tearPath(),
      Paint()..color = selected ? Colors.white : color,
    );

    // 3. Border
    canvas.drawPath(
      tearPath(),
      Paint()
        ..color = selected ? color : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // 4. Icon centered on the circle
    final iconColor = selected ? color : Colors.white;
    final tp = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: r * 0.95,
          fontFamily: icon.fontFamily,
          color: iconColor,
        ),
      )
      ..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

    final img = await recorder.endRecording().toImage(w.toInt(), h.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(data!.buffer.asUint8List());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _sheetExtent.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(
      List<MapPinModel> pins, MapPinModel? selectedPin) {
    return pins.map((pin) {
      final isSelected = pin.id == selectedPin?.id;
      final BitmapDescriptor markerIcon;
      if (pin.type == MapPinType.landmark) {
        markerIcon = isSelected ? _landmarkIconSelected : _landmarkIcon;
      } else if (pin.type == MapPinType.attraction) {
        final hex = pin.categoryColorCode;
        if (hex != null) {
          markerIcon = isSelected
              ? (_attractionColorIconsSelected[hex] ?? _attractionFallbackSelected)
              : (_attractionColorIcons[hex] ?? _attractionFallback);
        } else {
          markerIcon = isSelected ? _attractionFallbackSelected : _attractionFallback;
        }
      } else {
        markerIcon = isSelected ? _eventIconSelected : _eventIcon;
      }
      return Marker(
        markerId: MarkerId(pin.id),
        position: LatLng(pin.latitude, pin.longitude),
        icon: markerIcon,
        zIndexInt: isSelected ? 1 : 0,
        onTap: () {
          ref.read(mapNotifierProvider.notifier).selectPin(pin);
        },
      );
    }).toSet();
  }

  Future<void> _goToUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('يتطلب الوصول إلى موقعك تفعيل الإذن من الإعدادات'),
          ),
        );
      }
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      ref.read(mapNotifierProvider.notifier).setLocationGranted(true);

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          13,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapNotifierProvider);
    final filteredPins = ref.watch(filteredMapPinsProvider);
    final activeFilter = ref.watch(activeMapFilterProvider);
    final locationGranted = ref.watch(locationGrantedProvider);
    final selectedPin = ref.watch(selectedMapPinProvider);

    // Preload per-color attraction icons whenever the pin list changes
    ref.listen<List<MapPinModel>>(filteredMapPinsProvider, (_, pins) {
      _preloadAttractionIcons(pins);
    });

    // Animate camera to newly selected pin
    ref.listen<MapPinModel?>(selectedMapPinProvider, (_, next) {
      if (next != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(next.latitude, next.longitude),
            14,
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map (full screen)
          GoogleMap(
            initialCameraPosition: _saudiCenter,
            mapId: '3aa630a1f9a6e633f8a76f84',
            cameraTargetBounds: CameraTargetBounds(
              LatLngBounds(
                southwest: const LatLng(16.0, 34.0),
                northeast: const LatLng(32.0, 56.0),
              ),
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(5, 18),
            onMapCreated: (controller) => _mapController = controller,
            onCameraIdle: () async {
              final bounds = await _mapController?.getVisibleRegion();
              if (bounds != null && mounted) {
                setState(() => _visibleBounds = bounds);
              }
            },
            markers: mapState.when(
              data: (_) => _buildMarkers(filteredPins, selectedPin),
              loading: () => const {},
              error: (_, __) => const {},
            ),
            myLocationEnabled: locationGranted,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onTap: (_) {
              if (ref.read(selectedMapPinProvider) != null) {
                ref.read(mapNotifierProvider.notifier).selectPin(null);
              }
            },
          ),

          // 2. Error banner
          if (mapState.hasError)
            Positioned(
              top: 140,
              left: 16,
              right: 16,
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Text(
                    'تعذّر تحميل البيانات، تحقق من اتصالك بالإنترنت',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ),

          // 3. Search bar + filter chips — below the sheet so sheet covers them at full screen
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: MapSearchBar(
                    controller: _searchController,
                    onChanged: (q) =>
                        ref.read(mapNotifierProvider.notifier).setSearchQuery(q),
                  ),
                ),
                MapFilterChips(
                  activeFilter: activeFilter,
                  onChanged: (f) =>
                      ref.read(mapNotifierProvider.notifier).setFilter(f),
                ),
              ],
            ),
          ),

          // 4. Draggable results sheet — renders on top of search bar
          Positioned.fill(
            top: 90, 
            child: MapResultsSheet(
              visibleBounds: _visibleBounds,
              onExtentChanged: (extent) => _sheetExtent.value = extent,
            ),
          ),

          // 5. Loading indicator
          if (mapState.isLoading)
            const Center(child: CircularProgressIndicator()),

          // 6. My-location FAB — follows the sheet; hidden when sheet covers full screen
          ValueListenableBuilder<double>(
            valueListenable: _sheetExtent,
            builder: (context, extent, child) {
              if (extent > 0.7) return const SizedBox.shrink();
              return Positioned(
                bottom: MediaQuery.of(context).size.height * extent + 12,
                right: 16,
                child: FloatingActionButton.small(
                  onPressed: _goToUserLocation,
                  tooltip: 'موقعي',
                  child: const Icon(Icons.my_location),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:athar_app/core/models/map/map_pin_model.dart';
import 'package:athar_app/features/interactive_map/logic/map_notifier.dart';
import 'package:athar_app/features/interactive_map/widgets/map_filter_chips.dart';
import 'package:athar_app/features/interactive_map/widgets/map_search_bar.dart';
import 'package:athar_app/features/interactive_map/widgets/map_bottom_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  // Custom marker icons loaded once in initState
  BitmapDescriptor _landmarkIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  BitmapDescriptor _eventIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);

  static const _saudiCenter = CameraPosition(
    target: LatLng(24.7, 46.7),
    zoom: 5.5,
  );

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
  }

  Future<void> _loadMarkerIcons() async {
    // Try loading custom assets; fall back to default hue markers if assets don't exist yet
    try {
      final landmark = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/map_marker_landmark.png',
      );
      final event = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/map_marker_event.png',
      );
      if (mounted) {
        setState(() {
          _landmarkIcon = landmark;
          _eventIcon = event;
        });
      }
    } catch (_) {
      // Custom assets not added yet — default hue markers are already set
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(List<MapPinModel> pins) {
    return pins.map((pin) {
      return Marker(
        markerId: MarkerId(pin.id),
        position: LatLng(pin.latitude, pin.longitude),
        icon: pin.type == MapPinType.landmark ? _landmarkIcon : _eventIcon,
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
    final selectedPin = ref.watch(selectedMapPinProvider);
    final activeFilter = ref.watch(activeMapFilterProvider);
    final locationGranted = ref.watch(locationGrantedProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map (full screen)
          GoogleMap(
            initialCameraPosition: _saudiCenter,
            onMapCreated: (controller) => _mapController = controller,
            markers: mapState.when(
              data: (_) => _buildMarkers(filteredPins),
              loading: () => const {},
              error: (_, __) => const {},
            ),
            myLocationEnabled: locationGranted,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onTap: (_) {
              if (selectedPin != null) {
                ref.read(mapNotifierProvider.notifier).selectPin(null);
              }
            },
          ),

          // 2. Search bar + filter chips (top overlay)
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
                  showNearMe: locationGranted,
                  onChanged: (f) =>
                      ref.read(mapNotifierProvider.notifier).setFilter(f),
                ),
              ],
            ),
          ),

          // 3. Loading indicator
          if (mapState.isLoading)
            const Center(child: CircularProgressIndicator()),

          // 4. Bottom sheet when a pin is selected
          if (selectedPin != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MapBottomSheet(pin: selectedPin),
            ),
        ],
      ),

      // 5. My location FAB
      floatingActionButton: FloatingActionButton.small(
        onPressed: _goToUserLocation,
        tooltip: 'موقعي',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

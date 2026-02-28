import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

class NearbyPlace {
  final String name;
  final String address;
  final String type;
  final LatLng latLng;

  const NearbyPlace({
    required this.name,
    required this.address,
    required this.type,
    required this.latLng,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MapScreen
// ─────────────────────────────────────────────────────────────────────────────

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  LatLng _currentCenter = const LatLng(20.5937, 78.9629);
  LatLng? _userLocation;
  LatLng? _selectedPlace;
  bool _isLoading = false;
  bool _showInfoSheet = false;
  bool _showNearbyPanel = false;
  bool _loadingNearby = false;
  String _mapStyle = 'Standard';
  double _currentZoom = 5.0;

  List<NearbyPlace> _nearbyPlaces = [];
  NearbyPlace? _highlightedPlace;

  static const Map<String, String> _tileUrls = {
    'Standard': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'Satellite':
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    'Terrain': 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
  };

  // ─── Animate camera ───────────────────────────────────────────────────────
  void _animateTo(LatLng target, {double zoom = 15.0}) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: target.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: target.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: zoom,
    );

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });
    controller.addStatusListener((s) {
      if (s == AnimationStatus.completed || s == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  // ─── Fetch nearby places via Overpass API ─────────────────────────────────
  Future<void> _fetchNearbyPlaces(LatLng center) async {
    setState(() {
      _loadingNearby = true;
      _nearbyPlaces = [];
      _showNearbyPanel = true;
    });

    try {
      final lat = center.latitude;
      final lng = center.longitude;
      const radius = 1000;

      // Overpass QL query: only farmland (nodes, ways, relations) within radius
      final query = '''
[out:json][timeout:25];
(
  node["landuse"="farmland"](around:$radius,$lat,$lng);
  way["landuse"="farmland"](around:$radius,$lat,$lng);
  relation["landuse"="farmland"](around:$radius,$lat,$lng);
);
out center 40;
''';

      final uri = Uri.parse('https://overpass-api.de/api/interpreter');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'data=${Uri.encodeComponent(query)}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List<dynamic>;

        final places = <NearbyPlace>[];
        for (final el in elements) {
          final tags = el['tags'] as Map<String, dynamic>? ?? {};

          // Ways/relations return a 'center' object; nodes have lat/lon
          double? elLat;
          double? elLon;
          if (el['lat'] != null && el['lon'] != null) {
            elLat = (el['lat'] as num).toDouble();
            elLon = (el['lon'] as num).toDouble();
          } else if (el['center'] != null) {
            elLat = (el['center']['lat'] as num?)?.toDouble();
            elLon = (el['center']['lon'] as num?)?.toDouble();
          }
          if (elLat == null || elLon == null) continue;

          // Farmlands often have no name — provide a sensible default
          final name = tags['name'] as String? ??
              tags['ref'] as String? ??
              'Farmland';

          final type = _formatType((tags['landuse'] as String?) ?? 'farmland');

          final address =
              '~${_distanceStr(center, LatLng(elLat, elLon))} away';

          places.add(
            NearbyPlace(
              name: name,
              address: address,
              type: type,
              latLng: LatLng(elLat, elLon),
            ),
          );
        }

        setState(() {
          _nearbyPlaces = places;
          _loadingNearby = false;
        });
      } else {
        setState(() => _loadingNearby = false);
        _snack('Could not load nearby places.', error: true);
      }
    } catch (e) {
      setState(() => _loadingNearby = false);
      _snack('Error loading nearby places: $e', error: true);
    }
  }

  String _formatType(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }

  String _distanceStr(LatLng a, LatLng b) {
    final dist = const Distance().as(LengthUnit.Meter, a, b);
    return dist >= 1000
        ? '${(dist / 1000).toStringAsFixed(1)} km'
        : '${dist.toStringAsFixed(0)} m';
  }

  // ─── Get user location ────────────────────────────────────────────────────
  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
      _showInfoSheet = false;
      _showNearbyPanel = false;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _snack('Location services are disabled.', error: true);
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _snack('Location permission denied.', error: true);
          setState(() => _isLoading = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _snack(
          'Permission permanently denied. Enable in Settings.',
          error: true,
        );
        setState(() => _isLoading = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _userLocation = loc;
        _currentCenter = loc;
        _isLoading = false;
        _showInfoSheet = true;
      });

      _animateTo(loc, zoom: 17.0);
      _fetchNearbyPlaces(loc);
    } catch (e) {
      setState(() => _isLoading = false);
      _snack('Error: ${e.toString()}', error: true);
    }
  }

  void _onPlaceTapped(NearbyPlace place) {
    setState(() {
      _highlightedPlace = place;
      _selectedPlace = place.latLng;
    });
    _animateTo(place.latLng, zoom: 18.0);
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor:
            error ? const Color(0xFFB00020) : const Color(0xFF137333),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _zoom(double delta) {
    final newZoom = (_mapController.camera.zoom + delta).clamp(2.0, 19.0);
    _mapController.move(_mapController.camera.center, newZoom);
    setState(() => _currentZoom = newZoom);
  }

  // ─── Marker color by type ─────────────────────────────────────────────────
  Color _typeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('restaurant') ||
        t.contains('food') ||
        t.contains('cafe') ||
        t.contains('bar')) {
      return const Color(0xFFE67E22);
    } else if (t.contains('hospital') ||
        t.contains('pharmacy') ||
        t.contains('clinic') ||
        t.contains('doctor')) {
      return const Color(0xFFE74C3C);
    } else if (t.contains('school') ||
        t.contains('university') ||
        t.contains('college')) {
      return const Color(0xFF9B59B6);
    } else if (t.contains('bank') ||
        t.contains('atm') ||
        t.contains('office')) {
      return const Color(0xFF2980B9);
    } else if (t.contains('shop') ||
        t.contains('supermarket') ||
        t.contains('store')) {
      return const Color(0xFF27AE60);
    } else if (t.contains('park') ||
        t.contains('leisure') ||
        t.contains('garden')) {
      return const Color(0xFF1ABC9C);
    } else if (t.contains('hotel') ||
        t.contains('tourism') ||
        t.contains('museum')) {
      return const Color(0xFFF39C12);
    }
    return const Color(0xFF1A73E8);
  }

  IconData _typeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('restaurant') || t.contains('food')) return Icons.restaurant;
    if (t.contains('cafe') || t.contains('coffee')) return Icons.local_cafe;
    if (t.contains('bar') || t.contains('pub')) return Icons.local_bar;
    if (t.contains('hospital') || t.contains('clinic'))
      return Icons.local_hospital;
    if (t.contains('pharmacy')) return Icons.local_pharmacy;
    if (t.contains('school') || t.contains('university')) return Icons.school;
    if (t.contains('bank') || t.contains('atm')) return Icons.account_balance;
    if (t.contains('shop') || t.contains('supermarket'))
      return Icons.shopping_bag;
    if (t.contains('park') || t.contains('garden')) return Icons.park;
    if (t.contains('hotel')) return Icons.hotel;
    if (t.contains('museum')) return Icons.museum;
    if (t.contains('fuel') || t.contains('gas')) return Icons.local_gas_station;
    if (t.contains('parking')) return Icons.local_parking;
    if (t.contains('place of worship') ||
        t.contains('church') ||
        t.contains('mosque'))
      return Icons.place;
    return Icons.place;
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPanelHeight = _showNearbyPanel ? 320.0 : 0.0;
    final infoSheetHeight = _showInfoSheet ? 160.0 : 0.0;
    final totalBottom = bottomPanelHeight + infoSheetHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: _currentZoom,
              onMapEvent: (event) {
                if (event is MapEventMove) {
                  setState(() => _currentZoom = event.camera.zoom);
                }
              },
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrls[_mapStyle]!,
                userAgentPackageName: 'com.example.flutter_map_app',
                maxNativeZoom: 19,
              ),
              // Nearby place markers
              MarkerLayer(
                markers: [
                  ..._nearbyPlaces.map((place) {
                    final isSelected = _highlightedPlace == place;
                    final color = _typeColor(place.type);
                    return Marker(
                      point: place.latLng,
                      width: isSelected ? 52 : 36,
                      height: isSelected ? 52 : 36,
                      child: GestureDetector(
                        onTap: () => _onPlaceTapped(place),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isSelected ? 52 : 36,
                          height: isSelected ? 52 : 36,
                          decoration: BoxDecoration(
                            color: isSelected ? color : color.withOpacity(0.85),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: isSelected ? 12 : 6,
                                spreadRadius: isSelected ? 2 : 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            _typeIcon(place.type),
                            color: Colors.white,
                            size: isSelected ? 26 : 18,
                          ),
                        ),
                      ),
                    );
                  }),
                  // User location marker
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 72,
                      height: 72,
                      child: const _PulsingMarker(),
                    ),
                ],
              ),
            ],
          ),

          // ── Search Bar ────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: _GoogleSearchBar(),
            ),
          ),

          // ── Right Controls ────────────────────────────────────────────────
          Positioned(
            right: 12,
            bottom: totalBottom + 120,
            child: Column(
              children: [
                _CircleButton(
                  child: const Icon(
                    Icons.layers_outlined,
                    color: Color(0xFF444444),
                    size: 22,
                  ),
                  onTap: _showLayerPicker,
                  tooltip: 'Map type',
                ),
                const SizedBox(height: 8),
                _CircleButton(
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF444444),
                    size: 22,
                  ),
                  onTap: () => _zoom(1),
                ),
                const SizedBox(height: 4),
                _CircleButton(
                  child: const Icon(
                    Icons.remove,
                    color: Color(0xFF444444),
                    size: 22,
                  ),
                  onTap: () => _zoom(-1),
                ),
              ],
            ),
          ),

          // ── My Location FAB ───────────────────────────────────────────────
          Positioned(
            right: 12,
            bottom: totalBottom + 60,
            child: _MyLocationFab(
              isLoading: _isLoading,
              isLocated: _userLocation != null,
              onTap: _fetchLocation,
            ),
          ),

          // ── Scale bar ─────────────────────────────────────────────────────
          Positioned(
            left: 16,
            bottom: totalBottom + 65,
            child: _ScaleBar(zoom: _currentZoom),
          ),

          // ── Map style badge ───────────────────────────────────────────────
          if (_mapStyle != 'Standard')
            Positioned(
              left: 12,
              bottom: totalBottom + 130,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _mapStyle == 'Satellite'
                          ? Icons.satellite_alt
                          : Icons.terrain,
                      size: 14,
                      color: const Color(0xFF1A73E8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _mapStyle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Info Sheet ────────────────────────────────────────────────────
          if (_showInfoSheet && _userLocation != null)
            Positioned(
              bottom: bottomPanelHeight,
              left: 0,
              right: 0,
              child: _LocationBottomSheet(
                location: _userLocation!,
                onClose: () => setState(() => _showInfoSheet = false),
                onNavigate: () => _animateTo(_userLocation!, zoom: 17),
              ),
            ),

          // ── Nearby Places Panel ───────────────────────────────────────────
          if (_showNearbyPanel)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 320,
              child: _NearbyPlacesPanel(
                places: _nearbyPlaces,
                loading: _loadingNearby,
                highlighted: _highlightedPlace,
                onPlaceTap: _onPlaceTapped,
                onClose:
                    () => setState(() {
                      _showNearbyPanel = false;
                      _highlightedPlace = null;
                      _selectedPlace = null;
                    }),
              ),
            ),
        ],
      ),
    );
  }

  void _showLayerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _LayerPickerSheet(
            current: _mapStyle,
            onSelect: (style) {
              setState(() => _mapStyle = style);
              Navigator.pop(context);
            },
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nearby Places Panel
// ─────────────────────────────────────────────────────────────────────────────

class _NearbyPlacesPanel extends StatelessWidget {
  final List<NearbyPlace> places;
  final bool loading;
  final NearbyPlace? highlighted;
  final ValueChanged<NearbyPlace> onPlaceTap;
  final VoidCallback onClose;

  const _NearbyPlacesPanel({
    required this.places,
    required this.loading,
    required this.highlighted,
    required this.onPlaceTap,
    required this.onClose,
  });

  Color _typeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('restaurant') ||
        t.contains('food') ||
        t.contains('cafe') ||
        t.contains('bar')) {
      return const Color(0xFFE67E22);
    } else if (t.contains('hospital') ||
        t.contains('pharmacy') ||
        t.contains('clinic') ||
        t.contains('doctor')) {
      return const Color(0xFFE74C3C);
    } else if (t.contains('school') || t.contains('university'))
      return const Color(0xFF9B59B6);
    if (t.contains('bank') || t.contains('atm') || t.contains('office'))
      return const Color(0xFF2980B9);
    if (t.contains('shop') || t.contains('supermarket'))
      return const Color(0xFF27AE60);
    if (t.contains('park') || t.contains('leisure'))
      return const Color(0xFF1ABC9C);
    if (t.contains('hotel') || t.contains('tourism') || t.contains('museum'))
      return const Color(0xFFF39C12);
    return const Color(0xFF1A73E8);
  }

  IconData _typeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('restaurant') || t.contains('food')) return Icons.restaurant;
    if (t.contains('cafe') || t.contains('coffee')) return Icons.local_cafe;
    if (t.contains('bar') || t.contains('pub')) return Icons.local_bar;
    if (t.contains('hospital') || t.contains('clinic'))
      return Icons.local_hospital;
    if (t.contains('pharmacy')) return Icons.local_pharmacy;
    if (t.contains('school') || t.contains('university')) return Icons.school;
    if (t.contains('bank') || t.contains('atm')) return Icons.account_balance;
    if (t.contains('shop') || t.contains('supermarket'))
      return Icons.shopping_bag;
    if (t.contains('park') || t.contains('garden')) return Icons.park;
    if (t.contains('hotel')) return Icons.hotel;
    if (t.contains('museum')) return Icons.museum;
    if (t.contains('fuel') || t.contains('gas')) return Icons.local_gas_station;
    if (t.contains('parking')) return Icons.local_parking;
    return Icons.place;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle + header
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDADADA),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
            child: Row(
              children: [
                const Icon(Icons.near_me, color: Color(0xFF1A73E8), size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Nearby (200 m)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF202124),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF80868B),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child:
                loading
                    ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF1A73E8),
                            strokeWidth: 2.5,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Fetching nearby places…',
                            style: TextStyle(
                              color: Color(0xFF80868B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                    : places.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_off,
                            color: Color(0xFFDADADA),
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No named places found within 200 m',
                            style: TextStyle(
                              color: Color(0xFF80868B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: places.length,
                      separatorBuilder:
                          (_, __) => const Divider(height: 1, indent: 68),
                      itemBuilder: (context, i) {
                        final place = places[i];
                        final isSelected = highlighted == place;
                        final color = _typeColor(place.type);

                        return InkWell(
                          onTap: () => onPlaceTap(place),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            color:
                                isSelected
                                    ? color.withOpacity(0.07)
                                    : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                // Icon badge
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    border:
                                        isSelected
                                            ? Border.all(color: color, width: 2)
                                            : null,
                                  ),
                                  child: Icon(
                                    _typeIcon(place.type),
                                    color: color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color:
                                              isSelected
                                                  ? color
                                                  : const Color(0xFF202124),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        place.type,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        place.address,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF80868B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // LatLng chip
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      place.latLng.latitude.toStringAsFixed(4),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFAAAAAA),
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    Text(
                                      place.latLng.longitude.toStringAsFixed(4),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFAAAAAA),
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.location_on,
                                        color: color,
                                        size: 14,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google-style Search Bar
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.menu, color: Color(0xFF444444), size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Search here',
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: const Color(0xFFE0E0E0),
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF1A73E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulsing marker
// ─────────────────────────────────────────────────────────────────────────────

class _PulsingMarker extends StatefulWidget {
  const _PulsingMarker();
  @override
  State<_PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<_PulsingMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulse = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder:
          (_, __) => Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 72 * _pulse.value,
                height: 72 * _pulse.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(
                    0xFF4285F4,
                  ).withOpacity((1 - _pulse.value) * 0.25),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4285F4).withOpacity(0.18),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4285F4),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4285F4).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circle Button
// ─────────────────────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final String? tooltip;

  const _CircleButton({required this.child, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My Location FAB
// ─────────────────────────────────────────────────────────────────────────────

class _MyLocationFab extends StatelessWidget {
  final bool isLoading;
  final bool isLocated;
  final VoidCallback onTap;

  const _MyLocationFab({
    required this.isLoading,
    required this.isLocated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child:
            isLoading
                ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                )
                : Icon(
                  isLocated ? Icons.my_location : Icons.location_searching,
                  color:
                      isLocated
                          ? const Color(0xFF1A73E8)
                          : const Color(0xFF666666),
                  size: 22,
                ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Location Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _LocationBottomSheet extends StatelessWidget {
  final LatLng location;
  final VoidCallback onClose;
  final VoidCallback onNavigate;

  const _LocationBottomSheet({
    required this.location,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDADADA),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Color(0xFF1A73E8),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your location',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF202124),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF80868B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF80868B),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 20, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                _SheetActionButton(
                  icon: Icons.navigation_rounded,
                  label: 'Directions',
                  primary: true,
                  onTap: onNavigate,
                ),
                const SizedBox(width: 12),
                _SheetActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _SheetActionButton(
                  icon: Icons.bookmark_border_rounded,
                  label: 'Save',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _SheetActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  primary ? const Color(0xFF1A73E8) : const Color(0xFFF1F3F4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primary ? Colors.white : const Color(0xFF1A73E8),
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Layer Picker
// ─────────────────────────────────────────────────────────────────────────────

class _LayerPickerSheet extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelect;

  const _LayerPickerSheet({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final styles = [
      {'name': 'Standard', 'icon': Icons.map_outlined},
      {'name': 'Satellite', 'icon': Icons.satellite_alt},
      {'name': 'Terrain', 'icon': Icons.terrain},
    ];

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Map type',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF202124),
                ),
              ),
            ),
          ),
          const Divider(),
          ...styles.map((s) {
            final name = s['name'] as String;
            final icon = s['icon'] as IconData;
            final selected = name == current;
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      selected
                          ? const Color(0xFFE8F0FE)
                          : const Color(0xFFF1F3F4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color:
                      selected
                          ? const Color(0xFF1A73E8)
                          : const Color(0xFF666666),
                  size: 20,
                ),
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      selected
                          ? const Color(0xFF1A73E8)
                          : const Color(0xFF202124),
                ),
              ),
              trailing:
                  selected
                      ? const Icon(Icons.check_circle, color: Color(0xFF1A73E8))
                      : null,
              onTap: () => onSelect(name),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scale Bar
// ─────────────────────────────────────────────────────────────────────────────

class _ScaleBar extends StatelessWidget {
  final double zoom;
  const _ScaleBar({required this.zoom});

  String _scaleLabel() {
    final metersPerPx = 156543.03 / (1 << zoom.round());
    final barMeters = metersPerPx * 60;
    if (barMeters >= 1000) return '${(barMeters / 1000).toStringAsFixed(0)} km';
    return '${barMeters.toStringAsFixed(0)} m';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _scaleLabel(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF555555),
            shadows: [Shadow(color: Colors.white, blurRadius: 4)],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF555555),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 2),
            ],
          ),
        ),
      ],
    );
  }
}

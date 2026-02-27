import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MapScreen — Google Maps-style UI using flutter_map + OpenStreetMap
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
  bool _isLoading = false;
  bool _showInfoSheet = false;
  String _mapStyle = 'Standard'; // Standard / Satellite / Terrain
  double _currentZoom = 5.0;

  // Tile URLs for different styles
  static const Map<String, String> _tileUrls = {
    'Standard': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'Satellite':
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    'Terrain': 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
  };

  // ─── Animate camera ────────────────────────────────────────────────────────
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

  // ─── Get location ──────────────────────────────────────────────────────────
  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
      _showInfoSheet = false;
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

      _animateTo(loc, zoom: 15.0);
    } catch (e) {
      setState(() => _isLoading = false);
      _snack('Error: ${e.toString()}', error: true);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Map ─────────────────────────────────────────────────────────────
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
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
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

          // ── Search Bar (top) ─────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: _GoogleSearchBar(),
            ),
          ),

          // ── Right-side Controls ──────────────────────────────────────────────
          Positioned(
            right: 12,
            bottom: _showInfoSheet ? 230 : 120,
            child: Column(
              children: [
                // Layers button
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
                // Zoom in
                _CircleButton(
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF444444),
                    size: 22,
                  ),
                  onTap: () => _zoom(1),
                ),
                const SizedBox(height: 4),
                // Zoom out
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

          // ── My Location FAB ──────────────────────────────────────────────────
          Positioned(
            right: 12,
            bottom: _showInfoSheet ? 170 : 60,
            child: _MyLocationFab(
              isLoading: _isLoading,
              isLocated: _userLocation != null,
              onTap: _fetchLocation,
            ),
          ),

          // ── Bottom Info Sheet ────────────────────────────────────────────────
          if (_showInfoSheet && _userLocation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _LocationBottomSheet(
                location: _userLocation!,
                onClose: () => setState(() => _showInfoSheet = false),
                onNavigate: () {
                  _animateTo(_userLocation!, zoom: 17);
                },
              ),
            ),

          // ── Map style badge ─────────────────────────────────────────────────
          if (_mapStyle != 'Standard')
            Positioned(
              left: 12,
              bottom: _showInfoSheet ? 235 : 125,
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

          // ── Scale indicator ──────────────────────────────────────────────────
          Positioned(
            left: 16,
            bottom: _showInfoSheet ? 240 : 130,
            child: _ScaleBar(zoom: _currentZoom),
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
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8),
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
// Pulsing user location marker
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
              // Accuracy ring pulse
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
              // Blue accuracy circle (static)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4285F4).withOpacity(0.18),
                ),
              ),
              // White border + blue dot
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
// Circle icon button (zoom / layers)
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
// My Location FAB (Google-style blue when located)
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
// Bottom sheet that appears when location is found
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
          // Handle bar
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

          // Action buttons (Google Maps style)
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
// Layer Picker Bottom Sheet
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
// Simple Scale Bar
// ─────────────────────────────────────────────────────────────────────────────

class _ScaleBar extends StatelessWidget {
  final double zoom;
  const _ScaleBar({required this.zoom});

  String _scaleLabel() {
    // Rough scale approximation at equator
    final metersPerPx = 156543.03 / (1 << zoom.round());
    final barMeters = metersPerPx * 60; // 60px bar
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

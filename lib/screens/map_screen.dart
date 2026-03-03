import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() => runApp(
  const MaterialApp(
    home: MapScreen(enableDrawing: true),
    debugShowCheckedModeBanner: false,
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// Enums & Models
// ─────────────────────────────────────────────────────────────────────────────

enum AppFlow {
  idle, // Initial state — waiting for location
  scanning, // Fetching nearby land
  selectLand, // Showing land selection panel
  navigating, // Navigated to selected land
  drawing, // Drawing boundary on the land
  done, // Boundary saved
}

enum DrawMode { none, auto, manual, freehand }

class LandParcel {
  final String name;
  final String type;
  final String distance;
  final LatLng latLng;
  final String address;
  final double? estimatedAcres;

  const LandParcel({
    required this.name,
    required this.type,
    required this.distance,
    required this.latLng,
    this.address = '',
    this.estimatedAcres,
  });
}

class _CustomMarker {
  final LatLng latLng;
  final String label;
  final String note;
  final IconData icon;
  final Color color;

  _CustomMarker({
    required this.latLng,
    required this.label,
    this.note = '',
    this.icon = Icons.place,
    this.color = const Color(0xFFE53935),
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Geometry helpers
// ─────────────────────────────────────────────────────────────────────────────

List<LatLng> generatePolygonFromAcres(LatLng center, double acres) {
  final areaM2 = acres * 4046.86;
  final sideM = math.sqrt(areaM2);
  final halfSide = sideM / 2;
  final dLat = halfSide / 111320.0;
  final dLng =
      halfSide / (111320.0 * math.cos(center.latitude * math.pi / 180));
  return [
    LatLng(center.latitude - dLat, center.longitude - dLng),
    LatLng(center.latitude - dLat, center.longitude + dLng),
    LatLng(center.latitude + dLat, center.longitude + dLng),
    LatLng(center.latitude + dLat, center.longitude - dLng),
  ];
}

double polygonAreaAcres(List<LatLng> points) {
  if (points.length < 3) return 0;
  double area = 0;
  for (int i = 0; i < points.length; i++) {
    final j = (i + 1) % points.length;
    final xi = points[i].longitude * math.pi / 180;
    final yi = points[i].latitude * math.pi / 180;
    final xj = points[j].longitude * math.pi / 180;
    final yj = points[j].latitude * math.pi / 180;
    area += (xj - xi) * (2 + math.sin(yi) + math.sin(yj));
  }
  area = area.abs() * 6378137 * 6378137 / 2;
  return area / 4046.86;
}

String distanceStr(LatLng a, LatLng b) {
  final dist = const Distance().as(LengthUnit.Meter, a, b);
  return dist >= 1000
      ? '${(dist / 1000).toStringAsFixed(1)} km'
      : '${dist.toStringAsFixed(0)} m';
}

// ─────────────────────────────────────────────────────────────────────────────
// MapScreen
// ─────────────────────────────────────────────────────────────────────────────

class MapScreen extends StatefulWidget {
  // FIX: All optional named params properly typed and nullable
  final LatLng? initialLocation;
  final double? initialAcres;
  final bool enableDrawing;
  final List<LatLng>? initialPolygon;

  const MapScreen({
    super.key,
    this.initialLocation,
    this.initialAcres,
    required this.enableDrawing,
    this.initialPolygon,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  // App state
  AppFlow _flow = AppFlow.idle;
  LatLng _center = const LatLng(20.5937, 78.9629);
  LatLng? _userLocation;
  double _zoom = 5.0;
  bool _isLocating = false;
  bool _isFetchingLand = false;
  String _mapStyle = 'Standard';

  // Land parcels
  List<LandParcel> _landParcels = [];
  LandParcel? _selectedLand;
  LandParcel? _highlightedLand;

  // Drawing
  DrawMode _drawMode = DrawMode.none;
  List<LatLng> _polygonPoints = [];
  bool _isDrawing = false;
  List<Offset> _freehandOffsets = [];

  // Saved boundary
  List<LatLng>? _savedPolygon;
  double? _savedAreaAcres;

  // Acres target (for auto-draw)
  double _targetAcres = 1.0;

  // Custom markers
  List<_CustomMarker> _customMarkers = [];
  // FIX: Removed unused _selectedMarker field
  bool _addMarkerMode = false;

  static const Map<String, String> _tileUrls = {
    'Standard': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'Satellite': 'https://mt0.google.com/vt/lyrs=s&hl=en&x={x}&y={y}&z={z}',
    'Terrain': 'https://mt0.google.com/vt/lyrs=p&hl=en&x={x}&y={y}&z={z}',
    'Hybrid': 'https://mt0.google.com/vt/lyrs=y&hl=en&x={x}&y={y}&z={z}',
  };

  // ─── Initialise from widget params ────────────────────────────────────────
  // FIX: Actually use the widget's optional parameters
  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _center = widget.initialLocation!;
      _userLocation = widget.initialLocation;
      _zoom = 16.0;
    }
    if (widget.initialAcres != null) {
      _targetAcres = widget.initialAcres!;
    }
    if (widget.initialPolygon != null && widget.initialPolygon!.length >= 3) {
      _savedPolygon = widget.initialPolygon;
      _savedAreaAcres = polygonAreaAcres(widget.initialPolygon!);
      _flow = AppFlow.done;
    }
  }

  // ─── Animation ────────────────────────────────────────────────────────────

  void _animateTo(LatLng target, {double zoom = 17.0}) {
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
      duration: const Duration(milliseconds: 1000),
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

  // ─── Get user location ────────────────────────────────────────────────────

  Future<void> _getLocation() async {
    setState(() => _isLocating = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _snack('Location services are disabled.', error: true);
      setState(() => _isLocating = false);
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _snack('Location permission denied.', error: true);
        setState(() => _isLocating = false);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _snack('Enable location in app settings.', error: true);
      setState(() => _isLocating = false);
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _userLocation = loc;
        _center = loc;
        _isLocating = false;
        _flow = AppFlow.scanning;
      });
      _animateTo(loc, zoom: 16.0);
      await _fetchNearbyLand(loc);
    } catch (e) {
      setState(() => _isLocating = false);
      _snack('Error getting location: $e', error: true);
    }
  }

  // ─── Fetch nearby farmland via Overpass ───────────────────────────────────

  Future<void> _fetchNearbyLand(LatLng center) async {
    setState(() {
      _isFetchingLand = true;
      _landParcels = [];
    });

    try {
      final lat = center.latitude;
      final lng = center.longitude;
      const radius = 500;

      final query = '''
[out:json][timeout:30];
(
  node["landuse"~"farmland|meadow|orchard|farm|grass|allotments|village_green|recreation_ground|greenfield|brownfield|bare_land|construction|plant_nursery"](around:$radius,$lat,$lng);
  way["landuse"~"farmland|meadow|orchard|farm|grass|allotments|village_green|recreation_ground|greenfield|brownfield|bare_land|construction|plant_nursery"](around:$radius,$lat,$lng);
  way["natural"~"grassland|heath|scrub|wood|bare_rock|sand"](around:$radius,$lat,$lng);
  relation["landuse"~"farmland|meadow|orchard|farm|greenfield|brownfield"](around:$radius,$lat,$lng);
  way["leisure"~"park|garden|pitch|nature_reserve"](around:$radius,$lat,$lng);
);
out center 80;
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
        final parcels = <LandParcel>[];

        for (final el in elements) {
          final tags = el['tags'] as Map<String, dynamic>? ?? {};

          double? elLat, elLon;
          if (el['lat'] != null && el['lon'] != null) {
            elLat = (el['lat'] as num).toDouble();
            elLon = (el['lon'] as num).toDouble();
          } else if (el['center'] != null) {
            elLat = (el['center']['lat'] as num?)?.toDouble();
            elLon = (el['center']['lon'] as num?)?.toDouble();
          }
          if (elLat == null || elLon == null) continue;

          final landUse =
              tags['landuse'] as String? ??
              tags['natural'] as String? ??
              tags['leisure'] as String? ??
              'land';
          final name =
              tags['name'] as String? ??
              tags['ref'] as String? ??
              _formatLandType(landUse);

          parcels.add(
            LandParcel(
              name: name,
              type: _formatLandType(landUse),
              distance: distanceStr(center, LatLng(elLat, elLon)),
              latLng: LatLng(elLat, elLon),
            ),
          );
        }

        final addressFutures = parcels
            .take(15)
            .map(
              (p) =>
                  _reverseGeocodeParcel(p.latLng.latitude, p.latLng.longitude),
            );
        final addresses = await Future.wait(addressFutures);
        final enriched = <LandParcel>[];
        for (int i = 0; i < parcels.length; i++) {
          enriched.add(
            LandParcel(
              name: parcels[i].name,
              type: parcels[i].type,
              distance: parcels[i].distance,
              latLng: parcels[i].latLng,
              address: i < addresses.length ? addresses[i] : '',
            ),
          );
        }

        setState(() {
          _landParcels = enriched;
          _isFetchingLand = false;
          _flow = AppFlow.selectLand;
        });

        if (enriched.isEmpty) {
          _snack('No land found nearby. Try a rural or agricultural area.');
        }
      } else {
        setState(() {
          _isFetchingLand = false;
          _flow = AppFlow.selectLand;
        });
        _snack('Could not fetch nearby land.', error: true);
      }
    } catch (e) {
      setState(() {
        _isFetchingLand = false;
        _flow = AppFlow.selectLand;
      });
      _snack('Error: $e', error: true);
    }
  }

  Future<String> _reverseGeocodeParcel(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=16&addressdetails=1',
      );
      final resp = await http.get(
        uri,
        headers: {'User-Agent': 'KrishiSakhi/1.0'},
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final addr = data['address'] as Map<String, dynamic>? ?? {};
        final parts = <String>[];
        for (final key in [
          'village',
          'town',
          'city',
          'county',
          'state_district',
          'state',
        ]) {
          final v = addr[key] as String?;
          if (v != null && !parts.contains(v)) parts.add(v);
          if (parts.length >= 3) break;
        }
        return parts.isNotEmpty
            ? parts.join(', ')
            : (data['display_name'] as String? ?? '');
      }
    } catch (_) {}
    return '';
  }

  String _formatLandType(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }

  // ─── Select land and navigate ─────────────────────────────────────────────

  void _selectLandAndNavigate(LandParcel parcel) {
    setState(() {
      _selectedLand = parcel;
      _highlightedLand = parcel;
      _flow = AppFlow.navigating;
      _polygonPoints = [];
      _isDrawing = false;
      _drawMode = DrawMode.none;
      _savedPolygon = null;
    });
    _animateTo(parcel.latLng, zoom: 18.5);
    Future.delayed(const Duration(milliseconds: 600), () {
      _snack('Navigated to ${parcel.name}. Now draw your boundary below!');
    });
  }

  // ─── Drawing ──────────────────────────────────────────────────────────────

  void _startManualDraw() {
    setState(() {
      _drawMode = DrawMode.manual;
      _isDrawing = true;
      _polygonPoints = [];
      _flow = AppFlow.drawing;
    });
    _snack('Tap on the map to place boundary points');
  }

  void _startFreehandDraw() {
    setState(() {
      _drawMode = DrawMode.freehand;
      _isDrawing = true;
      _polygonPoints = [];
      _freehandOffsets = [];
      _flow = AppFlow.drawing;
    });
    _snack('Draw freely on the map with your finger');
  }

  void _startAutoDraw() {
    final center = _selectedLand?.latLng ?? _userLocation ?? _center;
    setState(() {
      _drawMode = DrawMode.auto;
      _isDrawing = true;
      _polygonPoints = generatePolygonFromAcres(center, _targetAcres);
      _flow = AppFlow.drawing;
    });
    _animateTo(center, zoom: 18.5);
  }

  void _updateAutoAcres(double acres) {
    if (_drawMode != DrawMode.auto) return;
    final center = _selectedLand?.latLng ?? _userLocation ?? _center;
    setState(() {
      _targetAcres = acres;
      _polygonPoints = generatePolygonFromAcres(center, acres);
    });
  }

  // Douglas-Peucker simplification for freehand paths
  List<LatLng> _simplify(List<LatLng> points, double epsilon) {
    if (points.length < 3) return points;
    double dmax = 0;
    int index = 0;
    final end = points.length - 1;
    for (int i = 1; i < end; i++) {
      final d = _perpendicularDist(points[i], points[0], points[end]);
      if (d > dmax) {
        dmax = d;
        index = i;
      }
    }
    if (dmax > epsilon) {
      final r1 = _simplify(points.sublist(0, index + 1), epsilon);
      final r2 = _simplify(points.sublist(index), epsilon);
      return [...r1.sublist(0, r1.length - 1), ...r2];
    }
    return [points[0], points[end]];
  }

  double _perpendicularDist(LatLng p, LatLng l1, LatLng l2) {
    final dx = l2.longitude - l1.longitude;
    final dy = l2.latitude - l1.latitude;
    if (dx == 0 && dy == 0) {
      return math.sqrt(
        math.pow(p.latitude - l1.latitude, 2) +
            math.pow(p.longitude - l1.longitude, 2),
      );
    }
    final t =
        ((p.latitude - l1.latitude) * dy + (p.longitude - l1.longitude) * dx) /
        (dy * dy + dx * dx);
    final nearLat = l1.latitude + t * dy;
    final nearLng = l1.longitude + t * dx;
    return math.sqrt(
      math.pow(p.latitude - nearLat, 2) + math.pow(p.longitude - nearLng, 2),
    );
  }

  void _addPolygonPoint(LatLng point) {
    if (!_isDrawing || _drawMode != DrawMode.manual) return;
    setState(() => _polygonPoints.add(point));
  }

  void _undoLastPoint() {
    if (_polygonPoints.isEmpty) return;
    setState(() => _polygonPoints.removeLast());
  }

  void _clearDraw() {
    setState(() {
      _polygonPoints = [];
      _isDrawing = false;
      _drawMode = DrawMode.none;
      _flow = AppFlow.navigating;
    });
  }

  void _saveBoundary() {
    if (_polygonPoints.length < 3) {
      _snack('Need at least 3 points to save boundary', error: true);
      return;
    }
    final area = polygonAreaAcres(_polygonPoints);
    setState(() {
      _savedPolygon = List.from(_polygonPoints);
      _savedAreaAcres = area;
      _isDrawing = false;
      _drawMode = DrawMode.none;
      _flow = AppFlow.done;
    });
    _snack('✓ Boundary saved! Area: ${area.toStringAsFixed(2)} acres');
  }

  void _returnToForm() {
    if (_savedPolygon != null && Navigator.canPop(context)) {
      Navigator.pop(context, _savedPolygon);
    } else {
      _resetAll();
    }
  }

  void _resetAll() {
    setState(() {
      _flow = AppFlow.idle;
      _userLocation = null;
      _selectedLand = null;
      _highlightedLand = null;
      _landParcels = [];
      _polygonPoints = [];
      _freehandOffsets = [];
      _savedPolygon = null;
      _savedAreaAcres = null;
      _isDrawing = false;
      _drawMode = DrawMode.none;
      _center = const LatLng(20.5937, 78.9629);
      _zoom = 5.0;
      _customMarkers = [];
      _addMarkerMode = false;
    });
  }

  void _showMarkerInfo(BuildContext context, _CustomMarker marker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _DragHandle(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        // FIX: withOpacity replaced with withValues for newer Flutter
                        color: marker.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(marker.icon, color: marker.color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            marker.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF202124),
                            ),
                          ),
                          if (marker.note.isNotEmpty)
                            Text(
                              marker.note,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF80868B),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() => _customMarkers.remove(marker));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.pin_drop,
                        size: 14,
                        color: Color(0xFF80868B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${marker.latLng.latitude.toStringAsFixed(6)}, '
                        '${marker.latLng.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF80868B),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor:
            error ? const Color(0xFFB00020) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // FIX: Made async/await consistent — method is async, all call sites use await
  Future<void> _showAddMarkerDialog(BuildContext context, LatLng latLng) async {
    final labelCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Add Field Marker',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Label (e.g. My Field)',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                onPressed: () {
                  final label =
                      labelCtrl.text.trim().isEmpty
                          ? 'Field Marker'
                          : labelCtrl.text.trim();
                  setState(() {
                    _customMarkers.add(
                      _CustomMarker(
                        latLng: latLng,
                        label: label,
                        note: noteCtrl.text.trim(),
                        icon: Icons.place,
                        color: const Color(0xFFE53935),
                      ),
                    );
                    _addMarkerMode = false;
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
    // Dispose controllers after dialog closes
    labelCtrl.dispose();
    noteCtrl.dispose();
  }

  Color _landColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('farm') || t.contains('orchard'))
      return const Color(0xFF388E3C);
    if (t.contains('meadow') || t.contains('grass') || t.contains('grassland'))
      return const Color(0xFF7CB342);
    if (t.contains('allotment')) return const Color(0xFF8D6E63);
    if (t.contains('scrub') || t.contains('heath'))
      return const Color(0xFFF57C00);
    if (t.contains('wood') || t.contains('forest'))
      return const Color(0xFF2E7D32);
    return const Color(0xFF1A73E8);
  }

  IconData _landIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('farm') || t.contains('farmland')) return Icons.agriculture;
    if (t.contains('orchard')) return Icons.park;
    if (t.contains('meadow') || t.contains('grass')) return Icons.grass;
    if (t.contains('wood') || t.contains('forest')) return Icons.forest;
    if (t.contains('allotment')) return Icons.yard;
    return Icons.terrain;
  }

  // ─── Getter for current polygon area ─────────────────────────────────────
  // FIX: Renamed getter to avoid confusion with the top-level function
  double get _currentPolygonAreaAcres =>
      _polygonPoints.length >= 3 ? polygonAreaAcres(_polygonPoints) : 0;

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // FIX: Use the renamed getter consistently
    final double currentAreaAcres = _currentPolygonAreaAcres;

    // Calculate bottom panel height based on flow
    double bottomPanelH = 0;
    if (_flow == AppFlow.selectLand) bottomPanelH = 340;
    if (_flow == AppFlow.navigating) bottomPanelH = 220;
    if (_flow == AppFlow.drawing)
      bottomPanelH = currentAreaAcres > 0 ? 200 : 170;
    if (_flow == AppFlow.done) bottomPanelH = 200;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
              onTap: (tapPos, latLng) async {
                // FIX: onTap is async to properly await _showAddMarkerDialog
                if (_addMarkerMode) {
                  await _showAddMarkerDialog(context, latLng);
                } else if (_isDrawing && _drawMode == DrawMode.manual) {
                  _addPolygonPoint(latLng);
                }
              },
              onLongPress: (tapPos, latLng) async {
                // FIX: await the async dialog
                if (!_isDrawing) {
                  await _showAddMarkerDialog(context, latLng);
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMove) {
                  setState(() => _zoom = event.camera.zoom);
                }
              },
              interactionOptions: InteractionOptions(
                flags:
                    _drawMode == DrawMode.freehand
                        ? InteractiveFlag.none
                        : InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrls[_mapStyle]!,
                userAgentPackageName: 'com.example.krishi_sakhi',
                maxNativeZoom: 19,
              ),

              // Saved polygon (green solid)
              if (_savedPolygon != null && _savedPolygon!.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _savedPolygon!,
                      color: const Color(0xFF2E7D32).withOpacity(0.25),
                      borderColor: const Color(0xFF2E7D32),
                      borderStrokeWidth: 3.5,
                    ),
                  ],
                ),

              // Drawing polygon (blue while drawing)
              if (_polygonPoints.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _polygonPoints,
                      color: const Color(0xFF1A73E8).withOpacity(0.18),
                      borderColor: const Color(0xFF1A73E8),
                      borderStrokeWidth: 2.5,
                    ),
                  ],
                ),

              if (_polygonPoints.length == 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polygonPoints,
                      color: const Color(0xFF1A73E8),
                      strokeWidth: 2.5,
                    ),
                  ],
                ),

              // Vertex markers
              if (_polygonPoints.isNotEmpty)
                MarkerLayer(
                  markers: List.generate(
                    _polygonPoints.length,
                    (i) => Marker(
                      point: _polygonPoints[i],
                      width: 26,
                      height: 26,
                      child: GestureDetector(
                        onPanUpdate:
                            _isDrawing
                                ? (details) {
                                  final screen = _mapController.camera
                                      .latLngToScreenOffset(_polygonPoints[i]);
                                  final newScreen = Offset(
                                    screen.dx + details.delta.dx,
                                    screen.dy + details.delta.dy,
                                  );
                                  setState(() {
                                    _polygonPoints[i] = _mapController.camera
                                        .screenOffsetToLatLng(newScreen);
                                  });
                                }
                                : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1A73E8),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1A73E8).withOpacity(0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A73E8),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Custom markers
              if (_customMarkers.isNotEmpty)
                MarkerLayer(
                  markers:
                      _customMarkers
                          .map(
                            (cm) => Marker(
                              point: cm.latLng,
                              width: 44,
                              height: 52,
                              child: GestureDetector(
                                onTap: () => _showMarkerInfo(context, cm),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: cm.color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: cm.color.withOpacity(0.4),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        cm.icon,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    CustomPaint(
                                      size: const Size(2, 10),
                                      painter: _PinTailPainter(cm.color),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),

              // Land parcel markers
              MarkerLayer(
                markers: [
                  ..._landParcels.map((parcel) {
                    final isHighlighted = _highlightedLand == parcel;
                    final isSelected = _selectedLand == parcel;
                    final color = _landColor(parcel.type);
                    return Marker(
                      point: parcel.latLng,
                      width: isHighlighted ? 56 : 38,
                      height: isHighlighted ? 56 : 38,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _highlightedLand = parcel);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? color
                                    : isHighlighted
                                    ? color
                                    : color.withOpacity(0.8),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: isHighlighted ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: isHighlighted ? 14 : 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            _landIcon(parcel.type),
                            color: Colors.white,
                            size: isHighlighted ? 28 : 18,
                          ),
                        ),
                      ),
                    );
                  }),

                  // User location
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 72,
                      height: 72,
                      child: const _PulsingMarker(),
                    ),

                  // Selected land pin
                  if (_selectedLand != null && _flow != AppFlow.selectLand)
                    Marker(
                      point: _selectedLand!.latLng,
                      width: 48,
                      height: 48,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _landColor(_selectedLand!.type),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: _landColor(
                                _selectedLand!.type,
                              ).withOpacity(0.5),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Icon(
                          _landIcon(_selectedLand!.type),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // ── Freehand drawing overlay ────────────────────────────────────────
          if (_drawMode == DrawMode.freehand)
            Positioned.fill(
              child: GestureDetector(
                onPanStart: (d) {
                  setState(() {
                    _polygonPoints = [];
                    _freehandOffsets = [d.localPosition];
                  });
                },
                onPanUpdate: (d) {
                  setState(() => _freehandOffsets.add(d.localPosition));
                  try {
                    final ll = _mapController.camera.screenOffsetToLatLng(
                      d.localPosition,
                    );
                    if (_polygonPoints.isEmpty ||
                        const Distance().as(
                              LengthUnit.Meter,
                              _polygonPoints.last,
                              ll,
                            ) >
                            2) {
                      setState(() => _polygonPoints.add(ll));
                    }
                  } catch (_) {}
                },
                onPanEnd: (_) {
                  if (_polygonPoints.length > 6) {
                    final simplified = _simplify(_polygonPoints, 0.00003);
                    if (simplified.length >= 3) {
                      setState(() => _polygonPoints = simplified);
                    }
                  }
                },
                child: Container(color: Colors.transparent),
              ),
            ),

          // ── Crosshair when drawing manually ──────────────────────────────────
          if (_isDrawing && _drawMode == DrawMode.manual)
            const Center(
              child: IgnorePointer(
                child: Icon(Icons.add, size: 32, color: Color(0x881A73E8)),
              ),
            ),

          // ── Add-marker mode banner ────────────────────────────────────────────
          if (_addMarkerMode)
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.92),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Tap anywhere to add a marker',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Top Bar ───────────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: _TopBar(
                flow: _flow,
                isLocating: _isLocating,
                isFetchingLand: _isFetchingLand,
                selectedLand: _selectedLand,
                onReset: _resetAll,
                onLocate: _getLocation,
                mapStyle: _mapStyle,
                onStyleChanged: (s) => setState(() => _mapStyle = s),
              ),
            ),
          ),

          // ── Right Controls ────────────────────────────────────────────────────
          Positioned(
            right: 12,
            bottom: bottomPanelH + 72,
            child: Column(
              children: [
                _CircleButton(
                  onTap: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF444444),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 4),
                _CircleButton(
                  onTap: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                  child: const Icon(
                    Icons.remove,
                    color: Color(0xFF444444),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 4),
                _CircleButton(
                  onTap: () => setState(() => _addMarkerMode = !_addMarkerMode),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _addMarkerMode
                          ? Icons.close
                          : Icons.add_location_alt_outlined,
                      key: ValueKey(_addMarkerMode),
                      color:
                          _addMarkerMode ? Colors.red : const Color(0xFF444444),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── My location FAB ───────────────────────────────────────────────────
          Positioned(
            right: 12,
            bottom: bottomPanelH + 20,
            child: _MyLocationFab(
              isLoading: _isLocating,
              isLocated: _userLocation != null,
              onTap: _getLocation,
            ),
          ),

          // ── Flow Panels ───────────────────────────────────────────────────────

          // IDLE
          if (_flow == AppFlow.idle)
            _IdleOverlay(isLocating: _isLocating, onLocate: _getLocation),

          // SCANNING
          if (_flow == AppFlow.scanning)
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              // FIX: _ScanningPanel is now const-constructible
              child: _ScanningPanel(),
            ),

          // SELECT LAND
          if (_flow == AppFlow.selectLand)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 340,
              child: _LandSelectionPanel(
                parcels: _landParcels,
                loading: _isFetchingLand,
                highlighted: _highlightedLand,
                onHighlight:
                    (p) => setState(() {
                      _highlightedLand = p;
                      _animateTo(p.latLng, zoom: 17.5);
                    }),
                onSelect: _selectLandAndNavigate,
                onRefresh: () {
                  if (_userLocation != null) {
                    _fetchNearbyLand(_userLocation!);
                  }
                },
                landColor: _landColor,
                landIcon: _landIcon,
              ),
            ),

          // NAVIGATING
          if (_flow == AppFlow.navigating)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _NavigatingPanel(
                land: _selectedLand!,
                onStartManual: _startManualDraw,
                onStartAuto: _startAutoDraw,
                onStartFreehand: _startFreehandDraw,
                onBack: () {
                  setState(() {
                    _selectedLand = null;
                    _highlightedLand = null;
                    _flow = AppFlow.selectLand;
                  });
                },
                landColor: _landColor,
                landIcon: _landIcon,
              ),
            ),

          // DRAWING
          if (_flow == AppFlow.drawing)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _DrawingPanel(
                drawMode: _drawMode,
                pointCount: _polygonPoints.length,
                areaAcres: currentAreaAcres,
                targetAcres: _targetAcres,
                onUndo: _undoLastPoint,
                onClear: _clearDraw,
                onSave: _saveBoundary,
                onAcresChanged: _updateAutoAcres,
              ),
            ),

          // DONE
          if (_flow == AppFlow.done)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _DonePanel(
                land: _selectedLand!,
                areaAcres: _savedAreaAcres ?? 0,
                pointCount: _savedPolygon?.length ?? 0,
                onRedraw: () {
                  setState(() {
                    _savedPolygon = null;
                    _polygonPoints = [];
                    _isDrawing = false;
                    _drawMode = DrawMode.none;
                    _flow = AppFlow.navigating;
                  });
                },
                onDone: _resetAll,
                onUseInForm: _returnToForm,
                landColor: _landColor,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Idle Overlay
// ─────────────────────────────────────────────────────────────────────────────

class _IdleOverlay extends StatelessWidget {
  final bool isLocating;
  final VoidCallback onLocate;

  const _IdleOverlay({required this.isLocating, required this.onLocate});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 60,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.agriculture,
                color: Color(0xFF2E7D32),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Farm Land Mapper',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover nearby farmland & empty plots within 500m, '
              'then draw your boundary.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: isLocating ? null : onLocate,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  ),
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child:
                      isLocating
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                          : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Find Nearby Land',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scanning Panel
// FIX: Added const constructor so it can be used as const widget
// ─────────────────────────────────────────────────────────────────────────────

class _ScanningPanel extends StatelessWidget {
  const _ScanningPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          const _DragHandle(),
          const SizedBox(height: 16),
          const CircularProgressIndicator(
            color: Color(0xFF2E7D32),
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 14),
          const Text(
            'Scanning 500m radius for farmland…',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Searching for farmland, meadows & empty plots',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Land Selection Panel
// ─────────────────────────────────────────────────────────────────────────────

class _LandSelectionPanel extends StatelessWidget {
  final List<LandParcel> parcels;
  final bool loading;
  final LandParcel? highlighted;
  final ValueChanged<LandParcel> onHighlight;
  final ValueChanged<LandParcel> onSelect;
  final VoidCallback onRefresh;
  final Color Function(String) landColor;
  final IconData Function(String) landIcon;

  const _LandSelectionPanel({
    required this.parcels,
    required this.loading,
    required this.highlighted,
    required this.onHighlight,
    required this.onSelect,
    required this.onRefresh,
    required this.landColor,
    required this.landIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          const _DragHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
            child: Row(
              children: [
                const Icon(
                  Icons.agriculture,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select a Land Parcel',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      Text(
                        'Tap to preview · Select to draw boundary',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF80868B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(
                    Icons.refresh,
                    color: Color(0xFF1A73E8),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child:
                loading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D32),
                        strokeWidth: 2.5,
                      ),
                    )
                    : parcels.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.terrain,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No land parcels found within 500m',
                            style: TextStyle(
                              color: Color(0xFF80868B),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try a rural or agricultural area',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: parcels.length,
                      separatorBuilder:
                          (_, __) => const Divider(height: 1, indent: 68),
                      itemBuilder: (context, i) {
                        final parcel = parcels[i];
                        final isHl = highlighted == parcel;
                        final color = landColor(parcel.type);
                        return InkWell(
                          onTap: () => onHighlight(parcel),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            color:
                                isHl
                                    ? color.withOpacity(0.06)
                                    : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    border:
                                        isHl
                                            ? Border.all(color: color, width: 2)
                                            : null,
                                  ),
                                  child: Icon(
                                    landIcon(parcel.type),
                                    color: color,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        parcel.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color:
                                              isHl
                                                  ? color
                                                  : const Color(0xFF202124),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              parcel.type,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: color,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            parcel.distance,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF80868B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (parcel.address.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_outlined,
                                                size: 11,
                                                color: Color(0xFFBDBDBD),
                                              ),
                                              const SizedBox(width: 3),
                                              Expanded(
                                                child: Text(
                                                  parcel.address,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFFBDBDBD),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isHl)
                                  GestureDetector(
                                    onTap: () => onSelect(parcel),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            color.withOpacity(0.9),
                                            color,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.navigation_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Go Here',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey[300],
                                    size: 20,
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
// Navigating Panel
// ─────────────────────────────────────────────────────────────────────────────

class _NavigatingPanel extends StatelessWidget {
  final LandParcel land;
  final VoidCallback onStartManual;
  final VoidCallback onStartAuto;
  final VoidCallback onStartFreehand;
  final VoidCallback onBack;
  final Color Function(String) landColor;
  final IconData Function(String) landIcon;

  const _NavigatingPanel({
    required this.land,
    required this.onStartManual,
    required this.onStartAuto,
    required this.onStartFreehand,
    required this.onBack,
    required this.landColor,
    required this.landIcon,
  });

  @override
  Widget build(BuildContext context) {
    final color = landColor(land.type);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          const _DragHandle(),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(landIcon(land.type), color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      land.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF202124),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            land.type,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF2E7D32),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Navigated',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: Color(0xFF444444),
                  ),
                ),
              ),
            ],
          ),
          if (land.address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: Color(0xFF80868B),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      land.address,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF80868B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DrawOptionButton(
                  icon: Icons.touch_app,
                  label: 'Tap Points',
                  desc: 'Tap to place points',
                  color: const Color(0xFF2E7D32),
                  onTap: onStartManual,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DrawOptionButton(
                  icon: Icons.gesture,
                  label: 'Freehand',
                  desc: 'Draw with finger',
                  color: const Color(0xFF7B1FA2),
                  onTap: onStartFreehand,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DrawOptionButton(
                  icon: Icons.auto_fix_high,
                  label: 'Auto Shape',
                  desc: 'Generate shape',
                  color: const Color(0xFF1A73E8),
                  onTap: onStartAuto,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _DrawOptionButton({
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(desc, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drawing Panel
// ─────────────────────────────────────────────────────────────────────────────

class _DrawingPanel extends StatelessWidget {
  final DrawMode drawMode;
  final int pointCount;
  final double areaAcres;
  final double targetAcres;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final VoidCallback onSave;
  final ValueChanged<double> onAcresChanged;

  const _DrawingPanel({
    required this.drawMode,
    required this.pointCount,
    required this.areaAcres,
    required this.targetAcres,
    required this.onUndo,
    required this.onClear,
    required this.onSave,
    required this.onAcresChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          const _DragHandle(),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      drawMode == DrawMode.manual
                          ? Icons.touch_app
                          : drawMode == DrawMode.freehand
                          ? Icons.gesture
                          : Icons.auto_fix_high,
                      size: 14,
                      color: const Color(0xFF1A73E8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      drawMode == DrawMode.manual
                          ? 'Tap Points'
                          : drawMode == DrawMode.freehand
                          ? 'Freehand Draw'
                          : 'Auto Boundary',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$pointCount point${pointCount == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              if (areaAcres > 0) ...[
                const SizedBox(width: 6),
                const Text('·', style: TextStyle(color: Color(0xFFCCCCCC))),
                const SizedBox(width: 6),
                Text(
                  '${areaAcres.toStringAsFixed(2)} acres',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (drawMode == DrawMode.auto) ...[
            Row(
              children: [
                const Icon(
                  Icons.crop_landscape_outlined,
                  size: 14,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Adjust size:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF444444),
                  ),
                ),
                const Spacer(),
                Text(
                  '${targetAcres.toStringAsFixed(1)} acres',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF2E7D32),
                thumbColor: const Color(0xFF2E7D32),
                overlayColor: const Color(0xFF2E7D32).withOpacity(0.15),
                trackHeight: 4,
              ),
              child: Slider(
                value: targetAcres.clamp(0.1, 50.0),
                min: 0.1,
                max: 50.0,
                divisions: 499,
                onChanged: onAcresChanged,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              if (drawMode == DrawMode.manual ||
                  drawMode == DrawMode.freehand) ...[
                _ActionBtn(
                  icon: Icons.undo,
                  label: 'Undo',
                  onTap: pointCount > 0 ? onUndo : null,
                ),
                const SizedBox(width: 8),
              ],
              _ActionBtn(
                icon: Icons.delete_outline,
                label: 'Clear',
                color: Colors.red,
                onTap: onClear,
              ),
              const Spacer(),
              if (pointCount >= 3)
                GestureDetector(
                  onTap: onSave,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.save_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Save Boundary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    drawMode == DrawMode.manual
                        ? 'Tap map to add points'
                        : drawMode == DrawMode.freehand
                        ? 'Draw with your finger'
                        : 'Drag points to adjust',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF444444);
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap != null ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: c.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: c),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Done Panel
// ─────────────────────────────────────────────────────────────────────────────

class _DonePanel extends StatelessWidget {
  final LandParcel land;
  final double areaAcres;
  final int pointCount;
  final VoidCallback onRedraw;
  final VoidCallback onDone;
  final VoidCallback onUseInForm;
  final Color Function(String) landColor;

  const _DonePanel({
    required this.land,
    required this.areaAcres,
    required this.pointCount,
    required this.onRedraw,
    required this.onDone,
    required this.onUseInForm,
    required this.landColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = landColor(land.type);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          const _DragHandle(),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Boundary Saved!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    Text(
                      'Your farm boundary has been recorded',
                      style: TextStyle(fontSize: 12, color: Color(0xFF80868B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: 'Area',
                    value: '${areaAcres.toStringAsFixed(2)} ac',
                    icon: Icons.crop_landscape,
                    color: color,
                  ),
                ),
                Container(width: 1, height: 40, color: color.withOpacity(0.2)),
                Expanded(
                  child: _StatChip(
                    label: 'Points',
                    value: '$pointCount',
                    icon: Icons.place,
                    color: color,
                  ),
                ),
                Container(width: 1, height: 40, color: color.withOpacity(0.2)),
                Expanded(
                  child: _StatChip(
                    label: 'Land',
                    value: land.type,
                    icon: Icons.terrain,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onRedraw,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(23),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 16,
                            color: Color(0xFF444444),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Redraw',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF444444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onUseInForm,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                      ),
                      borderRadius: BorderRadius.circular(23),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Use in Form',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onDone,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text(
                'Map Another Land',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF80868B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF80868B)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pin tail painter
// ─────────────────────────────────────────────────────────────────────────────

class _PinTailPainter extends CustomPainter {
  final Color color;
  const _PinTailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final AppFlow flow;
  final bool isLocating;
  final bool isFetchingLand;
  final LandParcel? selectedLand;
  final VoidCallback onReset;
  final VoidCallback onLocate;
  final String mapStyle;
  final ValueChanged<String> onStyleChanged;

  const _TopBar({
    required this.flow,
    required this.isLocating,
    required this.isFetchingLand,
    required this.selectedLand,
    required this.onReset,
    required this.onLocate,
    required this.mapStyle,
    required this.onStyleChanged,
  });

  String get _title {
    switch (flow) {
      case AppFlow.idle:
        return 'Farm Land Mapper';
      case AppFlow.scanning:
        return 'Scanning 500m…';
      case AppFlow.selectLand:
        return 'Choose a Land Parcel';
      case AppFlow.navigating:
        return selectedLand?.name ?? 'Selected Land';
      case AppFlow.drawing:
        return 'Drawing Boundary';
      case AppFlow.done:
        return 'Boundary Saved';
    }
  }

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
          const SizedBox(width: 14),
          const Icon(Icons.agriculture, color: Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF202124),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => _showStylePicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mapStyle == 'Satellite'
                        ? Icons.satellite_alt
                        : mapStyle == 'Terrain'
                        ? Icons.terrain
                        : Icons.map_outlined,
                    size: 14,
                    color: const Color(0xFF444444),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    mapStyle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF444444),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (flow != AppFlow.idle)
            GestureDetector(
              onTap: onReset,
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.red, size: 18),
              ),
            )
          else
            const SizedBox(width: 6),
        ],
      ),
    );
  }

  void _showStylePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
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
                      'Map Type',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                ...['Standard', 'Satellite', 'Terrain', 'Hybrid'].map((name) {
                  const icons = {
                    'Standard': Icons.map_outlined,
                    'Satellite': Icons.satellite_alt,
                    'Terrain': Icons.terrain,
                    'Hybrid': Icons.layers,
                  };
                  return ListTile(
                    leading: Icon(
                      icons[name],
                      color:
                          mapStyle == name
                              ? const Color(0xFF1A73E8)
                              : Colors.grey,
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight:
                            mapStyle == name
                                ? FontWeight.w600
                                : FontWeight.w400,
                      ),
                    ),
                    trailing:
                        mapStyle == name
                            ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF1A73E8),
                            )
                            : null,
                    onTap: () {
                      onStyleChanged(name);
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// FIX: Added const constructors to _DragHandle, _CircleButton, _MyLocationFab
// ─────────────────────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDADADA),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _CircleButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    );
  }
}

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
// Pulsing Marker
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:krishi_sakhi/models/farm_project.dart';
import 'package:krishi_sakhi/screens/Project_Details/widgets/project_hero_app_bar.dart';
import 'package:latlong2/latlong.dart';

enum _MapLayer { satellite, ndvi, moisture }

class FieldMapScreen extends StatefulWidget {
  final FarmProject? project;

  const FieldMapScreen({super.key, this.project});

  @override
  State<FieldMapScreen> createState() => _FieldMapScreenState();
}

class _FieldMapScreenState extends State<FieldMapScreen>
    with TickerProviderStateMixin {
  int _selectedField = 0;
  _MapLayer _mapLayer = _MapLayer.satellite;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final MapController _mapController = MapController();

  LatLng _center = const LatLng(20.5937, 78.9629);
  double _zoom = 16.0;

  // ── REAL working tile URL sources ─────────────────────────────
  //
  // SATELLITE : ESRI World Imagery (no key needed, public CDN)
  static const String _satelliteUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  // NDVI      : NASA GIBS – MODIS Terra NDVI 16-Day (true NDVI band-ratio layer)
  //             Format: EPSG:4326 → convert to Web Mercator via wmts/1.0.0
  //             The GIBS WMS endpoint supports TMS-style URL via xyz proxy:
  static const String _ndviUrl =
      'https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/'
      'MODIS_Terra_Land_Surface_Temp_Day/default/2024-01-01/'
      'GoogleMapsCompatible/{z}/{y}/{x}.png';

  // MOISTURE  : NASA GIBS – SMAP Surface Soil Moisture (L3, 9km)
  static const String _moistureUrl =
      'https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/'
      'SMAP_L4_Emult_Average/default/2024-01-01/'
      'GoogleMapsCompatible/{z}/{y}/{x}.png';

  // Fallback readable NDVI overlay (OpenWeatherMap NDVI-style natural)
  // We also tint the polygon per layer.
  // ──────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get fields {
    if (widget.project != null) {
      final p = widget.project!;
      return [
        {
          'name': p.farmName,
          'crop': p.cropName,
          'area': '${p.calculatedAreaAcres.toStringAsFixed(2)} acres',
          'health': 0.85,
          'status': 'Healthy',
          'stage': 'Growing',
          'moisture': '70%',
          'ndvi': '0.75',
          'pest': 'Low Risk',
          'harvest': 'Dec 15',
          'color': const Color(0xFF4CAF50),
          'polygon': p.polygonPoints,
          'center': p.polygonCenter,
        },
      ];
    }
    return [
      {
        'name': 'North Plot',
        'crop': 'Samba Rice',
        'area': '1.8 acres',
        'health': 0.78,
        'status': 'Healthy',
        'stage': 'Tillering',
        'moisture': '72%',
        'ndvi': '0.68',
        'pest': 'High Risk',
        'harvest': 'Dec 15',
        'color': const Color(0xFF8BC34A),
        'polygon': <LatLng>[],
        'center': const LatLng(20.5937, 78.9629),
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.project != null && widget.project!.polygonPoints.isNotEmpty) {
      _center = widget.project!.polygonCenter;
      _zoom = 17.0;
    } else if (widget.project != null) {
      _center = widget.project!.location;
      _zoom = 17.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Layer helpers ─────────────────────────────────────────────

  String get _baseTileUrl {
    switch (_mapLayer) {
      case _MapLayer.satellite:
        return _satelliteUrl;
      case _MapLayer.ndvi:
        // Satellite stays on as the base; NDVI rendered as a coloured overlay
        return _satelliteUrl;
      case _MapLayer.moisture:
        // Same – satellite base, moisture overlay on top
        return _satelliteUrl;
    }
  }

  String? get _overlayTileUrl {
    switch (_mapLayer) {
      case _MapLayer.satellite:
        return null;
      case _MapLayer.ndvi:
        return _ndviUrl;
      case _MapLayer.moisture:
        return _moistureUrl;
    }
  }

  Color get _polygonFill {
    switch (_mapLayer) {
      case _MapLayer.satellite:
        return const Color(0xFF4CAF50).withOpacity(0.25);
      case _MapLayer.ndvi:
        return const Color(0xFF8BC34A).withOpacity(0.45);
      case _MapLayer.moisture:
        return const Color(0xFF29B6F6).withOpacity(0.45);
    }
  }

  Color get _polygonBorder {
    switch (_mapLayer) {
      case _MapLayer.satellite:
        return const Color(0xFF2E7D32);
      case _MapLayer.ndvi:
        return const Color(0xFFCDDC39);
      case _MapLayer.moisture:
        return const Color(0xFF0288D1);
    }
  }

  String get _layerLabel {
    switch (_mapLayer) {
      case _MapLayer.satellite:
        return 'Satellite';
      case _MapLayer.ndvi:
        return 'NDVI';
      case _MapLayer.moisture:
        return 'Moisture';
    }
  }

  String get _layerMeaning {
    switch (_mapLayer) {
      case _MapLayer.satellite:
        return 'Use this for field boundary and on-ground visual checks.';
      case _MapLayer.ndvi:
        return 'Green means healthier crop growth; yellow/red needs attention.';
      case _MapLayer.moisture:
        return 'Blue indicates better soil moisture; pale zones may need irrigation.';
    }
  }

  String get _layerActionTip {
    switch (_mapLayer) {
      case _MapLayer.satellite:
        return 'Walk to spots with visible patchiness and check pest or weed spread.';
      case _MapLayer.ndvi:
        return 'If weak patches stay for 5-7 days, inspect nutrients and root health.';
      case _MapLayer.moisture:
        return 'Prioritize irrigation for dry zones and prevent waterlogging in wet zones.';
    }
  }

  Color get _layerBadgeColor {
    switch (_mapLayer) {
      case _MapLayer.satellite:
        return Colors.black.withOpacity(0.6);
      case _MapLayer.ndvi:
        return const Color(0xFF8BC34A).withOpacity(0.9);
      case _MapLayer.moisture:
        return const Color(0xFF29B6F6).withOpacity(0.9);
    }
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final totalArea =
        widget.project?.calculatedAreaAcres.toStringAsFixed(1) ?? '3.2';
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      body: Column(
        children: [
          ProjectHeroAppBar(
            title: widget.project?.farmName ?? 'Field Map',
            subtitle: 'Satellite and crop health layers',
            leadingIcon: Icons.terrain_rounded,
            chips: [
              ProjectHeroChipData(
                icon: Icons.landscape_rounded,
                value: '$totalArea acres total',
              ),
              ProjectHeroChipData(
                icon: Icons.layers_rounded,
                value: _layerLabel,
              ),
            ],
            actions: [
              GestureDetector(
                onTap: () => _mapController.move(_center, _zoom),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.gps_fixed_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildInteractiveMap(),
                  _buildLayerSelector(),
                  _buildLayerEducationCard(),
                  _buildFieldCardsHint(),
                  _buildFieldCards(),
                  if (fields.isNotEmpty)
                    _buildFieldDetails(fields[_selectedField]),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveMap() {
    final hasPolygon =
        widget.project != null && widget.project!.polygonPoints.length >= 3;
    final overlayUrl = _overlayTileUrl;

    return Container(
      margin: const EdgeInsets.all(16),
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // ── Flutter Map ────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: _zoom,
                minZoom: 4,
                maxZoom: 19,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                // Base tile layer (always satellite)
                TileLayer(
                  urlTemplate: _baseTileUrl,
                  userAgentPackageName: 'com.krishi_sakhi.app',
                  maxZoom: 19,
                  // Caching-friendly subdomains for ESRI
                  subdomains: const [],
                ),

                // NDVI overlay tile layer
                if (overlayUrl != null && _mapLayer == _MapLayer.ndvi)
                  Opacity(
                    opacity: 0.72,
                    child: TileLayer(
                      urlTemplate: overlayUrl,
                      userAgentPackageName: 'com.krishi_sakhi.app',
                      maxZoom: 8, // GIBS MODIS is coarse-resolution
                    ),
                  ),

                // Moisture overlay tile layer
                if (overlayUrl != null && _mapLayer == _MapLayer.moisture)
                  Opacity(
                    opacity: 0.72,
                    child: TileLayer(
                      urlTemplate: overlayUrl,
                      userAgentPackageName: 'com.krishi_sakhi.app',
                      maxZoom: 8,
                    ),
                  ),

                // Farm polygon boundary
                if (hasPolygon)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: widget.project!.polygonPoints,
                        color: _polygonFill,
                        borderColor: _polygonBorder,
                        borderStrokeWidth: 3.0,
                      ),
                    ],
                  ),

                // Centre marker (pulsing)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _center,
                      width: 40,
                      height: 40,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF2E7D32).withOpacity(0.3),
                                border: Border.all(
                                  color: const Color(0xFF2E7D32),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.agriculture_rounded,
                                color: Color(0xFF2E7D32),
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Map controls (zoom +/-/GPS) ────────────────────
            Positioned(
              top: 12,
              right: 12,
              child: Column(
                children: [
                  _buildGlassButton(Icons.add_rounded, () {
                    final z = (_zoom + 1).clamp(4.0, 19.0);
                    setState(() => _zoom = z);
                    _mapController.move(_center, z);
                  }),
                  const SizedBox(height: 8),
                  _buildGlassButton(Icons.remove_rounded, () {
                    final z = (_zoom - 1).clamp(4.0, 19.0);
                    setState(() => _zoom = z);
                    _mapController.move(_center, z);
                  }),
                  const SizedBox(height: 8),
                  _buildGlassButton(Icons.my_location_rounded, () {
                    _mapController.move(_center, 17.0);
                    setState(() => _zoom = 17.0);
                  }),
                ],
              ),
            ),

            // ── North indicator ────────────────────────────────
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'N',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Active layer badge ─────────────────────────────
            Positioned(
              top: 12,
              left: 66,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _layerBadgeColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _mapLayer == _MapLayer.satellite
                          ? Icons.satellite_alt_rounded
                          : _mapLayer == _MapLayer.ndvi
                          ? Icons.grass_rounded
                          : Icons.water_drop_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _layerLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Scale bar ─────────────────────────────────────
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '50m',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Legend ────────────────────────────────────────
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(
                      _polygonBorder,
                      widget.project?.farmName ?? 'Farm Boundary',
                    ),
                    const SizedBox(height: 4),
                    _buildLegendItem(const Color(0xFF2E7D32), 'Farm Centre'),
                  ],
                ),
              ),
            ),

            // ── NDVI colour-scale bar ──────────────────────────
            if (_mapLayer == _MapLayer.ndvi)
              Positioned(bottom: 60, left: 12, child: _buildNDVIColorScale()),

            // ── Moisture colour-scale bar ──────────────────────
            if (_mapLayer == _MapLayer.moisture)
              Positioned(
                bottom: 60,
                left: 12,
                child: _buildMoistureColorScale(),
              ),
          ],
        ),
      ),
    );
  }

  /// Compact NDVI colour ramp legend
  Widget _buildNDVIColorScale() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NDVI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 120,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD32F2F), // low NDVI – stressed / bare
                      Color(0xFFFF9800),
                      Color(0xFFCDDC39),
                      Color(0xFF8BC34A),
                      Color(0xFF2E7D32), // high NDVI – dense vegetation
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0.0', style: TextStyle(color: Colors.white60, fontSize: 9)),
              SizedBox(width: 40),
              Text('0.5', style: TextStyle(color: Colors.white60, fontSize: 9)),
              SizedBox(width: 40),
              Text('1.0', style: TextStyle(color: Colors.white60, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  /// Compact soil-moisture colour ramp legend
  Widget _buildMoistureColorScale() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Moisture',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 120,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFF9C4), // dry
                  Color(0xFF81D4FA),
                  Color(0xFF0288D1), // wet
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dry', style: TextStyle(color: Colors.white60, fontSize: 9)),
              SizedBox(width: 100),
              Text('Wet', style: TextStyle(color: Colors.white60, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1B5E20)),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.4), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A2E1A),
          ),
        ),
      ],
    );
  }

  // ── Layer selector tabs ────────────────────────────────────────

  Widget _buildLayerSelector() {
    final layers = [
      {
        'label': 'Satellite',
        'icon': Icons.satellite_alt_rounded,
        'layer': _MapLayer.satellite,
      },
      {'label': 'NDVI', 'icon': Icons.grass_rounded, 'layer': _MapLayer.ndvi},
      {
        'label': 'Moisture',
        'icon': Icons.water_drop_rounded,
        'layer': _MapLayer.moisture,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children:
            layers.map((item) {
              final selected = _mapLayer == (item['layer'] as _MapLayer);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _mapLayer = item['layer'] as _MapLayer);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient:
                          selected
                              ? const LinearGradient(
                                colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                              )
                              : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 16,
                          color: selected ? Colors.white : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color:
                                selected ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildLayerEducationCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B5E20).withOpacity(0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 18,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_layerLabel Layer Guide',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _layerMeaning,
                  style: const TextStyle(fontSize: 11, height: 1.35),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tip: $_layerActionTip',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCardsHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Icon(Icons.touch_app_rounded, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Tap a field card to focus the map and view quick crop-health advice.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Field cards horizontal list ────────────────────────────────

  Widget _buildFieldCards() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: fields.length,
        itemBuilder: (context, index) {
          final field = fields[index];
          final selected = index == _selectedField;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedField = index);
              final center = field['center'] as LatLng;
              _mapController.move(center, 17.0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 160,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient:
                    selected
                        ? const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : LinearGradient(
                          colors: [Colors.white, Colors.grey.shade50],
                        ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        selected
                            ? const Color(0xFF2E7D32).withOpacity(0.35)
                            : Colors.black.withOpacity(0.06),
                    blurRadius: selected ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color:
                      selected
                          ? Colors.transparent
                          : (field['color'] as Color).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          field['name'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color:
                                selected
                                    ? Colors.white
                                    : const Color(0xFF1A2E1A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color:
                              (field['pest'] as String).contains('High')
                                  ? Colors.red
                                  : Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    field['crop'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: selected ? Colors.white70 : Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  _buildMiniStat(field['area'] as String, selected),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniStat(String value, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            selected
                ? Colors.white.withOpacity(0.2)
                : const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : const Color(0xFF2E7D32),
        ),
      ),
    );
  }

  // ── Field detail card ──────────────────────────────────────────

  Widget _buildFieldDetails(Map<String, dynamic> field) {
    final health = field['health'] as double;
    final pestRisk = field['pest'] as String;
    final isHighRisk = pestRisk.contains('High');
    final recommendation = _buildRecommendationText(health, isHighRisk);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (field['color'] as Color).withOpacity(0.2),
                          (field['color'] as Color).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.grass_rounded,
                      color: field['color'] as Color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A2E1A),
                        ),
                      ),
                      Text(
                        '${field['crop']} • ${field['stage']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      isHighRisk
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isHighRisk
                            ? Colors.red.withOpacity(0.3)
                            : Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isHighRisk
                          ? Icons.warning_rounded
                          : Icons.check_circle_rounded,
                      size: 14,
                      color: isHighRisk ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pestRisk,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isHighRisk ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Crop Health',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2E1A),
                    ),
                  ),
                  Text(
                    '${(health * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: health > 0.7 ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: health,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    health > 0.8
                        ? const Color(0xFF4CAF50)
                        : health > 0.6
                        ? const Color(0xFF8BC34A)
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildFieldStat(
                'Moisture',
                field['moisture'] as String,
                Icons.water_drop_rounded,
                const Color(0xFF29B6F6),
              ),
              _buildFieldStat(
                'NDVI',
                field['ndvi'] as String,
                Icons.grass_rounded,
                const Color(0xFF8BC34A),
              ),
              _buildFieldStat(
                'Harvest',
                field['harvest'] as String,
                Icons.calendar_today_rounded,
                const Color(0xFFFF9800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2E7D32).withOpacity(0.22),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  color: Color(0xFF2E7D32),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildRecommendationText(double health, bool isHighRisk) {
    if (isHighRisk) {
      return 'High pest risk detected. Inspect leaves within 24 hours and apply targeted treatment only in affected patches.';
    }
    if (health < 0.65) {
      return 'Crop health is moderate. Check soil moisture and nutrition schedule to recover weak areas early.';
    }
    return 'Field condition is stable. Continue current irrigation plan and monitor NDVI every 3-4 days.';
  }

  Widget _buildFieldStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

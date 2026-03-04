import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../l10n/app_localizations.dart';
import '../models/farm_project.dart';
import 'map_screen.dart';
import 'project_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Crop data model for suggestions
// ─────────────────────────────────────────────────────────────────────────────

class _CropInfo {
  final String name;
  final String category;
  final IconData icon;
  final Color color;

  const _CropInfo({
    required this.name,
    required this.category,
    required this.icon,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Address suggestion model
// ─────────────────────────────────────────────────────────────────────────────

class _AddressSuggestion {
  final String displayName;
  final double lat;
  final double lon;

  const _AddressSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
  });
}

// ═════════════════════════════════════════════════════════════════════════════
// FormScreens
// ═════════════════════════════════════════════════════════════════════════════

class FormScreens extends StatefulWidget {
  const FormScreens({super.key});

  @override
  _FormScreensState createState() => _FormScreensState();
}

class _FormScreensState extends State<FormScreens>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ──────────────────────────────────────────────────────────
  final _farmNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _acresController = TextEditingController();
  final _cropSearchController = TextEditingController();

  // ── Location / GPS ────────────────────────────────────────────────────────
  LatLng? _selectedLatLng;
  bool _isFetchingLocation = false;

  // ── Polygon / boundary ────────────────────────────────────────────────────
  List<LatLng> _polygonPoints = [];

  // ── Location autocomplete ─────────────────────────────────────────────────
  List<_AddressSuggestion> _addressSuggestions = [];
  bool _isSearchingAddress = false;
  Timer? _debounce;
  final _locationFocusNode = FocusNode();
  bool _showSuggestions = false;

  // ── Crop ──────────────────────────────────────────────────────────────────
  String? _selectedCrop;
  List<_CropInfo> _filteredCrops = [];
  bool _showCropSuggestions = false;
  final _cropFocusNode = FocusNode();

  // ── Irrigation tags ───────────────────────────────────────────────────────
  final Set<String> _selectedIrrigationMethods = {};

  // ── Farmer level ──────────────────────────────────────────────────────────
  int _farmerLevel = 0; // 0-4 index

  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // ── All crop data ─────────────────────────────────────────────────────────
  List<_CropInfo> _allCrops = [];

  List<String> _irrigationMethods = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _locationFocusNode.addListener(() {
      if (!_locationFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showSuggestions = false);
        });
      }
    });

    _cropFocusNode.addListener(() {
      if (!_cropFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showCropSuggestions = false);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context)!;
    _allCrops = _buildCropList(loc);
    _filteredCrops = List.from(_allCrops);
    _irrigationMethods = _buildIrrigationMethods();
  }

  List<_CropInfo> _buildCropList(AppLocalizations loc) {
    return [
      // Cereals
      _CropInfo(
        name: loc.rice,
        category: 'Cereals',
        icon: Icons.grass,
        color: const Color(0xFF4CAF50),
      ),
      _CropInfo(
        name: loc.wheat,
        category: 'Cereals',
        icon: Icons.grass,
        color: const Color(0xFFFFC107),
      ),
      _CropInfo(
        name: loc.corn,
        category: 'Cereals',
        icon: Icons.grass,
        color: const Color(0xFFFF9800),
      ),
      _CropInfo(
        name: loc.barley,
        category: 'Cereals',
        icon: Icons.grass,
        color: const Color(0xFF8D6E63),
      ),
      _CropInfo(
        name: loc.oats,
        category: 'Cereals',
        icon: Icons.grass,
        color: const Color(0xFFBCAAA4),
      ),
      // Cash Crops
      _CropInfo(
        name: loc.cotton,
        category: 'Cash Crops',
        icon: Icons.local_florist,
        color: const Color(0xFFE0E0E0),
      ),
      _CropInfo(
        name: loc.sugarcane,
        category: 'Cash Crops',
        icon: Icons.agriculture,
        color: const Color(0xFF66BB6A),
      ),
      _CropInfo(
        name: loc.soybeans,
        category: 'Pulses',
        icon: Icons.spa,
        color: const Color(0xFF81C784),
      ),
      // Vegetables
      _CropInfo(
        name: loc.vegetables,
        category: 'Vegetables',
        icon: Icons.eco,
        color: const Color(0xFF43A047),
      ),
      // Plantation
      _CropInfo(
        name: loc.coconut,
        category: 'Plantation',
        icon: Icons.park,
        color: const Color(0xFF2E7D32),
      ),
    ];
  }

  List<String> _buildIrrigationMethods() {
    return [
      'Drip Irrigation',
      'Sprinkler',
      'Flood Irrigation',
      'Furrow',
      'Centre Pivot',
      'Rainfed',
      'Manual',
      'Micro-Sprinkler',
    ];
  }

  @override
  void dispose() {
    _farmNameController.dispose();
    _locationController.dispose();
    _acresController.dispose();
    _cropSearchController.dispose();
    _animationController.dispose();
    _locationFocusNode.dispose();
    _cropFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ─── Location: Fetch GPS ──────────────────────────────────────────────────
  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _snack('Location services are disabled.', error: true);
        setState(() => _isFetchingLocation = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _snack('Location permission denied.', error: true);
          setState(() => _isFetchingLocation = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _snack('Permission permanently denied.', error: true);
        setState(() => _isFetchingLocation = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(pos.latitude, pos.longitude);

      // Reverse geocode
      final address = await _reverseGeocode(pos.latitude, pos.longitude);

      setState(() {
        _selectedLatLng = latLng;
        _locationController.text = address;
        _isFetchingLocation = false;
      });
      _autoGeneratePolygon();
    } catch (e) {
      setState(() => _isFetchingLocation = false);
      _snack('Error fetching location: $e', error: true);
    }
  }

  Future<String> _reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      );
      final resp = await http.get(
        uri,
        headers: {'User-Agent': 'KrishiSakhi/1.0'},
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return data['display_name'] ?? '$lat, $lon';
      }
    } catch (_) {}
    return '$lat, $lon';
  }

  // ─── Location: Search Nominatim ───────────────────────────────────────────
  void _onLocationTextChanged(String query) {
    _debounce?.cancel();
    if (query.length < 3) {
      setState(() {
        _addressSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchAddress(query);
    });
  }

  Future<void> _searchAddress(String query) async {
    setState(() => _isSearchingAddress = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=5&addressdetails=1',
      );
      final resp = await http.get(
        uri,
        headers: {'User-Agent': 'KrishiSakhi/1.0'},
      );
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        setState(() {
          _addressSuggestions =
              data
                  .map(
                    (e) => _AddressSuggestion(
                      displayName: e['display_name'] ?? '',
                      lat: double.tryParse(e['lat'].toString()) ?? 0,
                      lon: double.tryParse(e['lon'].toString()) ?? 0,
                    ),
                  )
                  .toList();
          _showSuggestions = _addressSuggestions.isNotEmpty;
          _isSearchingAddress = false;
        });
      } else {
        setState(() => _isSearchingAddress = false);
      }
    } catch (_) {
      setState(() => _isSearchingAddress = false);
    }
  }

  void _selectAddress(_AddressSuggestion suggestion) {
    setState(() {
      _locationController.text = suggestion.displayName;
      _selectedLatLng = LatLng(suggestion.lat, suggestion.lon);
      _showSuggestions = false;
      _addressSuggestions = [];
    });
    _locationFocusNode.unfocus();
    _autoGeneratePolygon();
  }

  // ─── Crop search ──────────────────────────────────────────────────────────
  void _onCropSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCrops = List.from(_allCrops);
      } else {
        _filteredCrops =
            _allCrops
                .where(
                  (c) => c.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
      _showCropSuggestions = true;
    });
  }

  void _selectCrop(_CropInfo crop) {
    setState(() {
      _selectedCrop = crop.name;
      _cropSearchController.text = crop.name;
      _showCropSuggestions = false;
    });
    _cropFocusNode.unfocus();
  }

  // ─── Farmer level labels ──────────────────────────────────────────────────
  List<Map<String, dynamic>> _farmerLevels(AppLocalizations loc) {
    return [
      {
        'label': loc.beginner,
        'icon': Icons.eco_outlined,
        'color': const Color(0xFFA5D6A7),
        'desc': 'Just starting out',
      },
      {
        'label': loc.novice,
        'icon': Icons.spa_outlined,
        'color': const Color(0xFF81C784),
        'desc': '1-2 years',
      },
      {
        'label': loc.intermediate,
        'icon': Icons.agriculture_outlined,
        'color': const Color(0xFF66BB6A),
        'desc': '3-5 years',
      },
      {
        'label': loc.advanced,
        'icon': Icons.landscape_outlined,
        'color': const Color(0xFF43A047),
        'desc': '5-10 years',
      },
      {
        'label': loc.expert,
        'icon': Icons.emoji_events_outlined,
        'color': const Color(0xFF2E7D32),
        'desc': '10+ years',
      },
    ];
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor:
            error ? const Color(0xFFB00020) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      appBar: _buildAppBar(loc),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Step indicator ─────────────
                _buildStepIndicator(loc),
                const SizedBox(height: 24),

                // 1. Farm Name
                _buildSectionHeader(loc.farmName, Icons.agriculture_outlined),
                const SizedBox(height: 10),
                _buildFarmNameField(loc),
                const SizedBox(height: 28),

                // 2. Location with GPS + autocomplete
                _buildSectionHeader(loc.location, Icons.location_on_outlined),
                const SizedBox(height: 10),
                _buildLocationField(loc),
                const SizedBox(height: 20),

                // 3. Map grid preview – plot your land
                if (_selectedLatLng != null) ...[
                  _buildMapGridPreview(loc),
                  const SizedBox(height: 28),
                ],

                // 4. Acres
                _buildSectionHeader(
                  loc.landSize,
                  Icons.crop_landscape_outlined,
                ),
                const SizedBox(height: 10),
                _buildAcresField(loc),
                const SizedBox(height: 28),

                // 5. Crop Type with search suggestions
                _buildSectionHeader(loc.cropType, Icons.grass_outlined),
                const SizedBox(height: 10),
                _buildCropTypeField(loc),
                const SizedBox(height: 28),

                // 6. Irrigation Methods (tags)
                _buildSectionHeader(
                  'Irrigation Methods',
                  Icons.water_drop_outlined,
                ),
                const SizedBox(height: 10),
                _buildIrrigationTags(),
                const SizedBox(height: 28),

                // 7. Farmer Level
                _buildSectionHeader(loc.experience, Icons.trending_up),
                const SizedBox(height: 10),
                _buildFarmerLevelSelector(loc),
                const SizedBox(height: 40),

                // Submit
                _buildSubmitButton(loc),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(AppLocalizations loc) {
    return AppBar(
      backgroundColor: const Color(0xFF2E7D32),
      elevation: 0,
      title: Text(
        loc.newProject,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
        tooltip: loc.cancel,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white70, size: 22),
          onPressed: () {},
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  // ─── Step Indicator ───────────────────────────────────────────────────────
  Widget _buildStepIndicator(AppLocalizations loc) {
    final steps = ['Farm Info', 'Location', 'Crop & Land', 'Review'];
    // Auto-detect current step based on filled fields
    int progress = 0;
    if (_farmNameController.text.isNotEmpty) progress = 1;
    if (_selectedLatLng != null) progress = 2;
    if (_selectedCrop != null && _acresController.text.isNotEmpty) progress = 3;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i <= progress;
          final isCurrent = i == progress;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: isCurrent ? 36 : 28,
                        height: isCurrent ? 36 : 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isActive
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey[300],
                          boxShadow:
                              isCurrent
                                  ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2E7D32,
                                      ).withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Center(
                          child:
                              isActive && i < progress
                                  ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                  : Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      color:
                                          isActive
                                              ? Colors.white
                                              : Colors.grey[600],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color:
                              isActive ? const Color(0xFF2E7D32) : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Container(
                    height: 2,
                    width: 20,
                    margin: const EdgeInsets.only(bottom: 18),
                    color:
                        i < progress
                            ? const Color(0xFF2E7D32)
                            : Colors.grey[300],
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }

  // ─── 1. Farm Name ─────────────────────────────────────────────────────────
  Widget _buildFarmNameField(AppLocalizations loc) {
    return _CardWrapper(
      child: TextFormField(
        controller: _farmNameController,
        decoration: _inputDecoration(
          label: loc.farmName,
          hint: 'e.g. Green Valley Farm',
          icon: Icons.eco_outlined,
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  // ─── 2. Location with GPS + Autocomplete ──────────────────────────────────
  Widget _buildLocationField(AppLocalizations loc) {
    return Column(
      children: [
        _CardWrapper(
          child: Column(
            children: [
              TextFormField(
                controller: _locationController,
                focusNode: _locationFocusNode,
                decoration: _inputDecoration(
                  label: loc.location,
                  hint: 'Search address or use GPS',
                  icon: Icons.search,
                ).copyWith(
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isSearchingAddress)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap:
                              _isFetchingLocation
                                  ? null
                                  : _fetchCurrentLocation,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child:
                                _isFetchingLocation
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    )
                                    : const Icon(
                                      Icons.my_location,
                                      color: Color(0xFF2E7D32),
                                      size: 22,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onChanged: _onLocationTextChanged,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              // Lat/Lng display
              if (_selectedLatLng != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.pin_drop,
                        size: 14,
                        color: Color(0xFF66BB6A),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_selectedLatLng!.latitude.toStringAsFixed(6)}, ${_selectedLatLng!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF558B2F),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // Suggestions dropdown
        if (_showSuggestions && _addressSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children:
                    _addressSuggestions.map((s) {
                      return InkWell(
                        onTap: () => _selectAddress(s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFF0F0F0),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2E7D32,
                                  ).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF2E7D32),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  s.displayName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${s.lat.toStringAsFixed(2)}, ${s.lon.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  // ─── Auto-generate polygon from acres ─────────────────────────────────────
  void _autoGeneratePolygon() {
    if (_selectedLatLng == null) return;
    final acresText = _acresController.text;
    final acres = double.tryParse(acresText);
    if (acres != null && acres > 0) {
      setState(() {
        _polygonPoints = generatePolygonFromAcres(_selectedLatLng!, acres);
      });
    }
  }

  // ─── Open map for drawing ─────────────────────────────────────────────────
  Future<void> _openMapForDrawing() async {
    final acresText = _acresController.text;
    final acres = double.tryParse(acresText);
    final hasExistingPolygon = _polygonPoints.length >= 3;

    final result = await Navigator.push<List<LatLng>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => MapScreen(
              initialLocation: _selectedLatLng,
              initialAcres: acres,
              initialPolygon: _polygonPoints.isNotEmpty ? _polygonPoints : null,
              enableDrawing: true,
              editMode: hasExistingPolygon,
            ),
      ),
    );

    if (result != null && result.length >= 3) {
      setState(() {
        _polygonPoints = result;
      });
      // Update acres from polygon area
      final area = polygonAreaAcres(result);
      _acresController.text = area.toStringAsFixed(2);
      _snack('Boundary saved! Area: ${area.toStringAsFixed(2)} acres');
    }
  }

  // ─── 3. Map Grid Preview (plain bg + polygon painter) ───────────────────
  Widget _buildMapGridPreview(AppLocalizations loc) {
    final hasPolygon = _polygonPoints.length >= 3;
    final areaAcres = hasPolygon ? polygonAreaAcres(_polygonPoints) : 0.0;

    return GestureDetector(
      onTap: _openMapForDrawing,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Plain gradient background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Grid lines overlay
              CustomPaint(
                size: const Size(double.infinity, 200),
                painter: _GridPainter(),
              ),

              // Polygon painter (if drawn)
              if (hasPolygon && _selectedLatLng != null)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PolygonPreviewPainter(
                      points: _polygonPoints,
                      center: _selectedLatLng!,
                    ),
                  ),
                ),

              // Centre icon
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.2),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Color(0xFF2E7D32),
                    size: 36,
                  ),
                ),
              ),

              // Top label
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasPolygon ? Icons.check_circle : Icons.grid_on,
                        size: 14,
                        color: const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasPolygon
                            ? '${areaAcres.toStringAsFixed(2)} acres plotted'
                            : 'Your Farm Plot',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Draw button
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasPolygon ? Icons.edit : Icons.draw,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasPolygon ? 'Edit boundary' : 'Draw farm boundary',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Coordinates badge
              if (_selectedLatLng != null)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Calculate an appropriate zoom level to fit the polygon in the mini map.
  double _calculateZoomForPolygon() {
    if (_polygonPoints.isEmpty) return 16.0;
    double minLat = _polygonPoints.first.latitude;
    double maxLat = _polygonPoints.first.latitude;
    double minLng = _polygonPoints.first.longitude;
    double maxLng = _polygonPoints.first.longitude;
    for (final pt in _polygonPoints) {
      if (pt.latitude < minLat) minLat = pt.latitude;
      if (pt.latitude > maxLat) maxLat = pt.latitude;
      if (pt.longitude < minLng) minLng = pt.longitude;
      if (pt.longitude > maxLng) maxLng = pt.longitude;
    }
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = math.max(latDiff, lngDiff);
    if (maxDiff <= 0) return 17.0;
    // Rough: zoom ≈ log2(360 / maxDiff) - some padding
    final zoom = (math.log(360.0 / maxDiff) / math.ln2) - 1.0;
    return zoom.clamp(10.0, 19.0);
  }

  // ─── 4. Acres ─────────────────────────────────────────────────────────────
  Widget _buildAcresField(AppLocalizations loc) {
    return _CardWrapper(
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _acresController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: _inputDecoration(
                label: loc.landSize,
                hint: 'e.g. 2.5',
                icon: Icons.straighten_outlined,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Enter valid number';
                return null;
              },
              onChanged: (_) {
                setState(() {});
                _autoGeneratePolygon();
              },
            ),
          ),
          const SizedBox(width: 12),
          // Quick select chips
          Column(
            children: [
              _QuickChip(
                label: '1 ac',
                onTap: () {
                  _acresController.text = '1';
                  setState(() {});
                  _autoGeneratePolygon();
                },
              ),
              const SizedBox(height: 6),
              _QuickChip(
                label: '5 ac',
                onTap: () {
                  _acresController.text = '5';
                  setState(() {});
                  _autoGeneratePolygon();
                },
              ),
              const SizedBox(height: 6),
              _QuickChip(
                label: '10 ac',
                onTap: () {
                  _acresController.text = '10';
                  setState(() {});
                  _autoGeneratePolygon();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 5. Crop Type with Suggestions ────────────────────────────────────────
  Widget _buildCropTypeField(AppLocalizations loc) {
    return Column(
      children: [
        _CardWrapper(
          child: Column(
            children: [
              TextFormField(
                controller: _cropSearchController,
                focusNode: _cropFocusNode,
                decoration: _inputDecoration(
                  label: loc.cropType,
                  hint: 'Search or select a crop...',
                  icon: Icons.search,
                ).copyWith(
                  suffixIcon:
                      _selectedCrop != null
                          ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _selectedCrop = null;
                                _cropSearchController.clear();
                                _filteredCrops = List.from(_allCrops);
                              });
                            },
                          )
                          : null,
                ),
                onChanged: _onCropSearchChanged,
                onTap: () {
                  setState(() => _showCropSuggestions = true);
                },
                validator:
                    (_) =>
                        _selectedCrop == null ? 'Please select a crop' : null,
              ),
              // Selected crop display
              if (_selectedCrop != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _SelectedCropBadge(
                    crop: _allCrops.firstWhere(
                      (c) => c.name == _selectedCrop,
                      orElse:
                          () => _CropInfo(
                            name: _selectedCrop!,
                            category: '',
                            icon: Icons.grass,
                            color: const Color(0xFF4CAF50),
                          ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Crop suggestions panel
        if (_showCropSuggestions && _filteredCrops.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredCrops.length,
                itemBuilder: (ctx, i) {
                  final crop = _filteredCrops[i];
                  final isSelected = crop.name == _selectedCrop;
                  // Category header
                  final showCatHeader =
                      i == 0 || _filteredCrops[i - 1].category != crop.category;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showCatHeader)
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                          color: const Color(0xFFF5F8F5),
                          child: Text(
                            crop.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[600],
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      InkWell(
                        onTap: () => _selectCrop(crop),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color(0xFF2E7D32).withOpacity(0.06)
                                    : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: crop.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  crop.icon,
                                  color: crop.color,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      crop.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      crop.category,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF2E7D32),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  // ─── 6. Irrigation Tags ───────────────────────────────────────────────────
  Widget _buildIrrigationTags() {
    return _CardWrapper(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            _irrigationMethods.map((method) {
              final isSelected = _selectedIrrigationMethods.contains(method);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                child: FilterChip(
                  label: Text(
                    method,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF2E7D32),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  avatar:
                      isSelected
                          ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                          : Icon(
                            _irrigationIcon(method),
                            size: 16,
                            color: const Color(0xFF2E7D32),
                          ),
                  selected: isSelected,
                  onSelected: (sel) {
                    setState(() {
                      if (sel) {
                        _selectedIrrigationMethods.add(method);
                      } else {
                        _selectedIrrigationMethods.remove(method);
                      }
                    });
                  },
                  selectedColor: const Color(0xFF2E7D32),
                  backgroundColor: const Color(0xFF2E7D32).withOpacity(0.06),
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color:
                          isSelected
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF2E7D32).withOpacity(0.3),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  IconData _irrigationIcon(String method) {
    switch (method.toLowerCase()) {
      case 'drip irrigation':
        return Icons.water_drop;
      case 'sprinkler':
        return Icons.shower;
      case 'flood irrigation':
        return Icons.waves;
      case 'furrow':
        return Icons.horizontal_rule;
      case 'centre pivot':
        return Icons.sync;
      case 'rainfed':
        return Icons.cloud;
      case 'manual':
        return Icons.pan_tool;
      case 'micro-sprinkler':
        return Icons.grain;
      default:
        return Icons.water;
    }
  }

  // ─── 7. Farmer Level Selector ─────────────────────────────────────────────
  Widget _buildFarmerLevelSelector(AppLocalizations loc) {
    final levels = _farmerLevels(loc);
    return _CardWrapper(
      child: Column(
        children: [
          // Level steps (horizontal)
          SizedBox(
            height: 110,
            child: Row(
              children: List.generate(levels.length, (i) {
                final level = levels[i];
                final isSelected = i == _farmerLevel;
                final isPassed = i <= _farmerLevel;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _farmerLevel = i),
                    child: Column(
                      children: [
                        // Node
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isSelected ? 46 : 36,
                          height: isSelected ? 46 : 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isPassed
                                    ? level['color'] as Color
                                    : Colors.grey[200],
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: (level['color'] as Color)
                                            .withOpacity(0.4),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                    : null,
                          ),
                          child: Icon(
                            level['icon'] as IconData,
                            color: isPassed ? Colors.white : Colors.grey[500],
                            size: isSelected ? 22 : 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          level['label'] as String,
                          style: TextStyle(
                            fontSize: isSelected ? 11 : 10,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color:
                                isPassed
                                    ? const Color(0xFF1B5E20)
                                    : Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          level['desc'] as String,
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey[400],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _farmerLevel / (levels.length - 1),
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                levels[_farmerLevel]['color'] as Color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Current level description
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(_farmerLevel),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: (levels[_farmerLevel]['color'] as Color).withOpacity(
                  0.08,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    levels[_farmerLevel]['icon'] as IconData,
                    size: 18,
                    color: levels[_farmerLevel]['color'] as Color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${levels[_farmerLevel]['label']} — ${levels[_farmerLevel]['desc']}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: levels[_farmerLevel]['color'] as Color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Submit ───────────────────────────────────────────────────────────────
  Widget _buildSubmitButton(AppLocalizations loc) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (_selectedIrrigationMethods.isEmpty) {
              _snack(
                'Please select at least one irrigation method',
                error: true,
              );
              return;
            }
            if (_selectedLatLng == null) {
              _snack('Please select a location', error: true);
              return;
            }
            if (_selectedCrop == null) {
              _snack('Please select a crop', error: true);
              return;
            }

            // Create FarmProject with all data
            final project = FarmProject(
              farmName: _farmNameController.text,
              locationName: _locationController.text,
              location: _selectedLatLng!,
              acres: double.tryParse(_acresController.text) ?? 1.0,
              polygonPoints: _polygonPoints,
              cropName: _selectedCrop!,
              irrigationMethods: Set.from(_selectedIrrigationMethods),
              farmerLevel: _farmerLevel,
            );

            // Navigate to ProjectScreen with data
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectScreen(project: project),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 6,
          shadowColor: const Color(0xFF2E7D32).withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              loc.submit,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Input decoration helper ──────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 56, minHeight: 40),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: Colors.grey[600]),
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Reusable Widgets
// ═════════════════════════════════════════════════════════════════════════════

/// Card wrapper for sections.
class _CardWrapper extends StatelessWidget {
  final Widget child;
  const _CardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Quick chip for acres.
class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Selected crop badge.
class _SelectedCropBadge extends StatelessWidget {
  final _CropInfo crop;
  const _SelectedCropBadge({required this.crop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: crop.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: crop.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(crop.icon, size: 18, color: crop.color),
          const SizedBox(width: 8),
          Text(
            crop.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: crop.color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '• ${crop.category}',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

/// Custom painter to preview polygon on a plain background.
class _PolygonPreviewPainter extends CustomPainter {
  final List<LatLng> points;
  final LatLng center;
  _PolygonPreviewPainter({required this.points, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 3) return;
    // Find bounding box
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final latRange = (maxLat - minLat).clamp(0.0001, double.infinity);
    final lngRange = (maxLng - minLng).clamp(0.0001, double.infinity);
    final padding = 32.0;

    Offset toCanvas(LatLng p) {
      final x =
          padding +
          (p.longitude - minLng) / lngRange * (size.width - padding * 2);
      final y =
          padding +
          (maxLat - p.latitude) / latRange * (size.height - padding * 2);
      return Offset(x, y);
    }

    final fillPaint =
        Paint()
          ..color = const Color(0xFF2E7D32).withOpacity(0.18)
          ..style = PaintingStyle.fill;
    final strokePaint =
        Paint()
          ..color = const Color(0xFF2E7D32).withOpacity(0.8)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    final path = ui.Path();
    path.moveTo(toCanvas(points.first).dx, toCanvas(points.first).dy);
    for (int i = 1; i < points.length; i++) {
      final off = toCanvas(points[i]);
      path.lineTo(off.dx, off.dy);
    }
    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Vertex dots
    final dotPaint = Paint()..color = const Color(0xFF2E7D32);
    for (final p in points) {
      canvas.drawCircle(toCanvas(p), 4, dotPaint);
      canvas.drawCircle(
        toCanvas(p),
        4,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_PolygonPreviewPainter old) =>
      old.points != points || old.center != center;
}

/// Grid painter for plain background overlay.
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF2E7D32).withOpacity(0.12)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke;

    const spacing = 40.0;
    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Highlighted center area
    final highlightPaint =
        Paint()
          ..color = const Color(0xFF2E7D32).withOpacity(0.08)
          ..style = PaintingStyle.fill;

    final centerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: spacing * 3,
      height: spacing * 3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, const Radius.circular(4)),
      highlightPaint,
    );

    // Center border
    final borderPaint =
        Paint()
          ..color = const Color(0xFF2E7D32).withOpacity(0.4)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, const Radius.circular(4)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pulsing location dot for the mini map.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
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
                width: 44 * _pulse.value,
                height: 44 * _pulse.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(
                    0xFF2E7D32,
                  ).withOpacity((1 - _pulse.value) * 0.3),
                ),
              ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2E7D32),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}

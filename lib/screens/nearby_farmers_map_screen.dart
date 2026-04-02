import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

// ─────────────────────────────────────────────────────────────────────────────
// THEME CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────
const Color kPrimary = Color(0xFF2E7D32);
const Color kPrimaryDark = Color(0xFF1B5E20);
const Color kPrimaryLight = Color(0xFF81C784);
const Color kAccent = Color(0xFF66BB6A);
const Color kBg = Color(0xFFF5F7FA);
const Color kCard = Colors.white;
const Color kTextPrimary = Color(0xFF1A1A2E);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kDivider = Color(0xFFE5E7EB);
const Color kSurface = Color(0xFFFFFFFF);
const Color kOnlineGreen = Color(0xFF22C55E);

const LinearGradient kPrimaryGradient = LinearGradient(
  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─────────────────────────────────────────────────────────────────────────────
// FARMER DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────
class NearbyFarmer {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String specialty;
  final int distance; // in km
  final bool isOnline;
  final Color avatarColor;
  final String phoneNumber;
  final String expertise;
  final double rating;

  NearbyFarmer({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.specialty,
    required this.distance,
    this.isOnline = false,
    required this.avatarColor,
    required this.phoneNumber,
    required this.expertise,
    required this.rating,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// DUMMY NEARBY FARMERS
// ─────────────────────────────────────────────────────────────────────────────
final List<NearbyFarmer> dummyNearbyFarmers = [
  NearbyFarmer(
    id: '1',
    name: 'Rajesh Kumar',
    latitude: 28.6139,
    longitude: 77.2090,
    specialty: 'Rice Cultivation',
    distance: 2,
    isOnline: true,
    avatarColor: Color(0xFF1565C0),
    phoneNumber: '+91-9876543210',
    expertise: 'Organic Farming, Irrigation',
    rating: 4.8,
  ),
  NearbyFarmer(
    id: '2',
    name: 'Priya Patel',
    latitude: 28.6200,
    longitude: 77.2150,
    specialty: 'Vegetable Gardening',
    distance: 3,
    isOnline: true,
    avatarColor: Color(0xFF7B1FA2),
    phoneNumber: '+91-9876543211',
    expertise: 'Organic Vegetables, Pest Management',
    rating: 4.6,
  ),
  NearbyFarmer(
    id: '3',
    name: 'Ramesh Yadav',
    latitude: 28.6050,
    longitude: 77.2050,
    specialty: 'Wheat & Pulses',
    distance: 1,
    isOnline: false,
    avatarColor: Color(0xFFD84315),
    phoneNumber: '+91-9876543212',
    expertise: 'Soil Health, Fertilizers',
    rating: 4.5,
  ),
  NearbyFarmer(
    id: '4',
    name: 'Anita Sharma',
    latitude: 28.6180,
    longitude: 77.2120,
    specialty: 'Dairy Farming',
    distance: 4,
    isOnline: true,
    avatarColor: Color(0xFF00838F),
    phoneNumber: '+91-9876543213',
    expertise: 'Cattle Care, Dairy Production',
    rating: 4.7,
  ),
  NearbyFarmer(
    id: '5',
    name: 'Sunil Verma',
    latitude: 28.6100,
    longitude: 77.2080,
    specialty: 'Fruit Orchard',
    distance: 5,
    isOnline: false,
    avatarColor: Color(0xFF5D4037),
    phoneNumber: '+91-9876543214',
    expertise: 'Fruit farming, Weather Management',
    rating: 4.4,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// NEARBY FARMERS MAP SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class NearbyFarmersMapScreen extends StatefulWidget {
  const NearbyFarmersMapScreen({super.key});

  @override
  State<NearbyFarmersMapScreen> createState() => _NearbyFarmersMapScreenState();
}

class _NearbyFarmersMapScreenState extends State<NearbyFarmersMapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(28.6139, 77.2090);
  late List<NearbyFarmer> _nearbyFarmers;
  late List<NearbyFarmer> _filteredFarmers;
  NearbyFarmer? _selectedFarmer;
  bool _isLoadingLocation = false;
  final TextEditingController _searchCtrl = TextEditingController();
  int _distanceFilter = 10;

  @override
  void initState() {
    super.initState();
    _nearbyFarmers = List.from(dummyNearbyFarmers);
    _filteredFarmers = List.from(dummyNearbyFarmers);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
      } else {
        final position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _mapController.move(_currentLocation, 14);
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _filterFarmers(String query) {
    setState(() {
      _filteredFarmers =
          _nearbyFarmers
              .where(
                (farmer) =>
                    farmer.name.toLowerCase().contains(query.toLowerCase()) ||
                    farmer.specialty.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    farmer.expertise.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .where((farmer) => farmer.distance <= _distanceFilter)
              .toList();
    });
  }

  void _updateDistanceFilter(int distance) {
    setState(() {
      _distanceFilter = distance;
      _filterFarmers(_searchCtrl.text);
    });
  }

  void _communicateWithFarmer(NearbyFarmer farmer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _CommunicationBottomSheet(farmer: farmer),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(gradient: kPrimaryGradient),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Nearby Farmers',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Find & Connect',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.my_location_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: _getCurrentLocation,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 14,
              maxZoom: 18,
              minZoom: 5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.krishi.sakhi',
              ),
              MarkerLayer(
                markers: [
                  // Current location marker
                  Marker(
                    point: _currentLocation,
                    width: 80,
                    height: 80,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: kPrimary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: kPrimary.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Farmer markers
                  ..._filteredFarmers.map((farmer) {
                    final isSelected = _selectedFarmer?.id == farmer.id;
                    return Marker(
                      point: LatLng(farmer.latitude, farmer.longitude),
                      width: 80,
                      height: 90,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFarmer = farmer),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isSelected ? 60 : 50,
                              height: isSelected ? 60 : 50,
                              decoration: BoxDecoration(
                                color: farmer.avatarColor,
                                shape: BoxShape.circle,
                                boxShadow:
                                    isSelected
                                        ? [
                                          BoxShadow(
                                            color: farmer.avatarColor
                                                .withOpacity(0.6),
                                            blurRadius: 16,
                                            spreadRadius: 4,
                                          ),
                                        ]
                                        : [
                                          BoxShadow(
                                            color: farmer.avatarColor
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                border:
                                    isSelected
                                        ? Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        )
                                        : null,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    farmer.name[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  if (farmer.isOnline)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: kOnlineGreen,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),

          // Filters Panel (Top)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search bar
                  TextField(
                    controller: _searchCtrl,
                    onChanged: _filterFarmers,
                    decoration: InputDecoration(
                      hintText: 'Search farmers by name or specialty...',
                      hintStyle: TextStyle(
                        color: kTextSecondary.withOpacity(0.6),
                        fontSize: 13,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.search_rounded,
                          color: kTextSecondary,
                          size: 20,
                        ),
                      ),
                      suffixIcon:
                          _searchCtrl.text.isNotEmpty
                              ? GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  _filterFarmers('');
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: kTextSecondary,
                                  size: 18,
                                ),
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kDivider),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  // Distance filter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Distance Radius',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kTextSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_distanceFilter}km',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: kPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _distanceFilter.toDouble(),
                        min: 1,
                        max: 25,
                        divisions: 24,
                        activeColor: kPrimary,
                        inactiveColor: kDivider,
                        onChanged:
                            (value) => _updateDistanceFilter(value.toInt()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Farmers List panel (Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: kDivider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nearby Farmers',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: kTextPrimary,
                              ),
                            ),
                            Text(
                              '${_filteredFarmers.length} found ${_filteredFarmers.length != _nearbyFarmers.length ? '(of ${_nearbyFarmers.length})' : ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: kTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_filteredFarmers.fold<int>(0, (sum, f) => sum + f.distance)} km avg',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: kPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Farmers list
                  Expanded(
                    child:
                        _filteredFarmers.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off_rounded,
                                    size: 48,
                                    color: kTextSecondary.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No farmers found',
                                    style: TextStyle(
                                      color: kTextSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: _filteredFarmers.length,
                              itemBuilder: (context, index) {
                                final farmer = _filteredFarmers[index];
                                final isSelected =
                                    _selectedFarmer?.id == farmer.id;
                                return _FarmerTile(
                                  farmer: farmer,
                                  isSelected: isSelected,
                                  onTap:
                                      () => setState(
                                        () => _selectedFarmer = farmer,
                                      ),
                                  onCommunicate:
                                      () => _communicateWithFarmer(farmer),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isLoadingLocation)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: kPrimary),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FARMER TILE
// ─────────────────────────────────────────────────────────────────────────────
class _FarmerTile extends StatelessWidget {
  final NearbyFarmer farmer;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onCommunicate;

  const _FarmerTile({
    required this.farmer,
    required this.isSelected,
    required this.onTap,
    required this.onCommunicate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary.withOpacity(0.05) : kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected
                    ? kPrimary.withOpacity(0.3)
                    : kDivider.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: farmer.avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      farmer.name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                if (farmer.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: kOnlineGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          farmer.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${farmer.rating}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: farmer.avatarColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          farmer.specialty,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: farmer.avatarColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: kTextSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${farmer.distance} km',
                        style: const TextStyle(
                          fontSize: 11,
                          color: kTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Communicate button
            GestureDetector(
              onTap: onCommunicate,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_rounded,
                  color: Colors.white,
                  size: 18,
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
// COMMUNICATION BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _CommunicationBottomSheet extends StatelessWidget {
  final NearbyFarmer farmer;

  const _CommunicationBottomSheet({required this.farmer});

  void _launchPhone(BuildContext context, String phoneNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Would call: $phoneNumber'),
        backgroundColor: kPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kDivider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Farmer info
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: farmer.avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        farmer.name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      if (farmer.isOnline)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: kOnlineGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            farmer.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: kTextPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: kOnlineGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            farmer.isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color:
                                  farmer.isOnline
                                      ? kOnlineGreen
                                      : kTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      farmer.specialty,
                      style: TextStyle(fontSize: 12, color: kTextSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: kDivider.withOpacity(0.5)),
          const SizedBox(height: 16),
          // Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Expertise',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                farmer.expertise,
                style: const TextStyle(
                  fontSize: 13,
                  color: kTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distance',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${farmer.distance} km away',
                      style: const TextStyle(
                        fontSize: 13,
                        color: kTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rating',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${farmer.rating}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: kTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    _launchPhone(context, farmer.phoneNumber);
                  },
                  icon: const Icon(Icons.call_rounded, size: 18),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimary,
                    side: const BorderSide(color: kPrimary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Started chat with ${farmer.name}'),
                        backgroundColor: kPrimary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message_rounded, size: 18),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Close'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kTextSecondary,
                side: BorderSide(color: kDivider.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

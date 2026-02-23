import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(
    const MaterialApp(
      home: FarmlandMapScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class FarmlandMapScreen extends StatefulWidget {
  const FarmlandMapScreen({super.key});

  @override
  State<FarmlandMapScreen> createState() => _FarmlandMapScreenState();
}

class _FarmlandMapScreenState extends State<FarmlandMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  List<Polygon> _farmlandPolygons = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // 1. Get the Farmer's Real-Time Location
  Future<void> _getUserLocation() async {
    setState(() => _isLoading = true);

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController.move(_currentLocation!, 14.0);

      // Fetch farmlands once we have the location
      await _fetchFarmlands(position.latitude, position.longitude);
    }
    setState(() => _isLoading = false);
  }

  // 2 & 3. Fetch ONLY Farming/Plain Land via Overpass API
  Future<void> _fetchFarmlands(double lat, double lon) async {
    // Overpass QL Query: Searches for farmland, meadow, and grassland within a 2000m radius
    final query = """
      [out:json][timeout:25];
      (
        way["landuse"="farmland"](around:2000, $lat, $lon);
        way["landuse"="meadow"](around:2000, $lat, $lon);
        way["natural"="grassland"](around:2000, $lat, $lon);
      );
      out geom;
    """;

    final url = Uri.parse('https://overpass-api.de/api/interpreter');

    try {
      final response = await http.post(url, body: {'data': query});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Polygon> fetchedPolygons = [];

        // Parse the JSON and draw the Polygons
        for (var element in data['elements']) {
          if (element['type'] == 'way' && element['geometry'] != null) {
            List<LatLng> points = [];
            for (var node in element['geometry']) {
              points.add(LatLng(node['lat'], node['lon']));
            }
            fetchedPolygons.add(
              Polygon(
                points: points,
                color: Colors.green.withOpacity(0.4),
                borderColor: Colors.green,
                borderStrokeWidth: 2,
              ),
            );
          }
        }
        setState(() {
          _farmlandPolygons = fetchedPolygons;
        });
      }
    } catch (e) {
      debugPrint("Error fetching farmlands: $e");
    }
  }

  // 4. Navigate to the selected Farm
  Future<void> _navigateToFarm(LatLng destination) async {
    // Uses Google Maps for turn-by-turn routing to the farm
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Could not launch maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmland Navigator'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(
                20.5937,
                78.9629,
              ), // Default center (India)
              initialZoom: 5.0,
              onTap: (tapPosition, point) {
                // If a user taps the map, ask if they want to navigate there
                // (In a full production app, you would use Point-in-Polygon math
                // here to ensure they actually tapped inside a green polygon)
                showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text("Navigate to Farm?"),
                        content: const Text(
                          "Do you want to start routing to this location?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _navigateToFarm(point);
                            },
                            child: const Text("Go"),
                          ),
                        ],
                      ),
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.farmland_app',
              ),
              PolygonLayer(polygons: _farmlandPolygons),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getUserLocation,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

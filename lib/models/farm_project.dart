import 'package:latlong2/latlong.dart';

/// Model class for farm project data passed between screens.
class FarmProject {
  final String farmName;
  final String locationName;
  final LatLng location;
  final double acres;
  final List<LatLng> polygonPoints;
  final String cropName;
  final Set<String> irrigationMethods;
  final int farmerLevel;

  const FarmProject({
    required this.farmName,
    required this.locationName,
    required this.location,
    required this.acres,
    required this.polygonPoints,
    required this.cropName,
    required this.irrigationMethods,
    required this.farmerLevel,
  });

  /// Calculate area in acres from polygon points using Shoelace formula.
  double get calculatedAreaAcres {
    if (polygonPoints.length < 3) return acres;
    double area = 0;
    for (int i = 0; i < polygonPoints.length; i++) {
      final j = (i + 1) % polygonPoints.length;
      final lat1 = polygonPoints[i].latitude * 3.141592653589793 / 180;
      final lat2 = polygonPoints[j].latitude * 3.141592653589793 / 180;
      final lng1 = polygonPoints[i].longitude * 3.141592653589793 / 180;
      final lng2 = polygonPoints[j].longitude * 3.141592653589793 / 180;
      area += (lng2 - lng1) * (2 + (lat1).abs() + (lat2).abs());
    }
    area = area.abs() * 6378137 * 6378137 / 2;
    return area / 4046.86;
  }

  /// Get center point of the polygon.
  LatLng get polygonCenter {
    if (polygonPoints.isEmpty) return location;
    double lat = 0, lng = 0;
    for (final p in polygonPoints) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / polygonPoints.length, lng / polygonPoints.length);
  }
}

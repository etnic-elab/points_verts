import 'dart:math';

import 'package:maps_api/maps_api.dart' show Geolocation;

class DistanceCalculator {
  /// Earth's radius in meters
  static const double earthRadius = 6371000;

  /// Calculates the distance between two points using the Haversine formula.
  ///
  /// Returns the distance in meters.
  ///
  /// The Haversine formula determines the great-circle distance between two points
  /// on a sphere given their latitudes and longitudes.
  static double haversine(Geolocation start, Geolocation end) {
    final lat1 = start.latitude * (pi / 180);
    final lat2 = end.latitude * (pi / 180);
    final deltaLat = (end.latitude - start.latitude) * (pi / 180);
    final deltaLon = (end.longitude - start.longitude) * (pi / 180);

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}

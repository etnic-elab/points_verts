import 'package:meta_points_verts_adeps_api/src/models/lat_lng.dart';

class GeofilterDistance {
  const GeofilterDistance({
    required this.latLng,
    required this.distance,
  });

  final LatLng latLng;
  final int distance;

  @override
  String toString() => '$latLng,$distance';
}

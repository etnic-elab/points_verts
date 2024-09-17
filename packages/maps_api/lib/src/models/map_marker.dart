import 'package:maps_api/src/models/models.dart';

class MapMarker {
  MapMarker({
    required this.geolocation,
    this.iconUrl,
    this.anchor,
    this.scale,
  });

  final Geolocation geolocation;
  final String? iconUrl;
  final String? anchor;
  final int? scale;
}

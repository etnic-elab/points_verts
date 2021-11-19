import 'package:flutter_map/flutter_map.dart' as flutter;
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;

abstract class MarkerInterface {
  flutter.Marker buildFlutterMarker();
  google.Marker buildGoogleMarker(
      Map<dynamic, google.BitmapDescriptor> mapIcons);
}

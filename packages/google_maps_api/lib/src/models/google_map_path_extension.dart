import 'package:google_maps_api/src/models/google_color_extension.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:maps_api/maps_api.dart';

extension GoogleMapPathExtension on MapPath {
  String toGoogleEncode() {
    return [
      'color:${color.toGoogleMapsFormat(withAlpha: true)}',
      'weight:${weight ?? 3}',
      'enc:${encodePolyline(points)}',
    ].join('|');
  }
}

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xml/xml.dart';

class PathPoint {
  PathPoint({required this.latLng, this.elevation});

  final LatLng latLng;
  final double? elevation;

  factory PathPoint.fromXmlElement(XmlElement element) {
    double? latitude = double.parse(element.getAttribute('lat')!);
    double? longitude = double.parse(element.getAttribute('lon')!);
    double? elevation =
        double.tryParse(element.getElement('ele')?.text ?? '-0xFF');

    return PathPoint(latLng: LatLng(latitude, longitude), elevation: elevation);
  }

  @override
  String toString() => '${latLng.latitude},${latLng.longitude}';
}

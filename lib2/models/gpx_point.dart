import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xml/xml.dart';

class GpxPoint {
  GpxPoint({required this.latLng, this.elevation});

  factory GpxPoint.fromXmlElement(XmlElement element) {
    final latitude = double.parse(element.getAttribute('lat')!);
    final longitude = double.parse(element.getAttribute('lon')!);
    final elevation = double.tryParse(
        element.getElement('ele')?.firstChild?.value ?? '-0xFF',);

    return GpxPoint(latLng: LatLng(latitude, longitude), elevation: elevation);
  }

  final LatLng latLng;
  final double? elevation;

  @override
  String toString() => '${latLng.latitude},${latLng.longitude}';
}

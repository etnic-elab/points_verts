import 'package:maps_api/maps_api.dart' show Geolocation;
import 'package:trail_parser_api/trail_parser_api.dart'
    show TrailInfo, TrailParser, TrailParserException, TrailPoint;
import 'package:xml/xml.dart';

class KmlParser implements TrailParser {
  @override
  bool canHandle(String fileExtension) => fileExtension.toLowerCase() == '.kml';

  @override
  Future<TrailInfo> parse(String content) async {
    try {
      final xmlDoc = XmlDocument.parse(content);
      final points = _findPoints(xmlDoc);

      if (points.isEmpty) {
        throw const FormatException('No valid coordinates found in KML file');
      }

      return TrailInfo(
        points: points,
      );
    } catch (e) {
      throw TrailParserException();
    }
  }

  List<TrailPoint> _findPoints(XmlDocument doc) {
    final points = <TrailPoint>[];

    // Look for coordinates in LineString and LinearRing elements
    for (final element in [
      ...doc.findAllElements('LineString'),
      ...doc.findAllElements('LinearRing'),
    ]) {
      final coordsElement = element.findElements('coordinates').firstOrNull;
      final coordsValue = coordsElement?.value;

      if (coordsValue != null) {
        final coordsList =
            coordsValue.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty);

        for (final coords in coordsList) {
          final parts = coords.split(',');
          if (parts.length >= 2) {
            final lon = double.tryParse(parts[0]);
            final lat = double.tryParse(parts[1]);
            final ele = parts.length > 2 ? double.tryParse(parts[2]) : null;

            if (lon != null && lat != null) {
              points.add(
                TrailPoint(
                  location: Geolocation(
                    longitude: lon,
                    latitude: lat,
                  ),
                  elevation: ele,
                ),
              );
            }
          }
        }
      }
    }

    return points;
  }
}

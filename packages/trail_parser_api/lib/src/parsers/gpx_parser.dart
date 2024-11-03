import 'package:maps_api/maps_api.dart' show Geolocation;
import 'package:trail_parser_api/trail_parser_api.dart'
    show Trail, TrailParser, TrailParserException, TrailPoint;
import 'package:xml/xml.dart';

class GpxParser implements TrailParser {
  @override
  bool canHandle(String fileExtension) => fileExtension.toLowerCase() == '.gpx';

  @override
  Future<Trail> parse(String content) async {
    try {
      final xmlDoc = XmlDocument.parse(content);

      // Try to find points in order of preference
      final points = _findPoints(xmlDoc);

      if (points.isEmpty) {
        throw const FormatException('No valid track points found in GPX file');
      }

      return Trail(
        points: points,
      );
    } catch (e) {
      throw TrailParserException();
    }
  }

  List<TrailPoint> _findPoints(XmlDocument doc) {
    // Try different GPX elements in order of preference
    final pointsElements = [
      ...doc.findAllElements('trkpt'),
      ...doc.findAllElements('rtept'),
      ...doc.findAllElements('wpt'),
    ];

    return pointsElements.map((element) {
      final lat = double.parse(element.getAttribute('lat') ?? '0');
      final lon = double.parse(element.getAttribute('lon') ?? '0');

      // Parse elevation (might be in 'ele' or 'elevation' tag)
      double? elevation;
      final eleElement = element.findElements('ele').firstOrNull ??
          element.findElements('elevation').firstOrNull;
      final eleValue = eleElement?.value;

      if (eleValue != null) {
        elevation = double.tryParse(eleValue);
      }

      return TrailPoint(
        location: Geolocation(
          latitude: lat,
          longitude: lon,
        ),
        elevation: elevation,
      );
    }).toList();
  }
}

import 'package:http/http.dart' as http;
import 'package:points_verts/extensions.dart';
import 'package:points_verts/services/cache_managers/gpx_cache_manager.dart';
import 'package:xml/xml.dart';

import '../models/gpx_point.dart';

enum GpxCourse { track, route, waypoints }

Future<List<GpxPoint>> retrieveGpxPoints(String url) async {
  try {
    final response = await GpxCacheManager.gpx.getData(url);
    if (response.statusCode == 200) {
      XmlDocument xmlFile;

      xmlFile = XmlDocument.parse(response.body);

      Iterable<XmlElement> course;
      course = _largestCourse(xmlFile, GpxCourse.track);

      if (course.isEmpty) {
        course = _largestCourse(xmlFile, GpxCourse.route);
      }
      if (course.isEmpty) {
        course = xmlFile.findAllElements(GpxCourse.waypoints.point);
      }

      final var gpxPoints = <GpxPoint>[];
      for (final element in course) {
        try {
          final var point = GpxPoint.fromXmlElement(element);
          gpxPoints.add(point);
        } catch (err) {
          print('Cannot create GpxPoint from XmlElement: $err');
        }
      }

      return gpxPoints;
    } else {
      print('Failed to load gpx-file: $response');
    }
  } catch (err) {
    print('A problem occured parsing gpx file: $err');
  }

  return [];
}

Iterable<XmlElement> _largestCourse(XmlDocument xmlFile, GpxCourse gpxCourse) {
  final Iterable<XmlElement> course = xmlFile.findAllElements(gpxCourse.segment);

  if (course.isEmpty) return course;

  return course
      .map((path) => path.findElements(gpxCourse.point))
      .reduce((curr, next) => curr.length > next.length ? curr : next);
}

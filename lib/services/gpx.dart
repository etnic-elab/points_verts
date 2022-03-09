import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/path_point.dart';

import 'package:points_verts/services/cache_managers/gpx_cache_manager.dart';

enum GpxCourse { track, route, waypoints }

extension GpxCourseExtension on GpxCourse {
  String get segment {
    switch (this) {
      case GpxCourse.track:
        return 'trkseg';
      case GpxCourse.route:
        return 'rte';
      case GpxCourse.waypoints:
        return 'wpt';
    }
  }

  String get point {
    switch (this) {
      case GpxCourse.track:
        return 'trkpt';
      case GpxCourse.route:
        return 'rtept';
      case GpxCourse.waypoints:
        return 'wpt';
    }
  }
}

Future<List<PathPoint>> retrievePathPoints(String url) async {
  final http.Response response = await GpxCacheManager.gpx.getData(url);
  if (response.statusCode == 200) {
    XmlDocument xmlFile;
    try {
      xmlFile = XmlDocument.parse(response.body);

      Iterable<XmlElement> course;
      course = _largestCourse(xmlFile, GpxCourse.track);

      if (course.isEmpty) {
        course = _largestCourse(xmlFile, GpxCourse.route);
      }
      if (course.isEmpty) {
        course = xmlFile.findAllElements(GpxCourse.waypoints.point);
      }

      List<PathPoint> pathPoints = [];
      for (XmlElement element in course) {
        try {
          PathPoint point = PathPoint.fromXmlElement(element);
          pathPoints.add(point);
        } catch (err) {
          print("Cannot create PathPoint from XmlElement: $err");
        }
      }

      return pathPoints;
    } catch (err) {
      print("A problem occured parsing gpx file: $err");
    }
  } else {
    print('Failed to load gpx-file: $response');
  }

  return [];
}

Iterable<XmlElement> _largestCourse(XmlDocument xmlFile, GpxCourse gpxCourse) {
  Iterable<XmlElement> course = xmlFile.findAllElements(gpxCourse.segment);

  if (course.isEmpty) return course;

  return course
      .map((path) => path.findElements(gpxCourse.point))
      .reduce((curr, next) => curr.length > next.length ? curr : next);
}

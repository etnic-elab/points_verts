import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/gpx_point.dart';

import 'package:points_verts/services/cache_managers/gpx_cache_manager.dart';

Future<List<GpxPoint>> retrieveGpxPoints(String url) async {
  final http.Response response = await GpxCacheManager.gpx.getData(url);
  if (response.statusCode == 200) {
    XmlDocument xmlFile;
    try {
      xmlFile = XmlDocument.parse(response.body);

      Iterable<XmlElement> course;
      course = _largestCourse(xmlFile, _Course.track);

      if (course.isEmpty) {
        course = _largestCourse(xmlFile, _Course.route);
      }
      if (course.isEmpty) {
        course = xmlFile.findAllElements(_Course.waypoints.point);
      }

      List<GpxPoint> gpxPoints = [];
      for (XmlElement element in course) {
        try {
          GpxPoint point = GpxPoint.fromXmlElement(element);
          gpxPoints.add(point);
        } catch (err) {
          print("Cannot create GpxPoint from XmlElement: $err");
        }
      }

      return gpxPoints;
    } catch (err) {
      print("A problem occured parsing gpx file: $err");
    }
  } else {
    print('Failed to load gpx-file: $response');
  }

  return [];
}

Iterable<XmlElement> _largestCourse(XmlDocument xmlFile, _Course gpxCourse) {
  Iterable<XmlElement> course = xmlFile.findAllElements(gpxCourse.segment);

  if (course.isEmpty) return course;

  return course
      .map((path) => path.findElements(gpxCourse.point))
      .reduce((curr, next) => curr.length > next.length ? curr : next);
}

enum _Course { track, route, waypoints }

extension GpxCourseExtension on _Course {
  String get segment {
    switch (this) {
      case _Course.track:
        return 'trkseg';
      case _Course.route:
        return 'rte';
      case _Course.waypoints:
        return 'wpt';
    }
  }

  String get point {
    switch (this) {
      case _Course.track:
        return 'trkpt';
      case _Course.route:
        return 'rtept';
      case _Course.waypoints:
        return 'wpt';
    }
  }
}

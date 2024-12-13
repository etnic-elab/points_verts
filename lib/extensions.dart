import 'package:flutter/material.dart';
import 'package:points_verts/company_data.dart';

import 'package:points_verts/services/assets.dart';
import 'package:points_verts/services/gpx.dart';
import 'package:points_verts/views/maps/google_map.dart';
import 'package:points_verts/views/walks/walks_view.dart';

extension ColorX on Color {
  toHex({bool transparancy = false}) {
    return '0x'
        '${(r * 255).toInt().toRadixString(16).padLeft(2, '0')}'
        '${(g * 255).toInt().toRadixString(16).padLeft(2, '0')}'
        '${(b * 255).toInt().toRadixString(16).padLeft(2, '0')}'
        '${transparancy ? (a * 255).toInt().toRadixString(16).padLeft(2, '0') : ''}';
  }
}

extension GpxCourseX on GpxCourse {
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

extension GoogleMapIconsX on GoogleMapIcons {
  String get logo {
    switch (this) {
      case GoogleMapIcons.unselectedWalkIcon:
      case GoogleMapIcons.selectedWalkIcon:
        return Assets.logo;
      case GoogleMapIcons.unselectedCancelIcon:
      case GoogleMapIcons.selectedCancelIcon:
        return Assets.logoAnnule;
    }
  }

  Color get color {
    switch (this) {
      case GoogleMapIcons.unselectedWalkIcon:
      case GoogleMapIcons.unselectedCancelIcon:
        return CompanyColors.darkGreen;
      case GoogleMapIcons.selectedWalkIcon:
      case GoogleMapIcons.selectedCancelIcon:
        return CompanyColors.lightestGreen;
    }
  }
}

extension PlacesX on Places {
  IconData get icon {
    switch (this) {
      case Places.current:
        return Icons.location_on;
      case Places.home:
        return Icons.home;
    }
  }

  String get text {
    switch (this) {
      case Places.current:
        return "localisation";
      case Places.home:
        return "domicile";
    }
  }
}

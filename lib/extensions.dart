import 'package:flutter/material.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/services/gpx.dart';
import 'package:points_verts/services/map/googlemaps.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/mapbox.dart';
import 'package:points_verts/views/maps/google_map.dart';
import 'package:points_verts/views/walks/walks_view.dart';

extension ColorExt on Color {
  toHex({bool transparancy = false}) {
    return '0x'
        '${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}'
        '${transparancy ? alpha.toRadixString(16).padLeft(2, '0') : ''}';
  }
}

extension MapsExtension on Maps {
  String get api {
    switch (this) {
      case Maps.google:
        return 'Google';
      case Maps.mapbox:
        return 'MapBox';
    }
  }

  String get website {
    switch (this) {
      case Maps.google:
        return 'https://mapsplatform.google.com/';
      case Maps.mapbox:
        return 'https://www.mapbox.com';
    }
  }

  MapInterface get instance {
    switch (this) {
      case Maps.google:
        return GoogleMaps();
      case Maps.mapbox:
        return MapBox();
    }
  }

  String get key {
    switch (this) {
      case Maps.google:
        return 'GOOGLEMAPS_API_KEY';
      case Maps.mapbox:
        return 'MAPBOX_TOKEN';
    }
  }
}

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

extension GoogleMapIconsExtension on GoogleMapIcons {
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

extension PlacesExtension on Places {
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

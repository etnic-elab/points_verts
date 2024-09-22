import 'dart:ui';

import 'package:maps_api/maps_api.dart';

class GoogleMapStyle {
  GoogleMapStyle(
    this.mapType,
    this.brightness,
  );

  final MapType mapType;
  final Brightness brightness;

  Map<String, String> toParams() {
    switch (brightness) {
      case Brightness.light:
        return {'maptype': _getLightModeMapType()};
      case Brightness.dark:
        return {'style': _getDarkModeStyle().join('&style=')};
    }
  }

  String _getLightModeMapType() {
    switch (mapType) {
      case MapType.road:
        return 'roadmap';
      case MapType.satellite:
        return 'satellite';
      case MapType.terrain:
        return 'terrain';
      case MapType.hybrid:
        return 'hybrid';
    }
  }

  List<String> _getDarkModeStyle() {
    switch (mapType) {
      case MapType.road:
        return _darkRoadmapStyles;
      case MapType.satellite:
        return _darkSatelliteStyles;
      case MapType.terrain:
        return _darkTerrainStyles;
      case MapType.hybrid:
        return _darkHybridStyles;
    }
  }

  static const List<String> _darkRoadmapStyles = [
    'element:geometry|color:0x212121',
    'element:labels.icon|visibility:off',
    'element:labels.text.fill|color:0x757575',
    'element:labels.text.stroke|color:0x212121',
    'feature:administrative|element:geometry|color:0x757575',
    'feature:administrative.country|element:labels.text.fill|color:0x9e9e9e',
    'feature:administrative.land_parcel|visibility:off',
    'feature:administrative.locality|element:labels.text.fill|color:0xbdbdbd',
    'feature:poi|element:labels.text.fill|color:0x757575',
    'feature:poi.park|element:geometry|color:0x181818',
    'feature:poi.park|element:labels.text.fill|color:0x616161',
    'feature:road|element:geometry.fill|color:0x2c2c2c',
    'feature:road|element:labels.text.fill|color:0x8a8a8a',
    'feature:road.arterial|element:geometry|color:0x373737',
    'feature:road.highway|element:geometry|color:0x3c3c3c',
    'feature:road.highway.controlled_access|element:geometry|color:0x4e4e4e',
    'feature:road.local|element:labels.text.fill|color:0x616161',
    'feature:transit|element:labels.text.fill|color:0x757575',
    'feature:water|element:geometry|color:0x000000',
    'feature:water|element:labels.text.fill|color:0x3d3d3d',
  ];

  static const List<String> _darkSatelliteStyles = [
    'element:labels.text.fill|color:0x757575',
    'element:labels.text.stroke|color:0x212121',
    'feature:administrative|element:geometry|color:0x757575|visibility:off',
    'feature:administrative.country|element:labels.text.fill|color:0x9e9e9e',
    'feature:administrative.land_parcel|visibility:off',
    'feature:administrative.locality|element:labels.text.fill|color:0xbdbdbd',
    'feature:poi|element:labels.text.fill|color:0x757575',
    'feature:poi|element:labels.text.stroke|color:0x212121',
    'feature:road|element:geometry.fill|color:0x2c2c2c',
    'feature:road|element:labels.text.fill|color:0x8a8a8a',
    'feature:road|element:labels.text.stroke|color:0x212121',
    'feature:transit|element:labels.text.fill|color:0x757575',
    'feature:transit|element:labels.text.stroke|color:0x212121',
    'feature:water|element:labels.text.fill|color:0x3d3d3d',
    'feature:water|element:labels.text.stroke|color:0x212121',
  ];

  static const List<String> _darkTerrainStyles = [
    'element:geometry|color:0x212121',
    'element:labels.text.fill|color:0x757575',
    'element:labels.text.stroke|color:0x212121',
    'feature:administrative|element:geometry|color:0x757575',
    'feature:administrative.country|element:labels.text.fill|color:0x9e9e9e',
    'feature:administrative.land_parcel|visibility:off',
    'feature:administrative.locality|element:labels.text.fill|color:0xbdbdbd',
    'feature:poi|element:labels.text.fill|color:0x757575',
    'feature:poi.park|element:geometry|color:0x181818',
    'feature:poi.park|element:labels.text.fill|color:0x616161',
    'feature:road|element:geometry.fill|color:0x2c2c2c',
    'feature:road|element:labels.text.fill|color:0x8a8a8a',
    'feature:road.arterial|element:geometry|color:0x373737',
    'feature:road.highway|element:geometry|color:0x3c3c3c',
    'feature:road.highway.controlled_access|element:geometry|color:0x4e4e4e',
    'feature:road.local|element:labels.text.fill|color:0x616161',
    'feature:transit|element:labels.text.fill|color:0x757575',
    'feature:water|element:geometry|color:0x000000',
    'feature:water|element:labels.text.fill|color:0x3d3d3d',
  ];

  static const List<String> _darkHybridStyles = [
    'element:geometry|color:0x212121',
    'element:labels.text.fill|color:0x757575',
    'element:labels.text.stroke|color:0x212121',
    'feature:administrative|element:geometry|color:0x757575',
    'feature:administrative.country|element:labels.text.fill|color:0x9e9e9e',
    'feature:administrative.land_parcel|visibility:off',
    'feature:administrative.locality|element:labels.text.fill|color:0xbdbdbd',
    'feature:poi|element:labels.text.fill|color:0x757575',
    'feature:poi|element:labels.text.stroke|color:0x212121',
    'feature:road|element:geometry.fill|color:0x2c2c2c',
    'feature:road|element:labels.text.fill|color:0x8a8a8a',
    'feature:road|element:labels.text.stroke|color:0x212121',
    'feature:road.arterial|element:geometry|color:0x373737',
    'feature:road.highway|element:geometry|color:0x3c3c3c',
    'feature:road.highway.controlled_access|element:geometry|color:0x4e4e4e',
    'feature:road.local|element:labels.text.fill|color:0x616161',
    'feature:transit|element:labels.text.fill|color:0x757575',
    'feature:transit|element:labels.text.stroke|color:0x212121',
    'feature:water|element:geometry|color:0x000000',
    'feature:water|element:labels.text.fill|color:0x3d3d3d',
    'feature:water|element:labels.text.stroke|color:0x212121',
  ];
}

import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:points_verts/services/map/googlemaps.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/mapbox.dart';

enum Maps { google, mapbox }

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

const String tag = "dev.alpagaga.points_verts.Environment";

class Environment {
  static final String? openWeatherToken = dotenv.env['OPENWEATHER_TOKEN'];
  static Maps? map;
  //TODO: initialize singleton
  static MapInterface? _mapInstance;

  static MapInterface get mapInterface {
    _initMapConfiguration();
    return _mapInstance!;
  }

  static String? get mapApiKey {
    _initMapConfiguration();

    return dotenv.env[map!.key];
  }

  static String get mapApi {
    _initMapConfiguration();

    return map!.api;
  }

  static String get mapWebsite {
    _initMapConfiguration();

    return map!.website;
  }

  static void _initMapConfiguration() {
    if (map == null) {
      final String? _mapApi = dotenv.env['MAP_API'];
      map = Maps.values.firstWhere((map) => map.api == _mapApi);
      _mapInstance = map!.instance;
    }
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:points_verts/services/map/googlemaps.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/mapbox.dart';

class Environment {
  static final String? openWeatherToken = dotenv.env['OPENWEATHER_TOKEN'];
  late final MapInterface _map;

  Environment() {
    _map = MapServices.values
        .firstWhere(
            (MapServices mapService) => mapService.env == dotenv.env['MAP_API'],
            orElse: () => MapServices.mapbox)
        .service;
  }

  MapInterface get map => _map;
}

enum MapServices { google, mapbox }

extension MapsExtension on MapServices {
  String get env {
    switch (this) {
      case MapServices.google:
        return 'Google';
      case MapServices.mapbox:
        return 'MapBox';
    }
  }

  MapInterface get service {
    switch (this) {
      case MapServices.google:
        return GoogleMaps();
      case MapServices.mapbox:
        return MapBox();
    }
  }
}

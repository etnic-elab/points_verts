import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'extensions.dart';

enum Maps { google, mapbox }

const String tag = "dev.alpagaga.points_verts.Environment";

class Environment {
  static final String? openWeatherToken = dotenv.env['OPENWEATHER_TOKEN'];
  static final bool deleteData =
      (int.tryParse(dotenv.env['DELETE_DATA'] ?? '') ?? 0) == 1;
  static Maps? map;
  //TODO: initialize as singleton
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
      map = Maps.values
          .firstWhere((map) => map.api == _mapApi, orElse: () => Maps.mapbox);
      _mapInstance = map!.instance;
    }
  }
}

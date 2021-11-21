import 'package:points_verts/services/cache_managers/abstract_cache_manager.dart';

class WeatherCacheManager extends AbstractCacheManager {
  WeatherCacheManager._();
  static final WeatherCacheManager weather = WeatherCacheManager._();

  @override
  String getKey() {
    return key ??= "weatherCache";
  }

  @override
  Duration getCacheDuration() {
    return cacheDuration ??= const Duration(hours: 3);
  }
}

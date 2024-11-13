import 'abstract_cache_manager.dart';

class WeatherCacheManager extends AbstractCacheManager {
  WeatherCacheManager._();
  static final WeatherCacheManager weather = WeatherCacheManager._();

  @override
  String get key => 'weatherCache';

  @override
  String get contentType => 'application/json; charset=utf-8';

  @override
  Duration get cacheDuration => const Duration(hours: 3);
}

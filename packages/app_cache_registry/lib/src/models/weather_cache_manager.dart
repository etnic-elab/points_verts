import 'package:cache_manager/cache_manager.dart';
import 'package:jsonable/jsonable.dart' show JsonMap;
import 'package:maps_api/maps_api.dart' show Geolocation;
import 'package:weather_api/weather_api.dart' show WeatherForecast;

class WeatherCacheManager extends CacheManager<List<WeatherForecast>> {
  WeatherCacheManager()
      : super(
          persistentCacheKey: 'weathers_cache',
          defaultExpiration: const Duration(hours: 3),
        );

  @override
  List<WeatherForecast> fromJsonT(dynamic json) {
    if (json is List) {
      return json
          .map((item) => WeatherForecast.fromJson(item as JsonMap))
          .toList();
    }
    throw FormatException('Expected a List, but got ${json.runtimeType}');
  }

  String generateCacheKey(Geolocation geolocation, DateTime date) {
    return '${geolocation}_${date.toIso8601String()}';
  }
}

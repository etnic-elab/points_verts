import 'dart:async' show FutureOr;

import 'package:intl/intl.dart';
import 'package:json_map_typedef/json_map_typedef.dart' show JsonMap;
import 'package:maps_api/maps_api.dart' show Geolocation;
import 'package:persistent_storage_manager/persistent_storage_manager.dart'
    show PersistentStorageManager;
import 'package:weather_api/weather_api.dart' show WeatherForecast;

class WeatherCacheManager
    extends PersistentStorageManager<List<WeatherForecast>> {
  WeatherCacheManager({
    required super.prefs,
  }) : super(persistentKey: 'weather_cache');

  Future<List<WeatherForecast>> fetchWeatherForecasts({
    required Geolocation geolocation,
    required DateTime date,
    required FutureOr<List<WeatherForecast>> Function() defaultValueProvider,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);

    final cacheKey =
        '${geolocation}_${DateFormat('yyyy-MM-dd').format(startOfDay)}';

    final weatherForecasts = await getValue(
      key: cacheKey,
      defaultValueProvider: defaultValueProvider,
    );

    if (weatherForecasts == null) {
      throw StateError(
        'Failed to fetch weather forecasts for date $startOfDay and geolocation $geolocation',
      );
    }

    return weatherForecasts;
  }

  @override
  List<WeatherForecast> fromJson(dynamic json) {
    if (json is List) {
      return json
          .map((item) => WeatherForecast.fromJson(item as JsonMap))
          .toList();
    }
    throw FormatException('Expected a List, but got ${json.runtimeType}');
  }

  @override
  List<JsonMap> toJson(List<WeatherForecast> value) =>
      value.map((v) => v.toJson()).toList();
}

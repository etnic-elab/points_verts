import 'package:http/http.dart' as http;
import 'package:maps_api/maps_api.dart' show Geolocation;
import 'package:weather_api/src/models/models.dart';

/// {@template weather_api}
/// The interface for an API that provides access to weather-related services
/// {@endtemplate}
abstract class WeatherApi {
  /// {@macro weather_api}
  const WeatherApi();

  /// The name of the map service.
  String get name;

  /// The API key for the map service.
  String get apiKey;

  /// The base URL for API requests.
  String get baseUrl;

  /// The HTTP client used for making requests.
  http.Client get httpClient;

  Future<List<WeatherForecast>> getForecast({
    required Geolocation geolocation,
    TemperatureUnits units = TemperatureUnits.kelvin,
    String lang = 'en',
    DateTime? startDate,
    DateTime? endDate,
  });
}

class WeatherForecastException implements Exception {}

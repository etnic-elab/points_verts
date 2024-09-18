import 'package:http/http.dart' as http;

/// {@template weather_api}
/// The interface for an API that provides access to weahter-related services
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

  Future<Map<String, dynamic>> getForecast({
    required double lat,
    required double lon,
    String units = 'standard',
    String lang = 'en',
  });
}

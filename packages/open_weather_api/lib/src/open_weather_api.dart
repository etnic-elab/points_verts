import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_map_typedef/json_map_typedef.dart';
import 'package:maps_api/maps_api.dart' show Geolocation;
import 'package:open_weather_api/src/models/models.dart';
import 'package:weather_api/weather_api.dart';

/// {@template open_weather_api}
/// A flutter implementation of the weather_api using the OpenWeatherMap services
/// {@endtemplate}
class OpenWeatherApi implements WeatherApi {
  /// {@macro open_weather_api}
  OpenWeatherApi({
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  @override
  final String apiKey;

  @override
  String get name => 'OpenWeatherMap';

  @override
  String get baseUrl => 'api.openweathermap.org';

  @override
  http.Client get httpClient => _httpClient;

  final http.Client _httpClient;

  @override
  Future<List<WeatherForecast>> getForecast({
    required Geolocation geolocation,
    TemperatureUnits units = TemperatureUnits.celsius,
    String lang = 'fr',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final now = DateTime.now();
    final fiveDaysFromNow = now.add(const Duration(days: 5));

    // Check if the startDate is beyond the 5-day forecast period
    if (startDate != null && startDate.isAfter(fiveDaysFromNow)) {
      return []; // Return an empty list if startDate is beyond 5 days
    }

    final forecastRequest = Uri.https(
      baseUrl,
      '/data/2.5/forecast',
      {
        'lat': geolocation.latitude.toString(),
        'lon': geolocation.longitude.toString(),
        'appid': apiKey,
        'units': units.toOpenWeatherMapString(),
        'lang': lang,
      },
    );

    final forecastResponse = await httpClient.get(forecastRequest);

    if (forecastResponse.statusCode != 200) {
      throw WeatherForecastException();
    }

    final result = jsonDecode(forecastResponse.body) as JsonMap;

    if (result['cod'] != '200') {
      throw WeatherForecastException();
    }

    final forecastList = result['list'] as List<dynamic>;

    final forecasts = forecastList
        .map(
      (forecast) => WeatherForecastFactory.fromJson(
        forecast as JsonMap,
        units,
      ),
    )
        .where((forecast) {
      if (startDate != null && forecast.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && forecast.timestamp.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();

    return forecasts;
  }
}

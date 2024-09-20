import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jsonable/jsonable.dart';
import 'package:maps_api/maps_api.dart' show Geolocation;
import 'package:openweathermap_weather_api/src/models/models.dart';
import 'package:weather_api/weather_api.dart';

/// {@template openweathermap_weather_api}
/// A flutter implementation of the weather_api using the OpenWeatherMap services
/// {@endtemplate}
class OpenweathermapWeatherApi implements WeatherApi {
  /// {@macro openweathermap_weather_api}
  OpenweathermapWeatherApi({
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
    TemperatureUnits units = TemperatureUnits.kelvin,
    String lang = 'fr',
  }) async {
    final forecastRequest = Uri.https(
      baseUrl,
      '/data/2.5/forecast',
      {
        'lat': geolocation.latitude.toString(),
        'lon': geolocation.longitude.toString(),
        'appid': apiKey,
        'units': units.toOpenweathermapString(),
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

    return forecastList
        .map(
          (forecast) => WeatherForecastFactory.fromJson(
            forecast as JsonMap,
            units,
          ),
        )
        .toList();
  }
}

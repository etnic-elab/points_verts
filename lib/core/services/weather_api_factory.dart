import 'package:weather_api/weather_api.dart' show OpenWeatherApi, WeatherApi;

class WeatherApiFactory {
  static WeatherApi create({
    required String provider,
    required String apiKey,
  }) {
    switch (provider.toLowerCase()) {
      case 'openweather':
        return OpenWeatherApi(apiKey: apiKey);
      default:
        throw ArgumentError('Unsupported maps provider: $provider');
    }
  }
}

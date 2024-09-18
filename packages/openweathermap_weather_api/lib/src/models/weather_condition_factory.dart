import 'package:weather_api/weather_api.dart';

class WeatherConditionFactory {
  static WeatherCondition fromCode(int code) {
    if (code >= 200 && code < 300) {
      return WeatherCondition.thunderstorm;
    } else if (code >= 300 && code < 400) {
      return WeatherCondition.drizzle;
    } else if (code >= 500 && code < 600) {
      return WeatherCondition.rain;
    } else if (code >= 600 && code < 700) {
      return WeatherCondition.snow;
    } else if (code >= 700 && code < 800) {
      return WeatherCondition.atmosphere;
    } else if (code > 800 && code < 900) {
      return WeatherCondition.clouds;
    } else if (code == 800) {
      return WeatherCondition.clear;
    } else {
      return WeatherCondition.unknown;
    }
  }
}

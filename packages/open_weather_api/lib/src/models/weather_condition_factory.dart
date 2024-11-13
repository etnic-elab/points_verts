import 'package:weather_api/weather_api.dart';

class WeatherConditionFactory {
  static WeatherCondition fromCode(int code) {
    if (code >= 200 && code < 300) {
      return WeatherCondition.thunderstorm;
    }

    if (code >= 300 && code < 400) {
      return WeatherCondition.drizzle;
    }

    if (code >= 500 && code < 600) {
      return WeatherCondition.rain;
    }

    if (code >= 600 && code < 700) {
      return WeatherCondition.snow;
    }

    if (code >= 700 && code < 800) {
      return WeatherCondition.atmosphere;
    }

    if (code == 800) {
      return WeatherCondition.clear;
    }

    if (code > 800 && code < 900) {
      return WeatherCondition.clouds;
    }

    return WeatherCondition.unknown;
  }
}

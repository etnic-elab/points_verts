import 'package:jsonable/jsonable.dart';
import 'package:weather_api/src/models/temperature.dart';

class WeatherForecast {
  WeatherForecast({
    required this.temperature,
    required this.weatherCode,
    required this.weatherCondition,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.windSpeed,
    required this.timestamp,
    required this.cloudiness,
  });

  factory WeatherForecast.fromJson(
    JsonMap json,
    TemperatureUnits temperatureUnits,
  ) {
    final main = json['main'] as JsonMap;
    final weather = (json['weather'] as List<dynamic>).first as JsonMap;
    final wind = json['wind'] as JsonMap;
    final clouds = json['clouds'] as JsonMap;

    return WeatherForecast(
      temperature: Temperature(
        (main['temp'] as num).toDouble(),
        temperatureUnits,
      ),
      weatherCode: weather['id'] as int,
      weatherCondition: weather['main'] as String,
      weatherDescription: weather['description'] as String,
      weatherIcon: weather['icon'] as String,
      windSpeed: (wind['speed'] as num).toDouble(),
      timestamp:
          DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      cloudiness: clouds['all'] as int,
    );
  }

  final Temperature temperature;
  final int weatherCode;
  final String weatherCondition;
  final String weatherDescription;
  final String weatherIcon;
  final double windSpeed;
  final DateTime timestamp;
  final int cloudiness;

  JsonMap toJson() {
    return {
      'main': {
        'temp': temperature,
      },
      'weather': [
        {
          'id': weatherCode,
          'main': weatherCondition,
          'description': weatherDescription,
          'icon': weatherIcon,
        }
      ],
      'wind': {
        'speed': windSpeed,
      },
      'dt': timestamp.millisecondsSinceEpoch ~/ 1000,
      'clouds': {
        'all': cloudiness,
      },
    };
  }

  @override
  String toString() {
    return 'WeatherForecast('
        'temperature: $temperature, '
        'weatherCode: $weatherCode, '
        'weatherCondition: $weatherCondition, '
        'weatherDescription: $weatherDescription, '
        'weatherIcon: $weatherIcon, '
        'windSpeed: $windSpeed, '
        'timestamp: $timestamp, '
        'cloudiness: $cloudiness'
        ')';
  }
}

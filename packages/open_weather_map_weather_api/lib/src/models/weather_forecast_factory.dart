import 'package:jsonable/jsonable.dart';
import 'package:open_weather_map_weather_api/src/models/models.dart'
    show WeatherConditionFactory, WeatherIconFactory;
import 'package:weather_api/weather_api.dart';

class WeatherForecastFactory {
  static WeatherForecast fromJson(
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
      weatherCondition: WeatherConditionFactory.fromCode(weather['id'] as int),
      weatherDescription: weather['description'] as String,
      weatherIcon: WeatherIconFactory.fromCode(weather['icon'] as String),
      windSpeed: (wind['speed'] as num).toDouble(),
      timestamp:
          DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      cloudiness: clouds['all'] as int,
    );
  }
}

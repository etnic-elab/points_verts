import 'package:weather_api/weather_api.dart';

extension TemperatureUnitsExtension on TemperatureUnits {
  String toOpenWeatherMapString() {
    switch (this) {
      case TemperatureUnits.celsius:
        return 'metric';
      case TemperatureUnits.fahrenheit:
        return 'imperial';
      case TemperatureUnits.kelvin:
        return 'standard';
    }
  }
}

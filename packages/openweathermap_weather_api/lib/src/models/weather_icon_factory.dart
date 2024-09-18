import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherIconFactory {
  static final Map<String, IconData Function(bool)> _iconMapping = {
    '01': (isDay) => isDay ? WeatherIcons.day_sunny : WeatherIcons.night_clear,
    '02': (isDay) =>
        isDay ? WeatherIcons.day_cloudy : WeatherIcons.night_cloudy,
    '03': (_) => WeatherIcons.cloud,
    '04': (isDay) =>
        isDay ? WeatherIcons.day_cloudy : WeatherIcons.night_cloudy,
    '09': (isDay) =>
        isDay ? WeatherIcons.day_showers : WeatherIcons.night_showers,
    '10': (isDay) => isDay ? WeatherIcons.day_rain : WeatherIcons.night_rain,
    '11': (isDay) =>
        isDay ? WeatherIcons.day_thunderstorm : WeatherIcons.night_thunderstorm,
    '13': (isDay) => isDay ? WeatherIcons.day_snow : WeatherIcons.night_snow,
    '50': (isDay) => isDay ? WeatherIcons.day_fog : WeatherIcons.night_fog,
  };

  static IconData fromCode(String iconCode) {
    // Extract the main code and day/night indicator
    final mainCode = iconCode.substring(0, 2);
    final isDay = iconCode.endsWith('d');

    // Return the mapped icon or default to 'not available' if no match found
    return _iconMapping[mainCode]?.call(isDay) ?? WeatherIcons.na;
  }
}

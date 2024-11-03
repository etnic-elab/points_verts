import 'package:flutter/material.dart';
import 'package:json_map_typedef/json_map_typedef.dart';
import 'package:weather_api/src/models/models.dart';

class WeatherForecast {
  WeatherForecast({
    required this.temperature,
    required this.weatherCondition,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.windSpeed,
    required this.timestamp,
    required this.cloudiness,
  });

  // Add fromJson method
  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final weatherIcon = json['weatherIcon'] as JsonMap;

    return WeatherForecast(
      temperature: Temperature.fromJson(json['temperature'] as JsonMap),
      weatherCondition: WeatherCondition.values.firstWhere(
        (e) => e.toString().split('.').last == json['weatherCondition'],
        orElse: () => WeatherCondition.unknown,
      ),
      weatherDescription: json['weatherDescription'] as String,
      weatherIcon: IconData(
        weatherIcon['codePoint'] as int,
        fontFamily: weatherIcon['fontFamily'] as String?,
        fontPackage: weatherIcon['fontPackage'] as String?,
      ),
      windSpeed: json['windSpeed'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
      cloudiness: json['cloudiness'] as int,
    );
  }

  final Temperature temperature;
  final WeatherCondition weatherCondition;
  final String weatherDescription;
  final IconData weatherIcon;
  final double windSpeed;
  final DateTime timestamp;
  final int cloudiness;

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature.toJson(),
      'weatherCondition': weatherCondition.toString().split('.').last,
      'weatherDescription': weatherDescription,
      'weatherIcon': {
        'codePoint': weatherIcon.codePoint,
        'fontFamily': weatherIcon.fontFamily,
        'fontPackage': weatherIcon.fontPackage,
      },
      'windSpeed': windSpeed,
      'timestamp': timestamp.toIso8601String(),
      'cloudiness': cloudiness,
    };
  }
}

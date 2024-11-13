class Weather {
  Weather({
    required this.timestamp,
    required this.temperature,
    required this.weatherId,
    required this.weather,
    required this.weatherIcon,
    required this.windSpeed,
  });

  final DateTime timestamp;
  final double temperature;
  final int weatherId;
  final String weather;
  final String weatherIcon;
  final double windSpeed;
}

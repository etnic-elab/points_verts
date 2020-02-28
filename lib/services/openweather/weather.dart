class Weather {
  Weather({
    this.timestamp,
    this.temperature,
    this.weatherId,
    this.weather,
    this.weatherIcon,
    this.windSpeed,
  });

  final DateTime timestamp;
  final double temperature;
  final int weatherId;
  final String weather;
  final String weatherIcon;
  final double windSpeed;
}

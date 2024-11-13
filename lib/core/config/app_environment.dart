final class AppEnvironment {
  static const mapApiProvider = String.fromEnvironment('MAP_API_PROVIDER');
  static const mapApiKey = String.fromEnvironment('MAP_API_KEY');
  static const weatherApiProvider =
      String.fromEnvironment('WEATHER_API_PROVIDER');
  static const weatherApiKey = String.fromEnvironment('WEATHER_API_KEY');
}

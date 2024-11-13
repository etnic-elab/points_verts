import 'package:maps_api/maps_api.dart'
    show AzureMapsApi, GoogleMapsApi, MapboxMapsApi, MapsApi;

class MapsApiFactory {
  static MapsApi create({
    required String provider,
    required String apiKey,
  }) {
    switch (provider.toLowerCase()) {
      case 'google':
        return GoogleMapsApi(apiKey: apiKey);
      case 'azure':
        return AzureMapsApi(apiKey: apiKey);
      case 'mapbox':
        return MapboxMapsApi(apiKey: apiKey);
      default:
        throw ArgumentError('Unsupported maps provider: $provider');
    }
  }
}

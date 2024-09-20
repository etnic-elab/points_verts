import 'dart:ui';

import 'package:app_cache_registry/app_cache_registry.dart';
import 'package:azure_maps_api/azure_maps_api.dart';
import 'package:google_maps_api/google_maps_api.dart';
import 'package:mapbox_maps_api/mapbox_maps_api.dart';
import 'package:maps_api/maps_api.dart';
import 'package:maps_repository/src/session_strategy/session_strategy.dart';

// MapsRepository
class MapsRepository {
  MapsRepository({
    required MapsApi mapsApi,
    required SessionStrategy sessionStrategy,
    required int maxTrips,
  })  : _mapsApi = mapsApi,
        _sessionStrategy = sessionStrategy,
        _maxTrips = maxTrips;

  final MapsApi _mapsApi;
  final SessionStrategy _sessionStrategy;

  /// Based on map API pricing
  final int _maxTrips;

  Future<List<AddressSuggestion>> getAddressSuggestions(
    String query, {
    String? country,
  }) async {
    _sessionStrategy.ensureValidSession();

    final suggestions = await _mapsApi.searchAddress(
      query,
      country: country,
      sessionToken: _sessionStrategy.currentSessionToken,
    );

    return suggestions;
  }

  Future<Address> getGeolocatedAddress(
    AddressSuggestion addressSuggestion,
  ) async {
    if (addressSuggestion.geolocation != null) {
      // If the addressSuggestion has geolocation, transpose it into an Address
      return Address(
        mainText: addressSuggestion.mainText,
        geolocation: addressSuggestion.geolocation!,
      );
    } else {
      // If there's no geolocation, call getPlaceDetails
      final address = await _mapsApi.getPlaceDetails(
        addressSuggestion.placeId!,
        sessionToken: _sessionStrategy.currentSessionToken,
      );

      _sessionStrategy.endSession();

      return address;
    }
  }

  Future<List<TripInfo>> getTrips(
    Geolocation origin,
    List<Geolocation> destinations, {
    required DateTime cacheExpirationDateTime,
  }) {
    final tripsCacheManager = AppCacheRegistry.get<TripsCacheManager>();

    final limitedDestinations = destinations.take(_maxTrips).toList();

    return tripsCacheManager.getTrips(
      origin,
      limitedDestinations,
      _mapsApi.getTrips,
      expiration: cacheExpirationDateTime,
    );
  }

  String getStaticMapUrl({
    required int width,
    required int height,
    List<MapMarker> markers = const [],
    List<MapPath> paths = const [],
    MapType mapType = MapType.road,
    Brightness brightness = Brightness.light,
  }) {
    return _mapsApi.getStaticMapUrl(
      width: width,
      height: height,
      markers: markers,
      paths: paths,
      mapType: mapType,
      brightness: brightness,
    );
  }
}

/// Factory for creating appropriate MapsRepository
class MapsRepositoryFactory {
  static MapsRepository create(String provider, String apiKey) {
    late MapsApi mapsApi;
    late SessionStrategy sessionStrategy;
    late int maxTrips;

    switch (provider.toLowerCase()) {
      case 'google':
        mapsApi = GoogleMapsApi(apiKey: apiKey);
        sessionStrategy = GoogleSessionStrategy();
        maxTrips = 3;
      case 'azure':
        mapsApi = AzureMapsApi(apiKey: apiKey);
        sessionStrategy = NullSessionStrategy();
        maxTrips = 4;
      case 'mapbox':
        mapsApi = MapboxMapsApi(apiKey: apiKey);
        sessionStrategy = NullSessionStrategy();
        maxTrips = 3;
      default:
        throw ArgumentError('Unsupported map provider: $provider');
    }

    return MapsRepository(
      mapsApi: mapsApi,
      sessionStrategy: sessionStrategy,
      maxTrips: maxTrips,
    );
  }
}

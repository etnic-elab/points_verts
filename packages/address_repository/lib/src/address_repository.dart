import 'dart:ui';

import 'package:address_repository/src/session_strategy/session_strategy.dart';
import 'package:app_cache_registry/app_cache_registry.dart';
import 'package:azure_maps_api/azure_maps_api.dart';
import 'package:google_maps_api/google_maps_api.dart';
import 'package:mapbox_maps_api/mapbox_maps_api.dart';
import 'package:maps_api/maps_api.dart';

///TODO: At the moment, this is used as a connector to the maps api, but we should have one addressrepository and one pointvertrepository
// AddressRepository
class AddressRepository {
  AddressRepository({
    required MapsApi mapsApi,
    required SessionStrategy sessionStrategy,
  })  : _mapsApi = mapsApi,
        _sessionStrategy = sessionStrategy;

  final MapsApi _mapsApi;
  final SessionStrategy _sessionStrategy;

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

  ///TODO: Temporary implementation of this method. I think a better way would be to have a WalksRepository, where we store our walks as a stream, and we can adapt them with trip information when newly fetched/upon location change, we can insert weather info etc.
  Future<List<TripInfo>> getTrips(
    Geolocation origin,
    List<Geolocation> destinations,
  ) {
    final tripsCacheManager = AppCacheRegistry.get<TripsCacheManager>();
    final cacheKey = tripsCacheManager.generateCacheKey(origin, destinations);

    return tripsCacheManager.get(
      cacheKey,
      () => _mapsApi.getTrips(origin, destinations),
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

/// Factory for creating appropriate AddressRepository
class AddressRepositoryFactory {
  static AddressRepository create(String provider, String apiKey) {
    late MapsApi mapsApi;
    late SessionStrategy sessionStrategy;

    switch (provider.toLowerCase()) {
      case 'google':
        mapsApi = GoogleMapsApi(apiKey: apiKey);
        sessionStrategy = GoogleSessionStrategy();
      case 'azure':
        mapsApi = AzureMapsApi(apiKey: apiKey);
        sessionStrategy = NullSessionStrategy();
      case 'mapbox':
        mapsApi = MapboxMapsApi(apiKey: apiKey);
        sessionStrategy = NullSessionStrategy();
      default:
        throw ArgumentError('Unsupported map provider: $provider');
    }

    return AddressRepository(
      mapsApi: mapsApi,
      sessionStrategy: sessionStrategy,
    );
  }
}

import 'dart:ui';

import 'package:maps_api/maps_api.dart'
    show
        Address,
        AddressSuggestion,
        GoogleMapsApi,
        MapMarker,
        MapPath,
        MapType,
        MapsApi;
import 'package:maps_repository/src/session_strategy/session_strategy.dart';

// MapsRepository
class MapsRepository {
  MapsRepository({
    required MapsApi mapsApi,
  })  : _mapsApi = mapsApi,
        _sessionStrategy = _determineSessionStrategy(mapsApi);

  final MapsApi _mapsApi;
  final SessionStrategy _sessionStrategy;

  // Static method to determine the appropriate SessionStrategy based on MapsApi type
  static SessionStrategy _determineSessionStrategy(MapsApi mapsApi) {
    if (mapsApi is GoogleMapsApi) {
      return GoogleSessionStrategy();
    }
    return NullSessionStrategy();
  }

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
        mainText: addressSuggestion.description,
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

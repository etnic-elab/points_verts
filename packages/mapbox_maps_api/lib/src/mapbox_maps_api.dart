import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:jsonable/jsonable.dart';
import 'package:mapbox_maps_api/src/models/models.dart';
import 'package:maps_api/maps_api.dart';

/// {@template mapbox_maps_api}
/// An implementation of the MapsApi thats uses the Mapbox API
/// {@endtemplate}
class MapboxMapsApi implements MapsApi {
  /// {@macro mapbox_maps_api}
  MapboxMapsApi({
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  @override
  final String apiKey;

  @override
  String get name => 'Mapbox';

  @override
  String get baseUrl => 'api.mapbox.com';

  @override
  http.Client get httpClient => _httpClient;

  final http.Client _httpClient;

  @override
  Future<List<AddressSuggestion>> searchAddress(
    String search, {
    String? country,
    String? sessionToken,
  }) async {
    final suggestionsRequest = Uri.https(
      baseUrl,
      '/geocoding/v5/mapbox.places/$search.json',
      {
        'access_token': apiKey,
        'autocomplete': 'true',
        if (country != null) 'country': country,
        'language': 'fr',
        'types': 'address,poi',
        'limit': '10',
      },
    );

    final suggestionsResponse = await httpClient.get(suggestionsRequest);

    if (suggestionsResponse.statusCode != 200) {
      throw AddressSuggestionsException();
    }

    final result = jsonDecode(suggestionsResponse.body) as JsonMap;

    if (result['features'] == null) {
      throw AddressSuggestionsException();
    }

    final features = result['features'] as List;

    return features
        .map(
          (feature) => MapboxAddressSuggestionFactory.fromJson(
            feature as JsonMap,
          ),
        )
        .toList();
  }

  @override
  Future<Address> getPlaceDetails(String placeId, {String? sessionToken}) {
    // TODO(matthieu): implement getPlaceDetails
    throw UnimplementedError();
  }

  @override
  Future<List<TripInfo>> getTrips(
    Geolocation origin,
    List<Geolocation> destinations,
  ) async {
    if (destinations.isEmpty) {
      return [];
    }

    final coordinates = [origin, ...destinations]
        .map((loc) => '${loc.longitude},${loc.latitude}')
        .join(';');

    final tripsRequest = Uri.https(
      baseUrl,
      '/directions-matrix/v1/mapbox/driving/$coordinates',
      {
        'access_token': apiKey,
        'annotations': 'distance,duration',
        'sources': '0', // Use only the first coordinate (origin) as the source
        'destinations': destinations
            .asMap()
            .keys
            .map((i) => (i + 1).toString())
            .join(';'), // Use all except the first coordinate as destinations
      },
    );

    final tripsResponse = await httpClient.get(tripsRequest);

    if (tripsResponse.statusCode != 200) {
      throw TripsRetrievalException();
    }

    final result = jsonDecode(tripsResponse.body) as Map<String, dynamic>;

    if (result['code'] != 'Ok') {
      throw TripsRetrievalException();
    }

    final durations = result['durations'] as List<num>?;
    final distances = result['distances'] as List<num>?;

    if (durations == null ||
        distances == null ||
        durations.isEmpty ||
        distances.isEmpty) {
      return [];
    }

    return List.generate(durations.length, (index) {
      return TripInfo(
        distance: distances[index],
        duration: durations[index],
        origin: origin,
        destination: destinations[index],
      );
    });
  }

  @override
  String getStaticMapUrl({
    required int width,
    required int height,
    List<MapPath> paths = const [],
    List<MapMarker> markers = const [],
    Geolocation? center,
    num? zoom,
    MapType mapType = MapType.road,
    Brightness brightness = Brightness.light,
    String format = 'png',
    String language = 'fr',
    int scale = 2,
  }) {
    // TODO(matthieu): implement getStaticMapUrl
    throw UnimplementedError();
  }
}

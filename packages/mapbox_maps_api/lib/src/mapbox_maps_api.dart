import 'dart:convert';
import 'dart:ui';

import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
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
    final data = MatrixResponse.fromJson(result);
    final durations = data.castedDurations();
    final distances = data.castedDistances();

    if (result['code'] != 'Ok') {
      throw TripsRetrievalException();
    }

    if (durations.isEmpty || distances.isEmpty) {
      return [];
    }

    return List.generate(durations.length, (index) {
      return TripInfo(
        distance: distances[0][index],
        duration: durations[0][index],
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
    final style = brightness == Brightness.dark ? 'dark-v10' : 'light-v10';
    final path = _getEncodedPath(paths, brightness);
    final effectiveCenter = center ?? markers.first.geolocation;
    return Uri.https(
      baseUrl,
      '/styles/v1/mapbox/$style/static/pin-l(${effectiveCenter.longitude},${effectiveCenter.latitude})$path/auto/${width}x$height@2x',
      {'access_token': apiKey},
    ).toString();
  }

  String _getEncodedPath(List<MapPath> paths, Brightness brightness) {
    return paths
        .map((path) {
          final encodable = path.points;
          if (encodable.isNotEmpty) {
            final encoded = Uri.encodeComponent(encodePolyline(encodable));
            return 'path-2+${path.color.toARGB32().toRadixString(16)}-1($encoded)';
          } else {
            return null;
          }
        })
        .whereType<String>()
        .toList()
        .join(',');
  }
}

class MatrixResponse {
  MatrixResponse(this.code, this.durations, this.distances);

  MatrixResponse.fromJson(Map<String, dynamic> json)
      : code = json['code'] as String,
        durations = json['durations'] as List<dynamic>,
        distances = json['distances'] as List<dynamic>;

  List<List<num>> castedDurations() {
    final list = durations! as List<List>;
    return list.map((e) => List.castFrom<dynamic, num>(e)).toList();
  }

  List<List<num>> castedDistances() {
    final list = distances! as List<List>;
    return list.map((e) => List.castFrom<dynamic, num>(e)).toList();
  }

  final String code;
  final List<dynamic>? durations;
  final List<dynamic>? distances;
}

import 'dart:convert';
import 'dart:ui';

import 'package:azure_maps_api/src/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:jsonable/jsonable.dart';
import 'package:maps_api/maps_api.dart';

/// {@template azure_maps_api}
/// A dart implementation of the MapsApi that uses the Azure Maps API
/// {@endtemplate}
class AzureMapsApi implements MapsApi {
  /// {@macro azure_maps_api}
  AzureMapsApi({
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  @override
  final String apiKey;

  @override
  String get name => 'Azure Maps';

  @override
  String get baseUrl => 'atlas.microsoft.com';

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
      '/search/fuzzy/json',
      {
        'api-version': '1.0',
        'query': search,
        if (country != null) 'countrySet': country,
        'language': 'fr',
        'subscription-key': apiKey,
        'limit': '10',
        'idxSet': 'PAD,Str,POI',
      },
    );

    final suggestionsResponse = await httpClient.get(suggestionsRequest);

    if (suggestionsResponse.statusCode != 200) {
      throw AddressSuggestionsException();
    }

    final result = jsonDecode(suggestionsResponse.body) as JsonMap;

    if (result['results'] == null) {
      throw AddressSuggestionsException();
    }

    final results = result['results'] as List;

    return results
        .map(
          (result) => AzureAddressSuggestionFactory.fromJson(
            result as JsonMap,
          ),
        )
        .toList();
  }

  @override
  Future<Address> getPlaceDetails(
    String placeId, {
    String? sessionToken,
  }) {
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

    final tripsRequest = Uri.https(
      baseUrl,
      '/route/matrix/json',
      {
        'api-version': '1.0',
        'subscription-key': apiKey,
        'waitForResults': 'true',
        'travelMode': 'car',
      },
    );

    final requestBody = {
      'origins': {
        'type': 'MultiPoint',
        'coordinates': [
          [origin.longitude, origin.latitude],
        ],
      },
      'destinations': {
        'type': 'MultiPoint',
        'coordinates':
            destinations.map((d) => [d.longitude, d.latitude]).toList(),
      },
    };

    final tripsResponse = await httpClient.post(
      tripsRequest,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (tripsResponse.statusCode != 200) {
      throw TripsRetrievalException();
    }

    final result = jsonDecode(tripsResponse.body) as JsonMap;

    final matrix = result['matrix'] as List<dynamic>;

    if (matrix.isEmpty) {
      return [];
    }

    final trips = matrix[0] as List<dynamic>;
    return trips.asMap().entries.map((entry) {
      final index = entry.key;
      final trip = entry.value as JsonMap;
      return AzureTripInfoFactory.fromJson(
        trip,
        origin: origin,
        destination: destinations[index],
      );
    }).toList();
  }

  @override
  String getStaticMapUrl({
    required int width,
    required int height,
    List<MapPath> paths = const [],
    List<MapMarker> markers = const [],
    Geolocation? center,
    num zoom = 11,
    MapType mapType = MapType.road,
    Brightness brightness = Brightness.light,
    String format = 'png',
    String language = 'fr',
    int scale = 1,
  }) {
    _validateDimensions(width, height);

    final params = <String, String>{
      'api-version': '2024-04-01',
      'width': width.toString(),
      'height': height.toString(),
      'language': language,
      'subscription-key': apiKey,
    };

    _addTilesetId(params, mapType, brightness);
    _addCenter(params, center, paths, markers);
    _addZoom(params, zoom);

    // TODO(matthieu): Url created like this is too long.
    //  Azure Maps Data Storage should be implemented.
    //  Not even sure multiple paths are possible
    // _addPaths(params, paths);
    _addMarkers(params, markers);

    return Uri.https(baseUrl, '/map/static', params).toString();
  }

  void _validateDimensions(int width, int height) {
    if (width < 80 || width > 2000 || height < 80 || height > 1500) {
      throw ArgumentError(
        'Width must be between 80 and 2000, '
        'and height must be between 80 and 1500',
      );
    }
  }

  void _addTilesetId(
    Map<String, String> params,
    MapType mapType,
    Brightness brightness,
  ) {
    params['tilesetId'] = mapType.toAzureTilesetId(brightness);
  }

  void _addCenter(
    Map<String, String> params,
    Geolocation? center,
    List<MapPath> paths,
    List<MapMarker> markers,
  ) {
    var effectiveCenter = center;

    if (effectiveCenter == null) {
      if (markers.isNotEmpty) {
        effectiveCenter = markers.first.geolocation;
      } else if (paths.isNotEmpty && paths.first.points.isNotEmpty) {
        effectiveCenter = Geolocation(
          latitude: paths.first.points.first[1] as double,
          longitude: paths.first.points.first[0] as double,
        );
      }
    }

    if (effectiveCenter == null) {
      throw ArgumentError('Center is required and cannot be null');
    }

    params['center'] =
        '${effectiveCenter.longitude},${effectiveCenter.latitude}';
  }

  void _addZoom(
    Map<String, String> params,
    num zoom,
  ) {
    if (zoom < 0 || zoom > 20) {
      throw ArgumentError('Zoom must be between 0 and 20');
    }

    params['zoom'] = zoom.toInt().toString();
  }

  // ignore: unused_element
  void _addPaths(Map<String, String> params, List<MapPath> paths) {
    if (paths.isEmpty) return;

    params['path'] = paths.map((path) => path.toAzureEncode()).join('&path=');
  }

  void _addMarkers(Map<String, String> params, List<MapMarker> markers) {
    if (markers.isEmpty) return;

    params['pins'] =
        markers.map((marker) => marker.toAzureEncode()).join('&pins=');
  }
}

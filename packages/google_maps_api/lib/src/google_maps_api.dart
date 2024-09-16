import 'dart:convert';
import 'dart:ui';

import 'package:google_maps_api/src/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:jsonable/jsonable.dart';
import 'package:maps_api/maps_api.dart';

/// {@template azure_maps_api}
/// A dart implementation of the MapsApi that uses the Google Maps API
/// {@endtemplate}
class GoogleMapsApi implements MapsApi {
  /// {@macro google_maps_api}
  GoogleMapsApi({
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  @override
  final String apiKey;

  @override
  String get name => 'Google Maps';

  @override
  String get baseUrl => 'maps.googleapis.com';

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
      '/maps/api/place/autocomplete/json',
      {
        'input': search,
        'types': 'address',
        if (country != null) 'components': 'country:$country',
        'language': 'fr',
        'key': apiKey,
        if (sessionToken != null) 'sessiontoken': sessionToken,
      },
    );

    final suggestionsResponse = await httpClient.get(suggestionsRequest);

    if (suggestionsResponse.statusCode != 200) {
      throw AddressSuggestionsException();
    }

    final result = jsonDecode(suggestionsResponse.body) as JsonMap;

    if (result['status'] != 'OK') {
      throw AddressSuggestionsException();
    }

    final predictions = result['predictions'] as List;

    return predictions
        .map(
          (prediction) => GoogleAddressSuggestionFactory.fromJson(
            prediction as JsonMap,
          ),
        )
        .toList();
  }

  @override
  Future<Address> getPlaceDetails(
    String placeId, {
    String? sessionToken,
  }) async {
    final placeDetailsRequest = Uri.https(
      baseUrl,
      '/maps/api/place/details/json',
      {
        'place_id': placeId,
        'fields': 'formatted_address,geometry/location',
        'language': 'fr',
        'key': apiKey,
        if (sessionToken != null) 'sessiontoken': sessionToken,
      },
    );

    final placeDetailsResponse = await httpClient.get(placeDetailsRequest);

    if (placeDetailsResponse.statusCode != 200) {
      throw PlaceDetailsException();
    }

    final result = jsonDecode(placeDetailsResponse.body) as JsonMap;

    if (result['status'] != 'OK') {
      throw PlaceDetailsException();
    }

    return GoogleAddressFactory.fromJson(result);
  }

  @override
  Future<List<TripInfo>> getTrips(
    Geolocation origin,
    List<Geolocation> destinations,
  ) async {
    if (destinations.isEmpty) {
      return [];
    }

    final originString = '${origin.latitude},${origin.longitude}';
    final destinationsString =
        destinations.map((d) => '${d.latitude},${d.longitude}').join('|');

    final tripsRequest = Uri.https(
      baseUrl,
      '/maps/api/distancematrix/json',
      {
        'origins': originString,
        'destinations': destinationsString,
        'key': apiKey,
      },
    );

    final tripsResponse = await httpClient.get(tripsRequest);

    if (tripsResponse.statusCode != 200) {
      throw TripsRetrievalException();
    }

    final result = jsonDecode(tripsResponse.body) as JsonMap;

    if (result['status'] != 'OK') {
      throw TripsRetrievalException();
    }

    final rows = result['rows'] as List<dynamic>?;
    final elements = rows?.firstOrNull?['elements'] as List<dynamic>?;

    if (elements == null || elements.isEmpty) {
      return [];
    }

    return elements
        .map((element) => GoogleTripInfoFactory.fromJson(element as JsonMap))
        .toList();
  }

  @override
  String getStaticMapUrl({
    required int width,
    required int height,
    List<MapPath> paths = const [],
    List<MapMarker> markers = const [],
    Geolocation? center,
    num zoom = 10,
    MapType mapType = MapType.road,
    Brightness brightness = Brightness.light,
    String format = 'png',
    String language = 'fr',
    int scale = 2,
  }) {
    _validateDimensions(width, height);
    _validateMapParameters(paths, markers, center, zoom);

    final params = <String, String>{
      'size': '${width}x$height',
      'scale': scale.toString(),
      'language': language,
      'format': format,
      'key': apiKey,
    };

    _addPaths(params, paths);
    _addMarkers(params, markers);
    _addCenter(params, center, zoom);
    _addZoom(params, zoom);

    final mapStyle = GoogleMapStyle(mapType, brightness);
    params.addAll(mapStyle.toParams());

    return Uri.decodeFull(
      Uri.https(baseUrl, '/maps/api/staticmap', params).toString(),
    );
  }

  void _validateDimensions(int width, int height) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Width and height must be positive integers');
    }
  }

  void _validateMapParameters(
    List<MapPath> paths,
    List<MapMarker> markers,
    Geolocation? center,
    num? zoom,
  ) {
    final hasCenterAndZoom = center != null && zoom != null;
    final hasPathsOrMarkers = paths.isNotEmpty || markers.isNotEmpty;

    if (!hasCenterAndZoom && !hasPathsOrMarkers) {
      throw ArgumentError(
        'Either center and zoom must be set, or there must be paths and/or markers',
      );
    }
  }

  void _addPaths(Map<String, String> params, List<MapPath> paths) {
    if (paths.isEmpty) return;

    params['path'] = paths.map((path) => path.toGoogleEncode()).join('&path=');
  }

  void _addMarkers(Map<String, String> params, List<MapMarker> markers) {
    if (markers.isEmpty) return;

    params['markers'] =
        markers.map((marker) => marker.toGoogleEncode()).join('&markers=');
  }

  void _addCenter(
    Map<String, String> params,
    Geolocation? center,
    num? zoom,
  ) {
    if (center != null) {
      params['center'] = '${center.latitude},${center.longitude}';
    }
  }

  void _addZoom(
    Map<String, String> params,
    num zoom,
  ) {
    if (zoom < 0 || zoom > 21) {
      throw ArgumentError('Zoom must be between 0 and 21');
    }

    params['zoom'] = zoom.toInt().toString();
  }
}

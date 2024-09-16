import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:maps_api/src/models/models.dart';

/// {@template maps_api}
/// The interface for an API that provides access to map-related services.
/// {@endtemplate}
abstract class MapsApi {
  /// The name of the map service.
  String get name;

  /// The API key for the map service.
  String get apiKey;

  /// The base URL for API requests.
  String get baseUrl;

  /// The HTTP client used for making requests.
  http.Client get httpClient;

  /// Retrieves address suggestions based on a search query and country.
  ///
  /// [search] is the user's input string.
  /// [country] is the ISO 3166-1 alpha-2 country code to limit the search.
  /// [sessionToken] is an optional parameter for grouping related requests.
  ///
  /// Returns a list of [AddressSuggestion] objects.
  /// Throws an [AddressSuggestionsException] if the operation fails.
  Future<List<AddressSuggestion>> searchAddress(
    String search, {
    String? country,
    String? sessionToken,
  });

  /// Fetches details of a place given its ID.
  ///
  /// [placeId] is the unique identifier for the place.
  /// [sessionToken] is an optional parameter for grouping related requests.
  ///
  /// Returns an [Address] object.
  /// Throws a [PlaceDetailsException] if the place is not found.
  Future<Address> getPlaceDetails(
    String placeId, {
    String? sessionToken,
  });

  /// Calculates trip information from a given point to multiple destinations.
  ///
  /// [origin] is the starting point.
  /// [destinations] is a list of destination points.
  ///
  /// Returns a list of [TripInfo] objects 
  /// containing the calculated information.
  /// 
  /// Throws a [TripsRetrievalException] if the operation fails.
  Future<List<TripInfo>> getTrips(
    Geolocation origin,
    List<Geolocation> destinations,
  );

  /// Generates a URL for a static map image.
  ///
  /// [width] is the desired width of the image in pixels.
  /// [height] is the desired height of the image in pixels.
  /// [paths] is an optional list of paths to draw on the map.
  /// [markers] is an optional list of markers to place on the map.
  /// [center] is an optional center point for the map.
  /// [zoom] is an optional parameter to set the zoom level of the map.
  /// [mapType] specifies the type of map to generate.
  /// [format] specifies the image format.
  /// [language] specifies the language for map labels.
  /// [scale] specifies the scale of the image.
  ///
  /// Returns a String containing the URL for the static map image.
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
    int scale = 1,
  });
}

/// Exception thrown when address suggestions retrieval fails.
class AddressSuggestionsException implements Exception {}

/// Exception thrown when a place with a given ID is not found.
class PlaceDetailsException implements Exception {}

/// Exception thrown when trip retrieval operation fails.
class TripsRetrievalException implements Exception {}

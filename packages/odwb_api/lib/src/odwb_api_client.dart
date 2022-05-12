import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta_points_verts_adeps_api/odwb_api.dart';

/// Exception thrown when odwbSearch fails.
class PointVertRequestFailure implements Exception {}

/// Exception thrown when the points are not found.
class PointVertNotFoundFailure implements Exception {}

/// {@template meta_points_verts_adeps_api_client}
/// Dart API Client which wraps the [ODWB API](https://www.odwb.be/api/).
/// {@endtemplate}
class ODWBApiClient {
  /// {@macro odwb_api_client}
  ODWBApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _baseUrl = 'https://www.odwb.be';
  final http.Client _httpClient;

  /// Finds a [Point] `https://www.odwb.be/api/records/1.0/search/`.
  Future<List<Point>> pointVertSearch({
    String dataset = 'points-verts-de-ladeps',
    Set<String>? query,
    int? rows,
    int? start,
    Map<String, dynamic>? refine,
    Map<String, dynamic>? exclude,
    GeofilterDistance? geofilterDistance,
    GeofilterPolygon? geofilterPolygon,
  }) async {
    Map<String, dynamic> parameters = {
      'dataset': 'points-verts-de-ladeps',
      if (query != null) 'q': query.join(' AND'),
      if (rows != null) 'rows': rows,
      if (start != null) 'start': start,
      if (refine != null) ...refine,
      if (exclude != null) ...exclude,
      if (geofilterDistance != null)
        'geofilter.distance': geofilterDistance.stringify(),
      if (geofilterPolygon != null)
        'geofilter.polygon': geofilterPolygon.stringify(),
    };

    final odwbRequest = Uri.https(
      _baseUrl,
      '/api/records/1.0/search/',
      parameters,
    );
    final odwbResponse = await _httpClient.get(odwbRequest);

    if (odwbResponse.statusCode != 200) {
      throw PointVertRequestFailure();
    }

    final odwbJson = jsonDecode(
      odwbResponse.body,
    )['records'] as List;

    if (odwbJson.isEmpty) {
      throw PointVertNotFoundFailure();
    }

    return odwbJson
        .map((json) => Point.fromJson(json['fields'] as Map<String, dynamic>))
        .toList();
  }
}

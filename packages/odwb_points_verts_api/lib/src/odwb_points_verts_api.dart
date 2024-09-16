import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jsonable/jsonable.dart';
import 'package:odwb_points_verts_api/src/models/models.dart';

/// {@template odwb_points_verts_api}
/// An API that provides access to Open Source ODWB Points Verts data
/// {@endtemplate}
class OdwbPointsVertsApi {
  /// {@macro odwb_points_verts_api}
  OdwbPointsVertsApi({
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const String _baseUrl = 'www.odwb.be';
  static const int _limit = 100; // Maximum allowed by the API

  /// Fetches all Points Verts, handling pagination automatically.
  ///
  /// [startDate] filters records from this date onwards.
  /// [updatedSince] filters records updated since this date.
  Future<List<OdwbPointVert>> fetchAllPointsVerts({
    DateTime? startDate,
    DateTime? updatedSince,
  }) async {
    final formattedFromDate =
        DateFormat('yyyy-MM-dd').format(startDate ?? DateTime.now());
    var where = 'date>=$formattedFromDate';

    if (updatedSince != null) {
      final lastUpdateIso8601Utc = updatedSince.toUtc().toIso8601String();
      where += ' AND record_timestamp>$lastUpdateIso8601Utc';
    }

    return _fetchWithPagination(where);
  }

  Future<List<OdwbPointVert>> _fetchWithPagination(String where) async {
    final allPointsVerts = <OdwbPointVert>[];
    var offset = 0;
    var hasMoreRecords = true;

    while (hasMoreRecords) {
      final uri = Uri.https(_baseUrl,
          '/api/explore/v2.1/catalog/datasets/points-verts-de-ladeps/records', {
        'where': where,
        'limit': _limit,
        'offset': offset,
      });

      final response = await _httpClient.get(uri);

      if (response.statusCode != 200) {
        throw OdwbOdwbPointVertApiException();
      }

      final result = jsonDecode(response.body) as JsonMap;
      final records = result['records'] as List;

      allPointsVerts.addAll(
        records.map((record) {
          final fields =
              ((record as JsonMap)['record'] as JsonMap)['fields'] as JsonMap;
          return OdwbPointVert.fromJson(fields);
        }).toList(),
      );

      final totalCount = result['total_count'] as int;
      offset += _limit;
      hasMoreRecords = offset < totalCount;
    }

    return allPointsVerts;
  }
}

class OdwbOdwbPointVertApiException implements Exception {}

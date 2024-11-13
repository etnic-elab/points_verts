import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:json_map_typedef/json_map_typedef.dart';
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
  static const String _backupAssetPath = 'assets/walk_data.json';

  /// Fetches all walks scheduled for the specified date.
  ///
  /// [date] The date for which to fetch walks. Defaults to today if not specified.
  Future<List<OdwbPointVert>> getPointsVertsForDate({
    DateTime? date,
  }) async {
    final formattedDate =
        DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());
    final where = 'date=$formattedDate';

    final uri = Uri.https(_baseUrl,
        '/api/explore/v2.1/catalog/datasets/points-verts-de-ladeps/records', {
      'where': where,
    });

    final response = await _httpClient.get(uri);

    if (response.statusCode != 200) {
      throw OdwbPointVertApiException();
    }

    final result = jsonDecode(response.body) as JsonMap;
    final records = result['records'] as List;

    return records.map((record) {
      final fields =
          ((record as JsonMap)['record'] as JsonMap)['fields'] as JsonMap;
      return OdwbPointVert.fromJson(fields);
    }).toList();
  }

  /// Fetches all walks from today onwards.
  ///
  /// This method handles pagination automatically to fetch all available walks.
  Future<List<OdwbPointVert>> getAllPointsVerts() async {
    final formattedFromDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final where = 'date>=$formattedFromDate';

    return _fetchAllWalks(where);
  }

  /// Loads walks from the backup JSON file in assets.
  ///
  /// This can be used as a fallback when there's no internet connection
  /// or when the API is unavailable.
  Future<List<OdwbPointVert>> getBackupPointsVerts() async {
    try {
      final jsonString = await rootBundle.loadString(_backupAssetPath);
      final data = jsonDecode(jsonString) as JsonMap;
      final records = data['records'] as List;

      return records.map((record) {
        final fields =
            ((record as JsonMap)['record'] as JsonMap)['fields'] as JsonMap;
        return OdwbPointVert.fromJson(fields);
      }).toList();
    } catch (e) {
      throw OdwbPointVertBackupException();
    }
  }

  Future<List<OdwbPointVert>> _fetchAllWalks(String where) async {
    final allWalks = <OdwbPointVert>[];
    var offset = 0;
    var hasMoreRecords = true;

    while (hasMoreRecords) {
      final uri = Uri.https(_baseUrl,
          '/api/explore/v2.1/catalog/datasets/points-verts-de-ladeps/records', {
        'where': where,
        'limit': _limit.toString(),
        'offset': offset.toString(),
      });

      final response = await _httpClient.get(uri);

      if (response.statusCode != 200) {
        throw OdwbPointVertApiException();
      }

      final result = jsonDecode(response.body) as JsonMap;
      final records = result['records'] as List;

      allWalks.addAll(
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

    return allWalks;
  }
}

/// Exception thrown when the API request fails
class OdwbPointVertApiException implements Exception {}

class OdwbPointVertBackupException implements Exception {}

import 'dart:async';

import 'package:adeps_website/adeps_website.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Exception thrown when odwbSearch fails.
class PointVertRequestFailure implements Exception {}

/// Exception thrown when the points are not found.
class PointVertNotFoundFailure implements Exception {}

/// {@template meta_points_verts_adeps_api_client}
/// Dart API Client which wraps the [ADEPS Website](https://www.am-sport.cfwb.be/).
/// {@endtemplate}
class AdepsWebsiteClient {
  /// {@macro odwb_api_client}
  AdepsWebsiteClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _baseUrl = 'www.am-sport.cfwb.be';
  final http.Client _httpClient;

  /// Finds a [Point] `https://www.am-sport.cfwb.be/adeps/pv_data.asp`.
  Future<List<Point>> pointVertSearch(
      {DateTime? date,
      Province? province,
      List<Activity>? activities,
      List<Extra>? extras,
      bool publicTransport = false}) async {
    Map<String, dynamic> parameters = {
      if (date != null) 'dt': DateFormat('dd-MM-yyyy').format(date),
      if (province != null) 'prov_id': provinceEnumMap[province],
      if (activities != null)
        'activites': activities
            .map((Activity activity) => activityEnumMap[activity])
            .toList(),
      if (extras != null)
        'activites_supp_id': extras.map((Extra extra) => extraEnumMap[extra]),
      if (publicTransport) 'tec': 1
    };

    final websiteRequest = Uri.https(
      _baseUrl,
      '/adeps/pv_data.asp',
      parameters,
    );
    final websiteResponse = await _httpClient.get(websiteRequest);

    if (websiteResponse.statusCode != 200) {
      throw PointVertRequestFailure();
    }

    final websiteString = websiteResponse.body;
    final websiteCsv = _fixCsv(websiteString);
    final websitePoints =
        const CsvToListConverter(fieldDelimiter: ';').convert(websiteCsv);

    if (websitePoints.isEmpty) {
      throw PointVertNotFoundFailure();
    }

    return websitePoints.map((List point) => Point.fromList(point)).toList();
  }
}

String _fixCsv(String csv) {
  List<String> result = [];
  List<String> splitted = csv.split(';');
  String current = "";
  int tokenPosition = 0;
  for (String token in splitted) {
    if (tokenPosition == 0) {
      current = token;
    } else {
      current += ';$token';
    }
    tokenPosition++;
    if (tokenPosition == 10) {
      result.add(current);
      tokenPosition = 0;
    }
  }
  return result.join('\r\n');
}

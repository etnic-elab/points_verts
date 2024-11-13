import 'package:adeps_website_api/adeps_website_api.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// {@template adeps_website}
/// A web-crawling service that provides access to the adeps website data
/// {@endtemplate}
class AdepsWebsiteApi {
  /// {@macro adeps_website}
  AdepsWebsiteApi({
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const String _baseUrl = 'www.am-sport.cfwb.be';

  Future<List<WebsitePointVert>> getPointsVerts(DateTime date) async {
    final formattedDate = DateFormat('dd-MM-yyyy').format(date);

    final uri = Uri.https(_baseUrl, '/adeps/pv_data.asp', {
      'type': 'map',
      'dt': formattedDate,
      'activites': 'M,O',
    });

    final response = await _httpClient.get(uri);

    if (response.statusCode != 200) {
      throw AdepsWebsiteException();
    }

    final lines = response.body.split(';');
    final result = <WebsitePointVert>[];

    for (var i = 0; i < lines.length; i += 11) {
      try {
        result.add(WebsitePointVert.fromWebsiteData(lines, i));
      } catch (e) {
        continue;
      }
    }

    return result;
  }
}

class AdepsWebsiteException implements Exception {}

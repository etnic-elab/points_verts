import 'package:adeps_website/src/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// {@template adeps_website}
/// A web-crawling service that provides access to the adeps website data
/// {@endtemplate}
class AdepsWebsite {
  /// {@macro adeps_website}
  AdepsWebsite({
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

    if (response.statusCode == 200) {
      return _processAdepsData(response.body);
    } else {
      throw AdepsWebsiteException();
    }
  }

  List<WebsitePointVert> _processAdepsData(String data) {
    final lines = data.split(';');
    final result = <WebsitePointVert>[];

    for (var i = 0; i < lines.length; i += 11) {
      if (i + 10 < lines.length) {
        final id = int.parse(lines[i]);
        final status = lines[i + 9];
        result.add(
          WebsitePointVert(
            id: id,
            statut: WebsitePointVertStatus.fromString(status),
          ),
        );
      }
    }

    return result;
  }
}

class AdepsWebsiteException implements Exception {}

import 'dart:convert';
import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:points_verts/models/website_walk.dart';
import 'package:points_verts/services/firebase.dart';

import '../models/walk.dart';

const String tag = 'dev.alpagaga.points_verts.Adeps';
const String baseUrl =
    'https://www.odwb.be/api/records/1.0/search/?dataset=points-verts-de-ladeps';
const int pageSize = 500;

List<Walk> fetchJsonWalks({DateTime? fromDateLocal}) {
  var walks = <Walk>[];

  final String walkData =
      FirebaseLocalService.firebaseRemoteConfigService!.getJsonWalks();
  if (walkData.isNotEmpty) walks = _convertWalks(json.decode(walkData));

  return walks;
}

Future<List<Walk>> fetchApiWalks(String lastUpdateIso8601Utc,
    {DateTime? fromDateLocal,}) async {
  log('Refreshing future walks list since $lastUpdateIso8601Utc', name: tag);
  fromDateLocal ??= DateTime.now();
  final var dateFormat = DateFormat('yyyy/MM/dd');
  return _retrieveWalks(
      '$baseUrl&q=(date+>%3D+${dateFormat.format(fromDateLocal)}+AND+record_timestamp+>$lastUpdateIso8601Utc)',);
}

Future<List<Walk>> _retrieveWalks(String baseUrl) async {
  final walks = <Walk>[];
  try {
    var finished = false;
    var start = 0;
    while (!finished) {
      final url = '$baseUrl&rows=$pageSize&start=$start';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load walks, statusCode: ${response.statusCode}',);
      }

      final Map<String, dynamic> data = json.decode(response.body);
      walks.addAll(_convertWalks(data));
      start = start + pageSize;
      finished = data['nhits'] <= start;
    }
    return walks;
  } catch (err) {
    return Future.error(err);
  }
}

Future<List<WebsiteWalk>> retrieveWalksFromWebSite(DateTime date) async {
  final dateFormat = DateFormat('dd-MM-yyyy');
  final newList = <WebsiteWalk>[];
  final response = await http.get(Uri.parse(
      'https://www.am-sport.cfwb.be/adeps/pv_data.asp?type=map&dt=${dateFormat.format(date)}&activites=M,O',),);
  if (response.statusCode != 200) {
    throw Exception(
        "Couldn't load walks from website, statusCode: ${response.statusCode}",);
  }

  final fixed = _fixCsv(response.body);
  final List<List<dynamic>> rowsAsListOfValues =
      const CsvToListConverter(fieldDelimiter: ';').convert(fixed);
  for (final walk in rowsAsListOfValues) {
    newList.add(WebsiteWalk(id: walk[0], status: _convertStatus(walk[9])));
  }

  return newList;
}

List<Walk> _convertWalks(Map<String, dynamic> data) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final walks = <Walk>[];
  for (final Map<String, dynamic> walkJson in data['records']) {
    final walk = Walk.fromJson(walkJson);
    if (!walk.date.isBefore(today)) walks.add(walk);
  }
  return walks;
}

String? _convertStatus(String webSiteStatus) {
  if (webSiteStatus == 'ptvert_annule') {
    return 'Annulé';
  } else if (webSiteStatus == 'ptvert_modifie') {
    return 'Modifié';
  } else if (webSiteStatus == 'ptvert') {
    return 'OK';
  } else {
    return null;
  }
}

String _fixCsv(String csv) {
  final result = <String>[];
  final splitted = csv.split(';');
  var current = '';
  var tokens = 0;
  for (final token in splitted) {
    if (tokens == 0) {
      current = token;
    } else {
      current = '$current;$token';
    }
    tokens++;
    if (tokens == 10) {
      result.add(current);
      tokens = 0;
    }
  }
  return result.join('\r\n');
}

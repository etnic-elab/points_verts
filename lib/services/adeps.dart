import 'dart:convert';
import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:points_verts/models/website_walk.dart';

import '../models/walk.dart';

const String tag = "dev.alpagaga.points_verts.Adeps";
const String baseUrl =
    "https://www.odwb.be/api/records/1.0/search/?dataset=points-verts-de-ladeps";
const int pageSize = 500;

Future<List<Walk>> fetchJsonWalks({DateTime? fromDateLocal}) async {
  try {
    final String response =
        await rootBundle.loadString('assets/walk_data.json');
    Map<String, dynamic> data = await json.decode(response);
    return _convertWalks(data);
  } catch (e) {
    log("Cannot retrieve walks from JSON file: $e");
    return [];
  }
}

Future<List<Walk>> fetchApiWalks(String lastUpdateIso8601Utc,
    {DateTime? fromDateLocal}) async {
  log("Refreshing future walks list since $lastUpdateIso8601Utc", name: tag);
  fromDateLocal ??= DateTime.now();
  DateFormat dateFormat = DateFormat("yyyy/MM/dd");
  return _retrieveWalks(
      "$baseUrl&q=(date+>%3D+${dateFormat.format(fromDateLocal)}+AND+record_timestamp+>$lastUpdateIso8601Utc)");
}

Future<List<Walk>> _retrieveWalks(String baseUrl) async {
  List<Walk> walks = [];
  try {
    bool finished = false;
    int start = 0;
    while (!finished) {
      String url = "$baseUrl&rows=$pageSize&start=$start";
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        walks.addAll(_convertWalks(data));
        start = start + pageSize;
        finished = data['nhits'] <= start;
      } else {
        return Future.error(Exception('Failed to load walks'));
      }
    }
  } catch (err) {
    return Future.error(Exception('Failed to load walks'));
  }

  return walks;
}

Future<List<WebsiteWalk>> retrieveWalksFromWebSite(DateTime date) async {
  DateFormat dateFormat = DateFormat("dd-MM-yyyy");
  List<WebsiteWalk> newList = [];
  try {
    var response = await http.get(Uri.parse(
        "https://www.am-sport.cfwb.be/adeps/pv_data.asp?type=map&dt=${dateFormat.format(date)}&activites=M,O"));
    if (response.statusCode == 200) {
      var fixed = _fixCsv(response.body);
      List<List<dynamic>> rowsAsListOfValues =
          const CsvToListConverter(fieldDelimiter: ';').convert(fixed);
      for (List<dynamic> walk in rowsAsListOfValues) {
        newList.add(WebsiteWalk(id: walk[0], status: _convertStatus(walk[9])));
      }
    }
  } catch (err) {
    print("Couldn't retrieve walks from website, $err");
    newList = [];
  }

  return newList;
}

List<Walk> _convertWalks(Map<String, dynamic> data) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  List<Walk> walks = [];
  for (Map<String, dynamic> walkJson in data['records']) {
    Walk walk = Walk.fromJson(walkJson);
    if (!walk.date.isBefore(today)) walks.add(walk);
  }
  return walks;
}

String? _convertStatus(String webSiteStatus) {
  if (webSiteStatus == "ptvert_annule") {
    return "Annulé";
  } else if (webSiteStatus == "ptvert_modifie") {
    return "Modifié";
  } else if (webSiteStatus == "ptvert") {
    return "OK";
  } else {
    return null;
  }
}

String _fixCsv(String csv) {
  List<String> result = [];
  List<String> splitted = csv.split(';');
  String current = "";
  int tokens = 0;
  for (String token in splitted) {
    if (tokens == 0) {
      current = token;
    } else {
      current = "$current;$token";
    }
    tokens++;
    if (tokens == 10) {
      result.add(current);
      tokens = 0;
    }
  }
  return result.join('\r\n');
}

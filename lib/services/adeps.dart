import 'dart:convert';
import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:points_verts/models/website_walk.dart';

import '../models/walk.dart';

const String TAG = "dev.alpagaga.points_verts.Adeps";
const String BASE_URL =
    "https://www.odwb.be/api/records/1.0/search/?dataset=points-verts-de-ladeps";
const int PAGE_SIZE = 500;

Future<List<Walk>> fetchAllWalks() async {
  log("Fetching all future walks", name: TAG);
  DateFormat dateFormat = new DateFormat("yyyy/MM/dd");
  return _retrieveWalks(
      "$BASE_URL&q=date+>%3D+${dateFormat.format(DateTime.now())}");
}

Future<List<Walk>> refreshAllWalks(String lastUpdate) async {
  log("Refreshing future walks list since $lastUpdate", name: TAG);
  DateFormat dateFormat = new DateFormat("yyyy/MM/dd");
  return _retrieveWalks(
      "$BASE_URL&q=(date+>%3D+${dateFormat.format(DateTime.now())}+AND+record_timestamp+>$lastUpdate)");
}

Future<List<Walk>> _retrieveWalks(String baseUrl) async {
  List<Walk> walks = [];
  bool finished = false;
  int start = 0;
  while (!finished) {
    String url = "$baseUrl&rows=$PAGE_SIZE&start=$start";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      walks.addAll(_convertWalks(data));
      start = start + PAGE_SIZE;
      finished = data['nhits'] <= start;
    } else {
      throw Exception('Failed to load walks');
    }
  }
  return walks;
}

Future<List<WebsiteWalk>> retrieveWalksFromWebSite(DateTime date) async {
  DateFormat dateFormat = new DateFormat("dd-MM-yyyy");
  List<WebsiteWalk> newList = [];
  var response = await http.get(Uri.parse(
      "https://www.am-sport.cfwb.be/adeps/pv_data.asp?type=map&dt=${dateFormat.format(date)}&activites=M,O"));
  var fixed = _fixCsv(response.body);
  List<List<dynamic>> rowsAsListOfValues =
  const CsvToListConverter(fieldDelimiter: ';').convert(fixed);
  for (List<dynamic> walk in rowsAsListOfValues) {
    newList.add(WebsiteWalk(id: walk[0], status: _convertStatus(walk[9])));
  }
  return newList;
}

List<Walk> _convertWalks(Map<String, dynamic> data) {
  List<Walk> newList = [];
  List<dynamic> list = data['records'];
  for (Map<String, dynamic> walkJson in list) {
    newList.add(Walk.fromJson(walkJson));
  }
  return newList;
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
      current = current + ";" + token;
    }
    tokens++;
    if (tokens == 10) {
      result.add(current);
      tokens = 0;
    }
  }
  return result.join('\r\n');
}

import 'dart:convert';
import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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
  List<Walk> walks = List<Walk>();
  bool finished = false;
  int start = 0;
  while (!finished) {
    String url = "$baseUrl&rows=$PAGE_SIZE&start=$start";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      walks.addAll(_convertWalks(data));
      start = start + PAGE_SIZE;
      finished = data['nhits'] <= start;
    } else {
      throw Exception('Failed to load walks');
    }
  }
  return walks;
}

List<Walk> _convertWalks(var data) {
  List<Walk> newList = List<Walk>();
  List<dynamic> list = data['records'];
  for (Map<String, dynamic> walkJson in list) {
    newList.add(Walk.fromJson(walkJson));
  }
  return newList;
}

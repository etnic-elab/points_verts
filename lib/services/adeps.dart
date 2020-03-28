import 'dart:convert';
import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../models/walk.dart';

const String TAG = "dev.alpagaga.points_verts.Adeps";

Future<List<Walk>> fetchAllWalks() async {
  log("Fetching all future walks", name: TAG);
  List<Walk> walks = List<Walk>();
  DateFormat dateFormat = new DateFormat("yyyy/MM/dd");
  bool finished = false;
  int start = 0;
  while (!finished) {
    String url =
        "https://www.odwb.be/api/records/1.0/search/?dataset=points-verts-de-ladeps&q=date+>%3D+${dateFormat.format(DateTime.now())}&sort=-date&rows=500&start=$start";
    print(url);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      walks.addAll(_convertWalks(data));
      start = start + 500;
      finished = data['nhits'] <= start;
    } else {
      throw Exception('Failed to load walks');
    }
  }
  return walks;
}

Future<List<Walk>> refreshAllWalks(String lastUpdate) async {
  log("Refreshing future walks list since $lastUpdate", name: TAG);
  DateFormat dateFormat = new DateFormat("yyyy/MM/dd");
  String url =
      "https://www.odwb.be/api/records/1.0/search/?dataset=points-verts-de-ladeps&q=(date+>%3D+${dateFormat.format(DateTime.now())}+AND+record_timestamp+>$lastUpdate)&sort=-date&rows=1000";
  var response = await http.get(url);
  if (response.statusCode == 200) {
    return _convertWalks(json.decode(response.body));
  } else {
    throw Exception('Failed to refresh walks');
  }
}

List<Walk> _convertWalks(var data) {
  List<Walk> newList = List<Walk>();
  List<dynamic> list = data['records'];
  for (Map<String, dynamic> walkJson in list) {
    newList.add(Walk.fromJson(walkJson));
  }
  return newList;
}

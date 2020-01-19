import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:html/dom.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

import 'walk.dart';
import 'walk_details.dart';

Future<List<DateTime>> retrieveDatesFromWorker() async {
  try {
    String url = "https://points-verts.tbo.workers.dev/";
    var response = await http.get(url);
    List<dynamic> dates = jsonDecode(response.body);
    DateFormat dateFormat = new DateFormat("dd-MM-yyyy");
    return dates.map((dynamic date) => dateFormat.parse(date)).toList();
  } catch (err) {
    print("Cannot retrieve dates from worker: $err");
    return retrieveDatesFromEndpoint();
  }
}

Future<List<DateTime>> retrieveDatesFromEndpoint() async {
  String url = "https://www.am-sport.cfwb.be/adeps/pv_data.asp?type=dates";
  var response = await http.get(url);
  Document document = parse(response.body);
  List<String> results = new List<String>();
  for (dom.Element element in document.getElementsByTagName('option')) {
    String value = element.attributes['value'];
    if (value != '0') {
      results.add(value);
    }
  }
  DateFormat dateFormat = new DateFormat("dd-MM-yyyy");
  return results.map((String date) => dateFormat.parse(date)).toList();
}

Future<List<Walk>> retrieveWalksFromEndpoint(DateTime date) async {
  DateFormat dateFormat = new DateFormat("dd-MM-yyyy");
  List<Walk> newList = List<Walk>();
  var response = await http.get(
      "https://www.am-sport.cfwb.be/adeps/pv_data.asp?type=map&dt=${dateFormat.format(date)}&activites=M,O");
  var fixed = _fixCsv(response.body);
  List<List<dynamic>> rowsAsListOfValues =
      const CsvToListConverter(fieldDelimiter: ';').convert(fixed);
  for (List<dynamic> walk in rowsAsListOfValues) {
    newList.add(Walk(
        id: walk[0],
        city: walk[1],
        type: walk[2],
        lat: walk[3] != "" ? walk[3] : null,
        long: walk[4] != "" ? walk[4] : null,
        province: walk[5],
        date: walk[6],
        status: walk[9]));
  }
  return newList;
}

Future<WalkDetails> retrieveWalkDetails(int id) async {
  var response =
      await http.get('https://www.am-sport.cfwb.be/adeps/pv_detail.asp?i=$id');
  String body = response.body;
  Document document = parse(response.body);
  return WalkDetails(
    fifteenKm: body.contains("15.gif"),
    wheelchair: body.contains("handi.gif"),
    stroller: body.contains("poussette.gif"),
    orientation: body.contains("orientation.gif"),
    guided: body.contains("nature.gif"),
    bike: body.contains("velo.gif"),
    mountainBike: body.contains("vtt.gif"),
    supplying: body.contains("ravito.gif"),
  );
}

String _fixCsv(String csv) {
  List<String> result = new List<String>();
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

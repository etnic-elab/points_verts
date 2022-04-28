import 'dart:convert';

import 'package:points_verts/models/news.dart';

import 'package:http/http.dart' as http;

const String url = "https://points-verts-328310.ew.r.appspot.com/live_news";

Future<List<News>> retrieveNews() async {
  List<News> news = [];
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    for (Map<String, dynamic> json in data) {
      news.add(News.fromJson(json));
    }
  } else {
    print('Failed to load news');
  }
  return news;
}

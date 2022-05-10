import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:points_verts/models/news.dart';
import 'package:collection/collection.dart';

import 'package:http/http.dart' as http;
import 'package:points_verts/models/news_seen.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/news.dart';

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

Future<void> showNews(BuildContext context, bool mounted) async {
  DateTime now = DateTime.now();

  String? lastFetch = await PrefsProvider.prefs.getString(Prefs.lastNewsFetch);
  bool doFetchNews = DateTime.tryParse(lastFetch ?? '')
          ?.add(const Duration(days: 1))
          .isBefore(now) ??
      true;

  if (doFetchNews) {
    try {
      List<dynamic> futures = await Future.wait(
          [PrefsProvider.prefs.getString(Prefs.news), retrieveNews()]);

      List oldNewsJson = jsonDecode(futures[0] ?? '[]');
      List<NewsSeen> oldNews = [];
      oldNews =
          oldNewsJson.map<NewsSeen>((json) => NewsSeen.fromJson(json)).toList();

      List<News> news = futures[1];
      List<News> newsToShow = [];
      for (News _news in news) {
        NewsSeen? seen = oldNews
            .firstWhereOrNull((NewsSeen seen) => _news.name == seen.name);
        bool showNews = seen == null ||
            (_news.intervalHours != null &&
                seen.at
                    .add(Duration(hours: _news.intervalHours!))
                    .isBefore(now));

        if (showNews) newsToShow.add(_news);
      }

      if (newsToShow.isNotEmpty && mounted) {
        await showNewsDialog(context, newsToShow);

        for (News shown in newsToShow) {
          NewsSeen? seen = oldNews
              .firstWhereOrNull((NewsSeen seen) => shown.name == seen.name);
          seen == null
              ? oldNews.add(NewsSeen.fromNews(shown, now))
              : seen.at = now;
        }
        PrefsProvider.prefs.setString(Prefs.news, jsonEncode(oldNews));
      }
    } catch (err) {
      print('Unable to show news: $err');
    }

    await PrefsProvider.prefs
        .setString(Prefs.lastNewsFetch, now.toIso8601String());
  }
}

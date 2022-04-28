import 'package:points_verts/models/news.dart';

class NewsSeen {
  final String name;
  DateTime at;

  NewsSeen.fromNews(News news, DateTime now)
      : name = news.name,
        at = now;

  NewsSeen.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        at = DateTime.parse(json['at']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'at': at.toIso8601String(),
      };
}

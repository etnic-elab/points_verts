import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:points_verts/company_data.dart';
import 'package:collection/collection.dart';

import 'path_point.dart';

class GpxPath {
  GpxPath({required this.url, required this.title});

  final String url;
  final String title;
  List<PathPoint> pathPoints = [];
  bool visible = true;

  static Map<Brightness, List<Color>> colors = {
    Brightness.light: [
      CompanyColors.greenPrimary,
      CompanyColors.darkBlue,
      CompanyColors.darkBrown,
      CompanyColors.purple,
      CompanyColors.orange,
      CompanyColors.pink,
      CompanyColors.red,
      CompanyColors.darkGreen,
    ],
    Brightness.dark: [
      CompanyColors.greenPrimary,
      CompanyColors.blue,
      CompanyColors.brown,
      CompanyColors.purple,
      CompanyColors.orange,
      CompanyColors.pink,
      CompanyColors.lightRed,
      CompanyColors.lightestGreen,
    ]
  };
  static int width = 4;

  static Color color(Brightness brightness, int index) {
    return colors[brightness]![index % GpxPath.colors[brightness]!.length];
  }

  GpxPath.fromJson(Map<String, dynamic> json)
      : url = json['fichier'],
        title = json['titre'];

  Map<String, dynamic> toJson() => {
        'fichier': url,
        'titre': title,
      };

  List<LatLng> get latLngList =>
      pathPoints.map((point) => point.latLng).toList();

  List<String> get latLngStringList =>
      pathPoints.map((point) => '$point').toList();

  bool get hasPoints => pathPoints.firstOrNull != null;
}

import 'package:flutter/cupertino.dart';
import 'package:points_verts/company_data.dart';

import 'gpx_point.dart';

class Path {
  Path({required this.url, required this.title, required this.color});

  final String? url;
  final String title;
  final int? color;
  bool visible = false;
  List<GpxPoint> gpxPoints = [];

  Color getColor(Brightness brightness) {
    bool _isLight = brightness == Brightness.light;

    switch (color) {
      case 1:
        return _isLight ? CompanyColors.darkBlue : CompanyColors.blue;
      case 2:
        return CompanyColors.yellow;
      case 3:
        return CompanyColors.purple;
      case 4:
        return _isLight ? CompanyColors.red : CompanyColors.lightRed;
      case 5:
        return CompanyColors.orange;
      default:
        return CompanyColors.greenPrimary;
    }
  }

  Path.fromJson(Map<String, dynamic> json)
      : url = json['fichier'],
        title = json['titre'] ?? 'Parcours',
        color = _colorInt(json['color']);

  Map<String, dynamic> toJson() => {
        'fichier': url,
        'titre': title,
        'color': color,
      };

  static int? _colorInt(dynamic color) {
    if (color is String) {
      return int.tryParse(color);
    }

    if (color is int) {
      return color;
    }

    return null;
  }

  List<List<num>> get encodablePoints => gpxPoints
      .map((GpxPoint _gpxPoint) =>
          [_gpxPoint.latLng.latitude, _gpxPoint.latLng.longitude])
      .toList();
}

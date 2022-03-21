import 'package:flutter/cupertino.dart';
import 'package:points_verts/company_data.dart';

import 'gpx_point.dart';

class Path extends Comparable<Path> {
  Path({required this.url, required this.title, required this.color});

  final String? url;
  final String title;
  final String? color;
  bool visible = false;
  List<GpxPoint> gpxPoints = [];

// 1=Bleu (Parcours 5km)
// 2=Jaune (Parcours 10km)
// 3=Rouge (Parcours 20km)
// 4=Vert (Parcours commun)
// 5=Violet (Parcours 15km)
// 6=Orange (Parcours 5km poussettes/PMR)

  Color getColor(Brightness brightness) {
    bool _isLight = brightness == Brightness.light;

    switch (color) {
      case '1':
        return _isLight ? CompanyColors.darkBlue : CompanyColors.blue;
      case '2':
        return CompanyColors.yellow;
      case '3':
        return _isLight ? CompanyColors.red : CompanyColors.lightRed;
      case '4':
        return CompanyColors.greenPrimary;
      case '5':
        return CompanyColors.purple;
      case '6':
        return CompanyColors.orange;
      default:
        return _isLight ? CompanyColors.darkBrown : CompanyColors.brown;
    }
  }

  Path.fromJson(Map<String, dynamic> json)
      : url = json['fichier'],
        title = json['titre'] ?? 'Parcours',
        color = json['couleur'];

  Map<String, dynamic> toJson() => {
        'fichier': url,
        'titre': title,
        'couleur': color,
      };

  List<List<num>> get encodablePoints => gpxPoints
      .map((GpxPoint _gpxPoint) =>
          [_gpxPoint.latLng.latitude, _gpxPoint.latLng.longitude])
      .toList();

  @override
  int compareTo(Path other) {
    List _sortList = ['4', '6', '1', '2', '5', '3'];
    int indexThis = _sortList.indexOf(color);
    int indexOther = _sortList.indexOf(other.color);

    if (indexThis > indexOther) return -1;
    if (indexThis < indexOther) return 1;
    // color == other.color
    return 0;
  }
}

import 'package:flutter/cupertino.dart';
import 'package:points_verts/company_data.dart';

import 'gpx_point.dart';

class Elevation {
  Elevation({required this.positive, required this.negative});
  int? positive;
  int? negative;

  @override
  String toString() =>
      'Dénivelé : ${positive == 0 ? "Inconnu" : "${positive}m"}';
}

class Path implements Comparable<Path> {
  Path({required this.url, required this.title, required this.type});

  Path.fromJson(Map<String, dynamic> json)
      : url = json['fichier'],
        title = json['titre'] ?? 'Parcours',
        type = json['couleur'];

  final String? url;
  final String title;
  final String? type;
  bool visible = false;
  List<GpxPoint> gpxPoints = [];
  Elevation? elevation;

  static Path? fromJsonIfGpx(Map<String, dynamic> json) {
    final url = json['fichier'] as String?;
    if (url == null || !url.toLowerCase().endsWith('gpx')) {
      return null;
    }

    return Path(
      url: url,
      title: json['titre'] as String? ?? 'Parcours',
      type: json['couleur'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'fichier': url,
        'titre': title,
        'couleur': type,
      };

  // 1=Bleu (Parcours 5km)
// 2=Jaune (Parcours 10km)
// 3=Rouge (Parcours 20km)
// 4=Vert (Parcours commun)
// 5=Violet (Parcours 15km)
// 6=Orange (Parcours 5km poussettes/PMR)

  Color getColor(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    switch (type) {
      case '1':
        return isLight ? CompanyColors.darkBlue : CompanyColors.blue;
      case '2':
        return CompanyColors.yellow;
      case '3':
        return isLight ? CompanyColors.red : CompanyColors.lightRed;
      case '4':
        return CompanyColors.greenPrimary;
      case '5':
        return CompanyColors.purple;
      case '6':
        return CompanyColors.orange;
      default:
        return isLight ? CompanyColors.darkBrown : CompanyColors.brown;
    }
  }

  Elevation getElevation() {
    elevation ??= calculateElevation();

    return elevation!;
  }

  Elevation calculateElevation() {
    double? previous;
    var positive = 0;
    var negative = 0;

    for (final point in gpxPoints) {
      final current = point.elevation;
      if (previous == null) {
        previous = current;
        continue;
      }

      if (current == null) {
        continue;
      }

      final difference = current - previous;

      if (difference > 0) positive += difference.abs();
      if (difference < 0) negative += difference.abs();

      previous = current;
    }

    return Elevation(positive: positive, negative: negative);
  }

  String? get description {
    switch (type) {
      case '1':
        return 'Parcours 5km';
      case '2':
        return 'Parcours 10km';
      case '3':
        return 'Parcours 20km';
      case '4':
        return 'Parcours commun';
      case '5':
        return 'Parcours 15km';
      case '6':
        return 'Parcours 5km poussettes/PMR';
      default:
        return null;
    }
  }

  List<List<num>> get encodablePoints => gpxPoints
      .map((GpxPoint gpxPoint) =>
          [gpxPoint.latLng.latitude, gpxPoint.latLng.longitude],)
      .toList();

  @override
  int compareTo(Path other) {
    final sortList = ['4', '6', '1', '2', '5', '3'];
    final indexThis = sortList.indexOf(type);
    final indexOther = sortList.indexOf(other.type);

    if (indexThis > indexOther) return -1;
    if (indexThis < indexOther) return 1;
    // color == other.color
    return 0;
  }
}

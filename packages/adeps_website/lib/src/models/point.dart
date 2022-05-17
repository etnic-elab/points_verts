// 16944;CLABECQ;M;50.6870931;4.2250955;Brabant Wallon;15-05-2022;Dimanche 15 Mai 2022;Tubize;ptvert_annule;

import 'package:adeps_website/adeps_website.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

enum Activity { walk, orientation, unknown }
const activityEnumMap = {Activity.walk: 'M', Activity.orientation: 'O'};

enum Status { cancelled, modified, ok, unknown }
const statusEnumMap = {
  Status.cancelled: 'ptvert_annule',
  Status.modified: 'ptvert_modifie',
  Status.ok: 'ptvert'
};

class Point extends Equatable {
  const Point({
    required this.id,
    required this.activity,
    required this.status,
    required this.location,
    required this.date,
  });

  factory Point.fromList(List list) => Point(
      id: list[0],
      activity: activityEnumMap.keys.firstWhere(
          (k) => activityEnumMap[k] == list[2],
          orElse: () => Activity.unknown),
      date: DateFormat('dd-MM-yyyy').parse(list[6]),
      location: Location.fromList(list),
      status: statusEnumMap.keys.firstWhere((k) => statusEnumMap[k] == list[9],
          orElse: () => Status.unknown));

  final int id;
  final Activity activity;
  final Status status;
  final Location location;
  final DateTime date;

  @override
  List<Object?> get props => [id];
}

class Location extends Equatable {
  const Location(
      {required this.province,
      required this.municipality,
      required this.city,
      required this.latLng});

  factory Location.fromList(List list) => Location(
      city: list[1],
      latLng: LatLng(latitude: list[3], longitude: list[4]),
      municipality: list[8],
      province: list[5]);

  final String province;
  final String municipality;
  final String city;
  final LatLng latLng;

  @override
  List<Object?> get props => [latLng];
}

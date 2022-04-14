import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:points_verts/models/path.dart';
import 'package:points_verts/models/weather.dart';

import 'trip.dart';

final dateFormat = DateFormat("yyyy-MM-dd");

// const TRACES_GPX =
//     "[{\"titre\":\"Parcours 5 kms\",\"fichier\":\"https://www.am-sport.cfwb.be/adeps/pv_traces.asp?id=270&fichier=Parcours+5kms%2Egpx\",\"jourdemarche\":\"0\",\"couleur\":\"1\"},{\"titre\":\"Parcours 10 kms\",\"fichier\":\"https://www.am-sport.cfwb.be/adeps/pv_traces.asp?id=271&fichier=Parcours+10kms+%2Egpx\",\"jourdemarche\":\"0\",\"couleur\":\"2\"},{\"titre\":\"Parcours 15 kms\",\"fichier\":\"https://www.am-sport.cfwb.be/adeps/pv_traces.asp?id=272&fichier=Parcours+15kms+%2Egpx\",\"jourdemarche\":\"0\",\"couleur\":\"5\"},{\"titre\":\"Parcours 20 kms\",\"fichier\":\"https://www.am-sport.cfwb.be/adeps/pv_traces.asp?id=273&fichier=Parcours+20kms+%2Egpx\",\"jourdemarche\":\"0\",\"couleur\":\"3\"}]";

class Walk {
  Walk(
      {required this.id,
      required this.city,
      required this.entity,
      required this.type,
      required this.province,
      required this.long,
      required this.lat,
      required this.date,
      required this.status,
      required this.meetingPoint,
      required this.meetingPointInfo,
      required this.organizer,
      required this.contactFirstName,
      required this.contactLastName,
      required this.contactPhoneNumber,
      required this.ign,
      required this.transport,
      required this.fifteenKm,
      required this.wheelchair,
      required this.stroller,
      required this.extraOrientation,
      required this.extraWalk,
      required this.guided,
      required this.bike,
      required this.mountainBike,
      required this.waterSupply,
      required this.beWapp,
      required this.adepSante,
      required this.lastUpdated,
      this.paths = const []});

  final int id;
  final String city;
  final String entity;
  final String type;
  final String province;
  final DateTime date;
  final double? long;
  final double? lat;
  String status;
  final String? meetingPoint;
  final String? meetingPointInfo;
  final String organizer;
  final String contactFirstName;
  final String contactLastName;
  final String? contactPhoneNumber;
  final String? ign;
  final String? transport;
  final bool fifteenKm;
  final bool wheelchair;
  final bool stroller;
  final bool extraOrientation;
  final bool extraWalk;
  final bool guided;
  final bool bike;
  final bool mountainBike;
  final bool waterSupply;
  final bool beWapp;
  final bool adepSante;
  final DateTime lastUpdated;
  final List<Path> paths;

  double? distance;
  Trip? trip;
  List<Weather> weathers = [];

  factory Walk.fromJson(Map<String, dynamic> json) {
    return Walk(
        id: json['fields']['id'],
        city: json['fields']['localite'],
        entity: json['fields']['entite'],
        type: json['fields']['activite'],
        province: json['fields']['province'],
        date: dateFormat.parse(json['fields']['date']),
        long: json['fields']['geopoint'][1],
        lat: json['fields']['geopoint'][0],
        status: json['fields']['statut'],
        meetingPoint: json['fields']['lieu_de_rendez_vous'],
        meetingPointInfo: json['fields']['infos_rendez_vous'],
        organizer: json['fields']['groupement'],
        contactFirstName: json['fields']['prenom'],
        contactLastName: json['fields']['nom'],
        contactPhoneNumber: json['fields']['gsm'],
        ign: json['fields']['ign'],
        transport: json['fields']['gare'],
        fifteenKm: json['fields']['15km'] == "Oui" ? true : false,
        wheelchair: json['fields']['pmr'] == "Oui" ? true : false,
        stroller: json['fields']['poussettes'] == "Oui" ? true : false,
        extraOrientation: json['fields']['orientation'] == "Oui" ? true : false,
        extraWalk: json['fields']['10km'] == "Oui" ? true : false,
        guided: json['fields']['balade_guidee'] == "Oui" ? true : false,
        bike: json['fields']['velo'] == "Oui" ? true : false,
        mountainBike: json['fields']['vtt'] == "Oui" ? true : false,
        waterSupply: json['fields']['ravitaillement'] == "Oui" ? true : false,
        beWapp: json['fields']['bewapp'] == "Oui" ? true : false,
        adepSante: json['fields']['adep_sante'] == 'Oui' ? true : false,
        lastUpdated: DateTime.parse(json['record_timestamp']),
        paths: _decodePaths(json));
  }

  factory Walk.fromDb(Map<String, dynamic>? map) {
    return Walk(
      id: map?['id'],
      city: map?['city'],
      entity: map?['entity'],
      type: map?['type'],
      province: map?['province'],
      date: DateTime.parse(map?['date']),
      long: map?['longitude'],
      lat: map?['latitude'],
      status: map?['status'],
      meetingPoint: map?['meeting_point'],
      meetingPointInfo: map?['meeting_point_info'],
      organizer: map?['organizer'],
      contactFirstName: map?['contact_first_name'],
      contactLastName: map?['contact_last_name'],
      contactPhoneNumber: map?['contact_phone_number']?.toString(),
      ign: map?['ign'],
      transport: map?['transport'],
      fifteenKm: map?['fifteen_km'] == 1 ? true : false,
      wheelchair: map?['wheelchair'] == 1 ? true : false,
      stroller: map?['stroller'] == 1 ? true : false,
      extraOrientation: map?['extra_orientation'] == 1 ? true : false,
      extraWalk: map?['extra_walk'] == 1 ? true : false,
      guided: map?['guided'] == 1 ? true : false,
      bike: map?['bike'] == 1 ? true : false,
      mountainBike: map?['mountain_bike'] == 1 ? true : false,
      waterSupply: map?['water_supply'] == 1 ? true : false,
      beWapp: map?['be_wapp'] == 1 ? true : false,
      adepSante: map?['adep_sante'] == 1 ? true : false,
      lastUpdated: DateTime.parse(map?['last_updated']),
      paths: _pathsFromJson(jsonDecode(map?['paths'])),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'city': city,
      'entity': entity,
      'type': type,
      'province': province,
      'date': date.toIso8601String(),
      'longitude': long,
      'latitude': lat,
      'status': status,
      'meeting_point': meetingPoint,
      'meeting_point_info': meetingPointInfo,
      'organizer': organizer,
      'contact_first_name': contactFirstName,
      'contact_last_name': contactLastName,
      'contact_phone_number': contactPhoneNumber,
      'ign': ign,
      'transport': transport,
      'fifteen_km': fifteenKm ? 1 : 0,
      'wheelchair': wheelchair ? 1 : 0,
      'stroller': stroller ? 1 : 0,
      'extra_orientation': extraOrientation ? 1 : 0,
      'extra_walk': extraWalk ? 1 : 0,
      'guided': guided ? 1 : 0,
      'bike': bike ? 1 : 0,
      'mountain_bike': mountainBike ? 1 : 0,
      'water_supply': waterSupply ? 1 : 0,
      'be_wapp': beWapp ? 1 : 0,
      'last_updated': lastUpdated.toIso8601String(),
      'paths': jsonEncode(paths),
      'adep_sante': adepSante ? 1 : 0,
    };
  }

  static List<Path> _decodePaths(json) {
    try {
      return _pathsFromJson(json['fields']['traces_gpx']);
      // return _pathsFromJson(jsonDecode(TRACES_GPX));
    } catch (err) {
      print("Cannot decode paths for walk '${json['fields']['id']}': $err");
      return [];
    }
  }

  static List<Path> _pathsFromJson(dynamic json) {
    if (json is List) {
      List<Path> paths =
          (json).map<Path>((json) => Path.fromJson(json)).toList();
      paths.sort();
      return paths;
    }

    return <Path>[];
  }

  bool get isCancelled => status == "Annulé";

  bool get isModified => status == "Modifié";

  String? get formattedDistance {
    num? dist = trip?.distance ?? distance;
    if (dist == null) return null;
    if (dist < 1000) return '${dist.round().toString()} m';

    return '${(dist / 1000).round().toString()} km';
  }

  String? get navigationLabel => (trip?.duration != null)
      ? '${Duration(seconds: trip!.duration!.round()).inMinutes} min'
      : formattedDistance;

  bool get isPositionable => hasPosition && !isCancelled;

  bool get hasPosition => lat != null && long != null;

  String get contactLabel {
    String label = '$contactLastName $contactFirstName';
    if (contactPhoneNumber != null) label += ' : $contactPhoneNumber';

    return label;
  }

  bool get isWalk => !isOrientation;
  bool get isOrientation => type == 'Orientation';

  String rangeLabel({required bool compact}) {
    List<int> labels = [];
    String start = compact ? '' : 'Parcours de ';
    String end = ' km';
    String join = compact ? '-' : ' - ';

    if (isWalk) {
      labels.addAll([5, 10, 20]);
      if (fifteenKm) labels.add(15);
      if (extraOrientation) labels.add(8);
    } else {
      labels.addAll([4, 8, 16]);
      if (extraWalk) labels.add(10);
    }

    labels.sort();
    return start + labels.join(join) + end;
  }

  bool get hasExtraRoute => isWalk ? extraOrientation : extraWalk;
}

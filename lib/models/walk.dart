import 'package:intl/intl.dart';
import 'package:points_verts/models/weather.dart';

import 'trip.dart';

final dateFormat = DateFormat("yyyy-MM-dd");

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
      required this.lastUpdated});

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
        lastUpdated: DateTime.parse(json['record_timestamp']));
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
      'adep_sante': adepSante ? 1 : 0,
      'last_updated': lastUpdated.toIso8601String()
    };
  }

  bool isCancelled() {
    return status == "Annulé";
  }

  bool isModified() {
    return status == "Modifié";
  }

  String? getFormattedDistance() {
    num? dist = trip?.distance ?? distance;
    if (dist == null) {
      return null;
    } else if (dist < 1000) {
      return '${dist.round().toString()} m';
    } else {
      return '${(dist / 1000).round().toString()} km';
    }
  }

  String? getNavigationLabel() {
    if (trip != null && trip!.duration != null) {
      return '${Duration(seconds: trip!.duration!.round()).inMinutes} min';
    } else {
      return getFormattedDistance();
    }
  }

  bool isPositionable() {
    return long != null && lat != null && !isCancelled();
  }

  String getContactLabel() {
    if (contactPhoneNumber != null) {
      return "$contactLastName $contactFirstName : $contactPhoneNumber";
    } else {
      return "$contactLastName $contactFirstName";
    }
  }

  bool get isWalk => type == 'Marche';

  bool get isOrientation => type == 'Orientation';
}

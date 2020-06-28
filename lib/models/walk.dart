import 'package:intl/intl.dart';
import 'package:points_verts/models/weather.dart';

import 'trip.dart';

final dateFormat = new DateFormat("yyyy-MM-dd");

class Walk {
  Walk(
      {this.id,
      this.city,
      this.entity,
      this.type,
      this.province,
      this.long,
      this.lat,
      this.date,
      this.status,
      this.meetingPoint,
      this.meetingPointInfo,
      this.organizer,
      this.contactFirstName,
      this.contactLastName,
      this.contactPhoneNumber,
      this.transport,
      this.fifteenKm,
      this.wheelchair,
      this.stroller,
      this.extraOrientation,
      this.extraWalk,
      this.guided,
      this.bike,
      this.mountainBike,
      this.waterSupply,
      this.beWapp,
      this.lastUpdated});

  final int id;
  final String city;
  final String entity;
  final String type;
  final String province;
  final DateTime date;
  final double long;
  final double lat;
  String status;
  final String meetingPoint;
  final String meetingPointInfo;
  final String organizer;
  final String contactFirstName;
  final String contactLastName;
  final String contactPhoneNumber;
  final String transport;
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
  final DateTime lastUpdated;

  double distance;
  Trip trip;
  Future<List<Weather>> weathers;

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
      'last_updated': lastUpdated.toIso8601String()
    };
  }

  bool isCancelled() {
    return status == "Annulé";
  }

  bool isModified() {
    return status == "Modifié";
  }

  String getFormattedDistance() {
    double dist =
        trip != null && trip.distance != null ? trip.distance : distance;
    if (dist == null) {
      return null;
    } else if (dist < 1000) {
      return '${dist.round().toString()} m';
    } else {
      return '${(dist / 1000).round().toString()} km';
    }
  }

  String getNavigationLabel() {
    if (trip != null && trip.duration != null) {
      return '${Duration(seconds: trip.duration.round()).inMinutes} min';
    } else {
      return getFormattedDistance();
    }
  }

  bool isPositionable() {
    return long != null && lat != null && !isCancelled();
  }

  String getContactLabel() {
    if(contactPhoneNumber != null) {
      return "$contactLastName $contactFirstName : $contactPhoneNumber";
    } else {
      return "$contactLastName $contactFirstName";
    }
  }
}

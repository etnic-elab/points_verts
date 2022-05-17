import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta_points_verts_adeps_api/odwb_api.dart';

part 'point.g.dart';

enum Status {
  @JsonValue("Modifié")
  modified,
  @JsonValue('Annulé')
  cancelled,
  @JsonValue('OK')
  ok,
  unknown,
}

enum Activity {
  @JsonValue('Marche')
  walk,
  @JsonValue('Orientation')
  orientation,
  unknown,
}

@JsonSerializable(explicitToJson: true)
class Point extends Equatable {
  const Point({
    required this.id,
    required this.code,
    required this.ign,
    required this.status,
    required this.activity,
    required this.date,
    required this.location,
    required this.organizer,
    required this.gpxs,
    required this.eightKm,
    required this.tenKm,
    required this.fifteenKm,
    required this.mountainBike,
    required this.bike,
    required this.buggy,
    required this.reducedMobility,
    required this.adepSante,
    required this.guided,
    required this.bewapp,
    required this.provision,
    required this.publicTransport,
  });

  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);
  static _readLocation(Map map, _) {
    return {
      'lieu_de_rendez_vous': map['lieu_de_rendez_vous'],
      'localite': map['localite'],
      'entite': map['entite'],
      'geopoint': map['geopoint'],
      'infos_rendez_vous': map['infos_rendez_vous'],
      'province': map['province'],
    };
  }

  static _readOrganizer(Map map, _) {
    return {
      'groupement': map['groupement'],
      'nom': map['nom'],
      'prenom': map['prenom'],
      'gsm': map['gsm'],
    };
  }

  final int id;
  @JsonKey(name: 'ndeg_pv')
  final String code;
  final String ign;
  @JsonKey(name: 'statut', unknownEnumValue: Status.unknown)
  final Status status;
  @JsonKey(name: 'activite', unknownEnumValue: Activity.unknown)
  final Activity activity;
  final DateTime date;
  @JsonKey(readValue: _readLocation)
  final Location location;
  @JsonKey(readValue: _readOrganizer)
  final Organizer organizer;
  @JsonKey(name: 'traces_gpx')
  @GpxListConverter()
  final List<Gpx> gpxs;
  @JsonKey(name: 'orientation')
  @BoolConverter()
  final bool eightKm;
  @JsonKey(name: '10km')
  @BoolConverter()
  final bool tenKm;
  @JsonKey(name: '15km')
  @BoolConverter()
  final bool fifteenKm;
  @JsonKey(name: 'vtt')
  @BoolConverter()
  final bool mountainBike;
  @JsonKey(name: 'velo')
  @BoolConverter()
  final bool bike;
  @JsonKey(name: 'poussettes')
  @BoolConverter()
  final bool buggy;
  @JsonKey(name: 'pmr')
  @BoolConverter()
  final bool reducedMobility;
  @BoolConverter()
  final bool adepSante;
  @JsonKey(name: 'balade_guidee')
  @BoolConverter()
  final bool guided;
  @BoolConverter()
  final bool bewapp;
  @JsonKey(name: 'ravitaillement')
  @BoolConverter()
  final bool provision;
  @JsonKey(name: 'gare')
  final String? publicTransport;

  @override
  List<Object?> get props => [id];
}

@JsonSerializable()
class Organizer extends Equatable {
  const Organizer({
    required this.group,
    required this.name,
    required this.surname,
    required this.phoneNumber,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) =>
      _$OrganizerFromJson(json);

  @JsonKey(name: 'groupement')
  final String group;
  @JsonKey(name: 'nom')
  final String name;
  @JsonKey(name: 'prenom')
  final String surname;
  @JsonKey(name: 'gsm')
  final String phoneNumber;

  @override
  List<Object?> get props => [group, name, surname, phoneNumber];
}

@JsonSerializable()
class Location extends Equatable {
  const Location({
    required this.address,
    required this.city,
    required this.municipality,
    required this.province,
    required this.latLng,
    required this.additionalInfo,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  @JsonKey(name: 'lieu_de_rendez_vous')
  final String address;
  @JsonKey(name: 'localite')
  final String city;
  @JsonKey(name: 'entite')
  final String municipality;
  final String province;
  @JsonKey(name: 'geopoint')
  @LatLngConverter()
  final LatLng latLng;
  @JsonKey(name: 'infos_rendez_vous')
  final String? additionalInfo;

  @override
  List<Object?> get props => [latLng];
}

class LatLngConverter implements JsonConverter<LatLng, List> {
  const LatLngConverter();

  @override
  List toJson(LatLng latLng) {
    return [latLng.latitude, latLng.longitude];
  }

  @override
  LatLng fromJson(List jsonList) {
    return LatLng(latitude: jsonList[0], longitude: jsonList[1]);
  }
}

enum Availability {
  @JsonValue("0")
  always,
  @JsonValue("1")
  sameDay
}

@JsonSerializable()
class Gpx extends Equatable {
  const Gpx(
      {required this.name,
      required this.url,
      required this.availability,
      required this.color});

  factory Gpx.fromJson(Map<String, dynamic> json) => _$GpxFromJson(json);

  @JsonKey(name: 'titre')
  final String name;
  @JsonKey(name: 'fichier')
  final String url;
  @JsonKey(name: 'jourdemarche', unknownEnumValue: Availability.sameDay)
  final Availability availability;
  @JsonKey(name: 'couleur')
  final String color;

  @override
  List<Object?> get props => [name, url];
}

class GpxListConverter implements JsonConverter<List<Gpx>, String> {
  const GpxListConverter();

  @override
  String toJson(List<Gpx> gpxs) {
    return jsonEncode(gpxs);
  }

  @override
  List<Gpx> fromJson(String jsonString) {
    List jsonList = jsonDecode(jsonString);
    return jsonList.map<Gpx>((json) => Gpx.fromJson(json)).toList();
  }
}

class BoolConverter implements JsonConverter<bool, String> {
  const BoolConverter();

  @override
  String toJson(bool isTrue) {
    return isTrue ? 'Oui' : 'Non';
  }

  @override
  bool fromJson(String jsonString) {
    switch (jsonString) {
      case 'Oui':
        return true;
      case 'Non':
        return false;
      default:
        return false;
    }
  }
}

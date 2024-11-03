import 'dart:convert';

import 'package:json_map_typedef/json_map_typedef.dart';
import 'package:odwb_points_verts_api/src/models/fichier_parcours.dart';
import 'package:odwb_points_verts_api/src/models/odwb_point_vert_status.dart';

class OdwbPointVert {
  OdwbPointVert({
    required this.id,
    required this.activite,
    required this.ndegPv,
    required this.groupement,
    required this.entite,
    required this.localite,
    required this.province,
    required this.nom,
    required this.prenom,
    required this.statut,
    required this.date,
    required this.quinzeKm,
    required this.pmr,
    required this.poussettes,
    required this.orientation,
    required this.baladeGuidee,
    required this.dixKm,
    required this.velo,
    required this.vtt,
    required this.ravitaillement,
    required this.bewapp,
    required this.adepSante,
    required this.parcours,
    required this.latitude,
    required this.longitude,
    this.ign,
    this.gare,
    this.infosRendezVous,
    this.gsm,
    this.lieuDeRendezVous,
  });

  factory OdwbPointVert.fromJson(JsonMap json) {
    bool boolFromString(dynamic value) => value == 'Oui';

    List<FichierParcours> parseTracesGpx(String tracesGpxString) {
      if (tracesGpxString.isEmpty) {
        return [];
      }

      final decodedList = jsonDecode(tracesGpxString) as List<dynamic>;
      return decodedList
          .map((e) => FichierParcours.fromJson(e as JsonMap))
          .toList();
    }

    return OdwbPointVert(
      id: json['id'] as int,
      activite: json['activite'] as String,
      ndegPv: json['ndeg_pv'] as String,
      groupement: json['groupement'] as String,
      entite: json['entite'] as String,
      localite: json['localite'] as String,
      province: json['province'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      statut: OdwbPointVertStatus.fromString(json['statut'] as String),
      date: DateTime.parse(json['date'] as String),
      quinzeKm: boolFromString(json['15km']),
      pmr: boolFromString(json['pmr']),
      poussettes: boolFromString(json['poussettes']),
      orientation: boolFromString(json['orientation']),
      baladeGuidee: boolFromString(json['balade_guidee']),
      dixKm: boolFromString(json['10km']),
      velo: boolFromString(json['velo']),
      vtt: boolFromString(json['vtt']),
      ravitaillement: boolFromString(json['ravitaillement']),
      bewapp: boolFromString(json['bewapp']),
      adepSante: boolFromString(json['adep_sante']),
      parcours: parseTracesGpx(json['traces_gpx'] as String),
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      ign: json['ign'] as String?,
      gare: json['gare'] as String?,
      infosRendezVous: json['infos_rendez_vous'] as String?,
      gsm: json['gsm'] as String?,
      lieuDeRendezVous: json['lieu_de_rendez_vous'] as String?,
    );
  }

  JsonMap toJson() {
    String boolToString({required bool value}) => value ? 'Oui' : 'Non';

    return {
      'id': id,
      'activite': activite,
      'ndeg_pv': ndegPv,
      'groupement': groupement,
      'entite': entite,
      'localite': localite,
      'province': province,
      'nom': nom,
      'prenom': prenom,
      'statut': statut.toJson(),
      'date': date.toIso8601String().split('T')[0],
      '15km': boolToString(value: quinzeKm),
      'pmr': boolToString(value: pmr),
      'poussettes': boolToString(value: poussettes),
      'orientation': boolToString(value: orientation),
      'balade_guidee': boolToString(value: baladeGuidee),
      '10km': boolToString(value: dixKm),
      'velo': boolToString(value: velo),
      'vtt': boolToString(value: vtt),
      'ravitaillement': boolToString(value: ravitaillement),
      'bewapp': boolToString(value: bewapp),
      'adep_sante': boolToString(value: adepSante),
      'traces_gpx':
          jsonEncode(parcours.map((trace) => trace.toJson()).toList()),
      'latitude': latitude,
      'longitude': longitude,
      'ign': ign,
      'gare': gare,
      'infos_rendez_vous': infosRendezVous,
      'gsm': gsm,
      'lieu_de_rendez_vous': lieuDeRendezVous,
    };
  }

  final int id;
  final String activite;
  final String ndegPv;
  final String groupement;
  final String entite;
  final String localite;
  final String province;
  final String nom;
  final String prenom;
  final OdwbPointVertStatus statut;
  final DateTime date;
  final bool quinzeKm;
  final bool pmr;
  final bool poussettes;
  final bool orientation;
  final bool baladeGuidee;
  final bool dixKm;
  final bool velo;
  final bool vtt;
  final bool ravitaillement;
  final bool bewapp;
  final bool adepSante;
  final List<FichierParcours> parcours;

  final String? latitude;
  final String? longitude;
  final String? ign;
  final String? gare;
  final String? infosRendezVous;
  final String? gsm;
  final String? lieuDeRendezVous;
}

import 'dart:convert';

import 'package:jsonable/jsonable.dart';
import 'package:odwb_points_verts_api/src/models/odwb_point_vert_status.dart';
import 'package:odwb_points_verts_api/src/models/trace_gpx.dart';

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
    required this.tracesGpx,
    required this.latitude,
    required this.longitude,
    this.ign,
    this.gare,
    this.infosRendezVous,
    this.gsm,
    this.lieuDeRendezVous,
  });

  factory OdwbPointVert.fromJson(JsonMap json) {
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
      statut: OdwbPointVertStatus.fromString(['statut'] as String),
      date: json['date'] as String,
      quinzeKm: toBool(json['15km']),
      pmr: toBool(json['pmr']),
      poussettes: toBool(json['poussettes']),
      orientation: toBool(json['orientation']),
      baladeGuidee: toBool(json['balade_guidee']),
      dixKm: toBool(json['10km']),
      velo: toBool(json['velo']),
      vtt: toBool(json['vtt']),
      ravitaillement: toBool(json['ravitaillement']),
      bewapp: toBool(json['bewapp']),
      adepSante: toBool(json['adep_sante']),
      tracesGpx: parseTracesGpx(json['traces_gpx'] as String),
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      ign: json['ign'] as String?,
      gare: json['gare'] as String?,
      infosRendezVous: json['infos_rendez_vous'] as String?,
      gsm: json['gsm'] as String?,
      lieuDeRendezVous: json['lieu_de_rendez_vous'] as String?,
    );
  }

  static bool toBool(dynamic value) => value == 'Oui';

  static List<TraceGpx> parseTracesGpx(String tracesGpxString) {
    if (tracesGpxString.isNotEmpty != true) {
      return [];
    }

    final decodedList = jsonDecode(tracesGpxString) as List<dynamic>;
    return decodedList.map((e) => TraceGpx.fromJson(e as JsonMap)).toList();
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
  final String date;
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
  final List<TraceGpx> tracesGpx;

  final String? latitude;
  final String? longitude;
  final String? ign;
  final String? gare;
  final String? infosRendezVous;
  final String? gsm;
  final String? lieuDeRendezVous;
}

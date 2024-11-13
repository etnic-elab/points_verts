import 'package:equatable/equatable.dart' show Equatable;
import 'package:json_map_typedef/json_map_typedef.dart';
import 'package:maps_api/maps_api.dart' show Geolocation, TripInfo;
import 'package:odwb_points_verts_api/odwb_points_verts_api.dart'
    show OdwbPointVert;
import 'package:points_verts_repository/points_verts_repository.dart'
    show Parcours, PointVertStatut;
import 'package:weather_api/weather_api.dart' show WeatherForecast;

class PointVert extends Equatable {
  const PointVert({
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
    required this.geolocation,
    this.ign,
    this.gare,
    this.infosRendezVous,
    this.gsm,
    this.lieuDeRendezVous,
    this.trajetDomicile,
    this.previsionsMeteo,
  });

  factory PointVert.fromJson(JsonMap json) {
    return PointVert(
      id: json['id'] as int,
      activite: json['activite'] as String,
      ndegPv: json['ndegPv'] as String,
      groupement: json['groupement'] as String,
      entite: json['entite'] as String,
      localite: json['localite'] as String,
      province: json['province'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      statut: PointVertStatut.fromString(json['statut'] as String),
      date: DateTime.parse(json['date'] as String),
      quinzeKm: json['quinzeKm'] as bool,
      pmr: json['pmr'] as bool,
      poussettes: json['poussettes'] as bool,
      orientation: json['orientation'] as bool,
      baladeGuidee: json['baladeGuidee'] as bool,
      dixKm: json['dixKm'] as bool,
      velo: json['velo'] as bool,
      vtt: json['vtt'] as bool,
      ravitaillement: json['ravitaillement'] as bool,
      bewapp: json['bewapp'] as bool,
      adepSante: json['adepSante'] as bool,
      parcours: (json['parcours'] as List<dynamic>)
          .map((p) => Parcours.fromJson(p as JsonMap))
          .toList(),
      geolocation: Geolocation.fromJson(json['geolocation'] as JsonMap),
      ign: json['ign'] as String?,
      gare: json['gare'] as String?,
      infosRendezVous: json['infosRendezVous'] as String?,
      gsm: json['gsm'] as String?,
      lieuDeRendezVous: json['lieuDeRendezVous'] as String?,
      trajetDomicile: json['trajetDomicile'] != null
          ? TripInfo.fromJson(json['trajetDomicile'] as JsonMap)
          : null,
      previsionsMeteo: json['previsionsMeteo'] != null
          ? (json['previsionsMeteo'] as List<dynamic>)
              .map((w) => WeatherForecast.fromJson(w as JsonMap))
              .toList()
          : null,
    );
  }

  factory PointVert.empty() {
    return PointVert(
      id: 0,
      activite: '',
      ndegPv: '',
      groupement: '',
      entite: '',
      localite: '',
      province: '',
      nom: '',
      prenom: '',
      statut: PointVertStatut.unknown,
      date: DateTime.now(),
      quinzeKm: false,
      pmr: false,
      poussettes: false,
      orientation: false,
      baladeGuidee: false,
      dixKm: false,
      velo: false,
      vtt: false,
      ravitaillement: false,
      bewapp: false,
      adepSante: false,
      parcours: const [],
      geolocation: const Geolocation.empty(),
    );
  }

  factory PointVert.fromOdwb(OdwbPointVert pointVert) {
    final latitude = double.parse(pointVert.latitude);
    final longitude = double.parse(pointVert.longitude);

    return PointVert(
      id: pointVert.id,
      activite: pointVert.activite,
      ndegPv: pointVert.ndegPv,
      groupement: pointVert.groupement,
      entite: pointVert.entite,
      localite: pointVert.localite,
      province: pointVert.province,
      nom: pointVert.nom,
      prenom: pointVert.prenom,
      statut: PointVertStatut.fromOdwb(pointVert.statut),
      date: pointVert.date,
      quinzeKm: pointVert.quinzeKm,
      pmr: pointVert.pmr,
      poussettes: pointVert.poussettes,
      orientation: pointVert.orientation,
      baladeGuidee: pointVert.baladeGuidee,
      dixKm: pointVert.dixKm,
      velo: pointVert.velo,
      vtt: pointVert.vtt,
      ravitaillement: pointVert.ravitaillement,
      bewapp: pointVert.bewapp,
      adepSante: pointVert.adepSante,
      parcours: pointVert.parcours.map(Parcours.fromOdwb).toList(),
      geolocation: Geolocation(latitude: latitude, longitude: longitude),
      ign: pointVert.ign,
      gare: pointVert.gare,
      infosRendezVous: pointVert.infosRendezVous,
      gsm: pointVert.gsm,
      lieuDeRendezVous: pointVert.lieuDeRendezVous,
    );
  }

  JsonMap toJson() {
    return {
      'id': id,
      'activite': activite,
      'ndegPv': ndegPv,
      'groupement': groupement,
      'entite': entite,
      'localite': localite,
      'province': province,
      'nom': nom,
      'prenom': prenom,
      'statut': statut.toString(),
      'date': date.toIso8601String(),
      'quinzeKm': quinzeKm,
      'pmr': pmr,
      'poussettes': poussettes,
      'orientation': orientation,
      'baladeGuidee': baladeGuidee,
      'dixKm': dixKm,
      'velo': velo,
      'vtt': vtt,
      'ravitaillement': ravitaillement,
      'bewapp': bewapp,
      'adepSante': adepSante,
      'parcours': parcours.map((p) => p.toJson()).toList(),
      'geolocation': geolocation.toJson(),
      'ign': ign,
      'gare': gare,
      'infosRendezVous': infosRendezVous,
      'gsm': gsm,
      'lieuDeRendezVous': lieuDeRendezVous,
      'trajetDomicile': trajetDomicile?.toJson(),
      'previsionsMeteo': previsionsMeteo?.map((w) => w.toJson()).toList(),
    };
  }

  PointVert copyWith({
    int? id,
    String? activite,
    String? ndegPv,
    String? groupement,
    String? entite,
    String? localite,
    String? province,
    String? nom,
    String? prenom,
    PointVertStatut? statut,
    DateTime? date,
    bool? quinzeKm,
    bool? pmr,
    bool? poussettes,
    bool? orientation,
    bool? baladeGuidee,
    bool? dixKm,
    bool? velo,
    bool? vtt,
    bool? ravitaillement,
    bool? bewapp,
    bool? adepSante,
    List<Parcours>? parcours,
    Geolocation? geolocation,
    String? ign,
    String? gare,
    String? infosRendezVous,
    String? gsm,
    String? lieuDeRendezVous,
    TripInfo? trajetDomicile,
    List<WeatherForecast>? previsionsMeteo,
  }) {
    return PointVert(
      id: id ?? this.id,
      activite: activite ?? this.activite,
      ndegPv: ndegPv ?? this.ndegPv,
      groupement: groupement ?? this.groupement,
      entite: entite ?? this.entite,
      localite: localite ?? this.localite,
      province: province ?? this.province,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      statut: statut ?? this.statut,
      date: date ?? this.date,
      quinzeKm: quinzeKm ?? this.quinzeKm,
      pmr: pmr ?? this.pmr,
      poussettes: poussettes ?? this.poussettes,
      orientation: orientation ?? this.orientation,
      baladeGuidee: baladeGuidee ?? this.baladeGuidee,
      dixKm: dixKm ?? this.dixKm,
      velo: velo ?? this.velo,
      vtt: vtt ?? this.vtt,
      ravitaillement: ravitaillement ?? this.ravitaillement,
      bewapp: bewapp ?? this.bewapp,
      adepSante: adepSante ?? this.adepSante,
      parcours: parcours ?? this.parcours,
      geolocation: geolocation ?? this.geolocation,
      ign: ign ?? this.ign,
      gare: gare ?? this.gare,
      infosRendezVous: infosRendezVous ?? this.infosRendezVous,
      gsm: gsm ?? this.gsm,
      lieuDeRendezVous: lieuDeRendezVous ?? this.lieuDeRendezVous,
      trajetDomicile: trajetDomicile ?? this.trajetDomicile,
      previsionsMeteo: previsionsMeteo ?? this.previsionsMeteo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        activite,
        ndegPv,
        groupement,
        entite,
        localite,
        province,
        nom,
        prenom,
        statut,
        date,
        quinzeKm,
        pmr,
        poussettes,
        orientation,
        baladeGuidee,
        dixKm,
        velo,
        vtt,
        ravitaillement,
        bewapp,
        adepSante,
        parcours,
        geolocation,
        ign,
        gare,
        infosRendezVous,
        gsm,
        lieuDeRendezVous,
        trajetDomicile,
        previsionsMeteo,
      ];

  final int id;
  final String activite;
  final String ndegPv;
  final String groupement;
  final String entite;
  final String localite;
  final String province;
  final String nom;
  final String prenom;
  final PointVertStatut statut;
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
  final List<Parcours> parcours;
  final Geolocation geolocation;

  final String? ign;
  final String? gare;
  final String? infosRendezVous;
  final String? gsm;
  final String? lieuDeRendezVous;
  final TripInfo? trajetDomicile;
  final List<WeatherForecast>? previsionsMeteo;
}

import 'package:json_map_typedef/json_map_typedef.dart';
import 'package:odwb_points_verts_api/odwb_points_verts_api.dart'
    show FichierParcours;
import 'package:trail_parser_api/trail_parser_api.dart' show TrailInfo;

class Parcours {
  Parcours({
    required this.titre,
    required this.fichier,
    required this.jourDeMarche,
    required this.couleur,
    this.detailParcours,
  });

  factory Parcours.fromOdwb(FichierParcours fichierParcours) {
    return Parcours(
      titre: fichierParcours.titre,
      fichier: fichierParcours.fichier,
      jourDeMarche: fichierParcours.jourDeMarche,
      couleur: fichierParcours.couleur,
    );
  }

  factory Parcours.fromJson(JsonMap json) {
    return Parcours(
      titre: json['titre'] as String,
      fichier: json['fichier'] as String,
      jourDeMarche: json['jourdemarche'] as String,
      couleur: json['couleur'] as String,
      detailParcours: json['detailParcours'] != null
          ? TrailInfo.fromJson(json['detailParcours'] as JsonMap)
          : null,
    );
  }

  JsonMap toJson() {
    return {
      'titre': titre,
      'fichier': fichier,
      'jourdemarche': jourDeMarche,
      'couleur': couleur,
      'detailParcours': detailParcours,
    };
  }

  Parcours copyWith({
    String? titre,
    String? fichier,
    String? jourDeMarche,
    String? couleur,
    TrailInfo? detailParcours,
  }) {
    return Parcours(
      titre: titre ?? this.titre,
      fichier: fichier ?? this.fichier,
      jourDeMarche: jourDeMarche ?? this.jourDeMarche,
      couleur: couleur ?? this.couleur,
      detailParcours: detailParcours ?? this.detailParcours,
    );
  }

  final String titre;
  final String fichier;
  final String jourDeMarche;
  final String couleur;
  final TrailInfo? detailParcours;
}

class FichierParcours {
  FichierParcours({
    required this.titre,
    required this.fichier,
    required this.jourDeMarche,
    required this.couleur,
  });

  factory FichierParcours.fromJson(Map<String, dynamic> json) {
    return FichierParcours(
      titre: json['titre'] as String,
      fichier: json['fichier'] as String,
      jourDeMarche: json['jourdemarche'] as String,
      couleur: json['couleur'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'fichier': fichier,
      'jourdemarche': jourDeMarche,
      'couleur': couleur,
    };
  }

  final String titre;
  final String fichier;
  final String jourDeMarche;
  final String couleur;
}

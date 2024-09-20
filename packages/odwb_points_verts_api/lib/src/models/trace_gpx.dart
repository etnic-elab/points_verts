class TraceGpx {
  TraceGpx({
    required this.titre,
    required this.fichier,
    required this.jourDeMarche,
    required this.couleur,
  });

  factory TraceGpx.fromJson(Map<String, dynamic> json) {
    return TraceGpx(
      titre: json['titre'] as String,
      fichier: json['fichier'] as String,
      jourDeMarche: json['jourdemarche'] as String,
      couleur: json['couleur'] as String,
    );
  }

  final String titre;
  final String fichier;
  final String jourDeMarche;
  final String couleur;
}

import 'package:flutter/material.dart';
import 'package:points_verts/company_data.dart';

class WalkListError extends StatelessWidget {
  const WalkListError(this.refreshWalks, {super.key});

  final Function refreshWalks;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      children: <Widget>[
        const Spacer(),
        const Icon(
          Icons.warning,
          color: CompanyColors.red,
        ),
        Container(
            padding: const EdgeInsets.all(5.0),
            child: const Row(children: [
              Expanded(
                  child: Center(
                      child: Text(
                          "Une erreur est survenue lors de la récupération des données. Merci de réessayer plus tard.\n\nSi vous venez d'installer l'application ou qu'elle vient de se mettre à jour, assurez-vous d'être connecté à internet afin de récupérer le jeu de données initial.",
                          textAlign: TextAlign.center)))
            ])),
        ElevatedButton(
            child: const Text("Réessayer"), onPressed: () => refreshWalks()),
        const Spacer()
      ],
    ));
  }
}

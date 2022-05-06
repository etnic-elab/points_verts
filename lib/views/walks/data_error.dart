import 'package:flutter/material.dart';
import 'package:points_verts/abstractions/company_data.dart';

class DataError extends StatelessWidget {
  const DataError(this.refresh, {Key? key}) : super(key: key);

  final Function() refresh;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.warning,
          color: CompanyColors.of(Theme.of(context).brightness).red,
        ),
        Container(
            padding: const EdgeInsets.all(5.0),
            child: Row(children: const [
              Expanded(
                  child: Center(
                      child: Text(
                          "Une erreur est survenue lors de la récupération des données. Merci de réessayer plus tard.\n\nSi vous venez d'installer l'application ou qu'elle vient de se mettre à jour, assurez-vous d'être connecté à internet afin de récupérer le jeu de données initial.",
                          textAlign: TextAlign.center)))
            ])),
        ElevatedButton(child: const Text("Réessayer"), onPressed: refresh),
      ],
    ));
  }
}

import 'package:flutter/material.dart';

class WalkListError extends StatelessWidget {
  WalkListError(this.refreshWalks);

  final Function refreshWalks;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      children: <Widget>[
        Spacer(),
        Icon(Icons.warning),
        Container(
            padding: EdgeInsets.all(5.0),
            child: Row(children: [
              Expanded(
                  child: Center(
                      child: const Text(
                          "Une erreur est survenue lors de la récupération des données. Merci de réessayer plus tard.\n\nSi vous venez d'installer l'application ou qu'elle vient de se mettre à jour, assurez-vous d'être connecté à internet afin de récupérer le jeu de données initial.",
                          textAlign: TextAlign.center)))
            ])),
        RaisedButton(child: const Text("Réessayer"), onPressed: () => refreshWalks()),
        Spacer()
      ],
    ));
  }
}

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
                      child: Text(
                          "Une erreur est survenue lors de la récupération des données. Merci de réessayer plus tard.",
                          textAlign: TextAlign.center)))
            ])),
        RaisedButton(child: Text("Réessayer"), onPressed: () => refreshWalks()),
        Spacer()
      ],
    ));
  }
}

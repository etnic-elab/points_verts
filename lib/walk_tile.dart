import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'api.dart';
import 'geo_button.dart';
import 'loading.dart';
import 'walk.dart';
import 'walk_details.dart';
import 'walk_utils.dart';

class WalkTile extends StatelessWidget {
  WalkTile({this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    bool smallScreen = window.physicalSize.width <= 640;
    return ListTile(
      dense: smallScreen,
      leading: smallScreen
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [displayIcon(walk)]),
      title: Text(walk.city),
      subtitle: Text(subtitle(walk)),
      enabled: !walk.isCancelled(),
      onTap: () => showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(walk.city),
            content: SingleChildScrollView(
              child: _buildListItemDetails(context, walk),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
      trailing: walk.isCancelled() ? Text("Annulé") : GeoButton(walk: walk),
    );
  }

  Widget _buildListItemDetails(BuildContext context, Walk walk) {
    if (walk.details == null) {
      walk.details = retrieveWalkDetails(walk.id);
    }
    return FutureBuilder(
        future: walk.details,
        builder: (BuildContext context, AsyncSnapshot<WalkDetails> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final details = _buildDetailsList(snapshot.data);
              return Container(
                  height: details.semanticChildCount * 50.0,
                  width: double.maxFinite,
                  child: details);
            } else {
              return SizedBox.shrink();
            }
          } else {
            return Loading();
          }
        });
  }

  ListView _buildDetailsList(WalkDetails walkDetails) {
    List<Widget> list = [];
    if (walkDetails.fifteenKm) {
      list.add(_detailTile('Parcours suppplémentaire de marche de 15 km'));
    }
    if (walkDetails.wheelchair) {
      list.add(_detailTile(
          'Parcours de 5 km accessible aux personnes à mobilité réduite'));
    }
    if (walkDetails.stroller) {
      list.add(_detailTile('Parcours de 5 km accessible aux landaus'));
    }
    if (walkDetails.orientation) {
      list.add(_detailTile("Parcours supplémentaire d'orentation de +/- 8 km"));
    }
    if (walkDetails.guided) {
      list.add(_detailTile("Balade guidée Nature"));
    }
    if (walkDetails.bike) {
      list.add(_detailTile("Parcours supplémentaire de vélo de +/- 20 km"));
    }
    if (walkDetails.mountainBike) {
      list.add(_detailTile(
          "Parcours supplémentaire de vélo tout-terrain de +/- 20 km"));
    }
    if (walkDetails.supplying) {
      list.add(_detailTile("Ravitaillement"));
    }
    if (list.isEmpty) {
      list.add(_detailTile("Pas d'information supplémentaire"));
    }
    return ListView(children: list);
  }

  ListTile _detailTile(String text) {
    return ListTile(dense: true, title: Text(text));
  }

  String subtitle(Walk walk) {
    if (walk.trip != null) {
      return '${walk.province} - ${walk.getFormattedDistance()}';
    } else {
      return walk.province;
    }
  }
}

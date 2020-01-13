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
    if (walk.trip != null) {
      return ExpansionTile(
        leading: smallScreen
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [displayIcon(walk)]),
        title: Text(walk.city),
        subtitle: Text(subtitle(walk)),
        trailing: walk.isCancelled() ? Text("Annulé") : GeoButton(walk: walk),
        children: <Widget>[_buildListItemDetails(context, walk)],
      );
    } else {
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
        trailing: walk.isCancelled() ? Text("Annulé") : GeoButton(walk: walk),
      );
    }
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
              return _buildDetailsList(snapshot.data);
            } else {
              return SizedBox.shrink();
            }
          } else {
            return Loading();
          }
        });
  }

  Widget _buildDetailsList(WalkDetails walkDetails) {
    List<Widget> list = [];
    if (walkDetails.fifteenKm) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text('Parcours suppplémentaire de marche de 15 km'),
      ));
    }
    if (walkDetails.wheelchair) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text(
            'Parcours de 5 km accessible aux personnes à mobilité réduite'),
      ));
    }
    if (walkDetails.stroller) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text('Parcours de 5 km accessible aux landaus'),
      ));
    }
    if (walkDetails.orientation) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text("Parcours supplémentaire d'orentation de +/- 8 km"),
      ));
    }
    if (walkDetails.guided) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text("Balade guidée Nature"),
      ));
    }
    if (walkDetails.bike) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text("Parcours supplémentaire de vélo de +/- 20 km"),
      ));
    }
    if (walkDetails.mountainBike) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title:
            Text("Parcours supplémentaire de vélo tout-terrain de +/- 20 km"),
      ));
    }
    if (walkDetails.supplying) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text("Ravitaillement"),
      ));
    }
    if (list.isEmpty) {
      list.add(ListTile(
        leading: Icon(Icons.info),
        title: Text("Pas d'information supplémentaire"),
      ));
    }
    return ListView(
        shrinkWrap: true, physics: ClampingScrollPhysics(), children: list);
  }

  String subtitle(Walk walk) {
    if (walk.trip != null) {
      return '${walk.province} - ${walk.getFormattedDistance()}';
    } else {
      return walk.province;
    }
  }
}

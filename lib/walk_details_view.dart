import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:points_verts/geo_button.dart';

import 'api.dart';
import 'loading.dart';
import 'mapbox.dart';
import 'platform_widget.dart';
import 'walk.dart';
import 'walk_details.dart';

class WalkDetailsView extends StatelessWidget {
  WalkDetailsView(this.walk);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      androidBuilder: _androidLayout,
      iosBuilder: _iOSLayout,
    );
  }

  Widget _iOSLayout(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            backgroundColor: Theme.of(context).primaryColor,
            middle: Text(walk.city,
                style: Theme.of(context).primaryTextTheme.title)),
        child: SafeArea(
            child: Scaffold(
                body: Column(children: <Widget>[
          _buildMap(context),
          _basicDetails(context),
          Divider(),
          Expanded(child: _buildListItemDetails(context))
        ]))));
  }

  Widget _androidLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(walk.city),
      ),
      body: Column(children: <Widget>[
        _buildMap(context),
        _basicDetails(context),
        Divider(),
        Expanded(child: _buildListItemDetails(context))
      ]),
    );
  }

  Widget _basicDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 32, right: 32, top: 16, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    walk.city,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  walk.province,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          GeoButton(walk: walk),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    final Marker marker = Marker(
      point: new LatLng(walk.lat, walk.long),
      builder: (ctx) => new Container(child: Icon(Icons.location_on)),
    );
    return Container(
        height: 200.0,
        child: retrieveMap([marker], MediaQuery.of(context).platformBrightness,
            centerLat: walk.lat,
            centerLong: walk.long,
            zoom: 16.0,
            interactive: false));
  }

  Widget _buildListItemDetails(BuildContext context) {
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

  ListView _buildDetailsList(WalkDetails walkDetails) {
    List<Widget> list = [];
    if (walkDetails.fifteenKm) {
      list.add(_detailTile('Parcours supplémentaire de marche de 15 km'));
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
    return ListTile(dense: true, leading: Icon(Icons.info), title: Text(text));
  }
}

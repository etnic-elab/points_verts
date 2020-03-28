import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:points_verts/services/mapbox.dart';
import 'package:points_verts/views/walks/walk_details.dart';

import '../platform_widget.dart';
import '../../models/walk.dart';

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
        child: SafeArea(child: Scaffold(
          body: OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.portrait) {
                return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      _buildMap(context),
                      pictogramRow(),
                      WalkDetails(walk)
                    ]);
              } else {
                return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[pictogramRow(), WalkDetails(walk)]);
              }
            },
          ),
        )));
  }

  Widget _androidLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(walk.city),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
              _buildMap(context),
              pictogramRow(),
              WalkDetails(walk)
            ]);
          } else {
            return Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[pictogramRow(), WalkDetails(walk)]);
          }
        },
      ),
    );
  }

  Widget pictogramRow() {
    return Container(
      padding: EdgeInsets.only(top: 15, bottom: 15),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _pictogram("15", walk.fifteenKm,
              "Parcours supplémentaire de marche de 15 km"),
          _pictogram("handi", walk.wheelchair,
              "Parcours de 5 km accessible aux personnes à mobilité réduite"),
          _pictogram("poussette", walk.stroller,
              "Parcours de 5 km accessible aux landaus"),
          _pictogram("orientation", walk.extraOrientation,
              "Parcours supplémentaire de marche de 10 km"),
          _pictogram("marche", walk.extraWalk,
              "Parcours supplémentaire de marche de 15 km"),
          _pictogram("nature", walk.guided, "Balade guidée Nature"),
          _pictogram("velo", walk.bike,
              "Parcours supplémentaire de vélo de +/- 20 km"),
          _pictogram("vtt", walk.mountainBike,
              "Parcours supplémentaire de vélo tout-terrain de +/- 20 km"),
          _pictogram("ravito", walk.waterSupply, "Ravitaillement"),
        ],
      ),
    );
  }

  Widget _pictogram(String field, bool value, String message) {
    return Tooltip(
        message: message,
        child: Image.network(
          "https://www.am-sport.cfwb.be/adeps/med/cont/pv/$field${value ? "" : "_off"}.gif",
          semanticLabel: message,
        ));
  }

  Widget _buildMap(BuildContext context) {
    final Marker marker = Marker(
      point: new LatLng(walk.lat, walk.long),
      builder: (ctx) => new Container(child: Icon(Icons.location_on)),
    );
    return Container(
      height: 200.0,
      child: retrieveMap([marker], Theme.of(context).brightness,
          centerLat: walk.lat,
          centerLong: walk.long,
          zoom: 16.0,
          interactive: false),
    );
  }
}

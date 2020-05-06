import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:points_verts/services/mapbox.dart';
import 'package:points_verts/views/walks/walk_details.dart';

import '../../models/walk.dart';
import 'walk_utils.dart';

class WalkDetailsView extends StatelessWidget {
  WalkDetailsView(this.walk);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.directions), onPressed: () => launchGeoApp(walk))
        ],
        title: FittedBox(
            fit: BoxFit.fitWidth, child: Text("${walk.type} à ${walk.city}")),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
              _buildMap(context, false),
              WalkDetails(walk)
            ]);
          } else {
            return Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
              _buildMap(context, true),
              WalkDetails(walk)
            ]);
          }
        },
      ),
    );
  }

  Widget _buildMap(BuildContext context, bool landscape) {
    final Marker marker = Marker(
      point: new LatLng(walk.lat, walk.long),
      builder: (ctx) => new Container(child: Icon(Icons.location_on)),
    );
    Size size = MediaQuery.of(context).size;
    return Container(
      height: landscape ? size.height : 200.0,
      width: landscape ? size.width / 2 : size.width,
      child: retrieveMap([marker], Theme.of(context).brightness,
          centerLat: walk.lat,
          centerLong: walk.long,
          zoom: 16.0,
          interactive: false),
    );
  }
}

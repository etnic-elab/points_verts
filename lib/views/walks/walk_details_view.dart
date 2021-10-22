import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/services/map/googlemaps.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/mapbox.dart';
import 'package:points_verts/views/walks/walk_details.dart';

import '../../models/walk.dart';

class WalkDetailsView extends StatelessWidget {
  WalkDetailsView(this.walk);

  final MapInterface map = new GoogleMaps();

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    DateFormat fullDate = DateFormat.yMMMMEEEEd("fr_BE");
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${walk.city}"),
                Text("${walk.type} du ${fullDate.format(walk.date)}",
                    style: TextStyle(fontSize: 14))
              ],
            )),
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
    Size size = MediaQuery.of(context).size;
    double height = landscape ? size.height : 200.0;
    double width = landscape ? size.width / 2 : size.width;
    return Container(
      height: height,
      width: width,
      child: map.retrieveStaticImage(walk.long, walk.lat, width.round(),
          height.round(), Theme.of(context).brightness),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:points_verts/models/walk.dart';

import 'walk_utils.dart';

class GeoButton extends StatelessWidget {
  GeoButton({this.walk});

  final Walk walk;
  static final Icon carIcon = Icon(Icons.directions_car);
  static final Icon navIcon = Icon(Icons.near_me);

  @override
  Widget build(BuildContext context) {
    if (walk.isCancelled()) {
      return SizedBox.shrink();
    } else if (walk.trip != null &&
        walk.trip.distance != null &&
        walk.trip.duration != null) {
      return _androidDuration();
    } else if (walk.distance != null) {
      return _androidDistance();
    } else {
      return _androidNoLabel(context);
    }
  }

  Widget _androidDuration() {
    return RaisedButton.icon(
        icon: carIcon,
        onPressed: () {
          launchGeoApp(walk);
        },
        label: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(walk.getFormattedDistance()),
            Text(
                '${Duration(seconds: walk.trip.duration.round()).inMinutes} min')
          ],
        ));
  }

  Widget _androidDistance() {
    return RaisedButton.icon(
        icon: navIcon,
        onPressed: () {
          launchGeoApp(walk);
        },
        label: Text(walk.getFormattedDistance()));
  }

  Widget _androidNoLabel(BuildContext context) {
    return Material(
      child: Ink(
        height: 40.0,
        width: 40.0,
        decoration: ShapeDecoration(
          color: Theme.of(context).buttonColor,
          shape: RoundedRectangleBorder(),
        ),
        child: IconButton(
          tooltip: "Lancer la navigation vers ce point",
          icon: carIcon,
          onPressed: () {
            launchGeoApp(walk);
          },
        ),
      ),
    );
  }
}

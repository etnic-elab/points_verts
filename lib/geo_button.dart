import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:points_verts/platform_widget.dart';
import 'package:points_verts/walk.dart';

import 'walk_utils.dart';

class GeoButton extends StatelessWidget {
  GeoButton({this.walk});

  final Walk walk;
  final Icon carIcon = Icon(Icons.directions_car);
  final TextStyle textStyle = TextStyle();

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      androidBuilder: _android,
      iosBuilder: _android,
    );
  }

  Widget _android(BuildContext context) {
    if (walk.isCancelled()) {
      return SizedBox.shrink();
    } else if (walk.trip != null &&
        walk.trip.distance != null &&
        walk.trip.duration != null) {
      return _androidDuration();
    } else if (walk.distance != null) {
      return _androidDistance();
    } else {
      return _androidNoLabel();
    }
  }

  Widget _androidDuration() {
    return RaisedButton.icon(
        icon: carIcon,
        onPressed: () {
          launchGeoApp(walk);
        },
        label: Text(
          '${Duration(seconds: walk.trip.duration.round()).inMinutes} min',
          style: textStyle,
        ));
  }

  Widget _androidDistance() {
    return RaisedButton(
        onPressed: () {
          launchGeoApp(walk);
        },
        child: Text(
          walk.getFormattedDistance(), style: textStyle,
        ));
  }

  Widget _androidNoLabel() {
    return Material(
      color: Colors.white,
      child: Ink(
        height: 40.0,
        width: 40.0,
        decoration: const ShapeDecoration(
          color: Colors.green,
          shape: RoundedRectangleBorder(),
        ),
        child: IconButton(
          icon: carIcon,
          color: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}

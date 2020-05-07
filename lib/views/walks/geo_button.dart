import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:points_verts/models/walk.dart';

import 'outline_icon_button.dart';
import 'walk_utils.dart';

class GeoButton extends StatelessWidget {
  GeoButton(this.walk);

  final Walk walk;
  static final Icon carIcon = Icon(Icons.directions_car);
  static final Icon navIcon = Icon(Icons.near_me);

  @override
  Widget build(BuildContext context) {
    if (walk.isCancelled()) {
      return Text("Annulé", style: TextStyle(color: Colors.red));
    } else {
      String label = walk.getNavigationLabel();
      if (label != null) {
        return OutlineButton.icon(
            padding: EdgeInsets.all(0.0),
            onPressed: () => launchGeoApp(walk),
            icon: Icon(Icons.directions_car, size: 15.0),
            label: Text(label));
      } else {
        return OutlineIconButton(
            onPressed: () => launchGeoApp(walk), iconData: Icons.directions);
      }
    }
  }
}

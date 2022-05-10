import 'package:flutter/material.dart';
import 'package:points_verts/models/walk.dart';

import '../widgets/outline_icon_button.dart';
import 'utils.dart';

class GeoButton extends StatelessWidget {
  const GeoButton(this.walk, {Key? key}) : super(key: key);

  final Walk walk;
  static const Icon carIcon = Icon(Icons.directions_car);
  static const Icon navIcon = Icon(Icons.near_me);

  @override
  Widget build(BuildContext context) {
    String? label = walk.navigationLabel;
    if (label != null) {
      return OutlinedButton.icon(
          onPressed: () => launchGeoApp(walk),
          style: OutlinedButton.styleFrom(
              primary: Theme.of(context).textTheme.bodyText1!.color),
          icon: const Icon(Icons.directions_car, size: 15.0),
          label: Text(label));
    }

    return OutlineIconButton(
        onPressed: () => launchGeoApp(walk), iconData: Icons.directions);
  }
}

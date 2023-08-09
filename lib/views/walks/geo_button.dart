import 'package:flutter/material.dart';
import 'package:points_verts/models/walk.dart';

import 'outline_icon_button.dart';
import 'walk_utils.dart';

class GeoButton extends StatelessWidget {
  const GeoButton(this.walk, {Key? key}) : super(key: key);

  final Walk walk;
  static const Icon carIcon = Icon(Icons.directions_car);
  static const Icon navIcon = Icon(Icons.near_me);

  @override
  Widget build(BuildContext context) {
    String? label = walk.navigationLabel;
    if (label != null) {
      return Semantics(
        button: true,
        excludeSemantics: true,
        label:
            "Lieu de rendez-vous ${walk.city} est à ${label.replaceAll(r'min', 'minutes')} en voiture. Ouvrir dans une application de cartes externe",
        child: ActionChip(
          onPressed: () => launchGeoApp(walk),
          avatar: const Icon(Icons.directions_car),
          label: Text(label),
        ),
      );
    } else {
      return Semantics(
        button: true,
        label:
            'Ouvrir lieu de rendez-vous ${walk.city} dans une application de cartes externe',
        excludeSemantics: true,
        child: OutlineIconButton(
            onPressed: () => launchGeoApp(walk), iconData: Icons.directions),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:points_verts/company_data.dart';
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
    if (walk.isCancelled) {
      return ExcludeSemantics(
        child: Text("Annulé",
            style: TextStyle(color: CompanyColors.contextualRed(context))),
      );
    } else {
      String? label = walk.navigationLabel;
      if (label != null) {
        return Semantics(
          button: true,
          excludeSemantics: true,
          label:
              "Point de rendez-vous ${walk.city} est à ${label.replaceAll(r'min', 'minutes')} en voiture. Ouvrir dans une application de cartes externe",
          child: OutlinedButton(
            onPressed: () => launchGeoApp(walk),
            style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).textTheme.bodyText1!.color,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                textStyle: const TextStyle(fontSize: 13.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_car, size: 20.0),
                const SizedBox(height: 5),
                Text(label),
              ],
            ),
          ),
        );
      } else {
        return Semantics(
          button: true,
          label:
              'Ouvrir point de rendez-vous ${walk.city} dans une application de cartes externe',
          excludeSemantics: true,
          child: OutlineIconButton(
              onPressed: () => launchGeoApp(walk), iconData: Icons.directions),
        );
      }
    }
  }
}

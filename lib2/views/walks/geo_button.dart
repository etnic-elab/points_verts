import 'package:flutter/material.dart';
import 'package:points_verts/models/walk.dart';

import 'walk_utils.dart';

class GeoButton extends StatelessWidget {
  const GeoButton(this.walk, {super.key});

  final Walk walk;
  static const Icon carIcon = Icon(Icons.directions_car);
  static const Icon navIcon = Icon(Icons.near_me);

  @override
  Widget build(BuildContext context) {
    final String? label = walk.navigationLabel;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label:
          "Lieu de rendez-vous ${walk.city} est à ${label.replaceAll('min', 'minutes')} en voiture. Ouvrir dans une application de cartes externe",
      child: OutlinedButton(
        onPressed: () => launchGeoApp(walk),
        style: OutlinedButton.styleFrom(
            shape: const RoundedRectangleBorder(),
            foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            textStyle: const TextStyle(fontSize: 12),),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_car, size: 20),
            const SizedBox(height: 5),
            Text(label),
          ],
        ),
      ),
    );
    }
}

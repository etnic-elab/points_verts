import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:points_verts/models/walk.dart';

import 'walk_tile.dart';
import 'walks_view.dart';

class WalkResultsList extends StatelessWidget {
  const WalkResultsList(this.walks, this.position, this.currentPlace,
      {super.key});

  final List<Walk> walks;
  final LatLng? position;
  final Places? currentPlace;

  @override
  Widget build(BuildContext context) {
    if (walks.isEmpty) {
      return const Center(
          child: Text("Aucune marche ne correspond aux critères ce jour-là."));
    }
    return ListView.builder(
        itemBuilder: (context, i) {
            return WalkTile(walks[i], TileType.calendar);
        },
        itemCount: walks.length);
  }
}

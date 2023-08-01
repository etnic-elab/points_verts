import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:points_verts/models/walk.dart';

import '../list_header.dart';
import 'walk_tile.dart';
import 'walks_view.dart';

class WalkResultsList extends StatelessWidget {
  const WalkResultsList(this.walks, this.position, this.currentPlace,
      {Key? key})
      : super(key: key);

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
          if (position != null) {
            if (i == 0) {
              return ListHeader(_defineTopHeader());
            }
            // if (i == 6) {
            //   return const ListHeader("Autres Points");
            // }
            // if (i < 6) {
            //   i = i - 1;
            // } else {
            //   i = i - 2;
            // }
            i = i - 1;
          }
          if (walks.length > i) {
            return WalkTile(walks[i], TileType.calendar);
          } else {
            return const SizedBox.shrink();
          }
        },
        itemCount: _defineItemCount(walks));
  }

  String _defineTopHeader() {
    if (currentPlace == Places.home) {
      return "Points les plus proches du domicile";
    } else if (currentPlace == Places.current) {
      return "Points les plus proches de votre position";
    } else {
      return "Points les plus proches";
    }
  }

  int _defineItemCount(List<Walk>? walks) {
    if (position != null) {
      if (walks!.isEmpty) {
        return walks.length;
      } else if (walks.length > 5) {
        return walks.length + 2;
      } else {
        return walks.length + 1;
      }
    } else {
      return walks!.length;
    }
  }
}

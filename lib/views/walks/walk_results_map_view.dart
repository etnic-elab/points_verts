import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';

import 'package:points_verts/views/loading.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/models/coordinates.dart';
import 'package:points_verts/services/map/markers/walk_marker.dart';
import 'package:points_verts/services/map/markers/position_marker.dart';
import 'walks_view.dart';
import 'walk_list_error.dart';
import 'walk_tile.dart';

class WalkResultsMapView extends StatelessWidget {
  WalkResultsMapView(this.walks, this.position, this.currentPlace,
      this.selectedWalk, this.onWalkSelect, this.onMapTap, this.refreshWalks,
      {Key? key})
      : super(key: key);

  final Future<List<Walk>>? walks;
  final Coordinates? position;
  final Places? currentPlace;
  final Walk? selectedWalk;
  final Function(Walk) onWalkSelect;
  final Function onMapTap;
  final Function refreshWalks;
  final List<MarkerInterface> markers = [];
  final List<Map> rawMarkers = [];
  final MapInterface map = Environment.mapInterface;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: walks,
      builder: (BuildContext context, AsyncSnapshot<List<Walk>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            markers.clear();
            for (Walk walk in snapshot.data!) {
              if (walk.lat != null && walk.long != null) {
                markers.add(WalkMarker(walk, selectedWalk, onWalkSelect));
              }
            }
            if (position != null) {
              markers.add(PositionMarker(
                  position!.latitude, position!.longitude, currentPlace!));
            }

            return Stack(
              children: <Widget>[
                map.retrieveMap(markers, onMapTap),
                _buildWalkInfo(selectedWalk),
              ],
            );
          } else if (snapshot.hasError) {
            return WalkListError(refreshWalks);
          }
        }
        return Stack(
          children: <Widget>[
            map.retrieveMap(markers, onMapTap),
            const Loading(),
            _buildWalkInfo(selectedWalk),
          ],
        );
      },
    );
  }

  static Widget _buildWalkInfo(Walk? walk) {
    if (walk == null) {
      return const SizedBox.shrink();
    } else {
      return SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: WalkTile(walk, TileType.calendar),
        ),
      );
    }
  }
}

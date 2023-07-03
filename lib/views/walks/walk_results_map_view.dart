import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:points_verts/constants.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';

import 'package:points_verts/views/loading.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/services/map/markers/walk_marker.dart';
import 'package:points_verts/services/map/markers/position_marker.dart';
import 'walks_view.dart';
import 'walk_list_error.dart';
import 'walk_tile.dart';

import 'dart:io' show Platform;

class WalkResultsMapView extends StatelessWidget {
  WalkResultsMapView(this.walks, this.position, this.currentPlace,
      this.selectedWalk, this.onWalkSelect, this.onTapMap, this.refreshWalks,
      {Key? key})
      : super(key: key);

  final Future<List<Walk>>? walks;
  final LatLng? position;
  final Places? currentPlace;
  final Walk? selectedWalk;
  final Function(Walk) onWalkSelect;
  final Function onTapMap;
  final Function refreshWalks;
  final List<MarkerInterface> markers = [];
  final List<Map> rawMarkers = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: walks,
        builder: (BuildContext context, AsyncSnapshot<List<Walk>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            _setMarkers(snapshot.data!);

            return Stack(
              children: <Widget>[
                Platform.isIOS
                    ? Semantics(
                        label: 'La carte visualisant les Points Verts',
                        excludeSemantics: true,
                        child: kMap.instance
                            .retrieveMap(markers: markers, onTapMap: onTapMap))
                    : kMap.instance
                        .retrieveMap(markers: markers, onTapMap: onTapMap),
                _buildWalkInfo(),
              ],
            );
          }
          if (snapshot.hasError) {
            return WalkListError(refreshWalks);
          }
          return const Loading();
        });
  }

  Widget _buildWalkInfo() {
    return selectedWalk != null
        ? SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: WalkTile(selectedWalk!, TileType.map),
            ),
          )
        : const SizedBox.shrink();
  }

  void _setMarkers(List<Walk> walks) {
    markers.clear();
    if (position != null) {
      markers.add(PositionMarker(
          position!.latitude, position!.longitude, currentPlace!));
    }
    for (Walk walk in walks) {
      if (walk.hasPosition) {
        markers.add(
          WalkMarker(
            walk,
            selectedWalk: selectedWalk,
            onWalkSelect: onWalkSelect,
          ),
        );
      }
    }
  }
}

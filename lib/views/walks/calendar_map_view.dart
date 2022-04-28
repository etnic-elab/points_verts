import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:points_verts/abstractions/environment.dart';
import 'package:points_verts/abstractions/service_locator.dart';
import 'package:points_verts/services/map/map_interface.dart';

import 'package:points_verts/models/walk.dart';
import 'package:points_verts/views/maps/markers/marker_interface.dart';
import 'package:points_verts/views/maps/markers/position_marker.dart';
import 'package:points_verts/views/maps/markers/walk_marker.dart';
import 'package:points_verts/views/places.dart';

class CalendarMapView extends StatelessWidget {
  CalendarMapView(this.walks, this.position, this.place, this.selectedWalk,
      this.onWalkSelect, this.onTapMap,
      {Key? key})
      : super(key: key);

  final List<Walk> walks;
  final LatLng? position;
  final Places? place;
  final Walk? selectedWalk;
  final Function(Walk) onWalkSelect;
  final Function onTapMap;
  final List<MarkerInterface> _markers = [];
  final MapInterface map = locator<Environment>().map;

  @override
  Widget build(BuildContext context) {
    _setMarkers(walks);

    return map.retrieveMap(markers: _markers, onTapMap: onTapMap);
  }

  void _setMarkers(List<Walk> walks) {
    _markers.clear();
    for (Walk walk in walks) {
      if (walk.hasPosition) {
        _markers.add(WalkMarker(walk,
            selectedWalk: selectedWalk, onWalkSelect: onWalkSelect));
      }
    }

    if (position != null) {
      _markers
          .add(PositionMarker(position!.latitude, position!.longitude, place!));
    }
  }
}

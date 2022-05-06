import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:points_verts/services/service_locator.dart';

import 'package:points_verts/models/walk.dart';
import 'package:points_verts/views/walks/filter.dart';
import 'package:points_verts/views/walks/sort_sheet.dart';
import 'package:points_verts/views/widgets/loading.dart';
import 'package:points_verts/views/maps/markers/marker_interface.dart';
import 'package:points_verts/views/maps/markers/position_marker.dart';
import 'package:points_verts/views/maps/markers/walk_marker.dart';
import 'package:points_verts/models/places.dart';
import 'package:points_verts/views/walks/tile.dart';

class CalendarMapView extends StatelessWidget {
  const CalendarMapView(
      {required this.appBar,
      required this.walks,
      required this.sortSheet,
      required this.searching,
      required this.position,
      required this.place,
      required this.selectedWalk,
      required this.onTapMap,
      required this.onWalkSelect,
      Key? key})
      : super(key: key);

  final Widget appBar;
  final List<Walk> walks;
  final SortSheet sortSheet;
  final Future? searching;
  final LatLng? position;
  final Places? place;
  final Walk? selectedWalk;
  final Function(Walk) onWalkSelect;
  final Function onTapMap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomScrollView(
          controller: ScrollController(),
          slivers: [
            appBar,
            SliverFillRemaining(
              hasScrollBody: false,
              child: _Map(
                  walks, position, place, selectedWalk, onWalkSelect, onTapMap),
            ),
          ],
        ),
        if (searching == null)
          Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.only(bottom: 15.0),
              child: FilterFAB(sortSheet)),
        if (selectedWalk != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: WalkTile(selectedWalk!, TileType.map),
          ),
        if (searching != null)
          SimpleDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            children: const [LoadingText('Recherche en cours...')],
          ),
      ],
    );
  }
}

class _Map extends StatelessWidget {
  _Map(this.walks, this.position, this.place, this.selectedWalk,
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

  @override
  Widget build(BuildContext context) {
    _setMarkers(walks);

    return env.map.retrieveMap(markers: _markers, onTapMap: onTapMap);
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

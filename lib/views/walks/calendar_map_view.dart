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

class CalendarMapView extends StatefulWidget {
  const CalendarMapView(
      {required this.appBar,
      required this.walks,
      required this.sortSheet,
      required this.searching,
      required this.position,
      required this.place,
      required this.selectedWalk,
      required this.selectWalk,
      required this.unselectWalk,
      Key? key})
      : super(key: key);

  final Widget appBar;
  final List<Walk> walks;
  final SortSheet sortSheet;
  final Future? searching;
  final LatLng? position;
  final Places? place;
  final Walk? selectedWalk;
  final Function(Walk) selectWalk;
  final Function unselectWalk;

  @override
  State<CalendarMapView> createState() => _CalendarMapViewState();
}

class _CalendarMapViewState extends State<CalendarMapView> {
  late bool selectedWalkVisible;

  @override
  void initState() {
    super.initState();
    selectedWalkVisible = widget.selectedWalk != null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomScrollView(
          controller: ScrollController(),
          slivers: [
            widget.appBar,
            SliverFillRemaining(
              hasScrollBody: false,
              child: _Map(
                  walks: widget.walks,
                  position: widget.position,
                  place: widget.place,
                  selectedWalk: widget.selectedWalk,
                  onWalkSelect: _onWalkSelect,
                  onTapMap: _onTapMap),
            ),
          ],
        ),
        if (widget.searching == null)
          Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.only(bottom: 15.0),
              child: FilterFAB(widget.sortSheet)),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedSlide(
            onEnd: onEndAnimation,
            duration: const Duration(milliseconds: 310),
            offset: selectedWalkVisible ? Offset.zero : const Offset(0, 3),
            curve: Curves.linear,
            child: widget.selectedWalk != null
                ? WalkTile(widget.selectedWalk!, TileType.map)
                : Container(),
          ),
        ),
        if (widget.searching != null)
          SimpleDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            children: const [LoadingText('Recherche en cours...')],
          ),
      ],
    );
  }

  onEndAnimation() {
    if (selectedWalkVisible == false) widget.unselectWalk();
  }

  _onTapMap() {
    setState(() => selectedWalkVisible = false);
  }

  _onWalkSelect(Walk walk) {
    widget.selectWalk(walk);
    if (mounted) setState(() => selectedWalkVisible = true);
  }
}

class _Map extends StatelessWidget {
  _Map(
      {required this.walks,
      required this.position,
      required this.place,
      required this.selectedWalk,
      required this.onWalkSelect,
      required this.onTapMap,
      Key? key})
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

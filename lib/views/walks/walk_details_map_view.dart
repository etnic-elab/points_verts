import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/services/location.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';
import 'package:points_verts/services/map/markers/walk_marker.dart';
import 'package:collection/collection.dart';

class WalkDetailsMapView extends StatelessWidget {
  WalkDetailsMapView(this.walk, this.onTapMap, {Key? key}) : super(key: key);

  final Walk walk;
  final Function onTapMap;
  final MapInterface map = Environment.mapInterface;

  List<MarkerInterface> get _markers {
    if (walk.hasPosition) {
      return [WalkMarker(walk)];
    }

    return [];
  }

  double get _centerLat =>
      walk.lat ??
      walk.paths.firstOrNull?.gpxPoints.firstOrNull?.latLng.latitude ??
      MapInterface.defaultLat;

  double get _centerLong =>
      walk.long ??
      walk.paths.firstOrNull?.gpxPoints.firstOrNull?.latLng.longitude ??
      MapInterface.defaultLong;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkLocationPermission(),
      builder:
          (BuildContext context, AsyncSnapshot<LocationPermission?> snapshot) {
        if (snapshot.hasData) {
          return map.retrieveMap(
              centerLat: _centerLat,
              centerLong: _centerLong,
              zoom: 11.5,
              locationEnabled: true,
              markers: _markers,
              paths: walk.paths,
              onTapMap: onTapMap);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

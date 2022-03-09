import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/models/gpx_path.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/services/location.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';
import 'package:points_verts/services/map/markers/walk_marker.dart';
import 'package:points_verts/views/loading.dart';
import 'package:collection/collection.dart';

class WalkDetailsMapView extends StatelessWidget {
  WalkDetailsMapView(
      this.walk, this.selectedPath, this.onTapMap, this.onTapPath,
      {Key? key})
      : super(key: key);

  final Walk walk;
  final GpxPath? selectedPath;
  final Function() onTapMap;
  final Function(GpxPath) onTapPath;
  final MapInterface map = Environment.mapInterface;

  List<MarkerInterface> get _markers {
    if (walk.hasPosition) {
      return [WalkMarker(walk)];
    }

    return [];
  }

  double get _centerLat =>
      walk.paths.firstOrNull?.pathPoints.firstOrNull?.latLng.latitude ??
      walk.lat ??
      MapInterface.defaultLat;

  double get _centerLong =>
      walk.paths.firstOrNull?.pathPoints.firstOrNull?.latLng.longitude ??
      walk.long ??
      MapInterface.defaultLong;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkLocationPermission(),
      builder:
          (BuildContext context, AsyncSnapshot<LocationPermission?> snapshot) {
        if (snapshot.hasData) {
          return Stack(
            children: <Widget>[
              map.retrieveMap(
                centerLat: _centerLat,
                centerLong: _centerLong,
                zoom: 12.5,
                locationEnabled: true,
                markers: _markers,
                paths: walk.paths,
                onTapMap: onTapMap,
                onTapPath: onTapPath,
              ),
              _buildPathInfo(),
            ],
          );
        }
        return const Loading();
      },
    );
  }

  Widget _buildPathInfo() {
    if (selectedPath == null) {
      return const SizedBox.shrink();
    } else {
      return SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: ListTile(
              title: Text(selectedPath!.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      );
    }
  }
}

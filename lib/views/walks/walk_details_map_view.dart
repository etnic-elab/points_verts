import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/models/gpx_path.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/services/location.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';
import 'package:points_verts/services/map/markers/walk_marker.dart';
import 'package:collection/collection.dart';

class WalkDetailsMapView extends StatelessWidget {
  WalkDetailsMapView(this.walk, this.togglePathVisibility, {Key? key})
      : super(key: key);

  final Walk walk;
  final Function(GpxPath, bool) togglePathVisibility;
  final MapInterface map = Environment.mapInterface;

  List<MarkerInterface> get _markers {
    if (walk.hasPosition) {
      return [WalkMarker(walk)];
    }

    return [];
  }

  double get _centerLat =>
      walk.lat ??
      walk.paths.firstOrNull?.pathPoints.firstOrNull?.latLng.latitude ??
      MapInterface.defaultLat;

  double get _centerLong =>
      walk.long ??
      walk.paths.firstOrNull?.pathPoints.firstOrNull?.latLng.longitude ??
      MapInterface.defaultLong;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkLocationPermission(),
      builder:
          (BuildContext context, AsyncSnapshot<LocationPermission?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: <Widget>[
              map.retrieveMap(
                  centerLat: _centerLat,
                  centerLong: _centerLong,
                  zoom: 13,
                  locationEnabled: true,
                  markers: _markers,
                  paths: walk.paths),
              _buildPathSheet(context)
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPathSheet(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    return ScrollConfiguration(
      behavior: NoScrollGlowBehavior(),
      child: DraggableScrollableSheet(
        minChildSize: 0.1,
        maxChildSize: 0.2,
        initialChildSize: 0.1,
        snap: true,
        snapSizes: const [0.2],
        builder: ((context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: brightness == Brightness.light
                  ? Colors.white
                  : CompanyColors.black,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: brightness == Brightness.light
                      ? Colors.grey
                      : Colors.white,
                  offset: const Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: ListView(
              controller: scrollController,
              children: _buildPathTiles(brightness),
            ),
          );
        }),
      ),
    );
  }

  _buildPathTiles(Brightness brightness) {
    List<Widget> tiles = [];

    Widget header = const ListTile(
      leading: Icon(Icons.hiking),
      title: Text('Parcours'),
    );
    tiles.add(header);

    for (int i = 0; i < walk.paths.length; i++) {
      GpxPath _path = walk.paths[i];

      Widget tile = SwitchListTile(
        title: Text(
          _path.title,
        ),
        value: _path.visible,
        onChanged: (newValue) {
          togglePathVisibility(_path, newValue);
        },
        secondary: Icon(Icons.circle, color: GpxPath.color(brightness, i)),
      );

      tiles.add(tile);
    }

    return tiles;
  }

  // Widget _buildPathInfo() {
  //   if (selectedPath == null) {
  //     return const SizedBox.shrink();
  //   } else {
  //     return SafeArea(
  //       child: Align(
  //         alignment: Alignment.bottomCenter,
  //         child: Card(
  //           margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
  //           child: ListTile(
  //             leading: const Icon(Icons.hiking_rounded),
  //             title: Text(selectedPath!.title,
  //                 style: const TextStyle(fontWeight: FontWeight.bold),
  //                 overflow: TextOverflow.ellipsis),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

  // _showBottomSheet(BuildContext context) {
  //   if (walk.hasPath) {
  //     // Brightness brightness = Theme.of(context).brightness;
  //     showBottomSheet(
  //         context: context,
  //         shape: const RoundedRectangleBorder(
  //             borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  //         enableDrag: true,
  //         builder: (context) {
  //           return const ListTile(
  //             leading: Icon(Icons.hiking),
  //             title: Text('Parcours',
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //                 overflow: TextOverflow.ellipsis),
  //           );
  //         });
  //   }
  // }
}

class NoScrollGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

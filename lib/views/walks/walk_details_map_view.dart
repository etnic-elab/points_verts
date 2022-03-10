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
        if (snapshot.hasData) {
          return Stack(
            children: <Widget>[
              map.retrieveMap(
                centerLat: _centerLat,
                centerLong: _centerLong,
                zoom: 13,
                locationEnabled: true,
                markers: _markers,
                paths: walk.paths,
                onTapMap: onTapMap,
                onTapPath: onTapPath,
              ),
              _buildPathSheet(context),
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
              leading: const Icon(Icons.hiking_rounded),
              title: Text(selectedPath!.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildPathSheet(BuildContext context) {
    // showBottomSheet(context: context, builder: builder)
    return DraggableScrollableSheet(
      minChildSize: 0.1,
      maxChildSize: 0.2,
      initialChildSize: 0.1,
      snap: true,
      snapSizes: const [0.2],
      builder: ((context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Stack(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: ListTile(
                      leading: Icon(Icons.hiking),
                      title: Text('Parcours',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  Align(
                      alignment: Alignment.topCenter,
                      child: Icon(
                        Icons.horizontal_rule_rounded,
                        color: Colors.grey,
                        size: 40,
                      )),
                ],
              ),
              SwitchListTile(
                title: const Text('Parcours 5km'),
                value: true,
                onChanged: (newValue) {},
                secondary: const Icon(
                  Icons.circle,
                  color: CompanyColors.black,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

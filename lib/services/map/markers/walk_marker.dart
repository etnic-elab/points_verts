import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_map/flutter_map.dart' as flutter;
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:points_verts/services/map/googlemaps.dart';

import 'package:points_verts/services/map/markers/marker_interface.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/views/walks/walk_icon.dart';
import 'package:points_verts/models/walk.dart';

class WalkMarker implements MarkerInterface {
  final Walk walk;
  final Walk? selectedWalk;
  final Function(Walk) onWalkSelect;

  WalkMarker(this.walk, this.selectedWalk, this.onWalkSelect);

  @override
  flutter.Marker buildFlutterMarker() {
    return flutter.Marker(
      width: 25,
      height: 25,
      point: LatLng(walk.lat!, walk.long!),
      builder: (ctx) => RawMaterialButton(
        child: WalkIcon(walk, size: 21),
        shape: const CircleBorder(),
        elevation: selectedWalk == walk ? 5.0 : 2.0,
        fillColor: selectedWalk == walk
            ? CompanyColors.lightestGreen
            : CompanyColors.darkGreen,
        onPressed: () {
          onWalkSelect(walk);
        },
      ),
    );
  }

  @override
  google.Marker buildGoogleMarker(
      Map<dynamic, google.BitmapDescriptor> mapIcons) {
    google.MarkerId markerId =
        google.MarkerId(walk.lat!.toString() + walk.long!.toString());
    google.BitmapDescriptor icon;
    if (walk.isCancelled()) {
      icon = mapIcons[selectedWalk == walk
          ? GoogleMapIcons.selectedCancelIcon
          : GoogleMapIcons.unselectedCancelIcon]!;
    } else {
      icon = mapIcons[selectedWalk == walk
          ? GoogleMapIcons.selectedWalkIcon
          : GoogleMapIcons.unselectedWalkIcon]!;
    }

    return google.Marker(
      markerId: markerId,
      position: google.LatLng(walk.lat!, walk.long!),
      icon: icon,
      consumeTapEvents: true,
      onTap: () {
        onWalkSelect(walk);
      },
    );
  }
}

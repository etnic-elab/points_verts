import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_map/flutter_map.dart' as flutter;
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;

import 'package:points_verts/views/maps/markers/marker_interface.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/views/maps/google_map.dart';
import 'package:points_verts/views/walks/walk_icon.dart';
import 'package:points_verts/models/walk.dart';

class WalkMarker implements MarkerInterface {
  final Walk walk;
  final Walk? selectedWalk;
  final Function(Walk)? onWalkSelect;

  WalkMarker(this.walk, {this.selectedWalk, this.onWalkSelect});

  @override
  flutter.Marker buildFlutterMarker() {
    return flutter.Marker(
      width: 25,
      height: 25,
      point: LatLng(walk.lat!, walk.long!),
      child: RawMaterialButton(
        shape: const CircleBorder(),
        elevation: selectedWalk == walk ? 5.0 : 2.0,
        fillColor: selectedWalk == walk
            ? CompanyColors.lightestGreen
            : CompanyColors.darkGreen,
        onPressed: () {
          if (onWalkSelect != null) {
            onWalkSelect!(walk);
          }
        },
        child: WalkIcon(walk, size: 21),
      ),
    );
  }

  @override
  google.Marker buildGoogleMarker(Map<Enum, google.BitmapDescriptor> mapIcons) {
    google.MarkerId markerId =
        google.MarkerId(walk.lat!.toString() + walk.long!.toString());
    google.BitmapDescriptor icon;
    if (walk.isCancelled) {
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
      consumeTapEvents: onWalkSelect != null,
      infoWindow: google.InfoWindow(title: walk.city),
      onTap: () {
        if (onWalkSelect != null) {
          onWalkSelect!(walk);
        }
      },
    );
  }
}

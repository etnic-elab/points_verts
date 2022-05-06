import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_map/flutter_map.dart' as flutter;
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;

import 'package:points_verts/abstractions/company_data.dart';
import 'package:points_verts/views/maps/google_map.dart';
import 'package:points_verts/views/maps/markers/marker_interface.dart';
import 'package:points_verts/views/walks/icon.dart';
import 'package:points_verts/models/walk.dart';

class WalkMarker implements MarkerInterface {
  final Walk walk;
  final Walk? selectedWalk;
  final Function(Walk)? onWalkSelect;
  final String infoWindowText;

  WalkMarker(this.walk,
      {this.selectedWalk,
      this.onWalkSelect,
      this.infoWindowText = 'Point de rendez-vous'});

  @override
  flutter.Marker buildFlutterMarker() {
    return flutter.Marker(
      width: 25,
      height: 25,
      point: LatLng(walk.lat!, walk.long!),
      builder: (ctx) => RawMaterialButton(
        child: WalkIcon(walk, size: 21),
        shape: const CircleBorder(),
        elevation: selectedWalk == walk ? 6.0 : 2.0,
        fillColor: selectedWalk == walk
            ? CompanyColors.lightestGreen
            : CompanyColors.darkGreen,
        onPressed: () {
          if (onWalkSelect != null) {
            onWalkSelect!(walk);
          }
        },
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
      infoWindow: google.InfoWindow(title: infoWindowText),
      onTap: () {
        if (onWalkSelect != null) {
          onWalkSelect!(walk);
        }
      },
    );
  }
}

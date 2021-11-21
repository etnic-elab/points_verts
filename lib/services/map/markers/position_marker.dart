import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_map/flutter_map.dart' as flutter;
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;

import 'package:points_verts/services/map/markers/marker_interface.dart';
import 'package:points_verts/views/walks/walks_view.dart';

class PositionMarker implements MarkerInterface {
  final double latitude;
  final double longitude;
  final Places currentPlace;

  PositionMarker(this.latitude, this.longitude, this.currentPlace);

  @override
  flutter.Marker buildFlutterMarker() {
    return flutter.Marker(
      point: latlong.LatLng(latitude, longitude),
      builder: (ctx) => IgnorePointer(
        child: Icon(currentPlace.icon),
      ),
    );
  }

  @override
  google.Marker buildGoogleMarker(
      Map<dynamic, google.BitmapDescriptor> mapIcons) {
    google.MarkerId markerId =
        google.MarkerId(latitude.toString() + longitude.toString());

    return google.Marker(
        markerId: markerId,
        position: google.LatLng(latitude, longitude),
        infoWindow: InfoWindow(title: "Votre ${currentPlace.text}"),
        icon: mapIcons[currentPlace]!);
  }
}

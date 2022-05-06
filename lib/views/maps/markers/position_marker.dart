import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_map/flutter_map.dart' as flutter;
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;

import 'package:points_verts/views/maps/markers/marker_interface.dart';
import 'package:points_verts/models/places.dart';

class PositionMarker implements MarkerInterface {
  final double latitude;
  final double longitude;
  final Places place;

  PositionMarker(this.latitude, this.longitude, this.place);

  @override
  flutter.Marker buildFlutterMarker() {
    return flutter.Marker(
      point: latlong.LatLng(latitude, longitude),
      builder: (ctx) => IgnorePointer(
        child: Icon(place.icon),
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
        infoWindow: InfoWindow(title: "Votre ${place.text}"),
        icon: mapIcons[place]!);
  }
}

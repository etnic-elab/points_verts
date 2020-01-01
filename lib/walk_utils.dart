import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'walk.dart';

Widget displayIcon(Walk walk, {Color color, double size}) {
  if (walk.isCancelled()) {
    return Icon(Icons.cancel, color: color, size: size);
  } else if (walk.type == 'M') {
    return Icon(Icons.directions_walk, color: color, size: size);
  } else if (walk.type == 'O') {
    return Icon(Icons.map, color: color, size: size);
  } else {
    return SizedBox.shrink();
  }
}

Widget displayTripButton(Walk walk) {
  if (walk.trip != null &&
      walk.trip.distance != null &&
      walk.trip.duration != null) {
    return RaisedButton.icon(
        icon: Icon(Icons.directions_car, size: 15.0),
        onPressed: () {
          launchGeoApp(walk);
        },
        label: Text(
          ' ${Duration(seconds: walk.trip.duration.round()).inMinutes} min', style: TextStyle(fontSize: 12.0),));
  } else {
    return SizedBox.shrink();
  }
}

void launchGeoApp(Walk walk) async {
  if (walk.lat != null && walk.long != null) {
    if (Platform.isIOS) {
      String mapSchema = 'https://maps.apple.com/?q=${walk.lat},${walk.long}';
      if (await canLaunch(mapSchema)) {
        await launch(mapSchema);
      }
    } else {
      String mapSchema = 'geo:${walk.lat},${walk.long}';
      if (await canLaunch(mapSchema)) {
        await launch(mapSchema);
      }
    }
  }
}

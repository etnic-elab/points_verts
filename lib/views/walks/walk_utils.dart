import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import '../../models/walk.dart';

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

int sortWalks(Walk a, Walk b) {
  if (a.trip != null && b.trip != null) {
    return a.trip.duration.compareTo(b.trip.duration);
  } else if (!a.isCancelled() && b.isCancelled()) {
    return -1;
  } else if (a.isCancelled() && !b.isCancelled()) {
    return 1;
  } else if (a.distance != null && b.distance != null) {
    return a.distance.compareTo(b.distance);
  } else if (a.distance != null) {
    return -1;
  } else {
    return 1;
  }
}

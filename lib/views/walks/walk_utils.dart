import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import '../../models/walk.dart';

void launchGeoApp(Walk walk) async {
  if (walk.lat != null && walk.long != null) {
    if (Platform.isIOS) {
      launchURL('https://maps.apple.com/?q=${walk.lat},${walk.long}');
    } else {
      launchURL(
          'geo:${walk.lat},${walk.long}?q=${walk.lat},${walk.long}(${walk.city})');
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

launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  }
}

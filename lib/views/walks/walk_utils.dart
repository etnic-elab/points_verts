import 'dart:developer';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/services/adeps.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/mapbox.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/walk.dart';

const String TAG = "dev.alpagaga.points_verts.WalksUtils";

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

Future<List<Walk>> retrieveSortedWalks(DateTime date,
    {Position position, WalkFilter filter}) async {
  List<Walk> walks = await DBProvider.db.getWalks(date, filter: filter);
  if (position == null) {
    walks.sort((a, b) => sortWalks(a, b));
    return walks;
  }
  for (Walk walk in walks) {
    if (walk.isPositionable()) {
      double distance = Geolocator.distanceBetween(
          position.latitude, position.longitude, walk.lat, walk.long);
      walk.distance = distance;
      walk.trip = null;
    }
  }
  walks.sort((a, b) => sortWalks(a, b));
  try {
    await retrieveTrips(position.longitude, position.latitude, walks).then((_) {
      walks.sort((a, b) => sortWalks(a, b));
    });
  } catch (err) {
    print("Cannot retrieve trips: $err");
  }
  return walks;
}

launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  }
}

updateWalks() async {
  log("Updating walks", name: TAG);
  String lastUpdate = await PrefsProvider.prefs.getString("last_walk_update");
  DateTime now = DateTime.now().toUtc();
  if (lastUpdate == null) {
    try {
      List<Walk> newWalks = await fetchAllWalks();
      if (newWalks.isNotEmpty) {
        await DBProvider.db.insertWalks(newWalks);
        PrefsProvider.prefs
            .setString("last_walk_update", now.toIso8601String());
        await _fixNextWalks();
      }
    } catch (err) {
      print("Cannot fetch walks list: $err");
    }
  } else {
    DateTime lastUpdateDate = DateTime.parse(lastUpdate);
    if (now.difference(lastUpdateDate) > Duration(hours: 1)) {
      try {
        List<Walk> updatedWalks = await refreshAllWalks(lastUpdate);
        if (updatedWalks.isNotEmpty) {
          await DBProvider.db.insertWalks(updatedWalks);
        }
        PrefsProvider.prefs
            .setString("last_walk_update", now.toIso8601String());
        await _fixNextWalks();
        await DBProvider.db.deleteOldWalks();
      } catch (err) {
        print("Cannot refresh walks list: $err");
      }
    } else {
      log("Not refreshing walks list since it has been done less than an hour ago",
          name: TAG);
    }
  }
}

Future<List<DateTime>> retrieveNearestDates() async {
  List<DateTime> walkDates = await DBProvider.db.getWalkDates();
  DateTime now = DateTime.now();
  DateTime inAWeek = now.add(Duration(days: 10));
  walkDates.retainWhere(
      (element) => element.isAfter(now) && element.isBefore(inAWeek));
  return walkDates;
}

Future<Position> retrieveHomePosition() async {
  String homePos = await PrefsProvider.prefs.getString("home_coords");
  if (homePos == null) return null;
  List<String> split = homePos.split(",");
  return Position(
      latitude: double.parse(split[0]), longitude: double.parse(split[1]));
}

// For some reasons, the API is not as up-to-date as the website.
// To fix that until it is resolved, retrieve the statuses from the website
// for the walks of the next walk date when we refresh data from the API.
_fixNextWalks() async {
  List<DateTime> nextDates = await retrieveNearestDates();
  for (DateTime walkDate in nextDates) {
    List<Walk> fromWebsite = await retrieveWalksFromWebSite(walkDate);
    List<Walk> fromDbs = await DBProvider.db.getWalks(walkDate);
    for (Walk walk in fromDbs) {
      Walk website = fromWebsite.singleWhere((element) => element.id == walk.id,
          orElse: () => null);
      if (website == null) {
        walk.status = "Annulé";
      } else if (website.status != null) {
        walk.status = website.status;
      }
    }
    await DBProvider.db.insertWalks(fromDbs);
  }
}

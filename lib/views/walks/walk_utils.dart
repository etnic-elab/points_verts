import 'dart:developer';
import 'dart:io';

import 'package:points_verts/services/adeps.dart';
import 'package:points_verts/services/database.dart';
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

launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  }
}

updateWalks() async {
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
      } catch (err) {
        print("Cannot refresh walks list: $err");
      }
    } else {
      log("Not refreshing walks list since it has been done less than an hour ago",
          name: TAG);
    }
  }
}

// For some reasons, the API is not as up-to-date as the website.
// To fix that until it is resolved, retrieve the statuses from the website
// for the walks of the next walk date when we refresh data from the API.
_fixNextWalks() async {
  List<DateTime> walkDates = await DBProvider.db.getWalkDates();
  if (walkDates.isEmpty) return;
  DateTime nextWalkDate = walkDates[1];
  List<Walk> fromWebsite = await retrieveWalksFromWebSite(nextWalkDate);
  List<Walk> fromDbs = await DBProvider.db.getWalks(nextWalkDate);
  for (Walk walk in fromDbs) {
    Walk website = fromWebsite.singleWhere((element) => element.id == walk.id,
        orElse: () => null);
    walk.status = website == null ? "Annulé" : website.status;
  }
  await DBProvider.db.insertWalks(fromDbs);
}

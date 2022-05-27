import 'dart:developer';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/models/weather.dart';
import 'package:points_verts/models/website_walk.dart';
import 'package:points_verts/services/adeps.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/openweather.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

import '../../models/walk.dart';

final MapInterface map = Environment.mapInterface;

const String tag = "dev.alpagaga.points_verts.WalksUtils";

Future<void> launchGeoApp(Walk walk) async {
  if (walk.hasPosition) {
    if (Platform.isIOS) {
      launchURL('https://maps.apple.com/?q=${walk.lat},${walk.long}');
    } else {
      launchURL(
          'geo:${walk.lat},${walk.long}?q=${walk.lat},${walk.long}(${walk.city})');
    }
  }
}

void addToCalendar(Walk walk) {
  final Event event = Event(
    title: "Marche ADEPS de ${walk.city}",
    description: _generateEventDescription(walk),
    location: "${walk.meetingPoint}, ${walk.entity}",
    startDate: walk.date.add(const Duration(hours: 8)),
    endDate: walk.date.add(const Duration(hours: 18)),
  );
  Add2Calendar.addEvent2Cal(event);
}

String _generateEventDescription(Walk walk) {
  String result = "";
  result +=
      "Groupement organisateur : ${walk.organizer} - ${walk.contactFirstName} ${walk.contactLastName}";
  if (walk.contactPhoneNumber != null) {
    result += " - ${walk.contactPhoneNumber}";
  }
  if (walk.meetingPointInfo != null) {
    result += "\nRemarques : ${walk.meetingPointInfo}";
  }
  return result;
}

int sortWalks(Walk a, Walk b) {
  if (a.trip != null && b.trip != null) {
    return a.trip!.duration!.compareTo(b.trip!.duration!);
  } else if (!a.isCancelled && b.isCancelled) {
    return -1;
  } else if (a.isCancelled && !b.isCancelled) {
    return 1;
  } else if (a.distance != null && b.distance != null) {
    return a.distance!.compareTo(b.distance!);
  } else if (a.distance != null) {
    return -1;
  } else {
    return 1;
  }
}

Future<List<Walk>> retrieveSortedWalks(DateTime? date,
    {LatLng? position, WalkFilter? filter}) async {
  List<Walk> walks = await DBProvider.db.getWalks(date, filter: filter);
  if (position == null) {
    walks.sort((a, b) => sortWalks(a, b));
    return walks;
  }
  for (Walk walk in walks) {
    if (walk.isPositionable) {
      double distance = Geolocator.distanceBetween(
          position.latitude, position.longitude, walk.lat!, walk.long!);
      walk.distance = distance;
      walk.trip = null;
    }
  }
  walks.sort((a, b) => sortWalks(a, b));
  try {
    await map
        .retrieveTrips(position.longitude, position.latitude, walks)
        .then((_) {
      walks.sort((a, b) => sortWalks(a, b));
    });
  } catch (err) {
    print("Cannot retrieve trips: $err");
  }
  return walks;
}

Future<void> launchURL(String? url) async {
  if (url == null) return;
  Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    try {
      await launchUrl(uri);
    } catch (err) {
      print("Cannot launch URL: $err");
    }
  }
}

Future<void> updateWalks() async {
  log("Updating walks", name: tag);
  String? lastUpdateIso8601Utc =
      await PrefsProvider.prefs.getString(Prefs.lastWalkUpdate);
  DateTime nowDateLocal = DateTime.now();
  DateTime nowDateUtc = nowDateLocal.toUtc();
  String nowIso8601Utc = nowDateUtc.toIso8601String();
  if (lastUpdateIso8601Utc == null) {
    List<Walk> newWalks = await fetchAllWalks(fromDateLocal: nowDateLocal);
    // JSON might be out of date
    lastUpdateIso8601Utc = getLastUpdateTimestamp(newWalks).toIso8601String();
    if (newWalks.isNotEmpty) {
      await DBProvider.db.insertWalks(newWalks, empty: true);
      PrefsProvider.prefs.setString(Prefs.lastWalkUpdate, lastUpdateIso8601Utc);
    }
  }
  if (nowDateUtc.difference(DateTime.parse(lastUpdateIso8601Utc)) >
      const Duration(hours: 1)) {
    try {
      List<Walk> updatedWalks = await refreshAllWalks(lastUpdateIso8601Utc,
          fromDateLocal: nowDateLocal);
      if (updatedWalks.isNotEmpty) {
        await DBProvider.db.insertWalks(updatedWalks);
      }
      PrefsProvider.prefs.setString(Prefs.lastWalkUpdate, nowIso8601Utc);
      await _fixNextWalks();
      await DBProvider.db.deleteOldWalks();
    } catch (err) {
      print("Cannot refresh walks list: $err");
    }
  } else {
    log("Not refreshing walks list since it has been done less than an hour ago",
        name: tag);
  }
}

DateTime getLastUpdateTimestamp(List<Walk> walks) {
  // in case we have no walks (JSON too old), then set by default to a year
  // ago, so that updateWalks will retrieve them all
  DateTime lastUpdate = DateTime.now().subtract(const Duration(days: 365));
  for (Walk walk in walks) {
    if (walk.date.isAfter(lastUpdate)) {
      lastUpdate = walk.date;
    }
  }
  return lastUpdate;
}

Future<List<DateTime>> retrieveNearestDates() async {
  List<DateTime> walkDates = await DBProvider.db.getWalkDates();
  DateTime now = DateTime.now();
  DateTime inAWeek = now.add(const Duration(days: 10));
  walkDates.retainWhere(
      (element) => element.isAfter(now) && element.isBefore(inAWeek));
  return walkDates;
}

Future<LatLng?> retrieveHomePosition() async {
  String? homePos = await PrefsProvider.prefs.getString(Prefs.homeCoords);
  if (homePos == null) return null;
  List<String> split = homePos.split(",");
  return LatLng(double.parse(split[0]), double.parse(split[1]));
}

Future<List<Weather>> retrieveWeather(Walk walk) {
  if (walk.weathers.isEmpty && walk.isPositionable) {
    return getWeather(walk.long!, walk.lat!, walk.date);
  }

  return Future.value([]);
}

// For some reasons, the API is not as up-to-date as the website.
// To fix that until it is resolved, retrieve the statuses from the website
// for the walks of the next walk date when we refresh data from the API.
Future<void> _fixNextWalks() async {
  List<DateTime> nextDates = await retrieveNearestDates();
  for (DateTime walkDate in nextDates) {
    List<WebsiteWalk> fromWebsite = await retrieveWalksFromWebSite(walkDate);
    List<Walk> fromDb = await DBProvider.db.getWalks(walkDate);
    List<Walk> fromDbUpdated = [];
    for (Walk walk in fromDb) {
      WebsiteWalk? website;
      for (WebsiteWalk websiteWalk in fromWebsite) {
        if (walk.id == websiteWalk.id) {
          website = websiteWalk;
          break;
        }
      }
      if (website == null) {
        walk.status = "Annulé";
        fromDbUpdated.add(walk);
      } else if (website.status != null && website.status != walk.status) {
        walk.status = website.status!;
        fromDbUpdated.add(walk);
      }
    }
    await DBProvider.db.insertWalks(fromDbUpdated);
  }
}

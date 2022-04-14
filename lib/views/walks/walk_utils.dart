import 'dart:developer';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:points_verts/abstractions/environment.dart';
import 'package:points_verts/models/walk_sort.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/models/weather.dart';
import 'package:points_verts/models/website_walk.dart';
import 'package:points_verts/abstractions/service_locator.dart';
import 'package:points_verts/services/adeps.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/openweather.dart';
import 'package:points_verts/services/positioning.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

import '../../models/walk.dart';

final MapInterface _map = locator<Environment>().map;
final DBProvider _db = locator<DBProvider>();
final PrefsProvider _prefs = locator<PrefsProvider>();

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

int sortByPosition(Walk a, Walk b) {
  if (a.trip?.duration != null && b.trip?.duration != null) {
    return a.trip!.duration!.compareTo(b.trip!.duration!);
  }
  if (a.distance != null && b.distance != null) {
    return a.distance!.compareTo(b.distance!);
  }
  if (a.distance != null) return -1;

  return 1;
}

Future<List<Walk>> retrieveSortedWalks(
    {WalkFilter? filter, SortBy? sortBy, LatLng? position}) async {
  List<Walk> walks = await _db.getWalks(filter: filter, sortBy: sortBy);

  if (position == null) return walks;

  for (Walk walk in walks) {
    if (walk.isPositionable) {
      double distance = Geolocator.distanceBetween(
          position.latitude, position.longitude, walk.lat!, walk.long!);
      walk.distance = distance;
      walk.trip = null;
    }
  }
  walks.sort((a, b) => sortByPosition(a, b));
  try {
    await _map
        .retrieveTrips(position.longitude, position.latitude, walks)
        .then((_) {
      walks.sort((a, b) => sortByPosition(a, b));
    });
  } catch (err) {
    print("Cannot retrieve trips: $err");
  }
  return walks;
}

Future<void> launchURL(url) async {
  if (await canLaunch(url)) {
    try {
      await launch(url);
    } catch (err) {
      print("Cannot launch URL: $err");
    }
  }
}

Future<void> updateWalks() async {
  log("Updating walks", name: tag);
  String? lastUpdateIso8601Utc = await _prefs.getString(Prefs.lastWalkUpdate);
  DateTime nowDateLocal = DateTime.now();
  DateTime nowDateUtc = nowDateLocal.toUtc();
  String nowIso8601Utc = nowDateUtc.toIso8601String();
  if (lastUpdateIso8601Utc == null) {
    List<Walk> newWalks = await fetchAllWalks(fromDateLocal: nowDateLocal);
    if (newWalks.isNotEmpty) {
      await _db.insertWalks(newWalks);
      _prefs.setString(Prefs.lastWalkUpdate, nowIso8601Utc);
      await _fixNextWalks();
    }
  } else if (nowDateUtc.difference(DateTime.parse(lastUpdateIso8601Utc)) >
      const Duration(hours: 1)) {
    try {
      List<Walk> updatedWalks = await refreshAllWalks(lastUpdateIso8601Utc,
          fromDateLocal: nowDateLocal);
      if (updatedWalks.isNotEmpty) {
        await _db.insertWalks(updatedWalks);
      }
      _prefs.setString(Prefs.lastWalkUpdate, nowIso8601Utc);
      await _fixNextWalks();
      await _db.deleteOldWalks();
    } catch (err) {
      print("Cannot refresh walks list: $err");
    }
  } else {
    log("Not refreshing walks list since it has been done less than an hour ago",
        name: tag);
  }
}

Future<List<DateTime>> retrieveNearestDates() async {
  List<DateTime> walkDates = await _db.getWalkDates();
  DateTime now = DateTime.now();
  DateTime inAWeek = now.add(const Duration(days: 10));
  walkDates.retainWhere(
      (element) => element.isAfter(now) && element.isBefore(inAWeek));
  return walkDates;
}

Future<LatLng?> retrieveHomePosition() async {
  String? homePos = await _prefs.getString(Prefs.homeCoords);
  if (homePos == null) return null;
  List<String> split = homePos.split(",");
  return LatLng(double.parse(split[0]), double.parse(split[1]));
}

Future<LatLng?> retrieveCurrentPosition() async {
  Position position = await determinePosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 4));
  return LatLng(position.latitude, position.longitude);
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
    List<Walk> fromDb = await _db.getWalks(filter: WalkFilter.date(walkDate));
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
    await _db.insertWalks(fromDbUpdated);
  }
}

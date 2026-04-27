import 'dart:developer';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_api/maps_api.dart';
import 'package:maps_repository/maps_repository.dart';
import 'package:points_verts/locator.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/models/weather.dart';
import 'package:points_verts/models/website_walk.dart';
import 'package:points_verts/services/adeps.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/openweather.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/walks/walks_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:collection/collection.dart';

import '../../models/walk.dart';

const String tag = "dev.alpagaga.points_verts.WalksUtils";

Future<void> launchGeoApp(Walk walk) async {
  if (!walk.hasPosition) return;
  if (Platform.isIOS) {
    // Apple Maps directions to the meeting point. `daddr` opens the routing
    // sheet with the user's current location as origin.
    await launchURL('maps://?daddr=${walk.lat},${walk.long}');
  } else {
    // Prefer Google Maps turn-by-turn navigation; fall back to a geo: pin
    // if the navigation intent isn't handled (e.g. Maps not installed).
    final navigation = 'google.navigation:q=${walk.lat},${walk.long}&mode=d';
    final geoFallback =
        'geo:${walk.lat},${walk.long}?q=${walk.lat},${walk.long}(${walk.city})';
    if (await canLaunchUrl(Uri.parse(navigation))) {
      await launchURL(navigation);
    } else {
      await launchURL(geoFallback);
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
    return a.trip!.duration.compareTo(b.trip!.duration);
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

Future<List<Walk>> retrieveSortedWalks(
  DateTime? date, {
  LatLng? position,
  WalkFilter? filter,
}) async {
  List<Walk> walks = await DBProvider.db.getWalks(date, filter: filter);

  if (position == null) {
    walks.sort((a, b) => sortWalks(a, b));
    return walks;
  }

  for (Walk walk in walks) {
    if (walk.isPositionable) {
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        walk.lat!,
        walk.long!,
      );
      walk.distance = distance;
      walk.trip = null;
    }
  }

  walks.sort((a, b) => sortWalks(a, b));

  if (filter?.selectedPlace == Places.home) {
    try {
      await retrieveTrips(position, walks);
      walks.sort((a, b) => sortWalks(a, b));
    } catch (err) {
      log("Cannot retrieve trips: $err", name: tag);
    }
  }

  return walks;
}

Future<void> retrieveTrips(LatLng position, List<Walk> walks) async {
  final origin = Geolocation(
    latitude: position.latitude,
    longitude: position.longitude,
  );

  final positionableWalks = walks.where((walk) => walk.isPositionable).toList();

  if (positionableWalks.isEmpty) return;

  final destinations =
      positionableWalks
          .map(
            (walk) => Geolocation(latitude: walk.lat!, longitude: walk.long!),
          )
          .toList();

  try {
    final trips = await locator<MapsRepository>().getTrips(
      origin,
      destinations,
      cacheExpirationDateTime: walks[0].date.add(const Duration(days: 1)),
    );

    // Match trips to walks
    for (var trip in trips) {
      final matchingWalk = positionableWalks.firstWhereOrNull(
        (walk) =>
            walk.lat == trip.destination.latitude &&
            walk.long == trip.destination.longitude,
      );
      if (matchingWalk != null) {
        matchingWalk.trip = trip;
      }
    }
  } catch (e, stackTrace) {
    log('Error retrieving trips: $e',
        name: tag, error: e, stackTrace: stackTrace);
    rethrow;
  }
}

Future<void> launchURL(String? url) async {
  if (url == null) return;
  Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    try {
      await launchUrl(uri);
    } catch (err) {
      log("Cannot launch URL: $err", name: tag);
    }
  }
}

Future<void> updateWalks() async {
  log("Updating walks", name: tag);
  bool didUpdate = false;
  DateTime nowDateLocal = DateTime.now();
  DateTime nowDateUtc = nowDateLocal.toUtc();

  // Check if we have walks in the database
  bool hasWalks = !await DBProvider.db.isWalkTableEmpty();

  // If we don't have walks or a forced refresh is needed, load from JSON file
  final forceRefreshWalks = await PrefsProvider.prefs.getBoolean(
    Prefs.forceRefreshWalks,
    defaultValue: true,
  );

  if (!hasWalks || forceRefreshWalks) {
    await DBProvider.db.deleteWalks();
    List<Walk> newWalks = fetchJsonWalks(fromDateLocal: nowDateLocal);
    await DBProvider.db.insertWalks(newWalks);
    didUpdate = true;
  }

  // Always fetch current and future walks from API without using lastUpdate filter
  // This ensures we always get complete data including year boundaries
  try {
    List<Walk> updatedWalks = await fetchApiWalks(
      null,
      fromDateLocal: nowDateLocal,
    );
    await DBProvider.db.insertWalks(updatedWalks);

    // Only update timestamps and flags if API call was successful
    await PrefsProvider.prefs.setString(
      Prefs.lastWalkUpdate,
      nowDateUtc.toIso8601String(),
    );
    await PrefsProvider.prefs.setBoolean(Prefs.forceRefreshWalks, false);
    didUpdate = true;
  } catch (err) {
    log("Cannot refresh walks list: $err", name: tag);
    // If API call fails and we have no walks, throw error
    if (!hasWalks && await DBProvider.db.isWalkTableEmpty()) {
      return Future.error(Exception('walk table is empty'));
    }
  }

  // Proceed with post-update operations if needed
  if (didUpdate) {
    await _fixNextWalks();
    DBProvider.db.deleteOldWalks(nowDateLocal);
    NotificationManager.instance
        .scheduleNextNearestWalkNotifications()
        .catchError(
          (err) => log("Cannot schedule next nearest walk notification: $err",
              name: tag),
        );
  }
}

Future<List<DateTime>> retrieveNearestDates() async {
  List<DateTime> walkDates = await DBProvider.db.getWalkDates();
  DateTime now = DateTime.now();
  DateTime inAWeek = now.add(const Duration(days: 10));
  walkDates.retainWhere(
    (element) => element.isAfter(now) && element.isBefore(inAWeek),
  );
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
  try {
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
  } catch (err) {
    log("Couldn't fix next walks, $err", name: tag);
  }
}

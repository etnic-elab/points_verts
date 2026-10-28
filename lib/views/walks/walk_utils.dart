import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart' as ml;
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

/// Map apps offered by [launchGeoApp]. Keep in sync with
/// LSApplicationQueriesSchemes in ios/Runner/Info.plist (Apple Maps needs none).
const List<ml.MapApp> _supportedMapApps = [
  ml.MapApp.apple,
  ml.MapApp.google,
  ml.MapApp.waze,
  ml.MapApp.mapswithme,
  ml.MapApp.osmand,
  ml.MapApp.here,
];

/// Opens the walk's meeting point in an external map app.
///
/// Asks the OS which of [_supportedMapApps] are installed; with more than one,
/// shows a bottom sheet so the user picks. Apps that can show a place get a
/// pin with the address (Google Maps, Apple Maps...), from which the user can
/// read or copy the address and ask for directions. Navigation-only apps such
/// as Waze can't show a pin and get directions straight away.
///
/// The installed apps are found through a directions request on purpose:
/// 1.8.0 looked for apps that can show a pin, which silently dropped Waze from
/// the list, and with one app left the chooser never appeared.
///
/// Falls back to the platform URL scheme if nothing is detected (rare —
/// emulators without Play Services).
Future<void> launchGeoApp(BuildContext context, Walk walk) async {
  if (!walk.hasPosition) return;

  final location = ml.LocationCoords(
    walk.lat!,
    walk.long!,
    title: walk.meetingPoint ?? walk.city,
  );
  final marker = ml.MapLauncher.marker(location);

  Future<void> open(ml.SupportedMap map) => map.map.supportsMarkerCoords
      ? marker.show(map: map.map)
      : map.show();

  try {
    final installed =
        (await ml.MapLauncher.directions(location).getSupportedMaps(
      _supportedMapApps,
    ))
            .where((map) => map.isInstalled)
            .toList();

    if (installed.isEmpty) {
      if (Platform.isIOS) {
        final label = Uri.encodeComponent(walk.city);
        await launchURL(
          'https://maps.apple.com/?ll=${walk.lat},${walk.long}&q=$label',
        );
      } else {
        await launchURL(
          'geo:${walk.lat},${walk.long}?q=${walk.lat},${walk.long}(${walk.city})',
        );
      }
      return;
    }

    if (installed.length == 1) {
      await open(installed.first);
      return;
    }

    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                "Ouvrir le lieu de rendez-vous avec…",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final map in installed)
              ListTile(
                leading: Image.memory(map.map.iconBytes, width: 32, height: 32),
                title: Text(map.name),
                subtitle: map.map.supportsMarkerCoords
                    ? null
                    : const Text("Itinéraire direct"),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  open(map);
                },
              ),
          ],
        ),
      ),
    );
  } catch (err) {
    log("Cannot open maps app: $err", name: tag);
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

String pathsShortDate(Walk walk) =>
    DateFormat("dd/MM", "fr_BE").format(walk.date);

String pathsAvailableExplanation() =>
    "Touchez la carte pour voir les parcours de la marche sur la carte digitale de l'application.";

String walkDayOnlyPathsExplanation(Walk walk) =>
    "Les parcours de cette marche seront visibles sur la carte digitale de l'application le jour de la marche, le ${DateFormat.MMMMEEEEd("fr_BE").format(walk.date)}.";

class PathsTooltip extends StatelessWidget {
  const PathsTooltip({required this.message, required this.child, super.key});

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: TextStyle(fontSize: 15.0, color: colorScheme.onInverseSurface),
      child: child,
    );
  }
}

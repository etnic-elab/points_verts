import 'dart:developer';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/main.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

import 'mapbox.dart';
import 'prefs.dart';

const int NEXT_NEAREST_WALK = 0;
const String TAG = "dev.alpagaga.points_verts.NotificationManager";

class NotificationManager {
  NotificationManager._();

  static final NotificationManager instance = NotificationManager._();
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  Future<FlutterLocalNotificationsPlugin> get plugin async {
    if (_flutterLocalNotificationsPlugin != null)
      return _flutterLocalNotificationsPlugin;
    log("creating a new plugin instance", name: TAG);
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_name');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      int walkId = int.tryParse(payload);
      if (walkId != null) {
        MyApp.redirectToWalkDetails(walkId);
      }
    });
    return _flutterLocalNotificationsPlugin;
  }

  scheduleNextNearestWalk(Walk walk, DateTime walkDate) async {
    DateTime scheduledAt = walkDate.subtract(Duration(hours: 4));
    if (scheduledAt.isBefore(DateTime.now())) {
      return;
    }
    try {
      initializeDateFormatting("fr_BE");
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'NEXT_NEAREST_WALK',
          'Prochain point à proximité',
          'Indique la veille le prochain point vert Adeps le plus proche de votre domicile',
          importance: Importance.Max,
          priority: Priority.High,
          ticker: 'ticker');
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await cancelNextNearestWalkNotification();
      DateFormat fullDate = DateFormat.yMMMEd("fr_BE");
      FlutterLocalNotificationsPlugin instance = await plugin;
      if (walk.trip != null) {
        await instance.schedule(
            NEXT_NEAREST_WALK,
            'Point le plus proche le ${fullDate.format(walkDate)}',
            "${walk.city} - ${walk.province} - ${Duration(seconds: walk.trip.duration.round()).inMinutes} min. en voiture",
            scheduledAt,
            platformChannelSpecifics,
            payload: walk.id.toString());
      } else {
        await instance.schedule(
            NEXT_NEAREST_WALK,
            'Point le plus proche le ${fullDate.format(walkDate)}',
            "${walk.city} - ${walk.province}",
            scheduledAt,
            platformChannelSpecifics,
            payload: walk.id.toString());
      }
      log('Notification scheduled for ${scheduledAt.toString()}', name: TAG);
    } catch (err) {
      print("cannot display notification: $err");
    }
  }

  Future<void> cancelNextNearestWalkNotification() async {
    FlutterLocalNotificationsPlugin instance = await plugin;
    log('Cancelling next nearest walk notification', name: TAG);
    await instance.cancel(NEXT_NEAREST_WALK);
  }

  Future<bool> requestNotificationPermissions() async {
    if (Platform.isIOS) {
      FlutterLocalNotificationsPlugin instance = await plugin;
      return await instance
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          .requestPermissions(
            alert: true,
          );
    } else {
      return true;
    }
  }
}

Future<void> scheduleNextNearestWalkNotification() async {
  bool showNotification = await PrefsProvider.prefs
      .getBoolean(key: "show_notification", defaultValue: true);
  if (!showNotification) return;
  String homePos = await PrefsProvider.prefs.getString("home_coords");
  if (homePos == null) return;
  List<String> split = homePos.split(",");
  Position home = Position(
      latitude: double.parse(split[0]), longitude: double.parse(split[1]));
  DBProvider.db.deleteOldWalks();
  List<DateTime> dates = await DBProvider.db.getWalkDates();
  if (dates.length >= 1) {
    if (dates[0].isBefore(DateTime.now())) {
      // don't say that the next walk is tomorrow if it's today, user normally
      // already got the notification yesterday
      return;
    }
    await updateWalks();
    List<Walk> walks = await DBProvider.db.getWalks(dates[0]);
    final Geolocator geolocator = Geolocator();
    for (Walk walk in walks) {
      if (walk.isPositionable()) {
        walk.distance = await geolocator.distanceBetween(
            home.latitude, home.longitude, walk.lat, walk.long);
      }
    }
    walks.sort((a, b) => sortWalks(a, b));
    try {
      await retrieveTrips(home.longitude, home.latitude, walks);
    } catch (err) {
      print("Cannot retrieve trips: $err");
    }
    walks.sort((a, b) => sortWalks(a, b));
    if (walks.length >= 1 && !walks[0].isCancelled()) {
      await NotificationManager.instance
          .scheduleNextNearestWalk(walks[0], dates[0]);
    }
  }
}

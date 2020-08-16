import 'dart:developer';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/main.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

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

  scheduleNextNearestWalk(Walk walk) async {
    DateTime scheduledAt = walk.date.subtract(Duration(hours: 4));
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
            'Point le plus proche le ${fullDate.format(walk.date)}',
            "${walk.city} - ${walk.province} - ${Duration(seconds: walk.trip.duration.round()).inMinutes} min. en voiture",
            scheduledAt,
            platformChannelSpecifics,
            payload: walk.id.toString());
      } else {
        await instance.schedule(
            NEXT_NEAREST_WALK,
            'Point le plus proche le ${fullDate.format(walk.date)}',
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

  Future<List<PendingNotificationRequest>> pendingNotifications() async {
    FlutterLocalNotificationsPlugin instance = await plugin;
    return instance.pendingNotificationRequests();
  }
}

Future<void> scheduleNextNearestWalkNotification() async {
  bool showNotification = await PrefsProvider.prefs
      .getBoolean(key: "show_notification", defaultValue: false);
  if (!showNotification) return;
  Position home = await retrieveHomePosition();
  if (home == null) return;
  List<DateTime> dates = await retrieveNearestDates();
  if (dates.isNotEmpty) {
    await updateWalks();
    List<Walk> walks = await retrieveSortedWalks(dates[0], position: home);
    if (walks.length >= 1 && !walks[0].isCancelled()) {
      await NotificationManager.instance.scheduleNextNearestWalk(walks[0]);
    }
  }
}

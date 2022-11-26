import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/main.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/views/walks/walk_details_view.dart';
import 'package:points_verts/views/walks/walk_utils.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'prefs.dart';
import 'package:collection/collection.dart';

const String tag = "dev.alpagaga.points_verts.NotificationManager";
const String defaultIcon = 'ic_notification';
final DateFormat formatter = DateFormat('yyyyMMdd');

class NotificationManager {
  NotificationManager._();

  static final NotificationManager instance = NotificationManager._();
  Future<FlutterLocalNotificationsPlugin>? _flutterLocalNotificationsPlugin;

  Future<FlutterLocalNotificationsPlugin> get plugin =>
      _flutterLocalNotificationsPlugin ??= _initPlugin();

  Future<FlutterLocalNotificationsPlugin> _initPlugin() async {
    log("creating a new plugin instance", name: tag);
    var initializationSettingsAndroid =
        const AndroidInitializationSettings(defaultIcon);
    var initializationSettingsIOS = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
      int? walkId = int.tryParse(details.payload!);
      if (walkId != null) _redirectToWalkDetails(walkId);
    });
    tz.initializeTimeZones();
    return plugin;
  }

  _redirectToWalkDetails(int walkId) async {
    Walk? walk = await DBProvider.db.getWalk(walkId);
    if (walk != null) {
      MyApp.navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (context) => WalkDetailsView(walk)));
    }
  }

  Future<void> _scheduleNextNearestWalk(Walk walk) async {
    tz.initializeTimeZones();
    tz.TZDateTime scheduledAt = tz.TZDateTime.from(walk.date, tz.local)
        .subtract(const Duration(hours: 4));
    if (scheduledAt.isBefore(DateTime.now())) return;

    try {
      initializeDateFormatting("fr_BE");
      DateFormat fullDate = DateFormat.yMMMEd("fr_BE");
      FlutterLocalNotificationsPlugin instance = await plugin;

      String title;
      String description;

      if (walk.trip != null) {
        title = 'Point le plus proche le ${fullDate.format(walk.date)}';
        description =
            "${walk.city} - ${walk.province} - ${Duration(seconds: walk.trip!.duration!.round()).inMinutes} min. en voiture";
      } else {
        title = 'Point le plus proche le ${fullDate.format(walk.date)}';
        description = "${walk.city} - ${walk.province}";
      }

      int id = int.parse(formatter.format(scheduledAt));

      await instance.zonedSchedule(
          id, title, description, scheduledAt, _generateNotificationDetails(),
          payload: walk.id.toString(),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
      log('Notification scheduled for ${scheduledAt.toString()}', name: tag);
    } catch (err) {
      print("cannot display notification: $err");
    }
  }

  NotificationDetails _generateNotificationDetails() {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'NEXT_NEAREST_WALK', 'Prochain point à proximité',
        channelDescription:
            'Indique la veille le prochain point vert ADEPS le plus proche de votre domicile',
        importance: Importance.max,
        priority: Priority.high,
        color: CompanyColors.greenPrimary,
        ticker: 'ticker');
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    return NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
  }

  Future<void> displayNotification(int id, String? title, String? body) async {
    FlutterLocalNotificationsPlugin instance = await plugin;
    return instance.show(id, title, body, _generateNotificationDetails());
  }

  Future<void> cancelNextNearestWalkNotifications() async {
    FlutterLocalNotificationsPlugin instance = await plugin;
    await instance.cancelAll();
    log('Cancelled all next nearest walk notifications', name: tag);
  }

  Future<bool?> requestNotificationPermissions() async {
    FlutterLocalNotificationsPlugin instance = await plugin;
    if (Platform.isIOS) {
      return instance
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions(
            alert: true,
          );
    } else {
      return instance
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestPermission();
    }
  }

  Future<List<PendingNotificationRequest>> pendingNotifications() async {
    FlutterLocalNotificationsPlugin instance = await plugin;
    return instance.pendingNotificationRequests();
  }

  Future<void> scheduleNextNearestWalkNotifications() async {
    if (await isScheduleNextNearestWalkNotifications()) {
      List futures = await Future.wait([
        cancelNextNearestWalkNotifications(),
        retrieveNearestDates(),
        retrieveHomePosition()
      ]);
      List<DateTime> dates = futures[1];
      LatLng home = futures[2];

      for (DateTime date in dates) {
        List<Walk> walks = await retrieveSortedWalks(date, position: home);
        Walk? nearestWalk = walks.firstOrNull;
        if (nearestWalk != null) {
          nearestWalk.weathers = await retrieveWeather(nearestWalk);
          _scheduleNextNearestWalk(nearestWalk);
        }
      }
    }
  }

  Future<bool> isScheduleNextNearestWalkNotifications() async {
    List futures = await Future.wait([
      PrefsProvider.prefs
          .getBoolean(Prefs.showNotification, defaultValue: false),
      retrieveHomePosition()
    ]);

    return futures[0] == true && futures[1] != null;
  }
}

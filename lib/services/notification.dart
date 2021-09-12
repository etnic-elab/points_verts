import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/main.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/models/coordinates.dart';
import 'package:points_verts/views/walks/walk_utils.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'prefs.dart';

const int nextNearestWalk = 0;
const String tag = "dev.alpagaga.points_verts.NotificationManager";

class NotificationManager {
  NotificationManager._();

  static final NotificationManager instance = NotificationManager._();
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  Future<FlutterLocalNotificationsPlugin> get plugin async {
    if (_flutterLocalNotificationsPlugin != null) {
      return _flutterLocalNotificationsPlugin
          as FlutterLocalNotificationsPlugin;
    }
    log("creating a new plugin instance", name: tag);
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_notification');
    var initializationSettingsIOS = const IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await _flutterLocalNotificationsPlugin!.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      int? walkId = int.tryParse(payload!);
      if (walkId != null) {
        MyApp.redirectToWalkDetails(walkId);
      }
    });
    tz.initializeTimeZones();
    return _flutterLocalNotificationsPlugin as FlutterLocalNotificationsPlugin;
  }

  scheduleNextNearestWalk(Walk walk) async {
    tz.initializeTimeZones();
    tz.TZDateTime scheduledAt = tz.TZDateTime.from(walk.date, tz.local)
        .subtract(const Duration(hours: 4));
    if (scheduledAt.isBefore(DateTime.now())) {
      return;
    }
    try {
      initializeDateFormatting("fr_BE");
      var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'NEXT_NEAREST_WALK',
          'Prochain point à proximité',
          'Indique la veille le prochain point vert Adeps le plus proche de votre domicile',
          importance: Importance.max,
          priority: Priority.high,
          color: CompanyColors.greenPrimary,
          ticker: 'ticker');
      var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
      await cancelNextNearestWalkNotification();
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

      await instance.zonedSchedule(nextNearestWalk, title, description,
          scheduledAt, platformChannelSpecifics,
          payload: walk.id.toString(),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
      log('Notification scheduled for ${scheduledAt.toString()}', name: tag);
    } catch (err) {
      print("cannot display notification: $err");
    }
  }

  Future<void> cancelNextNearestWalkNotification() async {
    FlutterLocalNotificationsPlugin instance = await plugin;
    log('Cancelling next nearest walk notification', name: tag);
    await instance.cancel(nextNearestWalk);
  }

  Future<bool?> requestNotificationPermissions() async {
    if (Platform.isIOS) {
      FlutterLocalNotificationsPlugin instance = await plugin;
      return await instance
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()!
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
  Coordinates? home = await retrieveHomePosition();
  if (home == null) return;
  List<DateTime> dates = await retrieveNearestDates();
  if (dates.isNotEmpty) {
    List<Walk> walks = await retrieveSortedWalks(dates[0], position: home);
    if (walks.isNotEmpty && !walks[0].isCancelled()) {
      await NotificationManager.instance.scheduleNextNearestWalk(walks[0]);
    } else {
      // in case all walks are now cancelled and one notification was scheduled.
      NotificationManager.instance.cancelNextNearestWalkNotification();
    }
  }
}

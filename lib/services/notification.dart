import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/abstractions/company_data.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/services/service_locator.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/services/navigation.dart';
import 'package:points_verts/views/walks/utils.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'prefs.dart';

const String tag = "dev.alpagaga.points_verts.NotificationManager";
const String defaultIcon = 'ic_notification';
final DateFormat formatter = DateFormat('yyyyMMdd');

class NotificationManager {
  late final Future<FlutterLocalNotificationsPlugin> _plugin;

  NotificationManager() {
    _plugin = initPlugin();
  }

  Future<FlutterLocalNotificationsPlugin> get plugin => _plugin;

  Future<FlutterLocalNotificationsPlugin> initPlugin() async {
    log("creating a new plugin instance", name: tag);
    var initializationSettingsAndroid =
        const AndroidInitializationSettings(defaultIcon);
    var initializationSettingsIOS = const IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      int? walkId = int.tryParse(payload!);
      if (walkId != null) {
        _redirectToWalkDetails(walkId);
      }
    });
    tz.initializeTimeZones();
    return plugin;
  }

  void _redirectToWalkDetails(int walkId) async {
    Walk? walk = await db.getWalk(walkId);
    if (walk != null) {
      navigator.pushNamed(walkDetailRoute, arguments: walk);
    }
  }

  scheduleNextNearestWalk(Walk walk) async {
    tz.initializeTimeZones();
    tz.TZDateTime scheduledAt = tz.TZDateTime.from(walk.date, tz.local)
        .subtract(const Duration(hours: 4));
    if (scheduledAt.isBefore(DateTime.now())) {
      return;
    }
    try {
      DateFormat fullDate = DateFormat.yMMMEd("fr_BE");
      FlutterLocalNotificationsPlugin instance = await plugin;

      String title;
      String description;

      if (walk.trip?.duration != null) {
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
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    return NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
  }

  displayNotification(int id, String? title, String? body) async {
    FlutterLocalNotificationsPlugin instance = await plugin;

    await instance.show(id, title, body, _generateNotificationDetails());
  }

  Future<void> cancelNextNearestWalkNotifications() async {
    FlutterLocalNotificationsPlugin instance = await plugin;
    log('Cancelling all next nearest walk notifications', name: tag);
    await instance.cancelAll();
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

  Future<void> scheduleNextNearestWalkNotifications() async {
    List futures = await Future.wait([
      prefs.getBoolean(Prefs.showNotification, defaultValue: false),
      retrieveHomePosition()
    ]);
    bool showNotification = futures[0];
    LatLng? home = futures[1];
    if (showNotification == false || home == null) return;

    cancelNextNearestWalkNotifications();
    List<DateTime> dates = await retrieveNearestDates();
    for (DateTime date in dates) {
      List<Walk> walks = await retrieveSortedWalks(
          filter: WalkFilter.date(date), position: home);
      if (walks.isNotEmpty && !walks[0].isCancelled) {
        walks[0].weathers = await retrieveWeather(walks[0]);
        await scheduleNextNearestWalk(walks[0]);
      }
    }
  }
}

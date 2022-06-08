import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:points_verts/services/firebase.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

class BackgroundFetchProvider {
  static Future<void> task(bool mounted) async {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 60 * 6,
            // four times per day
            stopOnTerminate: false,
            enableHeadless: true,
            requiredNetworkType: NetworkType.ANY,
            startOnBoot: true), (String taskId) async {
      print("[BackgroundFetch] taskId: $taskId");
      FirebaseCrashlytics.instance.setCustomKey('foreground', false);
      try {
        await NotificationManager.instance
            .scheduleNextNearestWalkNotifications();
        await PrefsProvider.prefs.setString(Prefs.lastBackgroundFetch,
            DateTime.now().toUtc().toIso8601String());
      } catch (err) {
        print("Cannot schedule next nearest walk notification: $err");
      } finally {
        FirebaseCrashlytics.instance.setCustomKey('foreground', true);
        BackgroundFetch.finish(taskId);
      }
    }, (String taskId) async {
      print("[BackgroundFetch] TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  static headlessTask(HeadlessTask task) async {
    runZonedGuarded<Future<void>>(() async {
      String taskId = task.taskId;
      bool isTimeout = task.timeout;
      if (isTimeout) {
        print("[BackgroundFetch] Headless TIMEOUT: $taskId");
        BackgroundFetch.finish(taskId);
        return;
      }
      try {
        print("[BackgroundFetch] Headless task: $taskId");
        await dotenv.load();
        await FirebaseLocalService.initialize(isForeground: false);
        await updateWalks();
        await NotificationManager.instance
            .scheduleNextNearestWalkNotifications();
        await PrefsProvider.prefs.setString(Prefs.lastBackgroundFetch,
            DateTime.now().toUtc().toIso8601String());
      } catch (err) {
        print("Cannot schedule next nearest walk notification: $err");
      } finally {
        FirebaseCrashlytics.instance.setCustomKey('foreground', true);
        BackgroundFetch.finish(taskId);
      }
    },
        (error, stack) => FirebaseCrashlytics.instance
            .recordError(error, stack, fatal: true));
  }
}

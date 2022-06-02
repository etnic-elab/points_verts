import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

class BackgroundFetchProvider {
  static Future<void> task(bool mounted) async {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 60 * 18,
            // 1.3 times per day
            stopOnTerminate: false,
            enableHeadless: true,
            requiredNetworkType: NetworkType.ANY,
            startOnBoot: true), (String taskId) async {
      print("[BackgroundFetch] taskId: $taskId");
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
    String taskId = task.taskId;
    bool isTimeout = task.timeout;
    if (isTimeout) {
      print("[BackgroundFetch] Headless TIMEOUT: $taskId");
      BackgroundFetch.finish(taskId);
      return;
    }
    try {
      print("[BackgroundFetch] Headless task: $taskId");
      if (await NotificationManager.instance
          .isScheduleNextNearestWalkNotifications()) {
        await dotenv.load();
        bool didUpdate = await updateWalks();
        if (didUpdate) {
          NotificationManager.instance.scheduleNextNearestWalkNotifications();
        }
      }

      PrefsProvider.prefs.setString(
          Prefs.lastBackgroundFetch, DateTime.now().toUtc().toIso8601String());
    } catch (err) {
      print("Cannot schedule next nearest walk notification: $err");
    } finally {
      BackgroundFetch.finish(taskId);
    }
  }
}

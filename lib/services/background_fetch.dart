import 'dart:async';
import 'dart:developer';

import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:points_verts/services/firebase.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

const String _tag = "dev.alpagaga.points_verts.BackgroundFetch";

class BackgroundFetchProvider {
  static Future<void> task(bool mounted) async {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            // 1.3 times per day
            minimumFetchInterval: 60 * 18,
            stopOnTerminate: false,
            enableHeadless: true,
            requiredNetworkType: NetworkType.ANY,
            startOnBoot: true), (String taskId) async {
      log("taskId: $taskId", name: _tag);
    }, (String taskId) async {
      log("TIMEOUT taskId: $taskId", name: _tag);
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      log('configure success: $status', name: _tag);
    }).catchError((e) {
      log('configure ERROR: $e', name: _tag);
    });
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @pragma('vm:entry-point')
  static Future<void> headlessTask(HeadlessTask task) async {
    String taskId = task.taskId;
    bool isTimeout = task.timeout;
    if (isTimeout) {
      log("Headless TIMEOUT: $taskId", name: _tag);
      BackgroundFetch.finish(taskId);
      return;
    }
    try {
      log("Headless task: $taskId", name: _tag);
      await FirebaseLocalService.initialize(isForeground: false);
      if (await NotificationManager.instance
          .isScheduleNextNearestWalkNotifications()) {
        await dotenv.load();
        await updateWalks();
      }
      PrefsProvider.prefs.setString(
          Prefs.lastBackgroundFetch, DateTime.now().toUtc().toIso8601String());
    } catch (error, stack) {
      log("Cannot schedule next nearest walk notification: $error",
          name: _tag, error: error, stackTrace: stack);
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } finally {
      BackgroundFetch.finish(taskId);
    }
  }
}

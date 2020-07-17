import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/walks/walk_details_view.dart';

import 'package:points_verts/walks_home_screen.dart';

import 'models/walk.dart';

void backgroundFetchHeadlessTask(String taskId) async {
  print('[BackgroundFetch] Headless event received.');
  try {
    await DotEnv().load('.env');
    await scheduleNextNearestWalkNotification();
    await PrefsProvider.prefs.setString(
        "last_background_fetch", DateTime.now().toUtc().toIso8601String());
  } catch (err) {
    print("Cannot schedule next nearest walk notification: $err");
  }
  BackgroundFetch.finish(taskId);
}

void main() async {
  await DotEnv().load('.env');
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationManager.instance.plugin;
  runApp(new MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatelessWidget {
  static final navigatorKey = new GlobalKey<NavigatorState>();

  static redirectToWalkDetails(int walkId) async {
    Walk walk = await DBProvider.db.getWalk(walkId);
    if (walk != null) {
      MyApp.navigatorKey.currentState
          .push(MaterialPageRoute(builder: (context) => WalkDetailsView(walk)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Points Verts',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      darkTheme:
          ThemeData(brightness: Brightness.dark, primarySwatch: Colors.green),
      home: WalksHomeScreen(),
    );
  }
}

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:points_verts/services/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'views/walks/walks_view.dart';

void backgroundFetchHeadlessTask(String taskId) async {
  print('[BackgroundFetch] Headless event received.');
  try {
    await DotEnv().load('.env');
    await scheduleNextNearestWalkNotification();
  } catch (err) {
    print("Cannot schedule next nearest walk notification: $err");
  }
  BackgroundFetch.finish(taskId);
}

void main() async {
  await DotEnv().load('.env');
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(new MyApp(theme: prefs.getString("theme")));
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  MyApp({this.theme});

  final String theme;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    print('Initializing MyApp');
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.theme == "light") {
      return _lightTheme();
    } else if (widget.theme == "dark") {
      return _darkTheme();
    } else {
      return _defaultTheme();
    }
  }

  Widget _defaultTheme() {
    return MaterialApp(
      title: 'Points Verts',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      darkTheme:
          ThemeData(brightness: Brightness.dark, primarySwatch: Colors.green),
      home: WalksView(),
    );
  }

  Widget _lightTheme() {
    return MaterialApp(
      title: 'Points Verts',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: WalksView(),
    );
  }

  Widget _darkTheme() {
    return MaterialApp(
      title: 'Points Verts',
      theme:
          ThemeData(brightness: Brightness.dark, primarySwatch: Colors.green),
      home: WalksView(),
    );
  }

  Future<void> initPlatformState() async {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 60 * 12,
            // twice per day
            stopOnTerminate: false,
            enableHeadless: true,
            requiredNetworkType: NetworkType.ANY,
            startOnBoot: true), (String taskId) async {
      try {
        await scheduleNextNearestWalkNotification();
      } catch (err) {
        print("Cannot schedule next nearest walk notification: $err");
      }
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
}

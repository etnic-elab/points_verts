import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/views/directory/walk_directory_view.dart';

import 'views/settings/settings.dart';
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
  runApp(new MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  @override
  void initState() {
    print('Initializing MyApp');
    super.initState();
    initPlatformState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Points Verts',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      darkTheme:
          ThemeData(brightness: Brightness.dark, primarySwatch: Colors.green),
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), title: Text("Calendrier")),
            BottomNavigationBarItem(
                icon: Icon(Icons.import_contacts),
                title: Text("Annuaire")),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), title: Text("Paramètres")),
          ],
        ),
        body: _screen(),
      ),
    );
  }

  Widget _screen() {
    if (_selectedIndex == 0) {
      return WalksView();
    } else if (_selectedIndex == 1) {
      return WalkDirectoryView();
    } else {
      return Settings();
    }
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

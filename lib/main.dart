import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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

  void _firstLaunch() async {
    bool firstLaunch = await PrefsProvider.prefs
        .getBoolean(key: 'first_launch', defaultValue: true);
    if (firstLaunch) {
      PrefsProvider.prefs.setBoolean("first_launch", false);
      final snackBar = SnackBar(
          duration: Duration(days: 1),
          action: SnackBarAction(
            onPressed: () {
              _scaffoldKey.currentState.hideCurrentSnackBar();
            },
            label: "OK",
          ),
          content: const Text(
              "Pour voir en un coup d'oeil les marches les plus proches de chez vous, n'hésitez pas à indiquer votre adresse ou à partager votre position dans les Paramètres.",
              textAlign: TextAlign.justify));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
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
        key: _scaffoldKey,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), title: Text("Calendrier")),
            BottomNavigationBarItem(
                icon: Icon(Icons.import_contacts), title: Text("Annuaire")),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), title: Text("Paramètres")),
          ],
        ),
        body: _screen(),
      ),
    );
  }

  Widget _screen() {
    _firstLaunch();
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

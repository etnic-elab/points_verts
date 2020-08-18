import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';

import 'views/directory/walk_directory_view.dart';
import 'views/settings/settings.dart';
import 'views/walks/walks_view.dart';

class WalksHomeScreen extends StatefulWidget {
  @override
  _WalksHomeScreenState createState() => _WalksHomeScreenState();
}

class _WalksHomeScreenState extends State<WalksHomeScreen> {
  List<Widget> _pages = [WalksView(), WalkDirectoryView(), Settings()];
  int _selectedIndex = 0;

  @override
  void initState() {
    _initPlatformState();
    _checkLastBackgroundTask();
    super.initState();
  }

  void _checkLastBackgroundTask() async {
    String lastFetch =
    await PrefsProvider.prefs.getString("last_background_fetch");
    if (lastFetch == null) return;
    DateTime lastFetchDate = DateTime.parse(lastFetch);
    // temp fix (I hope) since iOS task scheduling is not friendly
    if (DateTime.now().difference(lastFetchDate) > Duration(days: 1)) {
      await scheduleNextNearestWalkNotification();
      await PrefsProvider.prefs.setString(
          "last_background_fetch", DateTime.now().toUtc().toIso8601String());
    }
  }

  Future<void> _initPlatformState() async {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 60 * 6,
            // four times per day
            stopOnTerminate: false,
            enableHeadless: true,
            requiredNetworkType: NetworkType.ANY,
            startOnBoot: true), (String taskId) async {
      try {
        await scheduleNextNearestWalkNotification();
        await PrefsProvider.prefs.setString(
            "last_background_fetch", DateTime.now().toUtc().toIso8601String());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), title: Text("Calendrier")),
          const BottomNavigationBarItem(
              icon: Icon(Icons.import_contacts), title: Text("Annuaire")),
          const BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text("Paramètres")),
        ],
      ),
      body: _pages[_selectedIndex],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

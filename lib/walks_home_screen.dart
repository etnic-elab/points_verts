import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:points_verts/services/notification.dart';

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
    super.initState();
  }

  Future<void> _initPlatformState() async {
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

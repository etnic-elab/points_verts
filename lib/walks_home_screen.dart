import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:points_verts/services/background_fetch.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/views/walks/walk_list_error.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

import 'views/directory/walk_directory_view.dart';
import 'views/settings/settings.dart';
import 'views/walks/walks_view.dart';

const String tag = "dev.alpagaga.points_verts.WalksHomeScreen";

class WalksHomeScreen extends StatefulWidget {
  const WalksHomeScreen({Key? key}) : super(key: key);

  @override
  State createState() => _WalksHomeScreenState();
}

class _WalksHomeScreenState extends State<WalksHomeScreen> {
  final List<Widget> _pages = [
    const WalksView(),
    const WalkDirectoryView(),
    const Settings()
  ];
  int _selectedIndex = 0;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    BackgroundFetchProvider.task(mounted);
    initializeData();
    FlutterNativeSplash.remove();
  }

  initializeData() async {
    setState(() => _loading = true);
    try {
      bool didUpdate = await updateWalks();
      if (didUpdate) _scheduleNotifications();
      await PrefsProvider.prefs.remove(Prefs.lastSelectedDate);
      _error = false;
    } catch (err) {
      log("error init State, $err", name: tag);
      _error = true;
    }
    setState(() => _loading = false);
  }

  void _scheduleNotifications() {
    NotificationManager.instance
        .scheduleNextNearestWalkNotifications()
        .catchError((err) =>
            print("Cannot schedule next nearest walk notification: $err"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _error
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today), label: "Calendrier"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.import_contacts), label: "Annuaire"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: "Paramètres"),
              ],
            ),
      body: _loading
          ? const Loading()
          : _error
              ? WalkListError(initializeData)
              : _pages[_selectedIndex],
    );
  }
}

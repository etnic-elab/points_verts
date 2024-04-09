import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:points_verts/services/background_fetch.dart';
import 'package:points_verts/services/firebase.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/views/walks/walk_list_error.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

import 'views/directory/walk_directory_view.dart';
import 'views/settings/settings.dart';
import 'views/walks/walks_view.dart';

const String tag = "dev.alpagaga.points_verts.WalksHomeScreen";

class WalksHomeScreen extends StatefulWidget {
  const WalksHomeScreen({super.key});

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
    _crashlyticsOptIn().then((_) {
      initializeData();
    });
  }

  Future<void> initializeData() async {
    setState(() => _loading = true);
    try {
      await Future.wait(
          [updateWalks(), PrefsProvider.prefs.remove(Prefs.lastSelectedDate)]);
      _error = false;
    } catch (err) {
      log("error init State, $err", name: tag);
      _error = true;
    }
    setState(() => _loading = false);
  }

  Future<void> _crashlyticsOptIn() async {
    bool? crashlyticsEnabled =
        await PrefsProvider.prefs.getBooleanNullable(Prefs.crashlyticsEnabled);
    if (crashlyticsEnabled != null) return;

    bool optIn = await _crashlyticsOptInDialog() ?? false;
    return CrashlyticsLocalService.toggleCrashlyticsEnabled(optIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _error
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              destinations: const <Widget>[
                NavigationDestination(
                    icon: Icon(Icons.calendar_today),
                    selectedIcon: Icon(Icons.calendar_today_outlined),
                    label: "Calendrier"),
                NavigationDestination(
                    icon: Icon(Icons.auto_stories),
                    selectedIcon: Icon(Icons.auto_stories_outlined),
                    label: "Annuaire"),
                NavigationDestination(
                    icon: Icon(Icons.settings),
                    selectedIcon: Icon(Icons.settings_outlined),
                    label: "Paramètres"),
              ],
            ),
      body: _loading
          ? const Loading()
          : _error
              ? WalkListError(initializeData)
              : _pages[_selectedIndex],
    );
  }

  Future<bool?> _crashlyticsOptInDialog() {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Diagnostic'),
              content: const Text(
                  "L'envoi automatique de données de diagnostic nous permet d'améliorer l'application."),
              actions: <Widget>[
                TextButton(
                  child: const Text('Autoriser'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  child: const Text('Refuser'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ]);
        });
  }
}

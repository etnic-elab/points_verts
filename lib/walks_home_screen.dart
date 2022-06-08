import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:points_verts/services/background_fetch.dart';
import 'package:points_verts/services/firebase.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/views/walks/walk_list_error.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

import 'views/directory/walk_directory_view.dart';
import 'views/settings/settings.dart';
import 'views/walks/walks_view.dart';

class WalksHomeScreen extends StatefulWidget {
  const WalksHomeScreen({Key? key}) : super(key: key);

  @override
  State createState() => _WalksHomeScreenState();
}

class _WalksHomeScreenState extends State<WalksHomeScreen>
    with WidgetsBindingObserver {
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
    FlutterNativeSplash.remove();
    _crashlyticsOptIn().then((_) {
      _fetchData().then((_) => BackgroundFetchProvider.task(mounted));
    });

    PrefsProvider.prefs.remove(Prefs.lastSelectedDate);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future _fetchData() {
    setState(() {
      _error = false;
      _loading = true;
    });
    return updateWalks().then((_) {
      setState(() {
        _loading = false;
      });
    }).catchError((err) {
      print("error fetch data");
      setState(() {
        _loading = false;
        _error = true;
      });
    });
  }

  Future<void> _crashlyticsOptIn() async {
    bool? crashlyticsEnabled =
        await PrefsProvider.prefs.getBooleanNullable(Prefs.crashlyticsEnabled);
    if (crashlyticsEnabled != null) return;

    bool optIn = await _crashlyticsOptInDialog() ?? false;
    await CrashlyticsLocalService.toggleCrashlyticsEnabled(optIn);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "Calendrier"),
          BottomNavigationBarItem(
              icon: Icon(Icons.import_contacts), label: "Annuaire"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Paramètres"),
        ],
      ),
      body: _error
          ? WalkListError(_fetchData)
          : _loading
              ? const Loading()
              : _pages[_selectedIndex],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

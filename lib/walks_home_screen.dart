import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:points_verts/abstractions/service_locator.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/views/walks/walk_list_error.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

import 'views/walks/walks_view.dart';

class WalksHomeScreen extends StatefulWidget {
  const WalksHomeScreen({Key? key}) : super(key: key);

  @override
  _WalksHomeScreenState createState() => _WalksHomeScreenState();
}

class _WalksHomeScreenState extends State<WalksHomeScreen>
    with WidgetsBindingObserver {
  final PrefsProvider prefs = locator<PrefsProvider>();
  bool _loading = true;
  bool _error = true;

  @override
  void initState() {
    super.initState();
    fetchData().then((_) {
      _initPlatformState();
    }).catchError((err) {
      print("error init state");
    });
    //TODO: remove last selected date in filter;
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() {
      _error = false;
      _loading = true;
    });
    updateWalks().then((_) {
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchData();
    }
  }

  void _initPlatformState() {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 60 * 6,
            // four times per day
            stopOnTerminate: false,
            enableHeadless: true,
            requiredNetworkType: NetworkType.ANY,
            startOnBoot: true), (String taskId) async {
      print("[BackgroundFetch] taskId: $taskId");
      try {
        await locator<NotificationManager>()
            .scheduleNextNearestWalkNotifications();
        await prefs.setString(Prefs.lastBackgroundFetch,
            DateTime.now().toUtc().toIso8601String());
      } catch (err) {
        print("Cannot schedule next nearest walk notification: $err");
      }
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      print("[BackgroundFetch] TIMEOUT taskId: $taskId");
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
    return _error
        ? WalkListError(fetchData)
        : _loading
            ? const Loading()
            : const WalksView();
  }
}

import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:points_verts/services/service_locator.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/services/navigation.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/widgets/loading.dart';
import 'package:points_verts/views/walks/data_error.dart';
import 'package:points_verts/views/walks/utils.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({Key? key}) : super(key: key);

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  bool error = false;
  @override
  void initState() {
    super.initState();
    _initBackgroundConfig();
    initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initializeData() async {
    if (error) setState(() => error = false);
    try {
      await updateWalks();
      await _resetDates();
      _scheduleNotifications();
      navigator.pushReplacementNamed(calendarRoute);
    } catch (err) {
      setState(() => error = true);
      print("error init State, $err");
    }
  }

  void _initBackgroundConfig() {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 60 * 6,
            // four times per day
            stopOnTerminate: false,
            enableHeadless: true,
            requiredNetworkType: NetworkType.ANY,
            startOnBoot: true), (String taskId) async {
      print("[BackgroundFetch] taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our nonexistent appearance.
    if (!mounted) return;
  }

  void _scheduleNotifications() {
    notification.scheduleNextNearestWalkNotifications().catchError(
        (err) => print("Cannot schedule next nearest walk notification: $err"));
  }

  Future _resetDates() {
    return Future.wait([
      _resetDate(Prefs.calendarWalkFilter),
      _resetDate(Prefs.directoryWalkFilter)
    ]);
  }

  Future _resetDate(Prefs filterKey) async {
    String? _filterString = await prefs.getString(filterKey);
    if (_filterString == null) return;

    WalkFilter? _filter = WalkFilter.fromJson(jsonDecode(_filterString));
    _filter.date = null;

    return prefs.setString(filterKey, jsonEncode(_filter));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: error ? DataError(initializeData) : const LoadingScreen(),
    );
  }
}

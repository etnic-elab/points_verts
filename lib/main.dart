import 'dart:developer';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:package_info/package_info.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

import 'package:points_verts/walks_home_screen.dart';
import 'package:points_verts/company_data.dart';

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    print("[BackgroundFetch] Headless TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  try {
    print("[BackgroundFetch] Headless task: $taskId");
    await dotenv.load();
    await updateWalks();
    await NotificationManager.instance.scheduleNextNearestWalkNotifications();
    await PrefsProvider.prefs.setString(
        Prefs.lastBackgroundFetch, DateTime.now().toUtc().toIso8601String());
  } catch (err) {
    print("Cannot schedule next nearest walk notification: $err");
  } finally {
    BackgroundFetch.finish(taskId);
  }
}

Future<void> _addTrustedCert(String certPath) async {
  ByteData data = await Assets.asset.load(certPath);
  SecurityContext context = SecurityContext.defaultContext;
  try {
    context.setTrustedCertificatesBytes(data.buffer.asUint8List());
  } catch (err) {
    print("Cannot add certificate: $err");
  }
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load();
  await _deleteData();
  //TODO: improve how we initialize these singletons (get_it package?)
  await NotificationManager.instance.plugin;
  await DBProvider.db.database;
  await _addTrustedCert(Assets.letsEncryptCert);
  runApp(const MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

Future _deleteData() async {
  if (Environment.deleteData) {
    List futures = await Future.wait([
      PackageInfo.fromPlatform(),
      PrefsProvider.prefs.getString(Prefs.lastDataDeleteBuild)
    ]);
    PackageInfo packageInfo = futures[0];
    String? lastDataDeleteBuild = futures[1];

    if (packageInfo.buildNumber != lastDataDeleteBuild) {
      await Future.wait([
        PrefsProvider.prefs.removeAll(remove: [
          Prefs.lastWalkUpdate,
          Prefs.news,
          Prefs.lastNewsFetch,
          Prefs.lastSelectedDate
        ]),
        PrefsProvider.prefs
            .setString(Prefs.lastDataDeleteBuild, packageInfo.buildNumber)
      ]);
      log("Local data deleted for buildNumber: ${packageInfo.buildNumber}");
    }
  }
}

class MyApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('fr', 'BE'),
        Locale('fr', 'FR'),
        Locale('fr', 'LU'),
      ],
      navigatorKey: MyApp.navigatorKey,
      title: applicationName,
      theme: CompanyTheme.companyLightTheme(),
      darkTheme: CompanyTheme.companyDarkTheme(),
      home: const WalksHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

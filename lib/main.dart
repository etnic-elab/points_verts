import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/walks/walk_details_view.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

import 'package:points_verts/walks_home_screen.dart';
import 'package:points_verts/company_data.dart';

import 'models/walk.dart';

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
    await scheduleNextNearestWalkNotifications();
    await PrefsProvider.prefs.setString(
        "last_background_fetch", DateTime.now().toUtc().toIso8601String());
  } catch (err) {
    print("Cannot schedule next nearest walk notification: $err");
  } finally {
    BackgroundFetch.finish(taskId);
  }
}

Future<void> _addTrustedCert(String certPath) async {
  ByteData data = await Assets.instance.load(certPath);
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
  //TODO: improve how we initialize these singletons (get_it package?)
  await NotificationManager.instance.plugin;
  await DBProvider.db.database;
  await _addTrustedCert(Assets.letsEncryptCert);
  runApp(const MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({Key? key}) : super(key: key);

  static redirectToWalkDetails(int walkId) async {
    Walk? walk = await DBProvider.db.getWalk(walkId);
    if (walk != null) {
      MyApp.navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (context) => WalkDetailsView(walk)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('fr', 'BE'),
        Locale('fr', 'FR'),
        Locale('fr', 'LU'),
      ],
      navigatorKey: navigatorKey,
      title: applicationName,
      theme: CompanyTheme.companyLightTheme(),
      darkTheme: CompanyTheme.companyDarkTheme(),
      home: const WalksHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

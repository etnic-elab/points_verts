import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:points_verts/abstractions/service_locator.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/walks/walk_details_view.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

import 'package:points_verts/walks_home_screen.dart';
import 'package:points_verts/abstractions/company_data.dart';

import 'models/walk.dart';

void main() async {
  await initialize();
  runApp(const MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

Future initialize({bool addCert = true}) {
  setupLocator();
  return Future.wait(
      [dotenv.load(), if (addCert) _addTrustedCert(Assets.letsEncryptCert)]);
}

//Only for Android. NOT IOS => When your app is terminated, iOS no longer fires events — There is no such thing as stopOnTerminate: false for iOS.
//Even when app is terminated, headless task will continue firing as per the BackgroundFetch configuration. Instead of the usual 'callback' in configuration, this method will be fired.
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
    await initialize(addCert: false);
    await updateWalks();
    await locator<NotificationManager>().scheduleNextNearestWalkNotifications();
    await locator<PrefsProvider>().setString(
        Prefs.lastBackgroundFetch, DateTime.now().toUtc().toIso8601String());
  } catch (err) {
    print("Cannot schedule next nearest walk notification: $err");
  } finally {
    BackgroundFetch.finish(taskId);
  }
}

Future _addTrustedCert(String certPath) async {
  ByteData data = await Assets.asset.load(certPath);
  SecurityContext context = SecurityContext.defaultContext;
  try {
    context.setTrustedCertificatesBytes(data.buffer.asUint8List());
  } catch (err) {
    print("Cannot add certificate: $err");
  }
}

class MyApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({Key? key}) : super(key: key);

  static redirectToWalkDetails(int walkId) async {
    Walk? walk = await locator<DBProvider>().getWalk(walkId);
    if (walk != null) {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (context) => WalkDetailsView(walk)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const ScrollBehavior(
          androidOverscrollIndicator: AndroidOverscrollIndicator.stretch),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('fr', 'BE'),
        Locale('fr', 'FR'),
        Locale('fr', 'LU'),
      ],
      navigatorKey: navigatorKey,
      title: applicationName,
      theme: FlexThemeData.light(
          appBarBackground: Colors.white,
          colors: FlexSchemeColor.from(
              primary: CompanyColors.greenPrimary,
              secondary: CompanyColors.greenSecondary)),
      darkTheme: FlexThemeData.dark(
          colors: FlexSchemeColor.from(
              primary: CompanyColors.greenPrimary,
              secondary: CompanyColors.greenSecondary),
          darkIsTrueBlack: true),
      home: const WalksHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

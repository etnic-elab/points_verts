import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:package_info/package_info.dart';
import 'package:points_verts/constants.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/services/background_fetch.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/firebase.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';

import 'package:points_verts/walks_home_screen.dart';
import 'package:points_verts/company_data.dart';

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
  runZonedGuarded<Future<void>>(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    await dotenv.load();
    await FirebaseLocalService.initialize(isForeground: true);
    await _deleteData();
    //TODO: improve how we initialize these singletons (get_it package?)
    await NotificationManager.instance.plugin;
    await DBProvider.db.database;
    await _addTrustedCert(Assets.letsEncryptCert);
    runApp(const MyApp());
    BackgroundFetch.registerHeadlessTask(BackgroundFetchProvider.headlessTask);
  },
      (error, stack) =>
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

Future _deleteData() async {
  if (kDeleteData) {
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
